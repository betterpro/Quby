-- Use existing "businesses" storage bucket for logo uploads

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
