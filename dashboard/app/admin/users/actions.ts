"use server";

import { createAdminClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

export async function updateUser(
  id: string,
  data: { name: string; handle?: string; balance: number; points: number }
) {
  const supabase = createAdminClient();

  await supabase
    .from("profiles")
    .update({
      name: data.name,
      handle: data.handle ?? null,
      balance: data.balance,
      points: data.points,
    })
    .eq("id", id);

  revalidatePath("/admin/users");
}

export async function deleteUser(id: string) {
  const supabase = createAdminClient();

  await supabase.auth.admin.deleteUser(id);

  revalidatePath("/admin/users");
}
