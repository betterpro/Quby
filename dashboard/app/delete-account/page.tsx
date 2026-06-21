import Link from "next/link";
import { Logo } from "@/components/logo";
import { AlertTriangle, User, CreditCard, Star, Users, MessageSquare } from "lucide-react";
import { DeleteForm } from "./delete-form";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Delete Account — Quby",
  description: "Permanently delete your Quby account and all associated data.",
};

const DATA_DELETED = [
  { icon: User, label: "Profile", desc: "Your name, handle, and profile photo" },
  { icon: CreditCard, label: "Wallet & Transactions", desc: "Balance, payment history, and transaction records" },
  { icon: Star, label: "Rewards & Loyalty", desc: "Points, stamp cards, and earned perks" },
  { icon: Users, label: "Groups & Splits", desc: "Bill splitting groups and shared expenses" },
  { icon: MessageSquare, label: "Business Data", desc: "Any business accounts you own or manage" },
];

export default function DeleteAccountPage() {
  return (
    <div className="min-h-screen bg-brand-ink-bg text-white">
      {/* Nav */}
      <nav className="border-b border-brand-ink-line bg-brand-ink-bg/80 backdrop-blur-md sticky top-0 z-50">
        <div className="max-w-2xl mx-auto px-6 py-4 flex items-center justify-between">
          <Link href="/"><Logo size="md" /></Link>
          <Link href="/privacy" className="text-sm text-gray-400 hover:text-white transition-colors">
            Privacy Policy
          </Link>
        </div>
      </nav>

      <main className="max-w-2xl mx-auto px-6 py-16">
        {/* Header */}
        <div className="mb-10">
          <div className="inline-flex items-center gap-2 bg-red-500/10 border border-red-500/20 rounded-full px-3 py-1.5 mb-6 text-sm text-red-400">
            <AlertTriangle size={13} />
            Permanent action
          </div>
          <h1 className="text-4xl font-bold font-display mb-4">Delete Your Account</h1>
          <p className="text-gray-400 leading-relaxed">
            Deleting your account is permanent and cannot be undone. All your data
            will be removed from our systems immediately.
          </p>
        </div>

        {/* What gets deleted */}
        <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-2xl p-6 mb-8">
          <h2 className="text-sm font-semibold text-gray-400 uppercase tracking-wider mb-5">
            What will be deleted
          </h2>
          <div className="space-y-4">
            {DATA_DELETED.map(({ icon: Icon, label, desc }) => (
              <div key={label} className="flex items-start gap-3">
                <div className="w-8 h-8 rounded-lg bg-red-500/10 flex items-center justify-center flex-shrink-0">
                  <Icon size={15} className="text-red-400" />
                </div>
                <div>
                  <p className="text-sm font-medium text-white">{label}</p>
                  <p className="text-xs text-gray-500 mt-0.5">{desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Alternative */}
        <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-2xl p-5 mb-8">
          <p className="text-sm text-gray-400">
            <span className="text-white font-medium">Not ready to delete?</span> You can also
            simply stop using the app. Your data stays private and is never sold.
            If you have concerns, email us at{" "}
            <a href="mailto:privacy@quby.app" className="text-brand-green-bright hover:underline">
              privacy@quby.app
            </a>
          </p>
        </div>

        {/* Delete form */}
        <div className="bg-brand-ink-surface border border-red-500/20 rounded-2xl p-6">
          <h2 className="text-lg font-semibold font-display text-white mb-1">
            Confirm deletion
          </h2>
          <p className="text-sm text-gray-500 mb-6">
            Enter the email address associated with your Quby account.
          </p>
          <DeleteForm />
        </div>

        {/* Footer note */}
        <p className="text-center text-xs text-gray-600 mt-8">
          Need help?{" "}
          <a href="mailto:support@quby.app" className="text-gray-500 hover:text-white transition-colors">
            Contact support
          </a>
        </p>
      </main>
    </div>
  );
}
