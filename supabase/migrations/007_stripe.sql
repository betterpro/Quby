-- Stripe wallet top-up integration

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS stripe_customer_id TEXT;

ALTER TABLE businesses
  ADD COLUMN IF NOT EXISTS stripe_account_id TEXT;

CREATE TABLE IF NOT EXISTS stripe_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  stripe_payment_intent_id TEXT NOT NULL UNIQUE,
  amount_cents INTEGER NOT NULL CHECK (amount_cents > 0),
  currency TEXT NOT NULL DEFAULT 'usd',
  purpose TEXT NOT NULL DEFAULT 'topup',
  business_id TEXT REFERENCES businesses(id),
  status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS stripe_payments_user_id_idx
  ON stripe_payments (user_id, created_at DESC);

ALTER TABLE stripe_payments ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'stripe_payments'
      AND policyname = 'stripe_payments_own_select'
  ) THEN
    CREATE POLICY "stripe_payments_own_select" ON stripe_payments
      FOR SELECT USING (auth.uid() = user_id);
  END IF;
END
$$;

-- Called by stripe-webhook edge function (service role only)
CREATE OR REPLACE FUNCTION public.complete_stripe_topup(
  p_stripe_payment_intent_id TEXT
) RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_payment stripe_payments%ROWTYPE;
  v_tx_id TEXT;
BEGIN
  SELECT * INTO v_payment
  FROM stripe_payments
  WHERE stripe_payment_intent_id = p_stripe_payment_intent_id
  FOR UPDATE;

  IF NOT FOUND OR v_payment.status <> 'pending' THEN
    RETURN FALSE;
  END IF;

  UPDATE stripe_payments
  SET status = 'succeeded', completed_at = NOW()
  WHERE id = v_payment.id;

  UPDATE profiles
  SET balance = balance + (v_payment.amount_cents / 100.0),
      updated_at = NOW()
  WHERE id = v_payment.user_id;

  v_tx_id := 'tx_stripe_' || substr(md5(v_payment.stripe_payment_intent_id), 1, 16);

  INSERT INTO transactions (
    id, user_id, title, subtitle, amount, is_debit, date, type, icon, icon_color
  ) VALUES (
    v_tx_id,
    v_payment.user_id,
    'Top Up',
    'Debit card · Stripe',
    v_payment.amount_cents / 100.0,
    FALSE,
    NOW(),
    'topup',
    'up',
    '#00B488'
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN TRUE;
END;
$$;

REVOKE ALL ON FUNCTION public.complete_stripe_topup(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.complete_stripe_topup(TEXT) TO service_role;
