"use client";

import { useState, useTransition } from "react";
import { Pencil, Trash2, Plus } from "lucide-react";
import { BusinessLogoImage } from "@/components/business-logo";
import { formatCurrency, type Business } from "@/lib/utils";
import { PendingSection } from "./pending-section";
import { createBusiness, updateBusiness, deleteBusiness } from "./actions";

type EnrichedBusiness = Business & {
  revenue: number;
  txnCount: number;
  status: string;
};

interface Props {
  businesses: EnrichedBusiness[];
  pendingRequests: any[];
}

interface FormState {
  name: string;
  category: string;
  icon: string;
  color: string;
  address: string;
  offer: string;
  distance: string;
  status: string;
}

const emptyForm: FormState = {
  name: "",
  category: "",
  icon: "🏪",
  color: "#00B488",
  address: "",
  offer: "",
  distance: "",
  status: "active",
};

export function BusinessesTable({ businesses, pendingRequests }: Props) {
  const [isPending, startTransition] = useTransition();
  const [showModal, setShowModal] = useState(false);
  const [editingBusiness, setEditingBusiness] = useState<EnrichedBusiness | null>(null);
  const [form, setForm] = useState<FormState>(emptyForm);
  const [deletingId, setDeletingId] = useState<string | null>(null);

  function openCreate() {
    setEditingBusiness(null);
    setForm(emptyForm);
    setShowModal(true);
  }

  function openEdit(biz: EnrichedBusiness) {
    setEditingBusiness(biz);
    setForm({
      name: biz.name || "",
      category: biz.category || "",
      icon: biz.icon || "🏪",
      color: biz.color || "#00B488",
      address: biz.address || "",
      offer: biz.offer || "",
      distance: biz.distance || "",
      status: biz.status || "active",
    });
    setShowModal(true);
  }

  function closeModal() {
    setShowModal(false);
    setEditingBusiness(null);
    setForm(emptyForm);
  }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const data = {
      name: form.name,
      category: form.category,
      icon: form.icon,
      color: form.color,
      address: form.address || undefined,
      offer: form.offer || undefined,
      distance: form.distance || undefined,
      status: form.status,
    };

    startTransition(async () => {
      if (editingBusiness) {
        await updateBusiness(editingBusiness.id, data);
      } else {
        await createBusiness(data);
      }
      closeModal();
    });
  }

  function handleDelete(id: string) {
    startTransition(async () => {
      await deleteBusiness(id);
      setDeletingId(null);
    });
  }

  function setField(field: keyof FormState, value: string) {
    setForm((prev) => ({ ...prev, [field]: value }));
  }

  return (
    <>
      <PendingSection requests={pendingRequests} />

      <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl overflow-hidden">
        <div className="px-6 py-4 border-b border-brand-ink-surface-2 flex items-center justify-between">
          <div>
            <h3 className="font-semibold text-white font-display">All Businesses</h3>
            <p className="text-xs text-gray-400 mt-0.5">
              {businesses.length} businesses on the QubyPay platform
            </p>
          </div>
          <button
            onClick={openCreate}
            className="flex items-center gap-2 bg-[#00B488] hover:bg-[#00997A] text-[#04261C] font-semibold text-sm px-4 py-2 rounded-lg transition-colors"
          >
            <Plus size={15} />
            Add Business
          </button>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="text-xs text-gray-500 border-b border-brand-ink-line">
                <th className="text-left px-6 py-3 font-medium">Business</th>
                <th className="text-left px-6 py-3 font-medium">Category</th>
                <th className="text-left px-6 py-3 font-medium">Offer</th>
                <th className="text-left px-6 py-3 font-medium">Transactions</th>
                <th className="text-left px-6 py-3 font-medium">Status</th>
                <th className="text-right px-6 py-3 font-medium">Revenue</th>
                <th className="text-right px-6 py-3 font-medium">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-brand-ink-line">
              {businesses.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-6 py-12 text-center text-sm text-gray-500">
                    No businesses yet
                  </td>
                </tr>
              ) : (
                businesses.map((biz) => (
                  <tr key={biz.id} className="table-row-hover">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div
                          className="w-9 h-9 rounded-xl flex items-center justify-center text-lg flex-shrink-0 overflow-hidden"
                          style={{ backgroundColor: `${biz.color || "#00B488"}20` }}
                        >
                          {biz.logo_url ? (
                            <BusinessLogoImage
                              logoUrl={biz.logo_url}
                              className="w-full h-full object-cover"
                              fallback={<span>{biz.icon || "🏪"}</span>}
                            />
                          ) : (
                            biz.icon || "🏪"
                          )}
                        </div>
                        <div>
                          <p className="text-sm font-medium text-white">{biz.name}</p>
                          <p className="text-xs text-gray-500">{biz.address || "—"}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <span className="text-xs bg-brand-ink-surface-2 text-gray-300 px-2 py-1 rounded-full">
                        {biz.category}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-400 max-w-[180px] truncate">
                      {biz.offer || "—"}
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-300">{biz.txnCount}</td>
                    <td className="px-6 py-4">
                      {biz.status === "active" ? (
                        <span className="inline-flex items-center gap-1.5 text-xs text-brand-green-bright bg-brand-green/10 px-2 py-0.5 rounded-full">
                          <span className="w-1.5 h-1.5 rounded-full bg-[#00D193]" />
                          Active
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1.5 text-xs text-gray-400 bg-gray-500/10 px-2 py-0.5 rounded-full">
                          <span className="w-1.5 h-1.5 rounded-full bg-gray-500" />
                          Inactive
                        </span>
                      )}
                    </td>
                    <td className="px-6 py-4 text-right">
                      <span className="text-sm font-semibold text-white">
                        {formatCurrency(biz.revenue)}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center justify-end gap-1">
                        {deletingId === biz.id ? (
                          <div className="flex items-center gap-2">
                            <span className="text-xs text-gray-400 whitespace-nowrap">Delete?</span>
                            <button
                              onClick={() => setDeletingId(null)}
                              className="border border-[#1E3040] hover:bg-[#1E3040] text-gray-300 text-xs px-2 py-1 rounded-lg transition-colors"
                            >
                              Cancel
                            </button>
                            <button
                              disabled={isPending}
                              onClick={() => handleDelete(biz.id)}
                              className="bg-red-500/15 hover:bg-red-500/25 text-red-400 text-xs px-2 py-1 rounded-lg transition-colors disabled:opacity-50"
                            >
                              Confirm
                            </button>
                          </div>
                        ) : (
                          <>
                            <button
                              onClick={() => openEdit(biz)}
                              className="text-gray-400 hover:text-white hover:bg-[#1E3040] p-1.5 rounded-lg transition-colors"
                              title="Edit"
                            >
                              <Pencil size={14} />
                            </button>
                            <button
                              onClick={() => setDeletingId(biz.id)}
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

      {showModal && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-[#0A1018] border border-[#1E3040] rounded-2xl w-full max-w-md p-6">
            <h2 className="text-lg font-semibold text-white font-display mb-5">
              {editingBusiness ? "Edit Business" : "Add Business"}
            </h2>

            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="col-span-2">
                  <label className="block text-xs font-medium text-gray-400 mb-1.5">
                    Name <span className="text-red-400">*</span>
                  </label>
                  <input
                    required
                    type="text"
                    value={form.name}
                    onChange={(e) => setField("name", e.target.value)}
                    placeholder="Business name"
                    className="w-full bg-[#0D1B2A] border border-[#1E3040] rounded-lg px-3 py-2 text-sm text-white placeholder-gray-600 focus:outline-none focus:border-[#00B488]"
                  />
                </div>

                <div className="col-span-2">
                  <label className="block text-xs font-medium text-gray-400 mb-1.5">
                    Category <span className="text-red-400">*</span>
                  </label>
                  <input
                    required
                    type="text"
                    value={form.category}
                    onChange={(e) => setField("category", e.target.value)}
                    placeholder="e.g. Coffee, Restaurant, Retail"
                    className="w-full bg-[#0D1B2A] border border-[#1E3040] rounded-lg px-3 py-2 text-sm text-white placeholder-gray-600 focus:outline-none focus:border-[#00B488]"
                  />
                </div>

                <div>
                  <label className="block text-xs font-medium text-gray-400 mb-1.5">
                    Icon (emoji)
                  </label>
                  <input
                    type="text"
                    value={form.icon}
                    onChange={(e) => setField("icon", e.target.value)}
                    placeholder="🏪"
                    className="w-full bg-[#0D1B2A] border border-[#1E3040] rounded-lg px-3 py-2 text-sm text-white placeholder-gray-600 focus:outline-none focus:border-[#00B488]"
                  />
                </div>

                <div>
                  <label className="block text-xs font-medium text-gray-400 mb-1.5">
                    Color
                  </label>
                  <div className="flex items-center gap-2">
                    <input
                      type="color"
                      value={form.color}
                      onChange={(e) => setField("color", e.target.value)}
                      className="w-10 h-9 rounded-lg border border-[#1E3040] bg-[#0D1B2A] cursor-pointer p-0.5"
                    />
                    <input
                      type="text"
                      value={form.color}
                      onChange={(e) => setField("color", e.target.value)}
                      placeholder="#00B488"
                      className="flex-1 bg-[#0D1B2A] border border-[#1E3040] rounded-lg px-3 py-2 text-sm text-white placeholder-gray-600 focus:outline-none focus:border-[#00B488]"
                    />
                  </div>
                </div>

                <div className="col-span-2">
                  <label className="block text-xs font-medium text-gray-400 mb-1.5">
                    Address
                  </label>
                  <input
                    type="text"
                    value={form.address}
                    onChange={(e) => setField("address", e.target.value)}
                    placeholder="Street address"
                    className="w-full bg-[#0D1B2A] border border-[#1E3040] rounded-lg px-3 py-2 text-sm text-white placeholder-gray-600 focus:outline-none focus:border-[#00B488]"
                  />
                </div>

                <div>
                  <label className="block text-xs font-medium text-gray-400 mb-1.5">
                    Offer
                  </label>
                  <input
                    type="text"
                    value={form.offer}
                    onChange={(e) => setField("offer", e.target.value)}
                    placeholder="e.g. 10% cashback"
                    className="w-full bg-[#0D1B2A] border border-[#1E3040] rounded-lg px-3 py-2 text-sm text-white placeholder-gray-600 focus:outline-none focus:border-[#00B488]"
                  />
                </div>

                <div>
                  <label className="block text-xs font-medium text-gray-400 mb-1.5">
                    Distance
                  </label>
                  <input
                    type="text"
                    value={form.distance}
                    onChange={(e) => setField("distance", e.target.value)}
                    placeholder="e.g. 0.3 km"
                    className="w-full bg-[#0D1B2A] border border-[#1E3040] rounded-lg px-3 py-2 text-sm text-white placeholder-gray-600 focus:outline-none focus:border-[#00B488]"
                  />
                </div>

                <div className="col-span-2">
                  <label className="block text-xs font-medium text-gray-400 mb-1.5">
                    Status
                  </label>
                  <select
                    value={form.status}
                    onChange={(e) => setField("status", e.target.value)}
                    className="w-full bg-[#0D1B2A] border border-[#1E3040] rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-[#00B488]"
                  >
                    <option value="active">Active</option>
                    <option value="inactive">Inactive</option>
                  </select>
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
                  {isPending ? "Saving…" : editingBusiness ? "Save Changes" : "Create Business"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  );
}
