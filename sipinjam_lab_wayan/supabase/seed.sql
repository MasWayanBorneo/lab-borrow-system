-- SiPinjam Lab - sample inventory data
-- Run in the Supabase SQL editor after schema.sql. Safe to re-run: uses `code`
-- (unique) as the conflict key, so it updates existing rows instead of duplicating.

insert into public.items (name, code, category, total_qty, available_qty, image_url)
values
  ('Proyektor Epson EB-X05', 'MM-001', 'Multimedia', 3, 3, null),
  ('Laptop Asus VivoBook', 'MM-002', 'Multimedia', 5, 5, null),
  ('Kamera DSLR Canon EOS', 'MM-003', 'Multimedia', 2, 2, null),
  ('Router Mikrotik hAP', 'JR-001', 'Jaringan', 4, 4, null),
  ('Switch TP-Link 8 Port', 'JR-002', 'Jaringan', 6, 6, null),
  ('Kabel LAN Cat6 (30m)', 'JR-003', 'Jaringan', 10, 10, null),
  ('Access Point TP-Link', 'JR-004', 'Jaringan', 4, 4, null),
  ('Multimeter Digital Sanwa', 'EL-001', 'Elektronika', 8, 8, null),
  ('Osiloskop Rigol DS1054Z', 'EL-002', 'Elektronika', 2, 2, null),
  ('Solder Uap Quick 861DW', 'EL-003', 'Elektronika', 3, 3, null)
on conflict (code) do update
set
  name = excluded.name,
  category = excluded.category,
  total_qty = excluded.total_qty,
  available_qty = excluded.available_qty;
