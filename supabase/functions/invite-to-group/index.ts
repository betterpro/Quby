import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const supabaseUrl = Deno.env.get("SUPABASE_URL");
const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (!supabaseUrl || !supabaseAnonKey || !supabaseServiceKey) {
    return new Response(
      JSON.stringify({ error: "Server is not configured." }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser();

    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const body = await req.json();
    const groupId = body.group_id as string | undefined;
    const rawEmail = (body.email as string | undefined)?.trim().toLowerCase();

    if (!groupId || !rawEmail) {
      return new Response(
        JSON.stringify({ error: "group_id and email are required." }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailPattern.test(rawEmail)) {
      return new Response(JSON.stringify({ error: "Invalid email address." }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { data: group, error: groupError } = await supabase
      .from("split_groups")
      .select("id, name")
      .eq("id", groupId)
      .eq("owner_id", user.id)
      .maybeSingle();

    if (groupError || !group) {
      return new Response(JSON.stringify({ error: "Group not found." }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const admin = createClient(supabaseUrl, supabaseServiceKey);

    const { data: existingUserData, error: lookupError } = await admin.auth
      .admin.getUserByEmail(rawEmail);

    if (lookupError && lookupError.message !== "User not found") {
      throw lookupError;
    }

    if (existingUserData?.user) {
      const targetUserId = existingUserData.user.id;

      const { data: contact, error: addError } = await supabase.rpc(
        "add_existing_user_to_group",
        {
          p_group_id: groupId,
          p_target_user_id: targetUserId,
        },
      );

      if (addError) {
        throw addError;
      }

      return new Response(
        JSON.stringify({ status: "added", contact }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const { error: inviteRowError } = await admin.from("group_invites").upsert(
      {
        group_id: groupId,
        inviter_id: user.id,
        email: rawEmail,
        status: "pending",
      },
      { onConflict: "group_id,email" },
    );

    if (inviteRowError) {
      throw inviteRowError;
    }

    const redirectTo = Deno.env.get("INVITE_REDIRECT_URL") ??
      `${supabaseUrl.replace(".supabase.co", ".supabase.co")}/auth/v1/callback`;

    const { error: inviteError } = await admin.auth.admin.inviteUserByEmail(
      rawEmail,
      {
        redirectTo,
        data: {
          invited_group_id: groupId,
          invited_group_name: group.name,
        },
      },
    );

    if (inviteError) {
      throw inviteError;
    }

    return new Response(
      JSON.stringify({ status: "invited", email: rawEmail }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    const message = error instanceof Error ? error.message : "Invite failed.";
    return new Response(JSON.stringify({ error: message }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
