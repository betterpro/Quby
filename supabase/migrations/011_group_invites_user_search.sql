-- User search, add existing users to groups, email invites

-- ── Pending invites ───────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS group_invites (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id         UUID NOT NULL REFERENCES split_groups(id) ON DELETE CASCADE,
  inviter_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  email            TEXT NOT NULL,
  invitee_user_id  UUID REFERENCES profiles(id) ON DELETE SET NULL,
  status           TEXT NOT NULL DEFAULT 'pending'
                   CHECK (status IN ('pending', 'accepted', 'cancelled')),
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (group_id, email)
);

CREATE INDEX IF NOT EXISTS group_invites_email_lower_idx
  ON group_invites (lower(email), status);

ALTER TABLE group_invites ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'group_invites'
      AND policyname = 'group_invites_inviter_select'
  ) THEN
    CREATE POLICY "group_invites_inviter_select" ON group_invites
      FOR SELECT USING (inviter_id = auth.uid());
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'group_invites'
      AND policyname = 'group_invites_inviter_insert'
  ) THEN
    CREATE POLICY "group_invites_inviter_insert" ON group_invites
      FOR INSERT WITH CHECK (
        inviter_id = auth.uid()
        AND EXISTS (
          SELECT 1 FROM split_groups g
          WHERE g.id = group_id AND g.owner_id = auth.uid()
        )
      );
  END IF;
END
$$;

-- ── Helpers ───────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.ensure_contact_for_linked_user(
  p_owner_id UUID,
  p_target_user_id UUID
)
RETURNS contacts
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_profile profiles%ROWTYPE;
  v_contact contacts%ROWTYPE;
BEGIN
  SELECT * INTO v_profile FROM profiles WHERE id = p_target_user_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  SELECT * INTO v_contact
  FROM contacts
  WHERE owner_id = p_owner_id AND linked_user_id = p_target_user_id;

  IF FOUND THEN
    UPDATE contacts
    SET
      name = v_profile.name,
      handle = COALESCE(v_profile.handle, handle),
      color = v_profile.avatar_color
    WHERE id = v_contact.id
    RETURNING * INTO v_contact;

    RETURN v_contact;
  END IF;

  INSERT INTO contacts (owner_id, linked_user_id, name, handle, color)
  VALUES (
    p_owner_id,
    p_target_user_id,
    v_profile.name,
    v_profile.handle,
    v_profile.avatar_color
  )
  RETURNING * INTO v_contact;

  RETURN v_contact;
END;
$$;

CREATE OR REPLACE FUNCTION public.accept_pending_group_invites(
  p_user_id UUID,
  p_email TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  invite RECORD;
  v_contact contacts%ROWTYPE;
BEGIN
  IF p_email IS NULL OR trim(p_email) = '' THEN
    RETURN;
  END IF;

  FOR invite IN
    SELECT *
    FROM group_invites
    WHERE lower(email) = lower(trim(p_email))
      AND status = 'pending'
  LOOP
    IF NOT EXISTS (SELECT 1 FROM split_groups WHERE id = invite.group_id) THEN
      CONTINUE;
    END IF;

    v_contact := public.ensure_contact_for_linked_user(
      invite.inviter_id,
      p_user_id
    );

    INSERT INTO group_members (group_id, contact_id, balance)
    VALUES (invite.group_id, v_contact.id, 0)
    ON CONFLICT (group_id, contact_id) DO NOTHING;

    UPDATE group_invites
    SET status = 'accepted', invitee_user_id = p_user_id
    WHERE id = invite.id;
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id)
  VALUES (NEW.id)
  ON CONFLICT (id) DO NOTHING;

  PERFORM public.accept_pending_group_invites(NEW.id, NEW.email);

  RETURN NEW;
END;
$$;

-- ── Search users by @handle or email ──────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.search_users(
  p_query TEXT,
  p_group_id UUID DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  name TEXT,
  handle TEXT,
  avatar_color TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_query TEXT;
BEGIN
  v_query := trim(both '@' from trim(coalesce(p_query, '')));
  IF length(v_query) < 2 THEN
    RETURN;
  END IF;

  RETURN QUERY
  SELECT
    p.id,
    p.name,
    coalesce(p.handle, '') AS handle,
    p.avatar_color
  FROM profiles p
  INNER JOIN auth.users u ON u.id = p.id
  WHERE p.id <> auth.uid()
    AND (
      (p.handle IS NOT NULL AND p.handle ILIKE '%' || v_query || '%')
      OR u.email ILIKE v_query || '%'
      OR u.email ILIKE '%' || v_query || '%'
    )
    AND (
      p_group_id IS NULL
      OR NOT EXISTS (
        SELECT 1
        FROM group_members gm
        INNER JOIN contacts c ON c.id = gm.contact_id
        WHERE gm.group_id = p_group_id
          AND c.linked_user_id = p.id
      )
    )
  ORDER BY
    CASE
      WHEN p.handle ILIKE v_query || '%' THEN 0
      WHEN u.email ILIKE v_query || '%' THEN 1
      ELSE 2
    END,
    p.name
  LIMIT 20;
END;
$$;

-- ── Add an existing Quby user to a group ──────────────────────────────────────

CREATE OR REPLACE FUNCTION public.add_existing_user_to_group(
  p_group_id UUID,
  p_target_user_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_contact contacts%ROWTYPE;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM split_groups
    WHERE id = p_group_id AND owner_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Not allowed';
  END IF;

  IF p_target_user_id = auth.uid() THEN
    RAISE EXCEPTION 'Cannot add yourself';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM profiles WHERE id = p_target_user_id) THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM group_members gm
    INNER JOIN contacts c ON c.id = gm.contact_id
    WHERE gm.group_id = p_group_id
      AND c.linked_user_id = p_target_user_id
  ) THEN
    RAISE EXCEPTION 'User is already in this group';
  END IF;

  v_contact := public.ensure_contact_for_linked_user(
    auth.uid(),
    p_target_user_id
  );

  INSERT INTO group_members (group_id, contact_id, balance)
  VALUES (p_group_id, v_contact.id, 0)
  ON CONFLICT (group_id, contact_id) DO NOTHING;

  RETURN jsonb_build_object(
    'id', v_contact.id,
    'name', v_contact.name,
    'handle', coalesce(v_contact.handle, ''),
    'color', v_contact.color
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.accept_my_group_invites()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_email TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RETURN;
  END IF;

  SELECT email INTO v_email FROM auth.users WHERE id = auth.uid();
  PERFORM public.accept_pending_group_invites(auth.uid(), v_email);
END;
$$;

GRANT EXECUTE ON FUNCTION public.search_users(TEXT, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.add_existing_user_to_group(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.accept_my_group_invites() TO authenticated;
