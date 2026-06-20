-- Business logos must be readable via public URLs in the app and dashboard

UPDATE storage.buckets
SET public = true
WHERE id = 'businesses';

NOTIFY pgrst, 'reload schema';
