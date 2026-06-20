"use server";

import { createAdminClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

export async function approveBusinessRequest(
  requestId: string,
  request: { name: string; category: string; address?: string | null; user_id: string }
) {
  const supabase = createAdminClient();
  const bizId = crypto.randomUUID();

  await supabase.from("businesses").insert({
    id: bizId,
    name: request.name,
    category: request.category,
    address: request.address ?? null,
    icon: "🏪",
    color: "#00B488",
    distance: null,
    owner_id: request.user_id,
    status: "active",
  });

  await supabase
    .from("business_requests")
    .update({
      status: "approved",
      business_id: bizId,
      updated_at: new Date().toISOString(),
    })
    .eq("id", requestId);

  revalidatePath("/admin/businesses");
}

export async function rejectBusinessRequest(requestId: string, reason: string) {
  const supabase = createAdminClient();

  await supabase
    .from("business_requests")
    .update({
      status: "rejected",
      rejection_reason: reason || "Application did not meet requirements.",
      updated_at: new Date().toISOString(),
    })
    .eq("id", requestId);

  revalidatePath("/admin/businesses");
}
