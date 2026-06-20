"use client";

import { useEffect, useRef, useState } from "react";

export type SelectedPlace = {
  address: string;
  lat: number;
  lng: number;
};

type Suggestion = {
  placeId: string;
  description: string;
};

type AddressAutocompleteProps = {
  value: string;
  onChange: (value: string) => void;
  onPlaceSelected: (place: SelectedPlace) => void;
  placeholder?: string;
  required?: boolean;
  className?: string;
};

export function AddressAutocomplete({
  value,
  onChange,
  onPlaceSelected,
  placeholder = "Search for your business address",
  required,
  className,
}: AddressAutocompleteProps) {
  const [suggestions, setSuggestions] = useState<Suggestion[]>([]);
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const [apiError, setApiError] = useState("");
  const containerRef = useRef<HTMLDivElement>(null);
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    if (value.trim().length < 3) {
      setSuggestions([]);
      setOpen(false);
      return;
    }

    if (debounceRef.current) clearTimeout(debounceRef.current);

    debounceRef.current = setTimeout(async () => {
      setLoading(true);
      setApiError("");

      try {
        const res = await fetch(
          `/api/places/autocomplete?input=${encodeURIComponent(value.trim())}`
        );
        const data = await res.json();

        if (!res.ok) {
          setApiError(data.error || "Address search unavailable");
          setSuggestions([]);
          setOpen(false);
          return;
        }

        setSuggestions(data.predictions ?? []);
        setOpen((data.predictions ?? []).length > 0);
      } catch {
        setApiError("Address search unavailable");
        setSuggestions([]);
        setOpen(false);
      } finally {
        setLoading(false);
      }
    }, 300);

    return () => {
      if (debounceRef.current) clearTimeout(debounceRef.current);
    };
  }, [value]);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (
        containerRef.current &&
        !containerRef.current.contains(event.target as Node)
      ) {
        setOpen(false);
      }
    }

    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  async function selectSuggestion(suggestion: Suggestion) {
    setOpen(false);
    setLoading(true);
    setApiError("");

    try {
      const res = await fetch(
        `/api/places/details?placeId=${encodeURIComponent(suggestion.placeId)}`
      );
      const data = await res.json();

      if (!res.ok) {
        setApiError(data.error || "Could not load address details");
        return;
      }

      onChange(data.address);
      onPlaceSelected({
        address: data.address,
        lat: data.lat,
        lng: data.lng,
      });
    } catch {
      setApiError("Could not load address details");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div ref={containerRef} className="relative">
      <input
        type="text"
        value={value}
        onChange={(e) => {
          onChange(e.target.value);
          setApiError("");
        }}
        onFocus={() => {
          if (suggestions.length > 0) setOpen(true);
        }}
        placeholder={placeholder}
        required={required}
        autoComplete="off"
        className={className}
      />

      {loading && (
        <p className="text-xs text-gray-500 mt-1.5">Searching addresses…</p>
      )}

      {apiError && (
        <p className="text-xs text-red-400 mt-1.5">{apiError}</p>
      )}

      {open && suggestions.length > 0 && (
        <ul className="absolute z-50 mt-1 w-full max-h-56 overflow-auto rounded-lg border border-brand-ink-line bg-brand-ink-bg shadow-xl">
          {suggestions.map((suggestion) => (
            <li key={suggestion.placeId}>
              <button
                type="button"
                onClick={() => selectSuggestion(suggestion)}
                className="w-full px-4 py-3 text-left text-sm text-gray-200 hover:bg-brand-ink-surface transition-colors"
              >
                {suggestion.description}
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
