import Stripe from "npm:stripe@17";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const stripeSecret = Deno.env.get("STRIPE_SECRET_KEY");
const supabaseUrl = Deno.env.get("SUPABASE_URL");
const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (
    !stripeSecret ||
    !supabaseUrl ||
    !supabaseAnonKey ||
    !supabaseServiceKey
  ) {
    return new Response(
      JSON.stringify({ error: "Stripe is not configured on the server." }),
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
    const amountCents = Number(body.amount_cents);
    const currency = (body.currency as string | undefined)?.toLowerCase() ??
      "usd";
    const purpose = (body.purpose as string | undefined) ?? "topup";

    if (!Number.isInteger(amountCents) || amountCents < 50) {
      return new Response(
        JSON.stringify({ error: "Minimum top-up is $0.50." }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const stripe = new Stripe(stripeSecret, {
      apiVersion: "2025-02-24.acacia",
    });

    const admin = createClient(supabaseUrl, supabaseServiceKey);

    const { data: profile } = await admin
      .from("profiles")
      .select("stripe_customer_id, name")
      .eq("id", user.id)
      .maybeSingle();

    let customerId = profile?.stripe_customer_id as string | null;

    if (!customerId) {
      const customer = await stripe.customers.create({
        email: user.email ?? undefined,
        name: (profile?.name as string | undefined) ?? undefined,
        metadata: { supabase_user_id: user.id },
      });
      customerId = customer.id;

      await admin
        .from("profiles")
        .update({ stripe_customer_id: customerId })
        .eq("id", user.id);
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountCents,
      currency,
      customer: customerId,
      automatic_payment_methods: { enabled: true },
      metadata: {
        supabase_user_id: user.id,
        purpose,
      },
    });

    const { error: insertError } = await admin.from("stripe_payments").insert({
      user_id: user.id,
      stripe_payment_intent_id: paymentIntent.id,
      amount_cents: amountCents,
      currency,
      purpose,
      status: "pending",
    });

    if (insertError) {
      console.error("stripe_payments insert failed:", insertError);
      return new Response(
        JSON.stringify({ error: "Could not start payment." }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    return new Response(
      JSON.stringify({
        client_secret: paymentIntent.client_secret,
        payment_intent_id: paymentIntent.id,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (err) {
    console.error("create-payment-intent error:", err);
    const message =
      err instanceof Error ? err.message : "Unexpected server error.";
    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
