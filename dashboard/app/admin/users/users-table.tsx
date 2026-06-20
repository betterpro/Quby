"use client";

import { useState, useTransition } from "react";
import { Pencil, Trash2 } from "lucide-react";
import { formatCurrency, formatDate, type Profile } from "@/lib/utils";
import { updateUser, deleteUser } from "./actions";

type EnrichedProfile = Profile & {
  totalSpent: number;
  joinDate: string;
};

interface Props {
  profiles: EnrichedProfile[];
}

interface FormState {
  name: string;
  handle: string;
  balance: number;
  points: number;
}

export function UsersTable({ profiles }: Props) {
  const [isPending, startTransition] = useTransition();
  const [editingProfile, setEditingProfile] = useState<EnrichedProfile | null>(null);
  const [form, setForm] = useState<FormState>({ name: "", handle: "", balance: 0, points: 0 });
  const [deletingId, setDeletingId] = useState<string | null>(null);

  function openEdit(profile: EnrichedProfile) {
    setEditingProfile(profile);
    setForm({
      name: profile.name || "",
      handle: profile.handle || "",
      balance: Number(profile.balance || 0),
      points: Number(profile.points || 0),
    });
  }

  function closeModal() {
    setEditingProfile(null);
    setForm({ name: "", handle: "", balance: 0, points: 0 });
  }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!editingProfile) return;

    startTransition(async () => {
      await updateUser(editingProfile.id, {
        name: form.name,
        handle: form.handle || undefined,
        balance: form.balance,
        points: form.points,
      });
      closeModal();
    });
  }

  function handleDelete(id: string) {
    startTransition(async () => {
      await deleteUser(id);
      setDeletingId(null);
    });
  }

  function setField<K extends keyof FormState>(field: K, value: FormState[K]) {
    setForm((prev) => ({ ...prev, [field]: value }));
  }

  return (
    <>
      <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl overflow-hidden">
        <div className="px-6 py-4 border-b border-brand-ink-surface-2">
          <h3 className="font-semibold text-white font-display">All Users</h3>
          <p className="text-xs text-gray-400 mt-0.5">
            {profiles.length} registered QubyPay wallet users
          </p>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="text-xs text-gray-500 border-b border-brand-ink-line">
                <th className="text-left px-6 py-3 font-medium">User</th>
                <th className="text-left px-6 py-3 font-medium">Balance</th>
                <th className="text-left px-6 py-3 font-medium">Points</th>
                <th className="text-left px-6 py-3 font-medium">Total Spent</th>
                <th className="text-left px-6 py-3 font-medium">Theme</th>
                <th className="text-left px-6 py-3 font-medium">Joined</th>
                <th className="text-right px-6 py-3 font-medium">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-brand-ink-line">
              {profiles.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-6 py-12 text-center text-sm text-gray-500">
                    No users yet
                  </td>
                </tr>
              ) : (
                profiles.map((profile) => (
                  <tr key={profile.id} className="table-row-hover">
                    <td className="px-6 py-3.5">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-gradient-to-br from-[#00B488] to-[#6366F1] flex items-center justify-center text-sm font-bold text-white flex-shrink-0">
                          {(profile.name || "U").charAt(0)}
                        </div>
                        <div>
                          <p className="text-sm font-medium text-white">
                            {profile.name || "Anonymous"}
                          </p>
                          <p className="text-xs text-gray-500">
                            {profile.handle || `@user_${profile.id?.slice(0, 6)}`}
                          </p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-3.5">
                      <span className="text-sm font-semibold text-brand-green-bright">
                        {formatCurrency(profile.balance || 0)}
                      </span>
                    </td>
                    <td className="px-6 py-3.5">
                      <span className="text-sm text-brand-honey">
                        {(profile.points || 0).toLocaleString()} pts
                      </span>
                    </td>
                    <td className="px-6 py-3.5">
                      <span className="text-sm text-white">
                        {formatCurrency(profile.totalSpent)}
                      </span>
                    </td>
                    <td className="px-6 py-3.5">
                      <span
                        className={`text-xs px-2 py-0.5 rounded-full ${
                          profile.is_dark
                            ? "bg-gray-800 text-gray-300"
                            : "bg-yellow-500/10 text-yellow-300"
                        }`}
                      >
                        {profile.is_dark ? "Dark" : "Light"}
                      </span>
                    </td>
                    <td className="px-6 py-3.5 text-sm text-gray-400">
                      {profile.joinDate ? formatDate(profile.joinDate) : "—"}
                    </td>
                    <td className="px-6 py-3.5">
                      <div className="flex items-center justify-end gap-1">
                        {deletingId === profile.id ? (
                          <div className="flex items-center gap-2">
                            <span className="text-xs text-gray-400 whitespace-nowrap">
                              Delete user and all data?
                            </span>
                            <button
                              onClick={() => setDeletingId(null)}
                              className="border border-[#1E3040] hover:bg-[#1E3040] text-gray-300 text-xs px-2 py-1 rounded-lg transition-colors"
                            >
                              Cancel
                            </button>
                            <button
                              disabled={isPending}
                              onClick={() => handleDelete(profile.id)}
                              className="bg-red-500/15 hover:bg-red-500/25 text-red-400 text-xs px-2 py-1 rounded-lg transition-colors disabled:opacity-50"
                            >
                              Confirm
                            </button>
                          </div>
                        ) : (
                          <>
                            <button
                              onClick={() => openEdit(profile)}
                              className="text-gray-400 hover:text-white hover:bg-[#1E3040] p-1.5 rounded-lg transition-colors"
                              title="Edit"
                            >
                              <Pencil size={14} />
                            </button>
                            <button
                              onClick={() => setDeletingId(profile.id)}
                              className="text-red-400 hover:text-red-300 hover:bg-red-500/10 p-1.5 rounded-lg transition-colors"
                              title="Delete"
                            >
                              <Trash2 size={14} />
                            </button>
                          </>
                        )}
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {editingProfile && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-[#0A1018] border border-[#1E3040] rounded-2xl w-full max-w-md p-6">
            <h2 className="text-lg font-semibold text-white font-display mb-5">Edit User</h2>

            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-xs font-medium text-gray-400 mb-1.5">Name</label>
                <input
                  type="text"
                  value={form.name}
                  onChange={(e) => setField("name", e.target.value)}
                  placeholder="Full name"
                  className="w-full bg-[#0D1B2A] border border-[#1E3040] rounded-lg px-3 py-2 text-sm text-white placeholder-gray-600 focus:outline-none focus:border-[#00B488]"
                />
              </div>

              <div>
                <label className="block text-xs font-medium text-gray-400 mb-1.5">Handle</label>
                <input
                  type="text"
                  value={form.handle}
                  onChange={(e) => setField("handle", e.target.value)}
                  placeholder="@handle"
                  className="w-full bg-[#0D1B2A] border border-[#1E3040] rounded-lg px-3 py-2 text-sm text-white placeholder-gray-600 focus:outline-none focus:border-[#00B488]"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-medium text-gray-400 mb-1.5">
                    Balance ($)
                  </label>
                  <input
                    type="number"
                    step="0.01"
                    min="0"
                    value={form.balance}
                    onChange={(e) => setField("balance", parseFloat(e.target.value) || 0)}
                    className="w-full bg-[#0D1B2A] border border-[#1E3040] rounded-lg px-3 py-2 text-sm text-white placeholder-gray-600 focus:outline-none focus:border-[#00B488]"
                  />
                </div>

                <div>
                  <label className="block text-xs font-medium text-gray-400 mb-1.5">Points</label>
                  <input
                    type="number"
                    step="1"
                    min="0"
                    value={form.points}
                    onChange={(e) => setField("points", parseInt(e.target.value) || 0)}
                    className="w-full bg-[#0D1B2A] border border-[#1E3040] rounded-lg px-3 py-2 text-sm text-white placeholder-gray-600 focus:outline-none focus:border-[#00B488]"
                  />
                </div>
              </div>

              <div className="flex gap-3 pt-2">
                <button
                  type="button"
                  onClick={closeModal}
                  className="flex-1 border border-[#1E3040] hover:bg-[#1E3040] text-gray-300 text-sm px-4 py-2 rounded-lg transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isPending}
                  className="flex-1 bg-[#00B488] hover:bg-[#00997A] text-[#04261C] font-semibold text-sm px-4 py-2 rounded-lg transition-colors disabled:opacity-50"
                >
                  {isPending ? "Saving…" : "Save Changes"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  );
}
