interface QubyMarkProps {
  size?: number;
  /** "dark" = on ink backgrounds (bright top, light sides); "light" = on paper (green top, ink sides) */
  variant?: "dark" | "light";
  className?: string;
}

export function QubyMark({ size = 32, variant = "dark", className }: QubyMarkProps) {
  const top = variant === "dark" ? "#00D193" : "#00B488";
  const side = variant === "dark" ? "#EAF0F6" : "#0E1726";

  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 32 32"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      aria-hidden
    >
      <path d="M16 3.2 27.4 9.4 16 15.6 4.6 9.4 16 3.2Z" fill={top} />
      <path d="M4.6 9.4 16 15.6V28.8L4.6 22.6V9.4Z" fill={side} />
      <path d="M27.4 9.4 16 15.6V28.8l11.4-6.2V9.4Z" fill={side} opacity="0.78" />
      <path
        d="M16 15.6 27.4 9.4 24.2 7.7 16 12.2 7.8 7.7 4.6 9.4"
        fill="white"
        opacity="0.16"
      />
    </svg>
  );
}
