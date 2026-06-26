-- Reset profile defaults: new users start with 0 balance and 0 points
ALTER TABLE profiles
  ALTER COLUMN balance SET DEFAULT 0.00,
  ALTER COLUMN points  SET DEFAULT 0;

-- Remove demo/seed businesses
DELETE FROM transactions  WHERE business_id IN ('field-notes','levain','pressed','kettle','crumb','verde');
DELETE FROM business_requests WHERE business_id IN ('field-notes','levain','pressed','kettle','crumb','verde');
DELETE FROM businesses WHERE id IN ('field-notes','levain','pressed','kettle','crumb','verde');
