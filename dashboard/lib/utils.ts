export function formatCurrency(amount: number): string {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    minimumFractionDigits: 2,
  }).format(Math.abs(amount));
}

export function formatDate(dateStr: string): string {
  return new Intl.DateTimeFormat("en-US", {
    month: "short",
    day: "numeric",
    year: "numeric",
  }).format(new Date(dateStr));
}

export function formatDateShort(dateStr: string): string {
  return new Intl.DateTimeFormat("en-US", {
    month: "short",
    day: "numeric",
  }).format(new Date(dateStr));
}

export function cn(...classes: (string | undefined | null | false)[]): string {
  return classes.filter(Boolean).join(" ");
}

export type Transaction = {
  id: string;
  title: string;
  subtitle: string;
  amount: number;
  is_debit: boolean;
  date: string;
  type: string;
  business_id: string | null;
  icon?: string | null;
  icon_color?: string | null;
  user_id?: string;
};

export type Business = {
  id: string;
  name: string;
  category: string;
  icon: string;
  color: string;
  distance: string;
  offer?: string | null;
  address?: string | null;
  latitude?: number | null;
  longitude?: number | null;
  logo_url?: string | null;
};

export type Profile = {
  id: string;
  name: string;
  handle?: string | null;
  balance: number;
  points: number;
  is_dark: boolean;
  created_at?: string;
};

export function buildRevenueData(transactions: Transaction[], days = 7) {
  const data = [];

  for (let i = days - 1; i >= 0; i--) {
    const date = new Date();
    date.setDate(date.getDate() - i);
    date.setHours(0, 0, 0, 0);

    const nextDay = new Date(date);
    nextDay.setDate(nextDay.getDate() + 1);

    const dayTxns = transactions.filter((t) => {
      const txnDate = new Date(t.date);
      return txnDate >= date && txnDate < nextDay;
    });

    data.push({
      date: date.toLocaleDateString("en-US", { month: "short", day: "numeric" }),
      revenue: dayTxns
        .filter((t) => t.is_debit)
        .reduce((sum, t) => sum + Math.abs(Number(t.amount)), 0),
      transactions: dayTxns.length,
    });
  }

  return data;
}

export function buildPaymentQrPayload(
  businessId: string,
  amount?: number | null
): string {
  const params = new URLSearchParams({ business: businessId });
  if (amount != null && amount > 0) {
    params.set("amount", amount.toFixed(2));
  }
  return `quby://pay?${params.toString()}`;
}

export function paymentQrImageUrl(payload: string, size = 220): string {
  return `https://api.qrserver.com/v1/create-qr-code/?size=${size}x${size}&data=${encodeURIComponent(payload)}`;
}
