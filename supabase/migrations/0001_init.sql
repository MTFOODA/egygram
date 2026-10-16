-- =============================================================================
-- EgyGram - Complete Supabase schema
-- Run this file ONCE in the Supabase SQL editor (or via `supabase db push`).
-- It is idempotent: safe to re-run.
--
-- DEPLOYMENT NOTE (fresh project): all tables are defined together at the top
-- BEFORE they are referenced by the realtime publication, RLS enablement, RLS
-- policies, and RPCs below. Earlier revisions created `notifications` at the
-- very end of the file, which made a first-time apply fail on a brand-new
-- database (`relation "public.notifications" does not exist` at the realtime
-- publication / RLS steps). The table is now defined up with the others so the
-- dependency order is correct for a clean database.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Extensions
-- ---------------------------------------------------------------------------
create extension if not exists "pgcrypto"; -- gen_random_uuid()

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

-- Profiles: 1:1 with auth.users. The app identifies users by user_name in the
-- UI while RLS ownership checks use the auth UUID (id).
create table if not exists public.profiles (
  id                   uuid primary key default gen_random_uuid(),
  user_name            text not null unique,
  user_token           text,
  bio                  text,
  webpage              text,
  profile_image        text,
  email                text,
  phone                text,
  gender               text,
  number_of_posts      int not null default 0,
  number_of_followers  int not null default 0,
  number_of_following  int not null default 0,
  list_of_reels        text[] not null default '{}',
  list_of_tagged_for_me text[] not null default '{}',
  list_of_posts        text[] not null default '{}',
  list_of_videos       text[] not null default '{}',
  created_at           timestamptz not null default now()
);

create table if not exists public.posts (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid references auth.users(id) on delete cascade,
  user_name     text not null,
  profile_image text,
  image_urls    text[] not null default '{}',
  description   text,
  loves         int not null default 0,
  comments      int not null default 0,
  shares        int not null default 0,
  created_at    timestamptz not null default now()
);

create table if not exists public.reels (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid references auth.users(id) on delete cascade,
  user_name     text not null,
  profile_image text,
  video         text not null default '',
  description   text,
  loves         int not null default 0,
  comments      int not null default 0,
  shares        int not null default 0,
  created_at    timestamptz not null default now()
);

create table if not exists public.stories (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid references auth.users(id) on delete cascade,
  user_name     text not null,
  profile_image text,
  image_urls    text,
  type          text not null default 'image',
  loves         int not null default 0,
  comments      int not null default 0,
  created_at    timestamptz not null default now()
);

create table if not exists public.comments (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid references auth.users(id) on delete cascade,
  user_name     text not null,
  profile_image text,
  post_id       uuid not null,
  content       text not null,
  created_at    timestamptz not null default now()
);

create table if not exists public.loves (
  id        uuid primary key default gen_random_uuid(),
  user_id   uuid references auth.users(id) on delete cascade,
  user_name text not null,
  post_id   uuid not null,
  loved     boolean not null default true,
  unique (post_id, user_name)
);

create table if not exists public.saves (
  id        uuid primary key default gen_random_uuid(),
  user_id   uuid references auth.users(id) on delete cascade,
  user_name text not null,
  post_id   uuid not null,
  saved     boolean not null default true,
  unique (post_id, user_name)
);

create table if not exists public.follows (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid references auth.users(id) on delete cascade,
  user_name     text not null,
  user_followed text not null,
  followed      boolean not null default true,
  unique (user_followed, user_name)
);

create table if not exists public.messages (
  id            uuid primary key default gen_random_uuid(),
  sender_id     uuid references auth.users(id) on delete cascade,
  receiver_id   uuid,
  sender_name   text not null,
  receiver_name text not null,
  text          text not null default '',
  media_url     text,
  created_at    timestamptz not null default now()
);

create table if not exists public.notifications (
  id         uuid primary key default gen_random_uuid(),
  user_name  text not null,
  actor_name text not null,
  type       text not null,
  body       text not null,
  post_id    uuid,
  is_read    boolean not null default false,
  created_at timestamptz not null default now()
);

-- Realtime for the tables the app streams.
do $$
begin
  begin
    alter publication supabase_realtime add table public.posts;
  exception when duplicate_object then null; end;
  begin
    alter publication supabase_realtime add table public.reels;
  exception when duplicate_object then null; end;
  begin
    alter publication supabase_realtime add table public.stories;
  exception when duplicate_object then null; end;
  begin
    alter publication supabase_realtime add table public.comments;
  exception when duplicate_object then null; end;
  begin
    alter publication supabase_realtime add table public.messages;
  exception when duplicate_object then null; end;
  begin
    alter publication supabase_realtime add table public.notifications;
  exception when duplicate_object then null; end;
end $$;

-- ---------------------------------------------------------------------------
-- RPCs (SECURITY DEFINER so counters never fail under RLS)
-- ---------------------------------------------------------------------------

-- Adjusts a numeric counter column on any content table (posts/reels/stories).
create or replace function public.adjust_content_counter(
  p_table  text,
  p_id     uuid,
  p_column text,
  p_delta  int
) returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_table not in ('posts', 'reels', 'stories') then
    raise exception 'adjust_content_counter: invalid table %', p_table;
  end if;
  if p_column not in ('loves', 'comments', 'shares') then
    raise exception 'adjust_content_counter: invalid column %', p_column;
  end if;

  execute format(
    'update public.%I set %I = greatest(0, %I + $1) where id = $2',
    p_table, p_column, p_column
  )
  using p_delta, p_id;
end;
$$;

-- Adjusts follower/following counters on a profile by user_name.
create or replace function public.adjust_profile_counter(
  p_user_name text,
  p_column    text,
  p_delta     int
) returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_column not in ('number_of_followers', 'number_of_following', 'number_of_posts') then
    raise exception 'adjust_profile_counter: invalid column %', p_column;
  end if;

  execute format(
    'update public.profiles set %I = greatest(0, %I + $1) where user_name = $2',
    p_column, p_column
  )
  using p_delta, p_user_name;
end;
$$;

-- Removes stories older than the given max age (client passes 50 minutes).
create or replace function public.delete_old_stories(max_age interval)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  removed int;
begin
  delete from public.stories
  where created_at < now() - max_age;

  get diagnostics removed = row_count;
  return removed;
end;
$$;

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
alter table public.profiles      enable row level security;
alter table public.posts         enable row level security;
alter table public.reels         enable row level security;
alter table public.stories       enable row level security;
alter table public.comments      enable row level security;
alter table public.loves         enable row level security;
alter table public.saves         enable row level security;
alter table public.follows       enable row level security;
alter table public.messages      enable row level security;
alter table public.notifications enable row level security;

-- Profiles: world-readable, owner-writable (by auth UID).
drop policy if exists "profiles_select" on public.profiles;
create policy "profiles_select" on public.profiles
  for select using (true);

drop policy if exists "profiles_insert" on public.profiles;
create policy "profiles_insert" on public.profiles
  for insert with check (auth.uid() = id);

drop policy if exists "profiles_update" on public.profiles;
create policy "profiles_update" on public.profiles
  for update using (auth.uid() = id)
  with check (auth.uid() = id);

drop policy if exists "profiles_delete" on public.profiles;
create policy "profiles_delete" on public.profiles
  for delete using (auth.uid() = id);

-- Posts: world-readable; author-writable.
drop policy if exists "posts_select" on public.posts;
create policy "posts_select" on public.posts for select using (true);

drop policy if exists "posts_insert" on public.posts;
create policy "posts_insert" on public.posts
  for insert with check (auth.uid() = user_id);

drop policy if exists "posts_update" on public.posts;
create policy "posts_update" on public.posts
  for update using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "posts_delete" on public.posts;
create policy "posts_delete" on public.posts
  for delete using (auth.uid() = user_id);

-- Reels: world-readable; author-writable.
drop policy if exists "reels_select" on public.reels;
create policy "reels_select" on public.reels for select using (true);

drop policy if exists "reels_insert" on public.reels;
create policy "reels_insert" on public.reels
  for insert with check (auth.uid() = user_id);

drop policy if exists "reels_update" on public.reels;
create policy "reels_update" on public.reels
  for update using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "reels_delete" on public.reels;
create policy "reels_delete" on public.reels
  for delete using (auth.uid() = user_id);

-- Stories: world-readable; author-writable.
drop policy if exists "stories_select" on public.stories;
create policy "stories_select" on public.stories for select using (true);

drop policy if exists "stories_insert" on public.stories;
create policy "stories_insert" on public.stories
  for insert with check (auth.uid() = user_id);


-- Loves / Saves: world-readable; the acting user may insert/delete their row.
drop policy if exists "loves_select" on public.loves;
create policy "loves_select" on public.loves for select using (true);

drop policy if exists "loves_insert" on public.loves;
create policy "loves_insert" on public.loves
  for insert with check (auth.uid() = user_id);

drop policy if exists "loves_delete" on public.loves;
create policy "loves_delete" on public.loves
  for delete using (auth.uid() = user_id);

drop policy if exists "saves_select" on public.saves;
create policy "saves_select" on public.saves for select using (true);

drop policy if exists "saves_insert" on public.saves;
create policy "saves_insert" on public.saves
  for insert with check (auth.uid() = user_id);

drop policy if exists "saves_delete" on public.saves;
create policy "saves_delete" on public.saves
  for delete using (auth.uid() = user_id);

-- Follows: world-readable; the acting user may insert/delete their row.
drop policy if exists "follows_select" on public.follows;
create policy "follows_select" on public.follows for select using (true);

drop policy if exists "follows_insert" on public.follows;
create policy "follows_insert" on public.follows
  for insert with check (auth.uid() = user_id);

drop policy if exists "follows_delete" on public.follows;
create policy "follows_delete" on public.follows
  for delete using (auth.uid() = user_id);

-- Messages: only participants can read; sender may insert/delete.
drop policy if exists "messages_select" on public.messages;
create policy "messages_select" on public.messages
  for select using (
    auth.uid() = sender_id
    or exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.user_name in (messages.sender_name, messages.receiver_name)
    )
  );

drop policy if exists "messages_insert" on public.messages;
create policy "messages_insert" on public.messages
  for insert with check (auth.uid() = sender_id);

drop policy if exists "messages_delete" on public.messages;
create policy "messages_delete" on public.messages
  for delete using (auth.uid() = sender_id);

-- Notifications: recipient-readable/writable; any authenticated user may create.
drop policy if exists "notifications_select" on public.notifications;
create policy "notifications_select" on public.notifications
  for select using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.user_name = notifications.user_name
    )
  );

drop policy if exists "notifications_insert" on public.notifications;
create policy "notifications_insert" on public.notifications
  for insert with check (auth.role() = 'authenticated');

drop policy if exists "notifications_update" on public.notifications;
create policy "notifications_update" on public.notifications
  for update using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.user_name = notifications.user_name
    )
  );

drop policy if exists "notifications_delete" on public.notifications;
create policy "notifications_delete" on public.notifications
  for delete using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid()
        and p.user_name = notifications.user_name
    )
  );

-- ---------------------------------------------------------------------------
-- Storage bucket + policies (single public 'media' bucket)
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('media', 'media', true)
on conflict (id) do nothing;

drop policy if exists "media_public_read" on storage.objects;
create policy "media_public_read" on storage.objects
  for select using (bucket_id = 'media');

drop policy if exists "media_auth_upload" on storage.objects;
create policy "media_auth_upload" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'media');

drop policy if exists "media_auth_update" on storage.objects;
create policy "media_auth_update" on storage.objects
  for update to authenticated
  using (bucket_id = 'media')
  with check (bucket_id = 'media');

drop policy if exists "media_auth_delete" on storage.objects;
create policy "media_auth_delete" on storage.objects
  for delete to authenticated
  using (bucket_id = 'media');

drop policy if exists "stories_update" on public.stories;
create policy "stories_update" on public.stories
  for update using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "stories_delete" on public.stories;
create policy "stories_delete" on public.stories
  for delete using (auth.uid() = user_id);

-- Comments: world-readable; author-writable.
drop policy if exists "comments_select" on public.comments;
create policy "comments_select" on public.comments for select using (true);

drop policy if exists "comments_insert" on public.comments;
create policy "comments_insert" on public.comments
  for insert with check (auth.uid() = user_id);

drop policy if exists "comments_delete" on public.comments;
create policy "comments_delete" on public.comments
  for delete using (auth.uid() = user_id);
