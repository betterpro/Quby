"use client";

import { useEffect, useState } from "react";
import { resolveBusinessLogoUrl } from "@/lib/business-logo";

interface BusinessLogoImageProps {
  logoUrl?: string | null;
  alt?: string;
  className?: string;
  fallback?: React.ReactNode;
}

export function BusinessLogoImage({
  logoUrl,
  alt = "",
  className,
  fallback = null,
}: BusinessLogoImageProps) {
  const [src, setSrc] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    if (!logoUrl) {
      setSrc(null);
      return;
    }

    resolveBusinessLogoUrl(logoUrl).then((resolved) => {
      if (!cancelled) setSrc(resolved);
    });

    return () => {
      cancelled = true;
    };
  }, [logoUrl]);

  if (!src) return fallback;

  // eslint-disable-next-line @next/next/no-img-element
  return <img src={src} alt={alt} className={className} />;
}
