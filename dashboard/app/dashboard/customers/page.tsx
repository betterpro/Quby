import { Suspense } from "react";
import { createAdminClient } from "@/lib/supabase/server";
import { formatCurrency, formatDate, type Profile, type Transaction } from "@/lib/utils";
import { Users, TrendingUp, Award } from "lucide-react";

async function fetchData(): Promise<{ transactions: Transaction[]; profiles: Profile[] }> {
  try {
    const supabase = createAdminClient();
    const [txnRes, profileRes] = await Promise.all([
      supabase.from("transactions").select("*").order("date", { ascending: false }),
      supabase.from("profiles").select("*"),
    ]);
    return {
      transactions: (txnRes.data as Transaction[]) ?? [],
      profiles: (profileRes.data as Profile[]) ?? [],
    };
  } catch {
    return { transactions: [], profiles: [] };
  }
}

async function CustomersList() {
  const { transactions, profiles } = await fetchData();

  const customerMap = new Map<
    string,
    { totalSpent: number; txnCount: number; lastVisit: string; userId: string }
  >();

  transactions
    .filter((t) => t.is_debit && t.user_id)
    .forEach((txn) => {
      const uid = txn.user_id!;
      const existing = customerMap.get(uid) || {
        totalSpent: 0,
        txnCount: 0,
        lastVisit: txn.date,
        userId: uid,
      };
      existing.totalSpent += Math.abs(Number(txn.amount));
      existing.txnCount += 1;
      if (new Date(txn.date) > new Date(existing.lastVisit)) {
        existing.lastVisit = txn.date;
      }
      customerMap.set(uid, existing);
    });

  const customers = Array.from(customerMap.values()).map((data) => {
    const profile = profiles.find((p) => p.id === data.userId);
    return {
      ...data,
      name: profile?.name || `Customer ${data.userId.slice(0, 6)}`,
      handle: profile?.handle || `@${data.userId.slice(0, 8)}`,
      points: profile?.points || 0,
    };
  });

  customers.sort((a, b) => b.totalSpent - a.totalSpent);

  const totalCustomers = customers.length;
  const totalRevenue = customers.reduce((s, c) => s + c.totalSpent, 0);
  const avgSpend = totalCustomers > 0 ? totalRevenue / totalCustomers : 0;

  return (
    <>
      <div className="grid grid-cols-3 gap-4 mb-6">
        <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-4">
          <div className="flex items-center gap-2 mb-1">
            <Users size={14} className="text-[#00B488]" />
            <p className="text-xs text-gray-400">Total Customers</p>
          </div>
          <p className="text-2xl font-bold text-white font-display">{totalCustomers}</p>
        </div>
        <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-4">
          <div className="flex items-center gap-2 mb-1">
            <TrendingUp size={14} className="text-brand-honey" />
            <p className="text-xs text-gray-400">Total Revenue</p>
          </div>
          <p className="text-2xl font-bold text-white font-display">
            {formatCurrency(totalRevenue)}
          </p>
        </div>
        <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-4">
          <div className="flex items-center gap-2 mb-1">
            <Award size={14} className="text-[#6366F1]" />
            <p className="text-xs text-gray-400">Avg. Spend / Customer</p>
          </div>
          <p className="text-2xl font-bold text-white font-display">
            {formatCurrency(avgSpend)}
          </p>
        </div>
      </div>

      <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl overflow-hidden">
        <div className="px-6 py-4 border-b border-brand-ink-surface-2">
          <h3 className="font-semibold text-white font-display">Customer Directory</h3>
          <p className="text-xs text-gray-400 mt-0.5">Sorted by total spend</p>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="text-xs text-gray-500 border-b border-brand-ink-line">
                <th className="text-left px-6 py-3 font-medium">Customer</th>
                <th className="text-left px-6 py-3 font-medium">Visits</th>
                <th className="text-left px-6 py-3 font-medium">Points</th>
                <th className="text-left px-6 py-3 font-medium">Last Visit</th>
                <th className="text-right px-6 py-3 font-medium">Total Spent</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-brand-ink-line">
              {customers.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-6 py-12 text-center text-sm text-gray-500">
                    No customers yet
                  </td>
                </tr>
              ) : (
                customers.map((customer) => (
                  <tr key={customer.userId} className="table-row-hover">
                    <td className="px-6 py-3.5">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-gradient-to-br from-[#00B488] to-brand-ink-surface-2 flex items-center justify-center text-sm font-bold text-white">
                          {customer.name.charAt(0)}
                        </div>
                        <div>
                          <p className="text-sm font-medium text-white">{customer.name}</p>
                          <p className="text-xs text-gray-500">{customer.handle}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-3.5 text-sm text-gray-300">
                      {customer.txnCount}x
                    </td>
                    <td className="px-6 py-3.5">
                      <span className="text-xs font-medium text-brand-honey">
                        {customer.points.toLocaleString()} pts
                      </span>
                    </td>
                    <td className="px-6 py-3.5 text-sm text-gray-400">
                      {formatDate(customer.lastVisit)}
                    </td>
                    <td className="px-6 py-3.5 text-right">
                      <span className="text-sm font-semibold text-white">
                        {formatCurrency(customer.totalSpent)}
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

function CustomersSkeleton() {
  return (
    <>
      <div className="grid grid-cols-3 gap-4 mb-6">
        {[1, 2, 3].map((i) => (
          <div key={i} className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-4 animate-pulse h-20" />
        ))}
      </div>
      <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl h-80 animate-pulse" />
    </>
  );
}

export default function CustomersPage() {
  return (
    <div className="animate-fadeIn">
      <div className="mb-8">
        <h1 className="text-2xl font-bold font-display text-white">Customers</h1>
        <p className="text-gray-400 text-sm mt-1">
          Understand your customer base and loyalty
        </p>
      </div>

      <Suspense fallback={<CustomersSkeleton />}>
        <CustomersList />
      </Suspense>
    </div>
  );
}
