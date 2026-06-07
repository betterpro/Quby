"use client";

import { useState } from "react";
import { Save, Store, MapPin, Clock, Tag, CheckCircle } from "lucide-react";

export default function SettingsPage() {
  const [saved, setSaved] = useState(false);
  const [form, setForm] = useState({
    businessName: "Green Leaf Cafe",
    category: "Food & Drink",
    offer: "10% off all drinks",
    address: "123 Main St, San Francisco, CA",
    hours: "Mon-Fri 7am-6pm, Sat-Sun 8am-5pm",
    phone: "+1 (415) 555-0123",
    website: "https://greenleafcafe.com",
    description:
      "A cozy neighborhood cafe serving specialty coffee, fresh pastries, and light bites. We believe in community, sustainability, and great coffee.",
  });

  function handleChange(
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>
  ) {
    setForm((prev) => ({ ...prev, [e.target.name]: e.target.value }));
  }

  function handleSave(e: React.FormEvent) {
    e.preventDefault();
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  return (
    <div className="animate-fadeIn">
      <div className="mb-8">
        <h1 className="text-2xl font-bold font-grotesk text-white">Settings</h1>
        <p className="text-gray-400 text-sm mt-1">Manage your business profile and preferences</p>
      </div>

      <form onSubmit={handleSave} className="space-y-6 max-w-3xl">
        {/* Business Info */}
        <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl p-6">
          <div className="flex items-center gap-2 mb-5">
            <Store size={16} className="text-[#00B488]" />
            <h3 className="font-semibold text-white font-grotesk">Business Information</h3>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="col-span-2">
              <label className="block text-sm text-gray-400 mb-1.5">Business Name</label>
              <input
                name="businessName"
                value={form.businessName}
                onChange={handleChange}
                className="w-full bg-[#0A1F15] border border-[#1A3828] rounded-lg px-4 py-2.5 text-white text-sm focus:outline-none focus:border-[#00B488] transition-colors"
              />
            </div>

            <div>
              <label className="block text-sm text-gray-400 mb-1.5">Category</label>
              <select
                name="category"
                value={form.category}
                onChange={handleChange}
                className="w-full bg-[#0A1F15] border border-[#1A3828] rounded-lg px-4 py-2.5 text-white text-sm focus:outline-none focus:border-[#00B488] transition-colors"
              >
                {["Food & Drink", "Beauty", "Electronics", "Health", "Retail", "Services"].map(
                  (cat) => (
                    <option key={cat} value={cat}>
                      {cat}
                    </option>
                  )
                )}
              </select>
            </div>

            <div>
              <label className="block text-sm text-gray-400 mb-1.5">Phone</label>
              <input
                name="phone"
                value={form.phone}
                onChange={handleChange}
                className="w-full bg-[#0A1F15] border border-[#1A3828] rounded-lg px-4 py-2.5 text-white text-sm focus:outline-none focus:border-[#00B488] transition-colors"
              />
            </div>

            <div className="col-span-2">
              <label className="block text-sm text-gray-400 mb-1.5">Website</label>
              <input
                name="website"
                value={form.website}
                onChange={handleChange}
                type="url"
                className="w-full bg-[#0A1F15] border border-[#1A3828] rounded-lg px-4 py-2.5 text-white text-sm focus:outline-none focus:border-[#00B488] transition-colors"
              />
            </div>

            <div className="col-span-2">
              <label className="block text-sm text-gray-400 mb-1.5">Description</label>
              <textarea
                name="description"
                value={form.description}
                onChange={handleChange}
                rows={3}
                className="w-full bg-[#0A1F15] border border-[#1A3828] rounded-lg px-4 py-2.5 text-white text-sm focus:outline-none focus:border-[#00B488] transition-colors resize-none"
              />
            </div>
          </div>
        </div>

        {/* Location */}
        <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl p-6">
          <div className="flex items-center gap-2 mb-5">
            <MapPin size={16} className="text-[#F6B43C]" />
            <h3 className="font-semibold text-white font-grotesk">Location</h3>
          </div>

          <div>
            <label className="block text-sm text-gray-400 mb-1.5">Address</label>
            <input
              name="address"
              value={form.address}
              onChange={handleChange}
              className="w-full bg-[#0A1F15] border border-[#1A3828] rounded-lg px-4 py-2.5 text-white text-sm focus:outline-none focus:border-[#00B488] transition-colors"
            />
          </div>
        </div>

        {/* Hours */}
        <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl p-6">
          <div className="flex items-center gap-2 mb-5">
            <Clock size={16} className="text-[#6366F1]" />
            <h3 className="font-semibold text-white font-grotesk">Business Hours</h3>
          </div>

          <div>
            <label className="block text-sm text-gray-400 mb-1.5">Hours of Operation</label>
            <input
              name="hours"
              value={form.hours}
              onChange={handleChange}
              className="w-full bg-[#0A1F15] border border-[#1A3828] rounded-lg px-4 py-2.5 text-white text-sm focus:outline-none focus:border-[#00B488] transition-colors"
            />
          </div>
        </div>

        {/* Loyalty Offer */}
        <div className="bg-[#0F2518] border border-[#1E4030] rounded-xl p-6">
          <div className="flex items-center gap-2 mb-5">
            <Tag size={16} className="text-[#00D193]" />
            <h3 className="font-semibold text-white font-grotesk">Loyalty Offer</h3>
          </div>

          <div>
            <label className="block text-sm text-gray-400 mb-1.5">Current Offer</label>
            <input
              name="offer"
              value={form.offer}
              onChange={handleChange}
              placeholder="e.g. 10% off all drinks"
              className="w-full bg-[#0A1F15] border border-[#1A3828] rounded-lg px-4 py-2.5 text-white text-sm focus:outline-none focus:border-[#00B488] transition-colors"
            />
            <p className="text-xs text-gray-500 mt-2">
              This offer is shown to customers in the QubyPay mobile app near your business.
            </p>
          </div>
        </div>

        {/* Save button */}
        <div className="flex items-center gap-4">
          <button
            type="submit"
            className="flex items-center gap-2 bg-[#00B488] hover:bg-[#00D193] text-white px-6 py-2.5 rounded-lg font-semibold text-sm transition-all"
          >
            <Save size={16} />
            Save Changes
          </button>

          {saved && (
            <div className="flex items-center gap-2 text-sm text-[#00D193]">
              <CheckCircle size={16} />
              Changes saved successfully!
            </div>
          )}
        </div>
      </form>
    </div>
  );
}
