import { NextResponse } from "next/server";
import { getGoogleMapsApiKey, googlePlacesHeaders } from "@/lib/google-maps";

type AutocompleteSuggestion = {
  placePrediction?: {
    placeId?: string;
    text?: { text?: string };
  };
  queryPrediction?: unknown;
};

export async function GET(request: Request) {
  const input = new URL(request.url).searchParams.get("input")?.trim();
  const key = getGoogleMapsApiKey();

  if (!input || input.length < 3) {
    return NextResponse.json({ predictions: [] });
  }

  if (!key) {
    return NextResponse.json(
      { error: "Google Maps API key is not configured" },
      { status: 500 }
    );
  }

  const res = await fetch("https://places.googleapis.com/v1/places:autocomplete", {
    method: "POST",
    headers: googlePlacesHeaders(
      key,
      "suggestions.placePrediction.placeId,suggestions.placePrediction.text.text"
    ),
    body: JSON.stringify({
      input,
      includedPrimaryTypes: ["street_address", "premise", "route"],
    }),
  });

  const data = (await res.json()) as {
    suggestions?: AutocompleteSuggestion[];
    error?: { message?: string; status?: string };
  };

  if (!res.ok) {
    return NextResponse.json(
      { error: data.error?.message || "Address search failed" },
      { status: 502 }
    );
  }

  const predictions = (data.suggestions ?? [])
    .map((suggestion) => suggestion.placePrediction)
    .filter(
      (prediction): prediction is NonNullable<typeof prediction> =>
        Boolean(prediction?.placeId && prediction?.text?.text)
    )
    .map((prediction) => ({
      placeId: prediction.placeId as string,
      description: prediction.text!.text as string,
    }));

  return NextResponse.json({ predictions });
}
