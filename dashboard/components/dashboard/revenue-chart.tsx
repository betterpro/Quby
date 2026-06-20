"use client";

import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Area,
  AreaChart,
} from "recharts";

interface RevenueDataPoint {
  date: string;
  revenue: number;
  transactions: number;
}

interface RevenueChartProps {
  data: RevenueDataPoint[];
}

function CustomTooltip({ active, payload, label }: any) {
  if (active && payload && payload.length) {
    return (
      <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-lg p-3 shadow-xl">
        <p className="text-xs text-gray-400 mb-2">{label}</p>
        {payload.map((entry: any) => (
          <div key={entry.name} className="flex items-center gap-2 text-sm">
            <div
              className="w-2 h-2 rounded-full"
              style={{ backgroundColor: entry.color }}
            />
            <span className="text-gray-300">{entry.name}:</span>
            <span className="text-white font-semibold">
              {entry.name === "Revenue"
                ? `$${entry.value.toLocaleString()}`
                : entry.value}
            </span>
          </div>
        ))}
      </div>
    );
  }
  return null;
}

export function RevenueChart({ data }: RevenueChartProps) {
  return (
    <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-6">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h3 className="font-semibold text-white font-display">Revenue Overview</h3>
          <p className="text-sm text-gray-400 mt-0.5">Last 7 days</p>
        </div>
        <div className="flex items-center gap-4 text-xs text-gray-400">
          <span className="flex items-center gap-1.5">
            <span className="w-3 h-0.5 bg-[#00D193] rounded inline-block" />
            Revenue
          </span>
          <span className="flex items-center gap-1.5">
            <span className="w-3 h-0.5 bg-brand-honey rounded inline-block" />
            Transactions
          </span>
        </div>
      </div>
      <ResponsiveContainer width="100%" height={240}>
        <AreaChart data={data} margin={{ top: 5, right: 5, left: -10, bottom: 5 }}>
          <defs>
            <linearGradient id="revenueGradient" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor="#00D193" stopOpacity={0.2} />
              <stop offset="95%" stopColor="#00D193" stopOpacity={0} />
            </linearGradient>
            <linearGradient id="txnGradient" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor="#E2911F" stopOpacity={0.15} />
              <stop offset="95%" stopColor="#E2911F" stopOpacity={0} />
            </linearGradient>
          </defs>
          <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.10)" vertical={false} />
          <XAxis
            dataKey="date"
            tick={{ fill: "#6B7280", fontSize: 11 }}
            axisLine={false}
            tickLine={false}
          />
          <YAxis
            yAxisId="revenue"
            tick={{ fill: "#6B7280", fontSize: 11 }}
            axisLine={false}
            tickLine={false}
            tickFormatter={(v) => `$${(v / 1000).toFixed(0)}k`}
          />
          <YAxis
            yAxisId="transactions"
            orientation="right"
            tick={{ fill: "#6B7280", fontSize: 11 }}
            axisLine={false}
            tickLine={false}
          />
          <Tooltip content={<CustomTooltip />} />
          <Area
            yAxisId="revenue"
            type="monotone"
            dataKey="revenue"
            name="Revenue"
            stroke="#00D193"
            strokeWidth={2}
            fill="url(#revenueGradient)"
            dot={false}
            activeDot={{ r: 4, fill: "#00D193" }}
          />
          <Area
            yAxisId="transactions"
            type="monotone"
            dataKey="transactions"
            name="Transactions"
            stroke="#E2911F"
            strokeWidth={2}
            fill="url(#txnGradient)"
            dot={false}
            activeDot={{ r: 4, fill: "#E2911F" }}
          />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  );
}
