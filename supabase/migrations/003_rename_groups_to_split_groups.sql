-- Rename legacy `groups` table if migration 002 was applied with the old name
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'groups'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'split_groups'
  ) THEN
    ALTER TABLE groups RENAME TO split_groups;
  END IF;
END $$;
