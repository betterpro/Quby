import { NextResponse } from "next/server";
import { getGoogleMapsApiKey, googlePlacesHeaders } from "@/lib/google-maps";

export async function GET(request: Request) {
  const placeId = new URL(request.url).searchParams.get("placeId")?.trim();
  const key = getGoogleMapsApiKey();

  if (!placeId) {
    return NextResponse.json({ error: "placeId is required" }, { status: 400 });
  }

  if (!key) {
    return NextResponse.json(
      { error: "Google Maps API key is not configured" },
      { status: 500 }
    );
  }

  const encodedPlaceId = encodeURIComponent(placeId);
  const res = await fetch(`https://places.googleapis.com/v1/places/${encodedPlaceId}`, {
    headers: googlePlacesHeaders(key, "formattedAddress,location"),
  });

  const data = (await res.json()) as {
    formattedAddress?: string;
    location?: { latitude?: number; longitude?: number };
    error?: { message?: string; status?: string };
  };

  if (!res.ok) {
    return NextResponse.json(
      { error: data.error?.message || "Could not load place details" },
      { status: 502 }
    );
  }

  const lat = data.location?.latitude;
  const lng = data.location?.longitude;

  if (!data.formattedAddress || lat == null || lng == null) {
    return NextResponse.json({ error: "Place details incomplete" }, { status: 502 });
  }

  return NextResponse.json({
    address: data.formattedAddress,
    lat,
    lng,
  });
}
