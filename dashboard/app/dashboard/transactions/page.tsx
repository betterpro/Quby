import { Suspense } from "react";
import { createAdminClient } from "@/lib/supabase/server";
import { formatCurrency, formatDate, type Transaction } from "@/lib/utils";
import { ArrowUpRight, ArrowDownLeft } from "lucide-react";

async function fetchTransactions(): Promise<Transaction[]> {
  try {
    const supabase = createAdminClient();
    const { data } = await supabase
      .from("transactions")
      .select("*")
      .order("date", { ascending: false })
      .limit(100);
    return (data as Transaction[]) ?? [];
  } catch {
    return [];
  }
}

async function TransactionsList() {
  const transactions = await fetchTransactions();

  const totalDebits = transactions
    .filter((t) => t.is_debit)
    .reduce((sum, t) => sum + Math.abs(Number(t.amount)), 0);
  const totalCredits = transactions
    .filter((t) => !t.is_debit)
    .reduce((sum, t) => sum + Math.abs(Number(t.amount)), 0);

  return (
    <>
      <div className="grid grid-cols-3 gap-4 mb-6">
        <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-4">
          <p className="text-xs text-gray-400 mb-1">Total Volume</p>
          <p className="text-xl font-bold text-white font-display">
            {formatCurrency(totalDebits + totalCredits)}
          </p>
        </div>
        <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-4">
          <p className="text-xs text-gray-400 mb-1">Revenue Collected</p>
          <p className="text-xl font-bold text-brand-green-bright font-display">
            {formatCurrency(totalDebits)}
          </p>
        </div>
        <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-4">
          <p className="text-xs text-gray-400 mb-1">Points & Credits</p>
          <p className="text-xl font-bold text-brand-honey font-display">
            {formatCurrency(totalCredits)}
          </p>
        </div>
      </div>

      <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl overflow-hidden">
        <div className="px-6 py-4 border-b border-brand-ink-surface-2 flex items-center justify-between">
          <h3 className="font-semibold text-white font-display">All Transactions</h3>
          <span className="text-xs text-gray-500 bg-brand-ink-surface-2 rounded-full px-2.5 py-1">
            {transactions.length} total
          </span>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="text-xs text-gray-500 border-b border-brand-ink-line">
                <th className="text-left px-6 py-3 font-medium">Transaction</th>
                <th className="text-left px-6 py-3 font-medium">Type</th>
                <th className="text-left px-6 py-3 font-medium">Date</th>
                <th className="text-right px-6 py-3 font-medium">Amount</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-brand-ink-line">
              {transactions.length === 0 ? (
                <tr>
                  <td colSpan={4} className="px-6 py-12 text-center text-sm text-gray-500">
                    No transactions yet
                  </td>
                </tr>
              ) : (
                transactions.map((txn) => (
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
                            : "bg-brand-green/10 text-brand-green-bright"
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
                          txn.is_debit ? "text-red-400" : "text-brand-green-bright"
                        }`}
                      >
                        {txn.is_debit ? "-" : "+"}
                        {formatCurrency(txn.amount)}
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

function TransactionsSkeleton() {
  return (
    <>
      <div className="grid grid-cols-3 gap-4 mb-6">
        {[1, 2, 3].map((i) => (
          <div key={i} className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-4 animate-pulse">
            <div className="w-20 h-3 bg-brand-ink-surface-2 rounded mb-2" />
            <div className="w-32 h-7 bg-brand-ink-surface-2 rounded" />
          </div>
        ))}
      </div>
      <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl h-96 animate-pulse" />
    </>
  );
}

export default function TransactionsPage() {
  return (
    <div className="animate-fadeIn">
      <div className="mb-8">
        <h1 className="text-2xl font-bold font-display text-white">Transactions</h1>
        <p className="text-gray-400 text-sm mt-1">View and manage all transactions</p>
      </div>

      <Suspense fallback={<TransactionsSkeleton />}>
        <TransactionsList />
      </Suspense>
    </div>
  );
}
