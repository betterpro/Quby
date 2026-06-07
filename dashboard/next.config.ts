import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  serverExternalPackages: ["@supabase/ssr"],
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "tbsuulymqbxzlzzahvgc.supabase.co",
      },
    ],
  },
};

export default nextConfig;
