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
drop policy if exists "posts are public" on public.posts;
create policy "posts are public" on public.posts for select using (true);
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

-- ---------- photo storage (public read, 2 MB images, each person writes their own folder) ----------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos', 'photos', true, 2097152, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public = true, file_size_limit = 2097152, allowed_mime_types = array['image/jpeg','image/png','image/webp'];

drop policy if exists "upload to your photo folder" on storage.objects;
create policy "upload to your photo folder" on storage.objects for insert to authenticated
  with check (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists "delete your photos or admin" on storage.objects;
create policy "delete your photos or admin" on storage.objects for delete to authenticated
  using (bucket_id = 'photos' and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin()));

-- ---------- make yourself the admin (can delete anyone's posts) ----------
-- 1. Open the web app and sign in once with your email.
-- 2. Replace YOUR_EMAIL below with that email, then run just this statement:
-- insert into public.admins (user_id) select id from auth.users where email = 'YOUR_EMAIL' on conflict do nothing;
