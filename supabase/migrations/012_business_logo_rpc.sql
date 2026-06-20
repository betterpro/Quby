-- Logo RPC helpers (safe to re-run if 008 was skipped)

ALTER TABLE businesses
  ADD COLUMN IF NOT EXISTS logo_url TEXT;

DROP FUNCTION IF EXISTS public.update_my_business(TEXT, TEXT, TEXT, TEXT, DOUBLE PRECISION, DOUBLE PRECISION);

CREATE OR REPLACE FUNCTION public.update_my_business(
  p_name TEXT,
  p_category TEXT,
  p_offer TEXT,
  p_address TEXT,
  p_latitude DOUBLE PRECISION DEFAULT NULL,
  p_longitude DOUBLE PRECISION DEFAULT NULL,
  p_logo_url TEXT DEFAULT NULL
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
    latitude = COALESCE(p_latitude, latitude),
    longitude = COALESCE(p_longitude, longitude),
    logo_url = CASE
      WHEN p_logo_url IS NOT NULL THEN NULLIF(trim(p_logo_url), '')
      ELSE logo_url
    END
  WHERE id = biz_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.update_my_business(
  TEXT, TEXT, TEXT, TEXT, DOUBLE PRECISION, DOUBLE PRECISION, TEXT
) TO authenticated;

CREATE OR REPLACE FUNCTION public.update_my_business_logo(p_logo_url TEXT)
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
  SET logo_url = NULLIF(trim(p_logo_url), '')
  WHERE id = biz_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.update_my_business_logo(TEXT) TO authenticated;

NOTIFY pgrst, 'reload schema';
