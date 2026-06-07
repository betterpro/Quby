import { Suspense } from "react";
import { createAdminClient } from "@/lib/supabase/server";
import { formatCurrency, formatDate, MOCK_TRANSACTIONS } from "@/lib/utils";
import { ArrowUpRight, ArrowDownLeft, Search, Filter } from "lucide-react";

async function TransactionsList() {
  let transactions = MOCK_TRANSACTIONS;

  try {
    const supabase = createAdminClient();
    const { data } = await supabase
      .from("transactions")
      .select("*")
      .order("date", { ascending: false })
      .limit(100);
    if (data && data.length > 0) transactions = data;
  } catch {
    // Use mock data
  }

  const totalDebits = transactions
    .filter((t) => t.is_debit)
    .reduce((sum, t) => sum + Math.abs(t.amount), 0);
  const totalCredits = transactions
    .filter((t) => !t.is_debit)
    .reduce((sum, t) => sum + Math.abs(t.amount), 0);

  return (
    <>
      {/* Summary cards */}
      <div className="grid grid-cols-3 gap-4 mb-6">
        <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl p-4">
          <p className="text-xs text-gray-400 mb-1">Total Volume</p>
          <p className="text-xl font-bold text-white font-grotesk">
            {formatCurrency(totalDebits + totalCredits)}
          </p>
        </div>
        <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl p-4">
          <p className="text-xs text-gray-400 mb-1">Revenue Collected</p>
          <p className="text-xl font-bold text-[#00D193] font-grotesk">
            {formatCurrency(totalDebits)}
          </p>
        </div>
        <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl p-4">
          <p className="text-xs text-gray-400 mb-1">Points & Credits</p>
          <p className="text-xl font-bold text-[#F6B43C] font-grotesk">
            {formatCurrency(totalCredits)}
          </p>
        </div>
      </div>

      {/* Table */}
      <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl overflow-hidden">
        <div className="px-6 py-4 border-b border-[#1E4030] flex items-center justify-between">
          <h3 className="font-semibold text-white font-grotesk">All Transactions</h3>
          <span className="text-xs text-gray-500 bg-[#1A3828] rounded-full px-2.5 py-1">
            {transactions.length} total
          </span>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="text-xs text-gray-500 border-b border-[#1A3828]">
                <th className="text-left px-6 py-3 font-medium">Transaction</th>
                <th className="text-left px-6 py-3 font-medium">Type</th>
                <th className="text-left px-6 py-3 font-medium">Date</th>
                <th className="text-right px-6 py-3 font-medium">Amount</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#1A3828]">
              {transactions.map((txn) => (
                <tr key={txn.id} className="table-row-hover">
                  <td className="px-6 py-3.5">
                    <div className="flex items-center gap-3">
                      <div
                        className="w-8 h-8 rounded-lg flex items-center justify-center text-sm flex-shrink-0"
                        style={{ backgroundColor: `${txn.icon_color || "#00B488"}20` }}
                      >
                        {txn.icon || "💳"}
                      </div>
                      <div>
                        <p className="text-sm font-medium text-white">{txn.title}</p>
                        <p className="text-xs text-gray-500">{txn.subtitle}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-3.5">
                    <span
                      className={`inline-flex items-center gap-1 text-xs px-2 py-0.5 rounded-full font-medium ${
                        txn.is_debit
                          ? "bg-red-500/10 text-red-400"
                          : "bg-[#00B488]/10 text-[#00D193]"
                      }`}
                    >
                      {txn.is_debit ? (
                        <ArrowUpRight size={10} />
                      ) : (
                        <ArrowDownLeft size={10} />
                      )}
                      {txn.type || (txn.is_debit ? "Purchase" : "Credit")}
                    </span>
                  </td>
                  <td className="px-6 py-3.5 text-sm text-gray-400">
                    {formatDate(txn.date)}
                  </td>
                  <td className="px-6 py-3.5 text-right">
                    <span
                      className={`text-sm font-semibold ${
                        txn.is_debit ? "text-red-400" : "text-[#00D193]"
                      }`}
                    >
                      {txn.is_debit ? "-" : "+"}
                      {formatCurrency(txn.amount)}
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

function TransactionsSkeleton() {
  return (
    <>
      <div className="grid grid-cols-3 gap-4 mb-6">
        {[1, 2, 3].map((i) => (
          <div key={i} className="bg-[#0F2518] border border-[#1E4030] rounded-xl p-4 animate-pulse">
            <div className="w-20 h-3 bg-[#1E4030] rounded mb-2" />
            <div className="w-32 h-7 bg-[#1E4030] rounded" />
          </div>
        ))}
      </div>
      <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl h-96 animate-pulse" />
    </>
  );
}

export default function TransactionsPage() {
  return (
    <div className="animate-fadeIn">
      <div className="mb-8">
        <h1 className="text-2xl font-bold font-grotesk text-white">Transactions</h1>
        <p className="text-gray-400 text-sm mt-1">View and manage all transactions</p>
      </div>

      <Suspense fallback={<TransactionsSkeleton />}>
        <TransactionsList />
      </Suspense>
    </div>
  );
}
