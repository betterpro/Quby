import { createClient } from "@/lib/supabase/server";
import SettingsForm from "./settings-form";
import type { Business } from "@/lib/utils";

async function fetchBusiness(): Promise<Business | null> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) return null;

  const { data: bizUser } = await supabase
    .from("business_users")
    .select("business_id")
    .eq("id", user.id)
    .maybeSingle();

  if (!bizUser?.business_id) return null;

  const { data: business } = await supabase
    .from("businesses")
    .select("*")
    .eq("id", bizUser.business_id)
    .maybeSingle();

  return (business as Business) ?? null;
}

export default async function SettingsPage() {
  const business = await fetchBusiness();

  return <SettingsForm business={business} />;
}
