-- Ubuntu SGs: run this once in Supabase (SQL Editor > New query > paste > Run)
-- Safe to run more than once.
-- Only the admin email below can add, edit or delete products and read visit counts.

create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null,
  price integer not null,
  sizes text default 'S,M,L,XL',
  size_guide text,
  image_url text,
  featured boolean default true,
  created_at timestamptz default now()
);

create table if not exists visits (
  id bigint generated always as identity primary key,
  created_at timestamptz default now()
);

alter table products add column if not exists images jsonb default '[]'::jsonb;

alter table products enable row level security;
alter table visits enable row level security;

drop policy if exists "public read products" on products;
create policy "public read products" on products for select using (true);
drop policy if exists "admin write products" on products;
create policy "admin write products" on products for all to authenticated
  using (auth.jwt()->>'email' = 'nshizirungueddy5@gmail.com')
  with check (auth.jwt()->>'email' = 'nshizirungueddy5@gmail.com');

drop policy if exists "anyone logs a visit" on visits;
create policy "anyone logs a visit" on visits for insert to anon, authenticated with check (true);
drop policy if exists "admin reads visits" on visits;
create policy "admin reads visits" on visits for select to authenticated
  using (auth.jwt()->>'email' = 'nshizirungueddy5@gmail.com');

insert into storage.buckets (id, name, public) values ('products', 'products', true)
  on conflict (id) do nothing;

drop policy if exists "public read product images" on storage.objects;
create policy "public read product images" on storage.objects for select
  using (bucket_id = 'products');
drop policy if exists "admin write product images" on storage.objects;
create policy "admin write product images" on storage.objects for all to authenticated
  using (bucket_id = 'products' and auth.jwt()->>'email' = 'nshizirungueddy5@gmail.com')
  with check (bucket_id = 'products' and auth.jwt()->>'email' = 'nshizirungueddy5@gmail.com');

notify pgrst, 'reload schema';
