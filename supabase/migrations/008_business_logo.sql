-- Business logo upload + display in mobile app

ALTER TABLE businesses
  ADD COLUMN IF NOT EXISTS logo_url TEXT;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'businesses',
  'businesses',
  true,
  2097152,
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
      AND policyname = 'business_logos_public_read'
  ) THEN
    CREATE POLICY "business_logos_public_read" ON storage.objects
      FOR SELECT
      USING (bucket_id = 'businesses');
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
      AND policyname = 'business_logos_owner_insert'
  ) THEN
    CREATE POLICY "business_logos_owner_insert" ON storage.objects
      FOR INSERT
      WITH CHECK (
        bucket_id = 'businesses'
        AND (storage.foldername(name))[1] IN (
          SELECT business_id FROM public.business_users WHERE id = auth.uid()
        )
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
      AND policyname = 'business_logos_owner_update'
  ) THEN
    CREATE POLICY "business_logos_owner_update" ON storage.objects
      FOR UPDATE
      USING (
        bucket_id = 'businesses'
        AND (storage.foldername(name))[1] IN (
          SELECT business_id FROM public.business_users WHERE id = auth.uid()
        )
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
      AND policyname = 'business_logos_owner_delete'
  ) THEN
    CREATE POLICY "business_logos_owner_delete" ON storage.objects
      FOR DELETE
      USING (
        bucket_id = 'businesses'
        AND (storage.foldername(name))[1] IN (
          SELECT business_id FROM public.business_users WHERE id = auth.uid()
        )
      );
  END IF;
END
$$;

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
