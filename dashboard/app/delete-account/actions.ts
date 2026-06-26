"use server";

import { createAdminClient } from "@/lib/supabase/server";

export type DeleteResult =
  | { success: true }
  | { error: string };

export async function requestAccountDeletion(
  formData: FormData
): Promise<DeleteResult> {
  const email = (formData.get("email") as string | null)?.trim().toLowerCase();
  const confirm = formData.get("confirm") as string | null;

  if (!email) return { error: "Please enter your email address." };
  if (confirm !== "DELETE") {
    return { error: 'Please type DELETE to confirm.' };
  }

  const supabase = createAdminClient();

  // Find user by email
  const { data, error: listError } = await supabase.auth.admin.listUsers();
  if (listError) return { error: "Could not process request. Please try again later." };

  const user = data.users.find(
    (u) => u.email?.toLowerCase() === email
  );

  if (!user) {
    // Return success anyway to avoid email enumeration
    return { success: true };
  }

  const { error: deleteError } = await supabase.auth.admin.deleteUser(user.id);
  if (deleteError) return { error: "Could not delete account. Please contact support@quby.app." };

  return { success: true };
}
