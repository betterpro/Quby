import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          // Ink + paper neutrals
          ink: "#0E1726",
          paper: "#F1F3EF",
          surface: "#FFFFFF",
          "surface-2": "#F4F6F2",
          "surface-3": "#E9ECE6",
          slate: "#5C6672",
          mist: "#9AA4AF",
          // Quby Green
          green: "#00B488",
          "green-600": "#00997A",
          "green-ink": "#067A5C",
          "green-bright": "#00D193",
          "on-green": "#04261C",
          // Supporting
          honey: "#E2911F",
          danger: "#E5484D",
          // Extended accents
          violet: "#6C4DE0",
          blue: "#2E6BF0",
          coral: "#F2624E",
          // Dark surfaces (ink-*)
          "ink-bg": "#0A0F1A",
          "ink-surface": "#121A28",
          "ink-surface-2": "#1A2333",
          "ink-text": "#EAF0F6",
          "ink-dim": "#93A1B3",
        },
      },
      fontFamily: {
        display: ["var(--font-space-grotesk)", "sans-serif"],
        body: ["var(--font-plus-jakarta)", "sans-serif"],
        mono: ["var(--font-jetbrains-mono)", "monospace"],
        grotesk: ["var(--font-space-grotesk)", "sans-serif"],
      },
      backgroundImage: {
        "gradient-radial": "radial-gradient(var(--tw-gradient-stops))",
      },
      borderColor: {
        "brand-ink-line": "rgba(255,255,255,0.10)",
      },
    },
  },
  plugins: [],
};

export default config;
