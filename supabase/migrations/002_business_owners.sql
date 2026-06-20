-- ── Business Requests (user-submitted, pending admin approval) ───────────────

CREATE TABLE IF NOT EXISTS business_requests (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name             TEXT        NOT NULL,
  category         TEXT        NOT NULL,
  address          TEXT,
  description      TEXT,
  status           TEXT        NOT NULL DEFAULT 'pending',   -- pending | approved | rejected
  rejection_reason TEXT,
  business_id      TEXT        REFERENCES businesses(id),    -- populated on approval
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE business_requests ENABLE ROW LEVEL SECURITY;

-- Users see only their own requests
CREATE POLICY "br_own_select" ON business_requests
  FOR SELECT USING (auth.uid() = user_id);

-- Users can submit new requests
CREATE POLICY "br_own_insert" ON business_requests
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Admin dashboard uses service_role key which bypasses RLS for approve/reject.

-- ── Businesses: track ownership ───────────────────────────────────────────────

ALTER TABLE businesses
  ADD COLUMN IF NOT EXISTS owner_id UUID REFERENCES profiles(id),
  ADD COLUMN IF NOT EXISTS status   TEXT NOT NULL DEFAULT 'active';

-- Allow NULL distance for user-submitted businesses
ALTER TABLE businesses ALTER COLUMN distance DROP NOT NULL;
