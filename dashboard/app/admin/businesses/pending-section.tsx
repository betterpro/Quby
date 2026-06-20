"use client";

import { useState, useTransition } from "react";
import { Clock, CheckCircle2, XCircle, ChevronDown, ChevronUp } from "lucide-react";
import { approveBusinessRequest, rejectBusinessRequest } from "./actions";

interface PendingRequest {
  id: string;
  user_id: string;
  name: string;
  category: string;
  address?: string | null;
  description?: string | null;
  created_at: string;
}

interface Props {
  requests: PendingRequest[];
}

export function PendingSection({ requests }: Props) {
  const [rejectingId, setRejectingId] = useState<string | null>(null);
  const [reason, setReason] = useState("");
  const [expanded, setExpanded] = useState(true);
  const [isPending, startTransition] = useTransition();

  if (requests.length === 0) return null;

  function handleApprove(req: PendingRequest) {
    startTransition(() =>
      approveBusinessRequest(req.id, {
        name: req.name,
        category: req.category,
        address: req.address,
        user_id: req.user_id,
      })
    );
  }

  function handleReject(id: string) {
    startTransition(() => {
      rejectBusinessRequest(id, reason).then(() => {
        setRejectingId(null);
        setReason("");
      });
    });
  }

  return (
    <div className="mb-6 bg-[#0F2518] border border-[#F6B43C]/30 rounded-xl overflow-hidden">
      <button
        className="w-full flex items-center justify-between px-6 py-4 text-left"
        onClick={() => setExpanded((e) => !e)}
      >
        <div className="flex items-center gap-2">
          <Clock size={15} className="text-[#F6B43C]" />
          <span className="font-semibold text-white font-grotesk">
            Pending Approvals
          </span>
          <span className="text-xs bg-[#F6B43C]/15 text-[#F6B43C] px-2 py-0.5 rounded-full font-medium">
            {requests.length}
          </span>
        </div>
        {expanded ? (
          <ChevronUp size={16} className="text-gray-400" />
        ) : (
          <ChevronDown size={16} className="text-gray-400" />
        )}
      </button>

      {expanded && (
        <div className="border-t border-[#1E4030] divide-y divide-[#1A3828]">
          {requests.map((req) => (
            <div key={req.id} className="px-6 py-4">
              <div className="flex items-start justify-between gap-4">
                <div className="min-w-0 flex-1">
                  <p className="text-sm font-semibold text-white">{req.name}</p>
                  <p className="text-xs text-gray-400 mt-0.5">
                    {req.category}
                    {req.address ? ` · ${req.address}` : ""}
                  </p>
                  {req.description && (
                    <p className="text-xs text-gray-500 mt-1 line-clamp-2">
                      {req.description}
                    </p>
                  )}
                  <p className="text-xs text-gray-600 mt-1">
                    Submitted{" "}
                    {new Date(req.created_at).toLocaleDateString("en-AU", {
                      day: "numeric",
                      month: "short",
                      year: "numeric",
                    })}
                  </p>
                </div>

                {rejectingId !== req.id && (
                  <div className="flex gap-2 flex-shrink-0">
                    <button
                      disabled={isPending}
                      onClick={() => handleApprove(req)}
                      className="flex items-center gap-1.5 text-xs bg-[#00B488]/15 hover:bg-[#00B488]/25 text-[#00D193] px-3 py-1.5 rounded-lg transition-colors disabled:opacity-50"
                    >
                      <CheckCircle2 size={13} />
                      Approve
                    </button>
                    <button
                      disabled={isPending}
                      onClick={() => {
                        setRejectingId(req.id);
                        setReason("");
                      }}
                      className="flex items-center gap-1.5 text-xs bg-red-500/10 hover:bg-red-500/20 text-red-400 px-3 py-1.5 rounded-lg transition-colors disabled:opacity-50"
                    >
                      <XCircle size={13} />
                      Reject
                    </button>
                  </div>
                )}
              </div>

              {rejectingId === req.id && (
                <div className="mt-3 flex gap-2 items-start">
                  <input
                    type="text"
                    value={reason}
                    onChange={(e) => setReason(e.target.value)}
                    placeholder="Reason for rejection (optional)"
                    className="flex-1 text-xs bg-[#0D2B1C] border border-[#1E4030] rounded-lg px-3 py-2 text-white placeholder-gray-600 focus:outline-none focus:border-red-400"
                  />
                  <button
                    disabled={isPending}
                    onClick={() => handleReject(req.id)}
                    className="text-xs bg-red-500/15 hover:bg-red-500/25 text-red-400 px-3 py-2 rounded-lg transition-colors disabled:opacity-50 whitespace-nowrap"
                  >
                    Confirm
                  </button>
                  <button
                    onClick={() => setRejectingId(null)}
                    className="text-xs text-gray-500 hover:text-gray-300 px-2 py-2 transition-colors"
                  >
                    Cancel
                  </button>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
