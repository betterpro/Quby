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

// Mock data for demo fallback
export const MOCK_BUSINESSES = [
  {
    id: "biz_1",
    name: "Green Leaf Cafe",
    category: "Food & Drink",
    icon: "☕",
    color: "#00B488",
    distance: "0.2 mi",
    offer: "10% off all drinks",
    address: "123 Main St",
  },
  {
    id: "biz_2",
    name: "Urban Cuts",
    category: "Beauty",
    icon: "✂️",
    color: "#F6B43C",
    distance: "0.5 mi",
    offer: "Free trim with 5 visits",
    address: "456 Oak Ave",
  },
  {
    id: "biz_3",
    name: "Tech Repair Hub",
    category: "Electronics",
    icon: "📱",
    color: "#6366F1",
    distance: "0.8 mi",
    offer: "15% off screen repairs",
    address: "789 Pine Blvd",
  },
  {
    id: "biz_4",
    name: "Sunrise Bakery",
    category: "Food & Drink",
    icon: "🥐",
    color: "#F59E0B",
    distance: "1.1 mi",
    offer: "Buy 5 get 1 free",
    address: "321 Elm St",
  },
  {
    id: "biz_5",
    name: "FitZone Gym",
    category: "Health",
    icon: "💪",
    color: "#EF4444",
    distance: "1.3 mi",
    offer: "Free first class",
    address: "654 Maple Dr",
  },
];

export const MOCK_TRANSACTIONS = [
  {
    id: "txn_1",
    title: "Green Leaf Cafe",
    subtitle: "Coffee & Pastry",
    amount: -12.5,
    is_debit: true,
    date: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(),
    type: "purchase",
    business_id: "biz_1",
    icon: "☕",
    icon_color: "#00B488",
    user_id: "user_1",
  },
  {
    id: "txn_2",
    title: "Urban Cuts",
    subtitle: "Haircut",
    amount: -35.0,
    is_debit: true,
    date: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(),
    type: "purchase",
    business_id: "biz_2",
    icon: "✂️",
    icon_color: "#F6B43C",
    user_id: "user_2",
  },
  {
    id: "txn_3",
    title: "Points Earned",
    subtitle: "Loyalty reward",
    amount: 50,
    is_debit: false,
    date: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(),
    type: "points",
    business_id: "biz_1",
    icon: "⭐",
    icon_color: "#F6B43C",
    user_id: "user_1",
  },
  {
    id: "txn_4",
    title: "Tech Repair Hub",
    subtitle: "Screen replacement",
    amount: -89.99,
    is_debit: true,
    date: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000).toISOString(),
    type: "purchase",
    business_id: "biz_3",
    icon: "📱",
    icon_color: "#6366F1",
    user_id: "user_3",
  },
  {
    id: "txn_5",
    title: "Sunrise Bakery",
    subtitle: "Morning pastries",
    amount: -18.75,
    is_debit: true,
    date: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000).toISOString(),
    type: "purchase",
    business_id: "biz_4",
    icon: "🥐",
    icon_color: "#F59E0B",
    user_id: "user_2",
  },
  {
    id: "txn_6",
    title: "Top-up",
    subtitle: "Wallet credit",
    amount: 100.0,
    is_debit: false,
    date: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000).toISOString(),
    type: "topup",
    business_id: null,
    icon: "💳",
    icon_color: "#00B488",
    user_id: "user_1",
  },
  {
    id: "txn_7",
    title: "FitZone Gym",
    subtitle: "Monthly membership",
    amount: -49.99,
    is_debit: true,
    date: new Date(Date.now() - 6 * 24 * 60 * 60 * 1000).toISOString(),
    type: "purchase",
    business_id: "biz_5",
    icon: "💪",
    icon_color: "#EF4444",
    user_id: "user_4",
  },
];

export const MOCK_PROFILES = [
  {
    id: "user_1",
    name: "Alex Johnson",
    handle: "@alexj",
    balance: 245.5,
    points: 1200,
    is_dark: true,
    created_at: "2024-01-15T10:00:00Z",
  },
  {
    id: "user_2",
    name: "Maria Garcia",
    handle: "@mariag",
    balance: 89.25,
    points: 450,
    is_dark: false,
    created_at: "2024-02-20T14:30:00Z",
  },
  {
    id: "user_3",
    name: "Sam Chen",
    handle: "@samchen",
    balance: 312.0,
    points: 2100,
    is_dark: true,
    created_at: "2024-01-08T09:15:00Z",
  },
  {
    id: "user_4",
    name: "Taylor Brown",
    handle: "@taylorb",
    balance: 56.75,
    points: 320,
    is_dark: false,
    created_at: "2024-03-01T16:45:00Z",
  },
];

export function generateRevenueData(days: number = 7) {
  const data = [];
  for (let i = days - 1; i >= 0; i--) {
    const date = new Date();
    date.setDate(date.getDate() - i);
    data.push({
      date: date.toLocaleDateString("en-US", { month: "short", day: "numeric" }),
      revenue: Math.floor(Math.random() * 5000 + 1000),
      transactions: Math.floor(Math.random() * 50 + 10),
    });
  }
  return data;
}
