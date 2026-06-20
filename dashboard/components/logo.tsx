import Link from "next/link";
import { QubyMark } from "@/components/quby-mark";

interface LogoProps {
  size?: "sm" | "md" | "lg";
  showWordmark?: boolean;
  href?: string;
  variant?: "dark" | "light";
}

export function Logo({
  size = "md",
  showWordmark = true,
  href = "/",
  variant = "dark",
}: LogoProps) {
  const sizes = {
    sm: { cube: 24, text: "text-lg" },
    md: { cube: 32, text: "text-xl" },
    lg: { cube: 48, text: "text-3xl" },
  };

  const { cube, text } = sizes[size];

  const logoContent = (
    <div className="flex items-center gap-2.5">
      <QubyMark size={cube} variant={variant} />

      {showWordmark && (
        <span className={`wordmark ${text}`}>
          <span className="text-brand-green-bright">Quby</span>
          <span className={variant === "light" ? "text-brand-ink" : "text-brand-ink-text"}>
            Pay
          </span>
        </span>
      )}
    </div>
  );

  if (href) {
    return <Link href={href}>{logoContent}</Link>;
  }

  return logoContent;
}
