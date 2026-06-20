-- Track expense creator and edit history

ALTER TABLE group_expenses
  ADD COLUMN IF NOT EXISTS created_by_contact_id UUID REFERENCES contacts(id),
  ADD COLUMN IF NOT EXISTS edited_at TIMESTAMPTZ;

UPDATE group_expenses
SET created_by_contact_id = paid_by_contact_id
WHERE created_by_contact_id IS NULL;
