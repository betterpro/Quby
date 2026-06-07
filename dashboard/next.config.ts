import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  experimental: {
    serverComponentsExternalPackages: ["@supabase/ssr"],
  },
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
