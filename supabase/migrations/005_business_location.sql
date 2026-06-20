-- Business map coordinates for Explore / Discover

ALTER TABLE businesses
  ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;

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
  biz_address TEXT;
  biz_lat DOUBLE PRECISION;
  biz_lng DOUBLE PRECISION;
BEGIN
  IF COALESCE(NEW.raw_user_meta_data->>'role', '') <> 'business' THEN
    RETURN NEW;
  END IF;

  biz_name := COALESCE(NULLIF(trim(NEW.raw_user_meta_data->>'business_name'), ''), 'My Business');
  biz_category := COALESCE(NULLIF(trim(NEW.raw_user_meta_data->>'category'), ''), 'Services');
  owner_name := COALESCE(NULLIF(trim(NEW.raw_user_meta_data->>'full_name'), ''), 'Owner');
  biz_address := NULLIF(trim(NEW.raw_user_meta_data->>'address'), '');
  biz_lat := NULLIF(trim(NEW.raw_user_meta_data->>'latitude'), '')::double precision;
  biz_lng := NULLIF(trim(NEW.raw_user_meta_data->>'longitude'), '')::double precision;
  biz_id := 'biz-' || substr(replace(NEW.id::text, '-', ''), 1, 12);

  INSERT INTO public.businesses (
    id, name, category, icon, color, distance, address, latitude, longitude
  )
  VALUES (
    biz_id, biz_name, biz_category, 'store', '#00B488', '—', biz_address, biz_lat, biz_lng
  );

  INSERT INTO public.business_users (id, business_id, name, email)
  VALUES (NEW.id, biz_id, owner_name, NEW.email);

  RETURN NEW;
EXCEPTION
  WHEN unique_violation THEN
    RETURN NEW;
END;
$$;

DROP FUNCTION IF EXISTS public.update_my_business(TEXT, TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION public.update_my_business(
  p_name TEXT,
  p_category TEXT,
  p_offer TEXT,
  p_address TEXT,
  p_latitude DOUBLE PRECISION DEFAULT NULL,
  p_longitude DOUBLE PRECISION DEFAULT NULL
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
    address = NULLIF(trim(p_address), ''),
    latitude = p_latitude,
    longitude = p_longitude
  WHERE id = biz_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.update_my_business(TEXT, TEXT, TEXT, TEXT, DOUBLE PRECISION, DOUBLE PRECISION) TO authenticated;

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
  biz_address TEXT;
  biz_lat DOUBLE PRECISION;
  biz_lng DOUBLE PRECISION;
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
  biz_address := NULLIF(trim(meta->>'address'), '');
  biz_lat := NULLIF(trim(meta->>'latitude'), '')::double precision;
  biz_lng := NULLIF(trim(meta->>'longitude'), '')::double precision;
  biz_id := 'biz-' || substr(replace(uid::text, '-', ''), 1, 12);

  INSERT INTO public.businesses (
    id, name, category, icon, color, distance, address, latitude, longitude
  )
  VALUES (
    biz_id, biz_name, biz_category, 'store', '#00B488', '—', biz_address, biz_lat, biz_lng
  )
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.business_users (id, business_id, name, email)
  VALUES (uid, biz_id, owner_name, user_email);

  RETURN biz_id;
END;
$$;
