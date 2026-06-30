-- True Agency Platform — Database Schema
-- Run this once in the Supabase SQL Editor

-- 1. Agencies
create table agencies (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz default now()
);

-- 2. Profiles (one per user, linked to Supabase's built-in auth.users)
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  agency_id uuid references agencies(id),
  name text,
  role text default 'agent' check (role in ('agent','team_lead','owner')),
  avatar_initials text,
  tier text default 'Tier 2',
  created_at timestamptz default now()
);

-- 3. Policies (insurance policies an agent has written)
create table policies (
  id uuid primary key default gen_random_uuid(),
  agent_id uuid references profiles(id),
  client_name text,
  carrier text,
  premium numeric,
  status text default 'active' check (status in ('active','pending','in_review')),
  renewal_date date,
  created_at timestamptz default now()
);

-- 4. Production entries (monthly production totals per agent)
create table production_entries (
  id uuid primary key default gen_random_uuid(),
  agent_id uuid references profiles(id),
  amount numeric not null,
  month date not null,
  created_at timestamptz default now()
);

-- 5. Dial logs
create table dial_logs (
  id uuid primary key default gen_random_uuid(),
  agent_id uuid references profiles(id),
  count integer not null,
  log_date date default current_date
);

-- 6. Activity feed
create table activity_feed (
  id uuid primary key default gen_random_uuid(),
  agency_id uuid references agencies(id),
  agent_id uuid references profiles(id),
  type text check (type in ('policy','deposit','dial')),
  description text,
  created_at timestamptz default now()
);

-- ── Row Level Security ──────────────────────────────
alter table profiles enable row level security;
alter table policies enable row level security;
alter table production_entries enable row level security;
alter table dial_logs enable row level security;
alter table activity_feed enable row level security;

-- Helper: get the current user's agency_id and role
create or replace function my_agency_id() returns uuid as $$
  select agency_id from profiles where id = auth.uid();
$$ language sql security definer stable;

create or replace function my_role() returns text as $$
  select role from profiles where id = auth.uid();
$$ language sql security definer stable;

-- Profiles: agents see their own row; owners see everyone in their agency
create policy "view own or agency profiles" on profiles
  for select using (
    id = auth.uid() or
    (my_role() = 'owner' and agency_id = my_agency_id())
  );

create policy "update own profile" on profiles
  for update using (id = auth.uid());

-- Policies: agents see/manage their own; owners see all in their agency
create policy "view own or agency policies" on policies
  for select using (
    agent_id = auth.uid() or
    (my_role() = 'owner' and agent_id in (select id from profiles where agency_id = my_agency_id()))
  );

create policy "insert own policies" on policies
  for insert with check (agent_id = auth.uid());

-- Production entries: same pattern
create policy "view own or agency production" on production_entries
  for select using (
    agent_id = auth.uid() or
    (my_role() = 'owner' and agent_id in (select id from profiles where agency_id = my_agency_id()))
  );

create policy "insert own production" on production_entries
  for insert with check (agent_id = auth.uid());

-- Dial logs: same pattern
create policy "view own or agency dials" on dial_logs
  for select using (
    agent_id = auth.uid() or
    (my_role() = 'owner' and agent_id in (select id from profiles where agency_id = my_agency_id()))
  );

create policy "insert own dials" on dial_logs
  for insert with check (agent_id = auth.uid());

-- Activity feed: visible to anyone in the same agency
create policy "view agency activity" on activity_feed
  for select using (agency_id = my_agency_id());

create policy "insert agency activity" on activity_feed
  for insert with check (agency_id = my_agency_id());

-- ── Auto-create a profile row whenever someone signs up ──
create or replace function handle_new_user() returns trigger as $$
begin
  insert into public.profiles (id, name, role, avatar_initials)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', 'New Agent'),
    coalesce(new.raw_user_meta_data->>'role', 'agent'),
    upper(left(coalesce(new.raw_user_meta_data->>'name', 'NA'), 2))
  );
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure handle_new_user();
