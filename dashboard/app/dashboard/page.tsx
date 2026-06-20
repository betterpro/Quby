import { Suspense } from "react";
import { createAdminClient } from "@/lib/supabase/server";
import { StatCard, StatCardSkeleton } from "@/components/stat-card";
import { RevenueChart } from "@/components/dashboard/revenue-chart";
import {
  DollarSign,
  ArrowLeftRight,
  Users,
  Star,
  TrendingUp,
} from "lucide-react";
import {
  formatCurrency,
  formatDate,
  buildRevenueData,
  type Transaction,
} from "@/lib/utils";

async function fetchTransactions(): Promise<Transaction[]> {
  try {
    const supabase = createAdminClient();
    const { data } = await supabase
      .from("transactions")
      .select("*")
      .order("date", { ascending: false });
    return (data as Transaction[]) ?? [];
  } catch {
    return [];
  }
}

async function DashboardStats() {
  const transactions = await fetchTransactions();

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const todayTxns = transactions.filter(
    (t) => new Date(t.date) >= today && t.is_debit
  );
  const todayRevenue = todayTxns.reduce(
    (sum, t) => sum + Math.abs(Number(t.amount)),
    0
  );

  const uniqueCustomers = new Set(
    transactions.filter((t) => t.user_id).map((t) => t.user_id)
  ).size;

  const pointsIssued = transactions
    .filter((t) => !t.is_debit && t.type === "points")
    .reduce((sum, t) => sum + Math.abs(Number(t.amount)), 0);

  const revenueData = buildRevenueData(transactions, 7);
  const recentTxns = transactions.slice(0, 8);

  return (
    <>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <StatCard
          title="Today's Revenue"
          value={formatCurrency(todayRevenue)}
          icon={DollarSign}
          iconColor="#00B488"
        />
        <StatCard
          title="Total Transactions"
          value={transactions.length.toString()}
          icon={ArrowLeftRight}
          iconColor="#6366F1"
        />
        <StatCard
          title="Active Customers"
          value={uniqueCustomers.toString()}
          icon={Users}
          iconColor="#E2911F"
        />
        <StatCard
          title="Points Issued"
          value={pointsIssued.toLocaleString()}
          icon={Star}
          iconColor="#00D193"
        />
      </div>

      <div className="mb-8">
        <RevenueChart data={revenueData} />
      </div>

      <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl overflow-hidden">
        <div className="px-6 py-4 border-b border-brand-ink-surface-2 flex items-center justify-between">
          <div>
            <h3 className="font-semibold text-white font-display">Recent Transactions</h3>
            <p className="text-xs text-gray-400 mt-0.5">Latest activity at your business</p>
          </div>
          <a
            href="/dashboard/transactions"
            className="text-xs text-[#00B488] hover:text-brand-green-bright transition-colors"
          >
            View all →
          </a>
        </div>
        {recentTxns.length === 0 ? (
          <div className="px-6 py-12 text-center text-sm text-gray-500">
            No transactions yet
          </div>
        ) : (
          <div className="divide-y divide-brand-ink-line">
            {recentTxns.map((txn) => (
              <div key={txn.id} className="flex items-center justify-between px-6 py-3.5 table-row-hover">
                <div className="flex items-center gap-3">
                  <div
                    className="w-9 h-9 rounded-lg flex items-center justify-center text-base"
                    style={{ backgroundColor: `${txn.icon_color || "#00B488"}20` }}
                  >
                    {txn.icon || "💳"}
                  </div>
                  <div>
                    <p className="text-sm font-medium text-white">{txn.title}</p>
                    <p className="text-xs text-gray-500">{txn.subtitle}</p>
                  </div>
                </div>
                <div className="text-right">
                  <p
                    className={`text-sm font-semibold ${
                      txn.is_debit ? "text-red-400" : "text-brand-green-bright"
                    }`}
                  >
                    {txn.is_debit ? "-" : "+"}
                    {formatCurrency(txn.amount)}
                  </p>
                  <p className="text-xs text-gray-500">{formatDate(txn.date)}</p>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </>
  );
}

function StatsSkeleton() {
  return (
    <>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        {[1, 2, 3, 4].map((i) => <StatCardSkeleton key={i} />)}
      </div>
      <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl h-72 animate-pulse mb-8" />
      <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl h-64 animate-pulse" />
    </>
  );
}

export default function DashboardPage() {
  return (
    <div className="animate-fadeIn">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold font-display text-white">Overview</h1>
          <p className="text-gray-400 text-sm mt-1">
            {new Date().toLocaleDateString("en-US", {
              weekday: "long",
              year: "numeric",
              month: "long",
              day: "numeric",
            })}
          </p>
        </div>
        <div className="flex items-center gap-2 text-xs text-brand-green-bright bg-brand-green/10 border border-brand-green/20 rounded-full px-3 py-1.5">
          <TrendingUp size={12} />
          <span>All systems operational</span>
        </div>
      </div>

      <Suspense fallback={<StatsSkeleton />}>
        <DashboardStats />
      </Suspense>
    </div>
  );
}
