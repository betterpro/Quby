import { createClient } from "@/lib/supabase/client";

const BUCKET = "businesses";

const STORAGE_MARKERS = [
  `/storage/v1/object/public/${BUCKET}/`,
  `/storage/v1/object/authenticated/${BUCKET}/`,
  `/storage/v1/object/sign/${BUCKET}/`,
];

export function businessLogoStoragePath(logoUrl: string): string | null {
  for (const marker of STORAGE_MARKERS) {
    const idx = logoUrl.indexOf(marker);
    if (idx !== -1) {
      return logoUrl.slice(idx + marker.length).split("?")[0];
    }
  }

  if (!logoUrl.includes("://") && logoUrl.includes("/")) {
    return logoUrl.split("?")[0];
  }

  return null;
}

export async function resolveBusinessLogoUrl(
  logoUrl: string | null | undefined
): Promise<string | null> {
  if (!logoUrl) return null;

  const path = businessLogoStoragePath(logoUrl);
  if (!path) return logoUrl;

  const supabase = createClient();
  const { data, error } = await supabase.storage
    .from(BUCKET)
    .createSignedUrl(path, 60 * 60 * 24);

  if (error || !data?.signedUrl) {
    return logoUrl;
  }

  return data.signedUrl;
}
