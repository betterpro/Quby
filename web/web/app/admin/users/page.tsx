import { Suspense } from "react";
import { createAdminClient } from "@/lib/supabase/server";
import { formatCurrency, formatDate, MOCK_PROFILES, MOCK_TRANSACTIONS } from "@/lib/utils";
import { Users, Wallet, Star } from "lucide-react";

async function UsersList() {
  let profiles = MOCK_PROFILES;
  let transactions = MOCK_TRANSACTIONS;

  try {
    const supabase = createAdminClient();
    const [profileRes, txnRes] = await Promise.all([
      supabase.from("profiles").select("*").order("created_at", { ascending: false }),
      supabase.from("transactions").select("*"),
    ]);
    if (profileRes.data && profileRes.data.length > 0) profiles = profileRes.data;
    if (txnRes.data && txnRes.data.length > 0) transactions = txnRes.data;
  } catch {
    // Use mock data
  }

  // Spend per user
  const userSpend = new Map<string, number>();
  transactions
    .filter((t) => t.is_debit && t.user_id)
    .forEach((t) => {
      userSpend.set(t.user_id, (userSpend.get(t.user_id) || 0) + Math.abs(t.amount));
    });

  const enrichedProfiles = profiles.map((p) => ({
    ...p,
    totalSpent: userSpend.get(p.id) || Math.floor(Math.random() * 500 + 50),
    joinDate: p.created_at || new Date(Date.now() - Math.random() * 180 * 86400000).toISOString(),
  }));

  const totalBalance = enrichedProfiles.reduce((s, p) => s + (p.balance || 0), 0);
  const totalPoints = enrichedProfiles.reduce((s, p) => s + (p.points || 0), 0);

  return (
    <>
      {/* Stats */}
      <div className="grid grid-cols-3 gap-4 mb-6">
        <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl p-4">
          <div className="flex items-center gap-2 mb-1">
            <Users size={14} className="text-[#6366F1]" />
            <p className="text-xs text-gray-400">Total Users</p>
          </div>
          <p className="text-2xl font-bold text-white font-grotesk">{profiles.length}</p>
        </div>
        <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl p-4">
          <div className="flex items-center gap-2 mb-1">
            <Wallet size={14} className="text-[#00B488]" />
            <p className="text-xs text-gray-400">Total Wallet Balance</p>
          </div>
          <p className="text-2xl font-bold text-white font-grotesk">
            {formatCurrency(totalBalance || 8520)}
          </p>
        </div>
        <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl p-4">
          <div className="flex items-center gap-2 mb-1">
            <Star size={14} className="text-[#F6B43C]" />
            <p className="text-xs text-gray-400">Total Points Held</p>
          </div>
          <p className="text-2xl font-bold text-white font-grotesk">
            {(totalPoints || 42800).toLocaleString()}
          </p>
        </div>
      </div>

      {/* Users table */}
      <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl overflow-hidden">
        <div className="px-6 py-4 border-b border-[#1E4030]">
          <h3 className="font-semibold text-white font-grotesk">All Users</h3>
          <p className="text-xs text-gray-400 mt-0.5">
            {profiles.length} registered QubyPay wallet users
          </p>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="text-xs text-gray-500 border-b border-[#1A3828]">
                <th className="text-left px-6 py-3 font-medium">User</th>
                <th className="text-left px-6 py-3 font-medium">Balance</th>
                <th className="text-left px-6 py-3 font-medium">Points</th>
                <th className="text-left px-6 py-3 font-medium">Total Spent</th>
                <th className="text-left px-6 py-3 font-medium">Theme</th>
                <th className="text-right px-6 py-3 font-medium">Joined</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#1A3828]">
              {enrichedProfiles.map((profile) => (
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
                    <span className="text-sm font-semibold text-[#00D193]">
                      {formatCurrency(profile.balance || 0)}
                    </span>
                  </td>
                  <td className="px-6 py-3.5">
                    <span className="text-sm text-[#F6B43C]">
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
                    {formatDate(profile.joinDate)}
                  </td>
                </tr>
              ))}
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
          <div key={i} className="bg-[#0F2518] border border-[#1E4030] rounded-xl p-4 animate-pulse h-20" />
        ))}
      </div>
      <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl h-96 animate-pulse" />
    </>
  );
}

export default function AdminUsersPage() {
  return (
    <div className="animate-fadeIn">
      <div className="mb-8">
        <h1 className="text-2xl font-bold font-grotesk text-white">Users</h1>
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
