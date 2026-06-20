import { Suspense } from "react";
import { createAdminClient } from "@/lib/supabase/server";
import { formatCurrency, type Business, type Transaction } from "@/lib/utils";
import { Building2, TrendingUp, CheckCircle2 } from "lucide-react";
import { BusinessesTable } from "./businesses-table";

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

      <BusinessesTable businesses={enrichedBusinesses} pendingRequests={pendingRequests} />
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
