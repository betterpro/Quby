-- Quby database schema
-- Run this in the Supabase SQL Editor: https://supabase.com/dashboard/project/tbsuulymqbxzlzzahvgc/sql

-- ── Businesses (global, public read) ─────────────────────────────────────────

CREATE TABLE IF NOT EXISTS businesses (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  category    TEXT NOT NULL,
  icon        TEXT NOT NULL,
  color       TEXT NOT NULL,
  distance    TEXT NOT NULL,
  offer       TEXT,
  address     TEXT
);

ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'businesses'
      AND policyname = 'businesses_public_read'
  ) THEN
    CREATE POLICY "businesses_public_read" ON businesses FOR SELECT USING (true);
  END IF;
END
$$;

-- ── Profiles (one per auth user) ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS profiles (
  id         UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name       TEXT NOT NULL DEFAULT 'User',
  handle     TEXT,
  balance    NUMERIC(12,2) NOT NULL DEFAULT 150.00,
  points     INTEGER       NOT NULL DEFAULT 1240,
  is_dark    BOOLEAN       NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'profiles'
      AND policyname = 'profiles_own_select'
  ) THEN
    CREATE POLICY "profiles_own_select" ON profiles FOR SELECT USING (auth.uid() = id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'profiles'
      AND policyname = 'profiles_own_insert'
  ) THEN
    CREATE POLICY "profiles_own_insert" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'profiles'
      AND policyname = 'profiles_own_update'
  ) THEN
    CREATE POLICY "profiles_own_update" ON profiles FOR UPDATE USING (auth.uid() = id);
  END IF;
END
$$;

-- ── Transactions ──────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS transactions (
  id          TEXT        PRIMARY KEY,
  user_id     UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title       TEXT        NOT NULL,
  subtitle    TEXT        NOT NULL,
  amount      NUMERIC(12,2) NOT NULL,
  is_debit    BOOLEAN     NOT NULL,
  date        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  type        TEXT        NOT NULL,
  business_id TEXT        REFERENCES businesses(id),
  icon        TEXT,
  icon_color  TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'transactions'
      AND policyname = 'transactions_own_select'
  ) THEN
    CREATE POLICY "transactions_own_select" ON transactions FOR SELECT USING (auth.uid() = user_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'transactions'
      AND policyname = 'transactions_own_insert'
  ) THEN
    CREATE POLICY "transactions_own_insert" ON transactions FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
END
$$;

-- ── Auto-create profile on sign-up ───────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id)
  VALUES (NEW.id)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ── Seed businesses ───────────────────────────────────────────────────────────

INSERT INTO businesses (id, name, category, icon, color, distance, offer, address) VALUES
  ('field-notes', 'Field Notes Coffee',  'Café',      'coffee',   '#1E9E73', '0.2 km', '2x points today',       '14 Wicklow St'),
  ('levain',      'Levain Bakehouse',    'Bakery',    'croissant','#E0913B', '0.4 km', 'Free coffee w/ pastry',  '22 Camden St'),
  ('pressed',     'Pressed Juice Bar',   'Juice',     'store',    '#46B36B', '0.6 km', NULL,                     '8 George St'),
  ('kettle',      'Kettle & Co.',        'Tea house', 'coffee',   '#9A6CD4', '0.7 km', '5th cup free',           '3 Nassau St'),
  ('crumb',       'Crumb Street Bakery', 'Bakery',    'croissant','#D8743C', '0.9 km', NULL,                     '51 Grafton St'),
  ('verde',       'Verde Lunch',         'Deli',      'store',    '#3E9C8E', '1.1 km', 'Lunch combo $6.50',      '17 South William St')
ON CONFLICT (id) DO NOTHING;
