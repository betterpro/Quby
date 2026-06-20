import { Suspense } from "react";
import { createAdminClient } from "@/lib/supabase/server";
import { BusinessLogoImage } from "@/components/business-logo";
import { formatCurrency, type Business, type Transaction } from "@/lib/utils";
import { Building2, TrendingUp, CheckCircle2 } from "lucide-react";
import { PendingSection } from "./pending-section";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
async function fetchData(): Promise<{ businesses: Business[]; transactions: Transaction[]; pendingRequests: any[] }> {
  try {
    const supabase = createAdminClient();
    const [bizRes, txnRes, reqRes] = await Promise.all([
      supabase.from("businesses").select("*"),
      supabase.from("transactions").select("*"),
      supabase.from("business_requests").select("*").eq("status", "pending").order("created_at", { ascending: false }),
    ]);
    return {
      businesses: (bizRes.data as Business[]) ?? [],
      transactions: (txnRes.data as Transaction[]) ?? [],
      pendingRequests: reqRes.data ?? [],
    };
  } catch {
    return { businesses: [], transactions: [], pendingRequests: [] };
  }
}

async function BusinessesList() {
  const { businesses, transactions, pendingRequests } = await fetchData();

  const bizRevenue = new Map<string, { revenue: number; txnCount: number }>();
  transactions
    .filter((t) => t.business_id)
    .forEach((t) => {
      const bizId = t.business_id as string;
      const existing = bizRevenue.get(bizId) || { revenue: 0, txnCount: 0 };
      if (t.is_debit) existing.revenue += Math.abs(Number(t.amount));
      existing.txnCount += 1;
      bizRevenue.set(bizId, existing);
    });

  const enrichedBusinesses = businesses.map((biz) => ({
    ...biz,
    revenue: bizRevenue.get(biz.id)?.revenue || 0,
    txnCount: bizRevenue.get(biz.id)?.txnCount || 0,
    status: "active",
  }));

  enrichedBusinesses.sort((a, b) => b.revenue - a.revenue);

  const totalRevenue = enrichedBusinesses.reduce((s, b) => s + b.revenue, 0);
  const totalTxns = enrichedBusinesses.reduce((s, b) => s + b.txnCount, 0);

  return (
    <>
      <PendingSection requests={pendingRequests} />

      <div className="grid grid-cols-3 gap-4 mb-6">
        <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-4">
          <div className="flex items-center gap-2 mb-1">
            <Building2 size={14} className="text-brand-honey" />
            <p className="text-xs text-gray-400">Total Businesses</p>
          </div>
          <p className="text-2xl font-bold text-white font-display">{businesses.length}</p>
        </div>
        <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-4">
          <div className="flex items-center gap-2 mb-1">
            <TrendingUp size={14} className="text-[#00B488]" />
            <p className="text-xs text-gray-400">Total Revenue</p>
          </div>
          <p className="text-2xl font-bold text-white font-display">
            {formatCurrency(totalRevenue)}
          </p>
        </div>
        <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-4">
          <div className="flex items-center gap-2 mb-1">
            <CheckCircle2 size={14} className="text-brand-green-bright" />
            <p className="text-xs text-gray-400">Total Transactions</p>
          </div>
          <p className="text-2xl font-bold text-white font-display">{totalTxns}</p>
        </div>
      </div>

      <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl overflow-hidden">
        <div className="px-6 py-4 border-b border-brand-ink-surface-2">
          <h3 className="font-semibold text-white font-display">All Businesses</h3>
          <p className="text-xs text-gray-400 mt-0.5">
            {businesses.length} businesses on the QubyPay platform
          </p>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="text-xs text-gray-500 border-b border-brand-ink-line">
                <th className="text-left px-6 py-3 font-medium">Business</th>
                <th className="text-left px-6 py-3 font-medium">Category</th>
                <th className="text-left px-6 py-3 font-medium">Offer</th>
                <th className="text-left px-6 py-3 font-medium">Transactions</th>
                <th className="text-left px-6 py-3 font-medium">Status</th>
                <th className="text-right px-6 py-3 font-medium">Revenue</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-brand-ink-line">
              {enrichedBusinesses.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-6 py-12 text-center text-sm text-gray-500">
                    No businesses yet
                  </td>
                </tr>
              ) : (
                enrichedBusinesses.map((biz) => (
                  <tr key={biz.id} className="table-row-hover">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div
                          className="w-9 h-9 rounded-xl flex items-center justify-center text-lg flex-shrink-0 overflow-hidden"
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
                    <td className="px-6 py-4">
                      <span className="text-xs bg-brand-ink-surface-2 text-gray-300 px-2 py-1 rounded-full">
                        {biz.category}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-400 max-w-[180px] truncate">
                      {biz.offer || "—"}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-300">{biz.txnCount}</td>
                    <td className="px-6 py-4">
                      <span className="inline-flex items-center gap-1.5 text-xs text-brand-green-bright bg-brand-green/10 px-2 py-0.5 rounded-full">
                        <span className="w-1.5 h-1.5 rounded-full bg-[#00D193]" />
                        Active
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right">
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
    </>
  );
}

function BusinessesSkeleton() {
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

export default function AdminBusinessesPage() {
  return (
    <div className="animate-fadeIn">
      <div className="mb-8">
        <h1 className="text-2xl font-bold font-display text-white">Businesses</h1>
        <p className="text-gray-400 text-sm mt-1">
          All businesses registered on the QubyPay platform
        </p>
      </div>

      <Suspense fallback={<BusinessesSkeleton />}>
        <BusinessesList />
      </Suspense>
    </div>
  );
}
