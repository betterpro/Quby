import { LucideIcon } from "lucide-react";

interface StatCardProps {
  title: string;
  value: string;
  change?: string;
  changeType?: "positive" | "negative" | "neutral";
  icon: LucideIcon;
  iconColor?: string;
  description?: string;
}

export function StatCard({
  title,
  value,
  change,
  changeType = "neutral",
  icon: Icon,
  iconColor = "#00B488",
  description,
}: StatCardProps) {
  const changeColors = {
    positive: "text-[#00D193]",
    negative: "text-red-400",
    neutral: "text-gray-400",
  };

  return (
    <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl p-5 hover:border-[#00B488]/30 transition-colors">
      <div className="flex items-start justify-between mb-4">
        <div
          className="w-10 h-10 rounded-lg flex items-center justify-center"
          style={{ backgroundColor: `${iconColor}20` }}
        >
          <Icon size={20} style={{ color: iconColor }} />
        </div>
        {change && (
          <span className={`text-xs font-medium ${changeColors[changeType]}`}>
            {change}
          </span>
        )}
      </div>
      <div>
        <p className="text-2xl font-bold text-white mb-1">{value}</p>
        <p className="text-sm text-gray-400">{title}</p>
        {description && (
          <p className="text-xs text-gray-500 mt-1">{description}</p>
        )}
      </div>
    </div>
  );
}

export function StatCardSkeleton() {
  return (
    <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl p-5 animate-pulse">
      <div className="flex items-start justify-between mb-4">
        <div className="w-10 h-10 rounded-lg bg-[#1E4030]" />
        <div className="w-12 h-4 rounded bg-[#1E4030]" />
      </div>
      <div>
        <div className="w-24 h-7 rounded bg-[#1E4030] mb-2" />
        <div className="w-32 h-4 rounded bg-[#1E4030]" />
      </div>
    </div>
  );
}
