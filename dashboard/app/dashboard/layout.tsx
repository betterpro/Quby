import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { DashboardSidebar } from "@/components/dashboard/sidebar";

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login");
  }

  return (
    <div className="flex min-h-screen bg-brand-ink-bg">
      <DashboardSidebar />
      <main className="flex-1 ml-64 p-8 min-h-screen">
        <div className="max-w-6xl mx-auto">{children}</div>
      </main>
    </div>
  );
}
