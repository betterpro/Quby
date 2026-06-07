import Link from "next/link";

interface LogoProps {
  size?: "sm" | "md" | "lg";
  showWordmark?: boolean;
  href?: string;
}

export function Logo({ size = "md", showWordmark = true, href = "/" }: LogoProps) {
  const sizes = {
    sm: { cube: 24, text: "text-lg" },
    md: { cube: 32, text: "text-xl" },
    lg: { cube: 48, text: "text-3xl" },
  };

  const { cube, text } = sizes[size];

  const logoContent = (
    <div className="flex items-center gap-2.5">
      {/* Quby 3D Cube SVG */}
      <svg
        width={cube}
        height={cube}
        viewBox="0 0 48 48"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        {/* Top face */}
        <path
          d="M24 4L44 14V16L24 6L4 16V14L24 4Z"
          fill="#00D193"
        />
        <path
          d="M4 14L24 4L44 14L24 24L4 14Z"
          fill="#00D193"
        />
        {/* Left face */}
        <path
          d="M4 14L24 24V44L4 34V14Z"
          fill="#009970"
        />
        {/* Right face */}
        <path
          d="M44 14L24 24V44L44 34V14Z"
          fill="#00B488"
        />
        {/* Shine on top face */}
        <path
          d="M24 6L40 14.5L24 23L8 14.5L24 6Z"
          fill="url(#topGradient)"
          opacity="0.3"
        />
        <defs>
          <linearGradient id="topGradient" x1="24" y1="6" x2="24" y2="23" gradientUnits="userSpaceOnUse">
            <stop stopColor="white" stopOpacity="0.6" />
            <stop offset="1" stopColor="white" stopOpacity="0" />
          </linearGradient>
        </defs>
      </svg>

      {showWordmark && (
        <span
          className={`${text} font-bold tracking-tight`}
          style={{ fontFamily: "var(--font-space-grotesk, sans-serif)" }}
        >
          <span className="text-[#00D193]">Quby</span>
          <span className="text-white">Pay</span>
        </span>
      )}
    </div>
  );

  if (href) {
    return <Link href={href}>{logoContent}</Link>;
  }

  return logoContent;
}
