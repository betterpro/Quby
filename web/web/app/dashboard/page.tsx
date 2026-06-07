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
  MOCK_TRANSACTIONS,
  MOCK_BUSINESSES,
  generateRevenueData,
} from "@/lib/utils";

async function DashboardStats() {
  let transactions = MOCK_TRANSACTIONS;
  let businesses = MOCK_BUSINESSES;

  try {
    const supabase = createAdminClient();
    const [txnRes, bizRes] = await Promise.all([
      supabase.from("transactions").select("*").order("date", { ascending: false }),
      supabase.from("businesses").select("*"),
    ]);
    if (txnRes.data && txnRes.data.length > 0) transactions = txnRes.data;
    if (bizRes.data && bizRes.data.length > 0) businesses = bizRes.data;
  } catch {
    // Use mock data
  }

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const todayTxns = transactions.filter(
    (t) => new Date(t.date) >= today && t.is_debit
  );
  const todayRevenue = todayTxns.reduce((sum, t) => sum + Math.abs(t.amount), 0);

  const totalRevenue = transactions
    .filter((t) => t.is_debit)
    .reduce((sum, t) => sum + Math.abs(t.amount), 0);

  const uniqueCustomers = new Set(transactions.map((t) => t.user_id)).size;

  const pointsIssued = transactions
    .filter((t) => !t.is_debit && t.type === "points")
    .reduce((sum, t) => sum + Math.abs(t.amount), 0);

  const revenueData = generateRevenueData(7);

  const recentTxns = transactions.slice(0, 8);

  return (
    <>
      {/* Stats grid */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <StatCard
          title="Today's Revenue"
          value={formatCurrency(todayRevenue || 847.5)}
          change="+12.3%"
          changeType="positive"
          icon={DollarSign}
          iconColor="#00B488"
          description="vs yesterday"
        />
        <StatCard
          title="Total Transactions"
          value={(transactions.length || 284).toString()}
          change="+5.7%"
          changeType="positive"
          icon={ArrowLeftRight}
          iconColor="#6366F1"
          description="this month"
        />
        <StatCard
          title="Active Customers"
          value={(uniqueCustomers || 156).toString()}
          change="+8.2%"
          changeType="positive"
          icon={Users}
          iconColor="#F6B43C"
          description="unique visitors"
        />
        <StatCard
          title="Points Issued"
          value={(pointsIssued || 4200).toLocaleString()}
          change="+15.1%"
          changeType="positive"
          icon={Star}
          iconColor="#00D193"
          description="loyalty points"
        />
      </div>

      {/* Chart */}
      <div className="mb-8">
        <RevenueChart data={revenueData} />
      </div>

      {/* Recent transactions */}
      <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl overflow-hidden">
        <div className="px-6 py-4 border-b border-[#1E4030] flex items-center justify-between">
          <div>
            <h3 className="font-semibold text-white font-grotesk">Recent Transactions</h3>
            <p className="text-xs text-gray-400 mt-0.5">Latest activity at your business</p>
          </div>
          <a
            href="/dashboard/transactions"
            className="text-xs text-[#00B488] hover:text-[#00D193] transition-colors"
          >
            View all →
          </a>
        </div>
        <div className="divide-y divide-[#1A3828]">
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
                    txn.is_debit ? "text-red-400" : "text-[#00D193]"
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
      <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl h-72 animate-pulse mb-8" />
      <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl h-64 animate-pulse" />
    </>
  );
}

export default function DashboardPage() {
  return (
    <div className="animate-fadeIn">
      {/* Page header */}
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold font-grotesk text-white">Overview</h1>
          <p className="text-gray-400 text-sm mt-1">
            {new Date().toLocaleDateString("en-US", {
              weekday: "long",
              year: "numeric",
              month: "long",
              day: "numeric",
            })}
          </p>
        </div>
        <div className="flex items-center gap-2 text-xs text-[#00D193] bg-[#00B488]/10 border border-[#00B488]/20 rounded-full px-3 py-1.5">
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
