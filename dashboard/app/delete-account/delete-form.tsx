"use client";

import { useActionState } from "react";
import { requestAccountDeletion, type DeleteResult } from "./actions";
import { AlertTriangle, Trash2, CheckCircle } from "lucide-react";

const initialState: DeleteResult | null = null;

export function DeleteForm() {
  const [result, formAction, isPending] = useActionState<DeleteResult | null, FormData>(
    async (_prev, formData) => requestAccountDeletion(formData),
    initialState
  );

  if (result && "success" in result) {
    return (
      <div className="rounded-2xl border border-brand-green/30 bg-brand-green/5 p-8 text-center">
        <CheckCircle className="mx-auto mb-4 text-brand-green-bright" size={40} />
        <h2 className="text-xl font-semibold font-display text-white mb-2">
          Request Received
        </h2>
        <p className="text-gray-400 text-sm leading-relaxed">
          If an account with that email exists, it has been permanently deleted
          along with all associated data. This action cannot be undone.
        </p>
      </div>
    );
  }

  return (
    <form action={formAction} className="space-y-5">
      {result && "error" in result && (
        <div className="flex items-start gap-3 rounded-xl bg-red-500/10 border border-red-500/20 px-4 py-3 text-sm text-red-400">
          <AlertTriangle size={16} className="mt-0.5 flex-shrink-0" />
          {result.error}
        </div>
      )}

      <div>
        <label className="block text-sm font-medium text-gray-300 mb-2">
          Email address
        </label>
        <input
          type="email"
          name="email"
          required
          placeholder="you@example.com"
          className="w-full bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl px-4 py-3 text-sm text-white placeholder-gray-600 focus:outline-none focus:border-red-500/50 transition-colors"
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-300 mb-2">
          Type <span className="font-mono text-red-400 bg-red-500/10 px-1.5 py-0.5 rounded">DELETE</span> to confirm
        </label>
        <input
          type="text"
          name="confirm"
          required
          placeholder="DELETE"
          autoComplete="off"
          className="w-full bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl px-4 py-3 text-sm text-white placeholder-gray-600 focus:outline-none focus:border-red-500/50 transition-colors font-mono"
        />
      </div>

      <button
        type="submit"
        disabled={isPending}
        className="w-full flex items-center justify-center gap-2 bg-red-500/15 hover:bg-red-500/25 border border-red-500/30 text-red-400 font-semibold text-sm px-4 py-3 rounded-xl transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
      >
        <Trash2 size={15} />
        {isPending ? "Deleting account…" : "Permanently delete my account"}
      </button>
    </form>
  );
}
