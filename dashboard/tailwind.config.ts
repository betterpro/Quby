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
          green: "#00B488",
          "green-light": "#00D193",
          "dark-bg": "#0A1F15",
          "dark-bg2": "#0D2B1C",
          honey: "#F6B43C",
          sidebar: "#091A11",
          "sidebar-border": "#1A3828",
          "card-bg": "#0F2518",
          "card-border": "#1E4030",
        },
      },
      fontFamily: {
        grotesk: ["var(--font-space-grotesk)", "sans-serif"],
        inter: ["var(--font-inter)", "sans-serif"],
      },
      backgroundImage: {
        "gradient-radial": "radial-gradient(var(--tw-gradient-stops))",
      },
    },
  },
  plugins: [],
};

export default config;
