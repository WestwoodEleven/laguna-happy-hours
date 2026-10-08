-- Laguna Happy Hours: shared data for the web version
-- Paste this whole file into Supabase → SQL Editor → New query, then click Run.
-- It is safe to run more than once.

-- ---------- helpers ----------
create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);
alter table public.admins enable row level security;
-- (no policies: only is_admin() below and the dashboard can read it)

create or replace function public.is_admin()
returns boolean
language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.admins where user_id = auth.uid()) $$;
grant execute on function public.is_admin() to anon, authenticated;

-- ---------- "Still active" confirmations (one row per person per restaurant) ----------
create table if not exists public.confirmations (
  venue_id     text not null check (venue_id ~ '^[a-z0-9-]{1,80}$'),
  user_id      uuid not null default auth.uid() references auth.users(id) on delete cascade,
  confirmed_at timestamptz not null default now(),
  primary key (venue_id, user_id)
);
alter table public.confirmations enable row level security;
drop policy if exists "confirmations are public" on public.confirmations;
create policy "confirmations are public" on public.confirmations for select using (true);
drop policy if exists "confirm as yourself" on public.confirmations;
create policy "confirm as yourself" on public.confirmations for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "update your confirmation" on public.confirmations;
create policy "update your confirmation" on public.confirmations for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ---------- 0-5 star ratings (one per person per restaurant) ----------
create table if not exists public.ratings (
  venue_id   text not null check (venue_id ~ '^[a-z0-9-]{1,80}$'),
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  stars      smallint not null check (stars between 0 and 5),
  updated_at timestamptz not null default now(),
  primary key (venue_id, user_id)
);
alter table public.ratings enable row level security;
drop policy if exists "ratings are public" on public.ratings;
create policy "ratings are public" on public.ratings for select using (true);
drop policy if exists "rate as yourself" on public.ratings;
create policy "rate as yourself" on public.ratings for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "change your rating" on public.ratings;
create policy "change your rating" on public.ratings for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ---------- visitor notes and photos ----------
create table if not exists public.posts (
  id          uuid primary key default gen_random_uuid(),
  venue_id    text not null check (venue_id ~ '^[a-z0-9-]{1,80}$'),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  author_name text not null default 'A visitor' check (char_length(author_name) between 1 and 40),
  body        text not null default '' check (char_length(body) <= 500),
  photo_path  text check (photo_path is null or photo_path like (user_id::text || '/%')),
  photo_url   text,
  created_at  timestamptz not null default now(),
  check (char_length(body) > 0 or photo_path is not null)
);
create index if not exists posts_venue_created on public.posts (venue_id, created_at desc);
alter table public.posts enable row level security;
alter table public.posts add column if not exists hidden boolean not null default false;
drop policy if exists "posts are public" on public.posts;
create policy "posts are public" on public.posts for select
  using (hidden = false or user_id = auth.uid() or public.is_admin());
drop policy if exists "admin can restore posts" on public.posts;
create policy "admin can restore posts" on public.posts for update to authenticated
  using (public.is_admin()) with check (public.is_admin());
drop policy if exists "post as yourself" on public.posts;
create policy "post as yourself" on public.posts for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "delete your posts or admin" on public.posts;
create policy "delete your posts or admin" on public.posts for delete to authenticated using (user_id = auth.uid() or public.is_admin());

-- simple flood limit: at most 20 posts per person per hour
create or replace function public.posts_rate_limit()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if (select count(*) from public.posts where user_id = new.user_id and created_at > now() - interval '1 hour') >= 20 then
    raise exception 'Too many posts in the last hour. Try again later.';
  end if;
  new.created_at := now();
  return new;
end $$;
drop trigger if exists posts_rate_limit on public.posts;
create trigger posts_rate_limit before insert on public.posts for each row execute function public.posts_rate_limit();

-- keep server time on confirmations and ratings
create or replace function public.touch_time()
returns trigger language plpgsql as $$
begin
  if tg_table_name = 'confirmations' then new.confirmed_at := now(); else new.updated_at := now(); end if;
  return new;
end $$;
drop trigger if exists confirmations_time on public.confirmations;
create trigger confirmations_time before insert or update on public.confirmations for each row execute function public.touch_time();
drop trigger if exists ratings_time on public.ratings;
create trigger ratings_time before insert or update on public.ratings for each row execute function public.touch_time();

-- ---------- "Report" on a post: hidden automatically after 3 different people report it ----------
create table if not exists public.post_reports (
  post_id     uuid not null references public.posts(id) on delete cascade,
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  reported_at timestamptz not null default now(),
  primary key (post_id, user_id)
);
alter table public.post_reports enable row level security;
drop policy if exists "see your own reports or admin" on public.post_reports;
create policy "see your own reports or admin" on public.post_reports for select to authenticated using (user_id = auth.uid() or public.is_admin());
drop policy if exists "report as yourself" on public.post_reports;
create policy "report as yourself" on public.post_reports for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "admin clears reports" on public.post_reports;
create policy "admin clears reports" on public.post_reports for delete to authenticated using (public.is_admin());

create or replace function public.hide_reported_post()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if (select count(*) from public.post_reports where post_id = new.post_id) >= 3 then
    update public.posts set hidden = true where id = new.post_id;
  end if;
  return new;
end $$;
drop trigger if exists hide_reported_post on public.post_reports;
create trigger hide_reported_post after insert on public.post_reports for each row execute function public.hide_reported_post();

-- ---------- "No longer running" reports (one per person per restaurant) ----------
create table if not exists public.ended_reports (
  venue_id    text not null check (venue_id ~ '^[a-z0-9-]{1,80}$'),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  reported_at timestamptz not null default now(),
  primary key (venue_id, user_id)
);
alter table public.ended_reports enable row level security;
drop policy if exists "ended reports are public" on public.ended_reports;
create policy "ended reports are public" on public.ended_reports for select using (true);
drop policy if exists "report ended as yourself" on public.ended_reports;
create policy "report ended as yourself" on public.ended_reports for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "update your ended report" on public.ended_reports;
create policy "update your ended report" on public.ended_reports for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

create or replace function public.touch_reported()
returns trigger language plpgsql as $$ begin new.reported_at := now(); return new; end $$;
drop trigger if exists ended_time on public.ended_reports;
create trigger ended_time before insert or update on public.ended_reports for each row execute function public.touch_reported();

-- ---------- "Still running?" on a single daily deal ----------
create table if not exists public.deal_confirmations (
  venue_id     text not null check (venue_id ~ '^[a-z0-9-]{1,80}$'),
  deal_key     text not null check (deal_key ~ '^[a-z0-9-]{1,60}$'),
  user_id      uuid not null default auth.uid() references auth.users(id) on delete cascade,
  confirmed_at timestamptz not null default now(),
  primary key (venue_id, deal_key, user_id)
);
alter table public.deal_confirmations enable row level security;
drop policy if exists "deal confirmations are public" on public.deal_confirmations;
create policy "deal confirmations are public" on public.deal_confirmations for select using (true);
drop policy if exists "confirm deal as yourself" on public.deal_confirmations;
create policy "confirm deal as yourself" on public.deal_confirmations for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "update your deal confirmation" on public.deal_confirmations;
create policy "update your deal confirmation" on public.deal_confirmations for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create or replace function public.touch_confirmed()
returns trigger language plpgsql as $$ begin new.confirmed_at := now(); return new; end $$;
drop trigger if exists deal_conf_time on public.deal_confirmations;
create trigger deal_conf_time before insert or update on public.deal_confirmations for each row execute function public.touch_confirmed();

-- ---------- price corrections on a menu line (turned off; kept for past data) ----------
create table if not exists public.price_reports (
  venue_id    text not null check (venue_id ~ '^[a-z0-9-]{1,80}$'),
  item        text not null check (char_length(item) between 1 and 80),
  price       text not null check (price ~ '^\$[0-9]{1,3}(\.[0-9]{1,2})?$'),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  reported_at timestamptz not null default now(),
  primary key (venue_id, item, user_id)
);
alter table public.price_reports enable row level security;
drop policy if exists "price reports are public" on public.price_reports;
create policy "price reports are public" on public.price_reports for select using (true);
-- Single-price corrections are turned off (prices change through menu photos), so nobody can add or change rows.
drop policy if exists "report price as yourself" on public.price_reports;
drop policy if exists "update your price report" on public.price_reports;
drop trigger if exists price_time on public.price_reports;
create trigger price_time before insert or update on public.price_reports for each row execute function public.touch_reported();

-- ---------- "Is this your place?" messages from restaurants (private: only the sender and admin can read) ----------
create table if not exists public.owner_claims (
  id            uuid primary key default gen_random_uuid(),
  venue_id      text not null check (venue_id ~ '^[a-z0-9-]{1,80}$'),
  user_id       uuid not null default auth.uid() references auth.users(id) on delete cascade,
  contact_name  text not null check (char_length(contact_name) between 1 and 60),
  contact_phone text not null default '' check (char_length(contact_phone) <= 30),
  message       text not null default '' check (char_length(message) <= 1000),
  all_correct   boolean not null default false,
  status        text not null default 'new' check (status in ('new','verified','rejected','done')),
  created_at    timestamptz not null default now()
);
alter table public.owner_claims enable row level security;
drop policy if exists "see your own claims or admin" on public.owner_claims;
create policy "see your own claims or admin" on public.owner_claims for select to authenticated using (user_id = auth.uid() or public.is_admin());
drop policy if exists "send a claim as yourself" on public.owner_claims;
create policy "send a claim as yourself" on public.owner_claims for insert to authenticated with check (user_id = auth.uid() and status = 'new');
drop policy if exists "admin updates claims" on public.owner_claims;
create policy "admin updates claims" on public.owner_claims for update to authenticated using (public.is_admin()) with check (public.is_admin());

create or replace function public.owner_claims_limit()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if (select count(*) from public.owner_claims where user_id = new.user_id and created_at > now() - interval '1 day') >= 5 then
    raise exception 'Too many messages today. Try again tomorrow.';
  end if;
  new.created_at := now();
  return new;
end $$;
drop trigger if exists owner_claims_limit on public.owner_claims;
create trigger owner_claims_limit before insert on public.owner_claims for each row execute function public.owner_claims_limit();

-- lets the scheduled check count new restaurant messages without being able to read them
create or replace function public.new_owner_claims_count()
returns integer language sql stable security definer set search_path = public
as $$ select count(*)::int from public.owner_claims where status = 'new' $$;
grant execute on function public.new_owner_claims_count() to anon, authenticated;

-- ---------- photo storage (public read, 2 MB images, each person writes their own folder) ----------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos', 'photos', true, 2097152, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public = true, file_size_limit = 2097152, allowed_mime_types = array['image/jpeg','image/png','image/webp'];

-- A photo can only be uploaded for a post you created in the last 15 minutes that points to it,
-- so uploads are capped by the 20-posts-per-hour limit and no stray photos pile up.
drop policy if exists "upload to your photo folder" on storage.objects;
create policy "upload to your photo folder" on storage.objects for insert to authenticated
  with check (
    bucket_id = 'photos'
    and (storage.foldername(name))[1] = auth.uid()::text
    and exists (select 1 from public.posts p
                where p.photo_path = name  -- the file being uploaded (posts has no "name" column)
                  and p.user_id = auth.uid()
                  and p.created_at > now() - interval '15 minutes')
  );
drop policy if exists "delete your photos or admin" on storage.objects;
create policy "delete your photos or admin" on storage.objects for delete to authenticated
  using (bucket_id = 'photos' and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin()));

-- ---------- make yourself the admin (can delete anyone's posts) ----------
-- 1. Open the web app and sign in once with your email.
-- 2. Replace YOUR_EMAIL below with that email, then run just this statement:
-- insert into public.admins (user_id) select id from auth.users where email = 'YOUR_EMAIL' on conflict do nothing;
