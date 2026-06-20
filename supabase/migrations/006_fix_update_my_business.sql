-- Fix update_my_business for latitude/longitude (run if settings save fails)

ALTER TABLE businesses
  ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;

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

NOTIFY pgrst, 'reload schema';
