import { Suspense } from "react";
import { createAdminClient } from "@/lib/supabase/server";
import { formatCurrency, formatDate, type Profile, type Transaction } from "@/lib/utils";
import { Users, Wallet, Star } from "lucide-react";

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
    joinDate: p.created_at,
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

      <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl overflow-hidden">
        <div className="px-6 py-4 border-b border-brand-ink-surface-2">
          <h3 className="font-semibold text-white font-display">All Users</h3>
          <p className="text-xs text-gray-400 mt-0.5">
            {profiles.length} registered QubyPay wallet users
          </p>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="text-xs text-gray-500 border-b border-brand-ink-line">
                <th className="text-left px-6 py-3 font-medium">User</th>
                <th className="text-left px-6 py-3 font-medium">Balance</th>
                <th className="text-left px-6 py-3 font-medium">Points</th>
                <th className="text-left px-6 py-3 font-medium">Total Spent</th>
                <th className="text-left px-6 py-3 font-medium">Theme</th>
                <th className="text-right px-6 py-3 font-medium">Joined</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-brand-ink-line">
              {enrichedProfiles.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-6 py-12 text-center text-sm text-gray-500">
                    No users yet
                  </td>
                </tr>
              ) : (
                enrichedProfiles.map((profile) => (
                  <tr key={profile.id} className="table-row-hover">
                    <td className="px-6 py-3.5">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-gradient-to-br from-[#00B488] to-[#6366F1] flex items-center justify-center text-sm font-bold text-white flex-shrink-0">
                          {(profile.name || "U").charAt(0)}
                        </div>
                        <div>
                          <p className="text-sm font-medium text-white">
                            {profile.name || "Anonymous"}
                          </p>
                          <p className="text-xs text-gray-500">
                            {profile.handle || `@user_${profile.id?.slice(0, 6)}`}
                          </p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-3.5">
                      <span className="text-sm font-semibold text-brand-green-bright">
                        {formatCurrency(profile.balance || 0)}
                      </span>
                    </td>
                    <td className="px-6 py-3.5">
                      <span className="text-sm text-brand-honey">
                        {(profile.points || 0).toLocaleString()} pts
                      </span>
                    </td>
                    <td className="px-6 py-3.5">
                      <span className="text-sm text-white">
                        {formatCurrency(profile.totalSpent)}
                      </span>
                    </td>
                    <td className="px-6 py-3.5">
                      <span
                        className={`text-xs px-2 py-0.5 rounded-full ${
                          profile.is_dark
                            ? "bg-gray-800 text-gray-300"
                            : "bg-yellow-500/10 text-yellow-300"
                        }`}
                      >
                        {profile.is_dark ? "Dark" : "Light"}
                      </span>
                    </td>
                    <td className="px-6 py-3.5 text-right text-sm text-gray-400">
                      {profile.joinDate ? formatDate(profile.joinDate) : "—"}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
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
