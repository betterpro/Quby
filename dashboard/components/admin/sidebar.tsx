"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { Logo } from "@/components/logo";
import { createClient } from "@/lib/supabase/client";
import {
  LayoutDashboard,
  Building2,
  Users,
  ArrowLeftRight,
  LogOut,
  ChevronRight,
  Shield,
} from "lucide-react";

const navItems = [
  { href: "/admin", label: "Overview", icon: LayoutDashboard },
  { href: "/admin/businesses", label: "Businesses", icon: Building2 },
  { href: "/admin/users", label: "Users", icon: Users },
  { href: "/admin/transactions", label: "Transactions", icon: ArrowLeftRight },
];

export function AdminSidebar() {
  const pathname = usePathname();
  const router = useRouter();
  const supabase = createClient();

  async function handleLogout() {
    await supabase.auth.signOut();
    router.push("/login?admin=true");
    router.refresh();
  }

  return (
    <aside className="w-64 min-h-screen bg-brand-ink-bg border-r border-brand-ink-line flex flex-col fixed left-0 top-0 bottom-0 z-40">
      {/* Logo */}
      <div className="p-6 border-b border-brand-ink-line">
        <Logo size="sm" />
        <div className="flex items-center gap-1.5 mt-2">
          <Shield size={10} className="text-brand-honey" />
          <p className="text-xs text-brand-honey">Admin Dashboard</p>
        </div>
      </div>

      {/* Nav */}
      <nav className="flex-1 p-4 space-y-1">
        {navItems.map((item) => {
          const isActive =
            item.href === "/admin"
              ? pathname === "/admin"
              : pathname.startsWith(item.href);

          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center justify-between px-3 py-2.5 rounded-lg text-sm font-medium transition-all ${
                isActive
                  ? "bg-brand-honey/10 text-brand-honey border border-[#E2911F]/20"
                  : "text-gray-400 hover:text-white hover:bg-brand-ink-surface"
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
      <div className="p-4 border-t border-brand-ink-line space-y-1">
        <button
          onClick={handleLogout}
          className="w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-gray-400 hover:text-red-400 hover:bg-red-500/5 transition-all"
        >
          <LogOut size={18} />
          Sign Out
        </button>
      </div>

      <div className="px-6 pb-4">
        <p className="text-xs text-gray-700">QubyPay Admin v1.0</p>
      </div>
    </aside>
  );
}
