import { Suspense } from "react";
import { createAdminClient } from "@/lib/supabase/server";
import { StatCard, StatCardSkeleton } from "@/components/stat-card";
import { BusinessLogoImage } from "@/components/business-logo";
import {
  DollarSign,
  Building2,
  Users,
  ArrowLeftRight,
  Shield,
} from "lucide-react";
import {
  formatCurrency,
  formatDate,
  type Business,
  type Profile,
  type Transaction,
} from "@/lib/utils";

async function fetchPlatformData(): Promise<{
  businesses: Business[];
  transactions: Transaction[];
  profiles: Profile[];
}> {
  try {
    const supabase = createAdminClient();
    const [bizRes, txnRes, profileRes] = await Promise.all([
      supabase.from("businesses").select("*"),
      supabase.from("transactions").select("*").order("date", { ascending: false }),
      supabase.from("profiles").select("*"),
    ]);
    return {
      businesses: (bizRes.data as Business[]) ?? [],
      transactions: (txnRes.data as Transaction[]) ?? [],
      profiles: (profileRes.data as Profile[]) ?? [],
    };
  } catch {
    return { businesses: [], transactions: [], profiles: [] };
  }
}

async function AdminStats() {
  const { businesses, transactions, profiles } = await fetchPlatformData();

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const todayTxns = transactions.filter((t) => new Date(t.date) >= today);
  const totalRevenue = transactions
    .filter((t) => t.is_debit)
    .reduce((sum, t) => sum + Math.abs(Number(t.amount)), 0);

  const bizRevenue = new Map<string, number>();
  transactions
    .filter((t) => t.is_debit && t.business_id)
    .forEach((t) => {
      const bizId = t.business_id as string;
      bizRevenue.set(
        bizId,
        (bizRevenue.get(bizId) || 0) + Math.abs(Number(t.amount))
      );
    });

  const bizWithRevenue = businesses.map((biz) => ({
    ...biz,
    revenue: bizRevenue.get(biz.id) || 0,
    txnCount: transactions.filter((t) => t.business_id === biz.id).length,
  }));

  bizWithRevenue.sort((a, b) => b.revenue - a.revenue);

  return (
    <>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <StatCard
          title="Total Platform Revenue"
          value={formatCurrency(totalRevenue)}
          icon={DollarSign}
          iconColor="#00B488"
        />
        <StatCard
          title="Active Businesses"
          value={businesses.length.toString()}
          icon={Building2}
          iconColor="#E2911F"
        />
        <StatCard
          title="Total Users"
          value={profiles.length.toString()}
          icon={Users}
          iconColor="#6366F1"
        />
        <StatCard
          title="Transactions Today"
          value={todayTxns.length.toString()}
          icon={ArrowLeftRight}
          iconColor="#00D193"
        />
      </div>

      <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl overflow-hidden">
        <div className="px-6 py-4 border-b border-brand-ink-surface-2 flex items-center justify-between">
          <div>
            <h3 className="font-semibold text-white font-display">Business Activity</h3>
            <p className="text-xs text-gray-400 mt-0.5">Top performing businesses on the platform</p>
          </div>
          <a
            href="/admin/businesses"
            className="text-xs text-brand-honey hover:text-yellow-300 transition-colors"
          >
            View all →
          </a>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="text-xs text-gray-500 border-b border-brand-ink-line">
                <th className="text-left px-6 py-3 font-medium">Business</th>
                <th className="text-left px-6 py-3 font-medium">Category</th>
                <th className="text-left px-6 py-3 font-medium">Transactions</th>
                <th className="text-right px-6 py-3 font-medium">Revenue</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-brand-ink-line">
              {bizWithRevenue.length === 0 ? (
                <tr>
                  <td colSpan={4} className="px-6 py-12 text-center text-sm text-gray-500">
                    No businesses yet
                  </td>
                </tr>
              ) : (
                bizWithRevenue.slice(0, 8).map((biz) => (
                  <tr key={biz.id} className="table-row-hover">
                    <td className="px-6 py-3.5">
                      <div className="flex items-center gap-3">
                        <div
                          className="w-8 h-8 rounded-lg flex items-center justify-center text-base overflow-hidden"
                          style={{ backgroundColor: `${biz.color || "#00B488"}20` }}
                        >
                          {biz.logo_url ? (
                            <BusinessLogoImage
                              logoUrl={biz.logo_url}
                              className="w-full h-full object-cover"
                              fallback={<span>{biz.icon || "🏪"}</span>}
                            />
                          ) : (
                            biz.icon || "🏪"
                          )}
                        </div>
                        <div>
                          <p className="text-sm font-medium text-white">{biz.name}</p>
                          <p className="text-xs text-gray-500">{biz.address || "—"}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-3.5">
                      <span className="text-xs bg-brand-ink-surface-2 text-gray-300 px-2 py-1 rounded-full">
                        {biz.category}
                      </span>
                    </td>
                    <td className="px-6 py-3.5 text-sm text-gray-300">{biz.txnCount}</td>
                    <td className="px-6 py-3.5 text-right">
                      <span className="text-sm font-semibold text-white">
                        {formatCurrency(biz.revenue)}
                      </span>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      <div className="mt-6 bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-6">
        <h3 className="font-semibold text-white font-display mb-4">Recent Transactions</h3>
        {transactions.length === 0 ? (
          <p className="text-sm text-gray-500 text-center py-6">No transactions yet</p>
        ) : (
          <div className="space-y-3">
            {transactions.slice(0, 5).map((txn) => (
              <div
                key={txn.id}
                className="flex items-center justify-between py-2.5 border-b border-brand-ink-line last:border-0"
              >
                <div className="flex items-center gap-3">
                  <div
                    className="w-8 h-8 rounded-lg flex items-center justify-center text-sm"
                    style={{ backgroundColor: `${txn.icon_color || "#00B488"}20` }}
                  >
                    {txn.icon || "💳"}
                  </div>
                  <div>
                    <p className="text-sm font-medium text-white">{txn.title}</p>
                    <p className="text-xs text-gray-500">{formatDate(txn.date)}</p>
                  </div>
                </div>
                <span
                  className={`text-sm font-semibold ${
                    txn.is_debit ? "text-red-400" : "text-brand-green-bright"
                  }`}
                >
                  {txn.is_debit ? "-" : "+"}
                  {formatCurrency(txn.amount)}
                </span>
              </div>
            ))}
          </div>
        )}
      </div>
    </>
  );
}

function AdminStatsSkeleton() {
  return (
    <>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        {[1, 2, 3, 4].map((i) => <StatCardSkeleton key={i} />)}
      </div>
      <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl h-80 animate-pulse mb-6" />
      <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl h-48 animate-pulse" />
    </>
  );
}

export default function AdminPage() {
  return (
    <div className="animate-fadeIn">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold font-display text-white">Platform Overview</h1>
          <p className="text-gray-400 text-sm mt-1">
            {new Date().toLocaleDateString("en-US", {
              weekday: "long",
              year: "numeric",
              month: "long",
              day: "numeric",
            })}
          </p>
        </div>
        <div className="flex items-center gap-2 text-xs text-brand-honey bg-brand-honey/10 border border-[#E2911F]/20 rounded-full px-3 py-1.5">
          <Shield size={12} />
          <span>Admin Access</span>
        </div>
      </div>

      <Suspense fallback={<AdminStatsSkeleton />}>
        <AdminStats />
      </Suspense>
    </div>
  );
}
