-- SiPinjam Lab - Supabase schema

-- profiles
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  name text not null,
  nim text,
  role text not null default 'student' check (role in ('student', 'admin')),
  ktm_path text,
  created_at timestamptz not null default now()
);

alter table public.profiles
  add column if not exists ktm_path text;

alter table public.profiles enable row level security;

-- Helper used by RLS policies below. `security definer` lets it read
-- `profiles` without recursing back into the `profiles` RLS policies.
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles where id = auth.uid() and role = 'admin'
  );
$$;

drop policy if exists "profiles_select_own_or_admin" on public.profiles;
create policy "profiles_select_own_or_admin" on public.profiles
  for select using (id = auth.uid() or public.is_admin());

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update using (id = auth.uid());

-- Students can update their own row (e.g. via the app), but must not be able
-- to grant themselves 'admin' by calling the REST API directly. Only lets the
-- role column change when there's no end-user session (SQL editor/table
-- editor) or the caller is already an admin.
create or replace function public.prevent_role_escalation()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.role <> old.role and auth.uid() is not null and not public.is_admin() then
    new.role := old.role;
  end if;
  return new;
end;
$$;

drop trigger if exists prevent_role_escalation_trigger on public.profiles;
create trigger prevent_role_escalation_trigger
  before update on public.profiles
  for each row execute function public.prevent_role_escalation();

-- Auto-create a profile row whenever a new auth user signs up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name, nim)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name', ''),
    new.raw_user_meta_data ->> 'nim'
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- items
create table if not exists public.items (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  code text not null unique,
  category text not null,
  total_qty integer not null default 0,
  available_qty integer not null default 0,
  image_url text,
  is_ready boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.items
  add column if not exists is_ready boolean not null default true;

alter table public.items enable row level security;

drop policy if exists "items_select_authenticated" on public.items;
create policy "items_select_authenticated" on public.items
  for select using (auth.role() = 'authenticated');

drop policy if exists "items_insert_admin" on public.items;
create policy "items_insert_admin" on public.items
  for insert with check (public.is_admin());

drop policy if exists "items_update_admin" on public.items;
create policy "items_update_admin" on public.items
  for update using (public.is_admin());

drop policy if exists "items_delete_admin" on public.items;
create policy "items_delete_admin" on public.items
  for delete using (public.is_admin());

-- loans
create table if not exists public.loans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  item_id uuid not null references public.items (id) on delete cascade,
  qty integer not null check (qty > 0),
  borrow_date date not null,
  return_date_planned date not null,
  return_date_actual date,
  status text not null default 'pending'
    check (status in ('pending', 'approved', 'rejected', 'returned')),
  created_at timestamptz not null default now()
);

alter table public.loans enable row level security;

drop policy if exists "loans_select_own_or_admin" on public.loans;
create policy "loans_select_own_or_admin" on public.loans
  for select using (user_id = auth.uid() or public.is_admin());

drop policy if exists "loans_insert_own" on public.loans;
create policy "loans_insert_own" on public.loans
  for insert with check (user_id = auth.uid());

drop policy if exists "loans_update_admin" on public.loans;
create policy "loans_update_admin" on public.loans
  for update using (public.is_admin());

-- RPCs: keep available_qty changes atomic with the loan status change
create or replace function public.approve_loan(p_loan_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_item_id uuid;
  v_qty integer;
  v_available integer;
  v_is_ready boolean;
begin
  if not public.is_admin() then
    raise exception 'Only admins can approve loans';
  end if;

  select item_id, qty into v_item_id, v_qty
  from public.loans where id = p_loan_id and status = 'pending'
  for update;

  if not found then
    raise exception 'Loan not found or not pending';
  end if;

  select available_qty, is_ready into v_available, v_is_ready
  from public.items where id = v_item_id for update;

  if not v_is_ready then
    raise exception 'Item is not ready to be borrowed (under repair)';
  end if;

  if v_available < v_qty then
    raise exception 'Not enough stock available';
  end if;

  update public.items set available_qty = available_qty - v_qty where id = v_item_id;
  update public.loans set status = 'approved' where id = p_loan_id;
end;
$$;

create or replace function public.return_loan(p_loan_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_item_id uuid;
  v_qty integer;
begin
  if not public.is_admin() then
    raise exception 'Only admins can mark loans returned';
  end if;

  select item_id, qty into v_item_id, v_qty
  from public.loans where id = p_loan_id and status = 'approved'
  for update;

  if not found then
    raise exception 'Loan not found or not approved';
  end if;

  update public.items set available_qty = available_qty + v_qty where id = v_item_id;
  update public.loans
    set status = 'returned', return_date_actual = current_date
    where id = p_loan_id;
end;
$$;

grant execute on function public.approve_loan(uuid) to authenticated;
grant execute on function public.return_loan(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- Storage: item images
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('item-images', 'item-images', true)
on conflict (id) do nothing;

drop policy if exists "item_images_public_read" on storage.objects;
create policy "item_images_public_read" on storage.objects
  for select using (bucket_id = 'item-images');

drop policy if exists "item_images_admin_write" on storage.objects;
create policy "item_images_admin_write" on storage.objects
  for insert with check (bucket_id = 'item-images' and public.is_admin());

drop policy if exists "item_images_admin_update" on storage.objects;
create policy "item_images_admin_update" on storage.objects
  for update using (bucket_id = 'item-images' and public.is_admin());

drop policy if exists "item_images_admin_delete" on storage.objects;
create policy "item_images_admin_delete" on storage.objects
  for delete using (bucket_id = 'item-images' and public.is_admin());

-- ---------------------------------------------------------------------------
-- Storage: identity proofs (KTM/KTP)
-- Private bucket. Objects are stored under "<user_id>/filename.ext" so RLS
-- can check the first path segment against auth.uid().
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('identity-proofs', 'identity-proofs', false)
on conflict (id) do nothing;

drop policy if exists "identity_proofs_owner_read" on storage.objects;
create policy "identity_proofs_owner_read" on storage.objects
  for select using (
    bucket_id = 'identity-proofs'
    and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin())
  );

drop policy if exists "identity_proofs_owner_write" on storage.objects;
create policy "identity_proofs_owner_write" on storage.objects
  for insert with check (
    bucket_id = 'identity-proofs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "identity_proofs_owner_update" on storage.objects;
create policy "identity_proofs_owner_update" on storage.objects
  for update using (
    bucket_id = 'identity-proofs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- ---------------------------------------------------------------------------
-- Realtime: let students get a live update when their loan status changes
-- (approved/rejected/returned) without needing to pull-to-refresh.
-- ---------------------------------------------------------------------------
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'loans'
  ) then
    alter publication supabase_realtime add table public.loans;
  end if;
end $$;
