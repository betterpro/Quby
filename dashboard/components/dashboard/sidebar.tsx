"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { Logo } from "@/components/logo";
import { createClient } from "@/lib/supabase/client";
import {
  LayoutDashboard,
  ArrowLeftRight,
  Users,
  BarChart3,
  Settings,
  LogOut,
  ChevronRight,
} from "lucide-react";

const navItems = [
  { href: "/dashboard", label: "Overview", icon: LayoutDashboard },
  { href: "/dashboard/transactions", label: "Transactions", icon: ArrowLeftRight },
  { href: "/dashboard/customers", label: "Customers", icon: Users },
  { href: "/dashboard/settings", label: "Settings", icon: Settings },
];

export function DashboardSidebar() {
  const pathname = usePathname();
  const router = useRouter();
  const supabase = createClient();

  async function handleLogout() {
    await supabase.auth.signOut();
    router.push("/login");
    router.refresh();
  }

  return (
    <aside className="w-64 min-h-screen bg-[#091A11] border-r border-[#1A3828] flex flex-col fixed left-0 top-0 bottom-0 z-40">
      {/* Logo */}
      <div className="p-6 border-b border-[#1A3828]">
        <Logo size="sm" />
        <p className="text-xs text-gray-500 mt-2 ml-0.5">Business Dashboard</p>
      </div>

      {/* Nav */}
      <nav className="flex-1 p-4 space-y-1">
        {navItems.map((item) => {
          const isActive =
            item.href === "/dashboard"
              ? pathname === "/dashboard"
              : pathname.startsWith(item.href);

          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center justify-between px-3 py-2.5 rounded-lg text-sm font-medium transition-all group ${
                isActive
                  ? "bg-[#00B488]/15 text-[#00D193] border border-[#00B488]/20"
                  : "text-gray-400 hover:text-white hover:bg-[#0F2518]"
              }`}
            >
              <span className="flex items-center gap-3">
                <item.icon size={18} />
                {item.label}
              </span>
              {isActive && <ChevronRight size={14} className="opacity-60" />}
            </Link>
          );
        })}
      </nav>

      {/* Bottom section */}
      <div className="p-4 border-t border-[#1A3828] space-y-1">
        <button
          onClick={handleLogout}
          className="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-gray-400 hover:text-red-400 hover:bg-red-500/5 transition-all"
        >
          <LogOut size={18} />
          Sign Out
        </button>
      </div>

      {/* Version */}
      <div className="px-6 pb-4">
        <p className="text-xs text-gray-700">QubyPay v1.0</p>
      </div>
    </aside>
  );
}
