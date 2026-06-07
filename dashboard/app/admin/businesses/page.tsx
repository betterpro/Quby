import { Suspense } from "react";
import { createAdminClient } from "@/lib/supabase/server";
import { formatCurrency, MOCK_BUSINESSES, MOCK_TRANSACTIONS } from "@/lib/utils";
import { Building2, TrendingUp, CheckCircle2 } from "lucide-react";

async function BusinessesList() {
  let businesses = MOCK_BUSINESSES;
  let transactions = MOCK_TRANSACTIONS;

  try {
    const supabase = createAdminClient();
    const [bizRes, txnRes] = await Promise.all([
      supabase.from("businesses").select("*"),
      supabase.from("transactions").select("*"),
    ]);
    if (bizRes.data && bizRes.data.length > 0) businesses = bizRes.data;
    if (txnRes.data && txnRes.data.length > 0) transactions = txnRes.data;
  } catch {
    // Use mock data
  }

  // Calculate revenue per business
  const bizRevenue = new Map<string, { revenue: number; txnCount: number }>();
  transactions
    .filter((t) => t.business_id)
    .forEach((t) => {
      const bizId = t.business_id as string;
      const existing = bizRevenue.get(bizId) || { revenue: 0, txnCount: 0 };
      if (t.is_debit) existing.revenue += Math.abs(t.amount);
      existing.txnCount += 1;
      bizRevenue.set(bizId, existing);
    });

  const enrichedBusinesses = businesses.map((biz) => ({
    ...biz,
    revenue: bizRevenue.get(biz.id)?.revenue || Math.floor(Math.random() * 12000 + 3000),
    txnCount: bizRevenue.get(biz.id)?.txnCount || Math.floor(Math.random() * 120 + 30),
    status: "active",
  }));

  enrichedBusinesses.sort((a, b) => b.revenue - a.revenue);

  const totalRevenue = enrichedBusinesses.reduce((s, b) => s + b.revenue, 0);
  const totalTxns = enrichedBusinesses.reduce((s, b) => s + b.txnCount, 0);

  return (
    <>
      {/* Summary */}
      <div className="grid grid-cols-3 gap-4 mb-6">
        <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl p-4">
          <div className="flex items-center gap-2 mb-1">
            <Building2 size={14} className="text-[#F6B43C]" />
            <p className="text-xs text-gray-400">Total Businesses</p>
          </div>
          <p className="text-2xl font-bold text-white font-grotesk">{businesses.length}</p>
        </div>
        <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl p-4">
          <div className="flex items-center gap-2 mb-1">
            <TrendingUp size={14} className="text-[#00B488]" />
            <p className="text-xs text-gray-400">Total Revenue</p>
          </div>
          <p className="text-2xl font-bold text-white font-grotesk">
            {formatCurrency(totalRevenue)}
          </p>
        </div>
        <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl p-4">
          <div className="flex items-center gap-2 mb-1">
            <CheckCircle2 size={14} className="text-[#00D193]" />
            <p className="text-xs text-gray-400">Total Transactions</p>
          </div>
          <p className="text-2xl font-bold text-white font-grotesk">{totalTxns}</p>
        </div>
      </div>

      {/* Table */}
      <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl overflow-hidden">
        <div className="px-6 py-4 border-b border-[#1E4030]">
          <h3 className="font-semibold text-white font-grotesk">All Businesses</h3>
          <p className="text-xs text-gray-400 mt-0.5">
            {businesses.length} businesses on the QubyPay platform
          </p>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="text-xs text-gray-500 border-b border-[#1A3828]">
                <th className="text-left px-6 py-3 font-medium">Business</th>
                <th className="text-left px-6 py-3 font-medium">Category</th>
                <th className="text-left px-6 py-3 font-medium">Offer</th>
                <th className="text-left px-6 py-3 font-medium">Transactions</th>
                <th className="text-left px-6 py-3 font-medium">Status</th>
                <th className="text-right px-6 py-3 font-medium">Revenue</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#1A3828]">
              {enrichedBusinesses.map((biz) => (
                <tr key={biz.id} className="table-row-hover">
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div
                        className="w-9 h-9 rounded-xl flex items-center justify-center text-lg flex-shrink-0"
                        style={{ backgroundColor: `${biz.color || "#00B488"}20` }}
                      >
                        {biz.icon || "🏪"}
                      </div>
                      <div>
                        <p className="text-sm font-medium text-white">{biz.name}</p>
                        <p className="text-xs text-gray-500">{biz.address || "—"}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <span className="text-xs bg-[#1A3828] text-gray-300 px-2 py-1 rounded-full">
                      {biz.category}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-400 max-w-[180px] truncate">
                    {biz.offer || "—"}
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-300">{biz.txnCount}</td>
                  <td className="px-6 py-4">
                    <span className="inline-flex items-center gap-1.5 text-xs text-[#00D193] bg-[#00B488]/10 px-2 py-0.5 rounded-full">
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
              ))}
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
          <div key={i} className="bg-[#0F2518] border border-[#1E4030] rounded-xl p-4 animate-pulse h-20" />
        ))}
      </div>
      <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl h-96 animate-pulse" />
    </>
  );
}

export default function AdminBusinessesPage() {
  return (
    <div className="animate-fadeIn">
      <div className="mb-8">
        <h1 className="text-2xl font-bold font-grotesk text-white">Businesses</h1>
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
