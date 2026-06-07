-- QubyPay Web Platform Migration
-- Business owner accounts
CREATE TABLE IF NOT EXISTS business_users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  business_id TEXT NOT NULL REFERENCES businesses(id),
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE business_users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "business_users_own" ON business_users FOR ALL USING (auth.uid() = id);

-- Admin users
CREATE TABLE IF NOT EXISTS admin_users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "admin_select_own" ON admin_users FOR SELECT USING (auth.uid() = id);

-- Allow business users to see transactions at their business
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
