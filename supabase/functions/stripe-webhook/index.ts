import Stripe from "npm:stripe@17";
import { createClient } from "npm:@supabase/supabase-js@2";

const stripeSecret = Deno.env.get("STRIPE_SECRET_KEY");
const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET");
const supabaseUrl = Deno.env.get("SUPABASE_URL");
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

Deno.serve(async (req) => {
  if (
    !stripeSecret ||
    !webhookSecret ||
    !supabaseUrl ||
    !supabaseServiceKey
  ) {
    return new Response("Stripe webhook is not configured.", { status: 500 });
  }

  const stripe = new Stripe(stripeSecret, {
    apiVersion: "2025-02-24.acacia",
  });

  const signature = req.headers.get("stripe-signature");
  if (!signature) {
    return new Response("Missing stripe-signature header.", { status: 400 });
  }

  const body = await req.text();

  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(body, signature, webhookSecret);
  } catch (err) {
    console.error("Webhook signature verification failed:", err);
    return new Response("Invalid signature.", { status: 400 });
  }

  const admin = createClient(supabaseUrl, supabaseServiceKey);

  if (event.type === "payment_intent.succeeded") {
    const paymentIntent = event.data.object as Stripe.PaymentIntent;

    const { data, error } = await admin.rpc("complete_stripe_topup", {
      p_stripe_payment_intent_id: paymentIntent.id,
    });

    if (error) {
      console.error("complete_stripe_topup failed:", error);
      return new Response("Failed to credit wallet.", { status: 500 });
    }

    if (!data) {
      console.warn("Payment already processed or not found:", paymentIntent.id);
    }
  }

  if (event.type === "payment_intent.payment_failed") {
    const paymentIntent = event.data.object as Stripe.PaymentIntent;

    await admin
      .from("stripe_payments")
      .update({ status: "failed" })
      .eq("stripe_payment_intent_id", paymentIntent.id)
      .eq("status", "pending");
  }

  return new Response(JSON.stringify({ received: true }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
});
