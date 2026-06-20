-- QubyPay web dashboard: business owner accounts + auto-provisioning on signup

CREATE TABLE IF NOT EXISTS business_users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  business_id TEXT NOT NULL REFERENCES businesses(id),
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE business_users ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'business_users'
      AND policyname = 'business_users_own'
  ) THEN
    CREATE POLICY "business_users_own" ON business_users
      FOR ALL USING (auth.uid() = id);
  END IF;
END
$$;

CREATE TABLE IF NOT EXISTS admin_users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'admin_users'
      AND policyname = 'admin_select_own'
  ) THEN
    CREATE POLICY "admin_select_own" ON admin_users
      FOR SELECT USING (auth.uid() = id);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'transactions'
      AND policyname = 'transactions_biz_view'
  ) THEN
    CREATE POLICY "transactions_biz_view" ON transactions
      FOR SELECT USING (
        business_id IN (SELECT business_id FROM business_users WHERE id = auth.uid())
      );
  END IF;
END
$$;

CREATE OR REPLACE FUNCTION public.handle_business_owner_signup()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  biz_id TEXT;
  biz_name TEXT;
  biz_category TEXT;
  owner_name TEXT;
BEGIN
  IF COALESCE(NEW.raw_user_meta_data->>'role', '') <> 'business' THEN
    RETURN NEW;
  END IF;

  biz_name := COALESCE(NULLIF(trim(NEW.raw_user_meta_data->>'business_name'), ''), 'My Business');
  biz_category := COALESCE(NULLIF(trim(NEW.raw_user_meta_data->>'category'), ''), 'Services');
  owner_name := COALESCE(NULLIF(trim(NEW.raw_user_meta_data->>'full_name'), ''), 'Owner');
  biz_id := 'biz-' || substr(replace(NEW.id::text, '-', ''), 1, 12);

  INSERT INTO public.businesses (id, name, category, icon, color, distance)
  VALUES (biz_id, biz_name, biz_category, 'store', '#00B488', '—');

  INSERT INTO public.business_users (id, business_id, name, email)
  VALUES (NEW.id, biz_id, owner_name, NEW.email);

  RETURN NEW;
EXCEPTION
  WHEN unique_violation THEN
    -- Business or owner row already exists (retry / duplicate signup)
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_business_owner_created ON auth.users;
CREATE TRIGGER on_business_owner_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_business_owner_signup();

CREATE OR REPLACE FUNCTION public.update_my_business(
  p_name TEXT,
  p_category TEXT,
  p_offer TEXT,
  p_address TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  biz_id TEXT;
BEGIN
  SELECT business_id INTO biz_id
  FROM business_users
  WHERE id = auth.uid();

  IF biz_id IS NULL THEN
    RAISE EXCEPTION 'No business linked to this account';
  END IF;

  UPDATE businesses
  SET
    name = p_name,
    category = p_category,
    offer = NULLIF(trim(p_offer), ''),
    address = NULLIF(trim(p_address), '')
  WHERE id = biz_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.update_my_business(TEXT, TEXT, TEXT, TEXT) TO authenticated;

CREATE OR REPLACE FUNCTION public.complete_business_signup()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid UUID := auth.uid();
  meta JSONB;
  biz_id TEXT;
  biz_name TEXT;
  biz_category TEXT;
  owner_name TEXT;
  user_email TEXT;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT business_id INTO biz_id FROM business_users WHERE id = uid;
  IF biz_id IS NOT NULL THEN
    RETURN biz_id;
  END IF;

  SELECT raw_user_meta_data, email INTO meta, user_email
  FROM auth.users
  WHERE id = uid;

  IF COALESCE(meta->>'role', '') <> 'business' THEN
    RETURN NULL;
  END IF;

  biz_name := COALESCE(NULLIF(trim(meta->>'business_name'), ''), 'My Business');
  biz_category := COALESCE(NULLIF(trim(meta->>'category'), ''), 'Services');
  owner_name := COALESCE(NULLIF(trim(meta->>'full_name'), ''), 'Owner');
  biz_id := 'biz-' || substr(replace(uid::text, '-', ''), 1, 12);

  INSERT INTO public.businesses (id, name, category, icon, color, distance)
  VALUES (biz_id, biz_name, biz_category, 'store', '#00B488', '—')
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.business_users (id, business_id, name, email)
  VALUES (uid, biz_id, owner_name, user_email);

  RETURN biz_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.complete_business_signup() TO authenticated;
