import { Suspense } from "react";
import { createAdminClient } from "@/lib/supabase/server";
import { formatCurrency, type Profile, type Transaction } from "@/lib/utils";
import { Users, Wallet, Star } from "lucide-react";
import { UsersTable } from "./users-table";

async function fetchData(): Promise<{ profiles: Profile[]; transactions: Transaction[] }> {
  try {
    const supabase = createAdminClient();
    const [profileRes, txnRes] = await Promise.all([
      supabase.from("profiles").select("*").order("created_at", { ascending: false }),
      supabase.from("transactions").select("*"),
    ]);
    return {
      profiles: (profileRes.data as Profile[]) ?? [],
      transactions: (txnRes.data as Transaction[]) ?? [],
    };
  } catch {
    return { profiles: [], transactions: [] };
  }
}

async function UsersList() {
  const { profiles, transactions } = await fetchData();

  const userSpend = new Map<string, number>();
  transactions
    .filter((t) => t.is_debit && t.user_id)
    .forEach((t) => {
      userSpend.set(t.user_id!, (userSpend.get(t.user_id!) || 0) + Math.abs(Number(t.amount)));
    });

  const enrichedProfiles = profiles.map((p) => ({
    ...p,
    totalSpent: userSpend.get(p.id) || 0,
    joinDate: p.created_at ?? "",
  }));

  const totalBalance = enrichedProfiles.reduce((s, p) => s + Number(p.balance || 0), 0);
  const totalPoints = enrichedProfiles.reduce((s, p) => s + Number(p.points || 0), 0);

  return (
    <>
      <div className="grid grid-cols-3 gap-4 mb-6">
        <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-4">
          <div className="flex items-center gap-2 mb-1">
            <Users size={14} className="text-[#6366F1]" />
            <p className="text-xs text-gray-400">Total Users</p>
          </div>
          <p className="text-2xl font-bold text-white font-display">{profiles.length}</p>
        </div>
        <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-4">
          <div className="flex items-center gap-2 mb-1">
            <Wallet size={14} className="text-[#00B488]" />
            <p className="text-xs text-gray-400">Total Wallet Balance</p>
          </div>
          <p className="text-2xl font-bold text-white font-display">
            {formatCurrency(totalBalance)}
          </p>
        </div>
        <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-4">
          <div className="flex items-center gap-2 mb-1">
            <Star size={14} className="text-brand-honey" />
            <p className="text-xs text-gray-400">Total Points Held</p>
          </div>
          <p className="text-2xl font-bold text-white font-display">
            {totalPoints.toLocaleString()}
          </p>
        </div>
      </div>

      <UsersTable profiles={enrichedProfiles} />
    </>
  );
}

function UsersSkeleton() {
  return (
    <>
      <div className="grid grid-cols-3 gap-4 mb-6">
        {[1, 2, 3].map((i) => (
          <div key={i} className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-4 animate-pulse h-20" />
        ))}
      </div>
      <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl h-96 animate-pulse" />
    </>
  );
}

export default function AdminUsersPage() {
  return (
    <div className="animate-fadeIn">
      <div className="mb-8">
        <h1 className="text-2xl font-bold font-display text-white">Users</h1>
        <p className="text-gray-400 text-sm mt-1">
          All QubyPay wallet users across the platform
        </p>
      </div>

      <Suspense fallback={<UsersSkeleton />}>
        <UsersList />
      </Suspense>
    </div>
  );
}
