import { NextResponse } from "next/server";

export function getGoogleMapsApiKey() {
  return (
    process.env.GOOGLE_MAPS_API_KEY ||
    process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY ||
    ""
  );
}

export function googlePlacesHeaders(apiKey: string, fieldMask?: string) {
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    "X-Goog-Api-Key": apiKey,
  };
  if (fieldMask) {
    headers["X-Goog-FieldMask"] = fieldMask;
  }
  return headers;
}
