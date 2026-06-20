-- Contacts, groups/splits, rewards — replaces Flutter seed data

-- ── Profile extras ───────────────────────────────────────────────────────────

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS avatar_color TEXT NOT NULL DEFAULT '#5B6CE0';

-- ── Contacts (address book per user) ─────────────────────────────────────────

CREATE TABLE IF NOT EXISTS contacts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id        UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name            TEXT NOT NULL,
  handle          TEXT,
  color           TEXT NOT NULL DEFAULT '#5B6CE0',
  linked_user_id  UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'contacts'
      AND policyname = 'contacts_own_all'
  ) THEN
    CREATE POLICY "contacts_own_all" ON contacts
      FOR ALL USING (auth.uid() = owner_id) WITH CHECK (auth.uid() = owner_id);
  END IF;
END
$$;

-- ── Split groups ─────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS split_groups (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id    UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  emoji       TEXT,
  color       TEXT NOT NULL DEFAULT '#5B6CE0',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE split_groups ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'split_groups'
      AND policyname = 'split_groups_own_all'
  ) THEN
    CREATE POLICY "split_groups_own_all" ON split_groups
      FOR ALL USING (auth.uid() = owner_id) WITH CHECK (auth.uid() = owner_id);
  END IF;
END
$$;

-- ── Group members ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS group_members (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id    UUID NOT NULL REFERENCES split_groups(id) ON DELETE CASCADE,
  contact_id  UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
  balance     NUMERIC(12,2) NOT NULL DEFAULT 0,
  UNIQUE (group_id, contact_id)
);

ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'group_members'
      AND policyname = 'group_members_via_group'
  ) THEN
    CREATE POLICY "group_members_via_group" ON group_members
      FOR ALL USING (
        EXISTS (
          SELECT 1 FROM split_groups g
          WHERE g.id = group_members.group_id AND g.owner_id = auth.uid()
        )
      ) WITH CHECK (
        EXISTS (
          SELECT 1 FROM split_groups g
          WHERE g.id = group_members.group_id AND g.owner_id = auth.uid()
        )
      );
  END IF;
END
$$;

-- ── Group expenses ───────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS group_expenses (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id            UUID NOT NULL REFERENCES split_groups(id) ON DELETE CASCADE,
  title               TEXT NOT NULL,
  amount              NUMERIC(12,2) NOT NULL,
  paid_by_contact_id  UUID NOT NULL REFERENCES contacts(id),
  category            TEXT,
  date                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE group_expenses ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'group_expenses'
      AND policyname = 'group_expenses_via_group'
  ) THEN
    CREATE POLICY "group_expenses_via_group" ON group_expenses
      FOR ALL USING (
        EXISTS (
          SELECT 1 FROM split_groups g
          WHERE g.id = group_expenses.group_id AND g.owner_id = auth.uid()
        )
      ) WITH CHECK (
        EXISTS (
          SELECT 1 FROM split_groups g
          WHERE g.id = group_expenses.group_id AND g.owner_id = auth.uid()
        )
      );
  END IF;
END
$$;

-- ── Expense splits ───────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS expense_splits (
  expense_id  UUID NOT NULL REFERENCES group_expenses(id) ON DELETE CASCADE,
  contact_id  UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
  PRIMARY KEY (expense_id, contact_id)
);

ALTER TABLE expense_splits ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'expense_splits'
      AND policyname = 'expense_splits_via_expense'
  ) THEN
    CREATE POLICY "expense_splits_via_expense" ON expense_splits
      FOR ALL USING (
        EXISTS (
          SELECT 1 FROM group_expenses e
          JOIN split_groups g ON g.id = e.group_id
          WHERE e.id = expense_splits.expense_id AND g.owner_id = auth.uid()
        )
      ) WITH CHECK (
        EXISTS (
          SELECT 1 FROM group_expenses e
          JOIN split_groups g ON g.id = e.group_id
          WHERE e.id = expense_splits.expense_id AND g.owner_id = auth.uid()
        )
      );
  END IF;
END
$$;

-- ── Rewards: perks & stamp cards ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS perks (
  id          TEXT PRIMARY KEY,
  business_id TEXT REFERENCES businesses(id) ON DELETE SET NULL,
  title       TEXT NOT NULL,
  subtitle    TEXT NOT NULL,
  cost_points INTEGER NOT NULL,
  icon        TEXT NOT NULL,
  color       TEXT NOT NULL
);

ALTER TABLE perks ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'perks'
      AND policyname = 'perks_public_read'
  ) THEN
    CREATE POLICY "perks_public_read" ON perks FOR SELECT USING (true);
  END IF;
END
$$;

CREATE TABLE IF NOT EXISTS user_stamps (
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  business_id TEXT NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  stamp_count INTEGER NOT NULL DEFAULT 0,
  goal        INTEGER NOT NULL DEFAULT 6,
  PRIMARY KEY (user_id, business_id)
);

ALTER TABLE user_stamps ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'user_stamps'
      AND policyname = 'user_stamps_own_all'
  ) THEN
    CREATE POLICY "user_stamps_own_all" ON user_stamps
      FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
  END IF;
END
$$;

-- ── Seed perks (replaces hardcoded rewards screen data) ──────────────────────

INSERT INTO perks (id, business_id, title, subtitle, cost_points, icon, color) VALUES
  ('perk-coffee',   'field-notes', 'Free Coffee',   'Field Notes Coffee', 500,  'coffee',    '#1E9E73'),
  ('perk-pastry',   'levain',      'Free Pastry',   'Levain Bakehouse',   800,  'croissant', '#E0913B'),
  ('perk-cashback', NULL,          '$5 Cashback',   'Any Quby merchant',  1000, 'wallet',    '#5B6CE0'),
  ('perk-juice',    'pressed',     'Juice Combo',   'Pressed Juice Bar',  600,  'store',     '#46B36B'),
  ('perk-lunch',    'verde',       'Lunch Deal',    'Verde Lunch',        750,  'gift',      '#3E9C8E')
ON CONFLICT (id) DO NOTHING;
