"use client";



import { useRef, useState } from "react";

import { Save, Store, Tag, CheckCircle, MapPin, ImagePlus, Loader2, QrCode } from "lucide-react";

import { createClient } from "@/lib/supabase/client";

import { AddressAutocomplete } from "@/components/address-autocomplete";
import { BusinessLogoImage } from "@/components/business-logo";

import type { Business } from "@/lib/utils";
import { buildPaymentQrPayload, paymentQrImageUrl } from "@/lib/utils";



const CATEGORIES = [

  "Food & Drink",

  "Beauty",

  "Electronics",

  "Health",

  "Retail",

  "Services",

];



const inputClassName =

  "w-full bg-brand-ink-bg border border-brand-ink-line rounded-lg px-4 py-2.5 text-white text-sm focus:outline-none focus:border-brand-green transition-colors";



const ALLOWED_LOGO_TYPES = ["image/jpeg", "image/png", "image/webp", "image/gif"];

const MAX_LOGO_BYTES = 2 * 1024 * 1024;



interface SettingsFormProps {

  business: Business | null;

}



export default function SettingsForm({ business }: SettingsFormProps) {

  const fileInputRef = useRef<HTMLInputElement>(null);

  const [saved, setSaved] = useState(false);

  const [saving, setSaving] = useState(false);

  const [uploadingLogo, setUploadingLogo] = useState(false);

  const [error, setError] = useState("");

  const [logoUrl, setLogoUrl] = useState(business?.logo_url ?? "");

  const [form, setForm] = useState({

    businessName: business?.name ?? "",

    category: business?.category ?? CATEGORIES[0],

    offer: business?.offer ?? "",

    address: business?.address ?? "",

  });

  const [latitude, setLatitude] = useState<number | null>(business?.latitude ?? null);

  const [longitude, setLongitude] = useState<number | null>(business?.longitude ?? null);
  const [fixedQrAmount, setFixedQrAmount] = useState("");



  function handleChange(

    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>

  ) {

    setForm((prev) => ({ ...prev, [e.target.name]: e.target.value }));

  }



  async function handleLogoSelect(e: React.ChangeEvent<HTMLInputElement>) {

    const file = e.target.files?.[0];

    e.target.value = "";

    if (!file || !business) return;



    if (!ALLOWED_LOGO_TYPES.includes(file.type)) {

      setError("Logo must be a JPG, PNG, WebP, or GIF image");

      return;

    }



    if (file.size > MAX_LOGO_BYTES) {

      setError("Logo must be 2 MB or smaller");

      return;

    }



    setUploadingLogo(true);

    setError("");



    const supabase = createClient();

    const ext = file.name.split(".").pop()?.toLowerCase() || "png";

    const path = `${business.id}/logo.${ext}`;



    const { error: uploadError } = await supabase.storage

      .from("businesses")

      .upload(path, file, { upsert: true, contentType: file.type });



    if (uploadError) {

      setUploadingLogo(false);

      setError(uploadError.message || "Failed to upload logo. Please try again.");

      return;

    }



    const {

      data: { publicUrl },

    } = supabase.storage.from("businesses").getPublicUrl(path);



    const { error: updateError } = await supabase.rpc("update_my_business", {

      p_name: form.businessName || business.name,

      p_category: form.category || business.category,

      p_offer: form.offer ?? business.offer ?? "",

      p_address: form.address || business.address || "",

      p_latitude: latitude ?? business.latitude ?? null,

      p_longitude: longitude ?? business.longitude ?? null,

      p_logo_url: publicUrl,

    });



    setUploadingLogo(false);



    if (updateError) {

      setError(updateError.message || "Logo uploaded but failed to save. Try saving again.");

      return;

    }



    setLogoUrl(`${publicUrl}?t=${Date.now()}`);

  }



  async function handleSave(e: React.FormEvent) {

    e.preventDefault();

    if (!business) return;



    if (!latitude || !longitude || !form.address.trim()) {

      setError("Select your business address from Google suggestions to pin it on the map");

      return;

    }



    setSaving(true);

    setError("");



    const supabase = createClient();

    const cleanLogoUrl = logoUrl.split("?")[0] || null;

    const { error: updateError } = await supabase.rpc("update_my_business", {

      p_name: form.businessName,

      p_category: form.category,

      p_offer: form.offer,

      p_address: form.address,

      p_latitude: latitude,

      p_longitude: longitude,

      p_logo_url: cleanLogoUrl,

    });



    setSaving(false);



    if (updateError) {

      setError(updateError.message || "Failed to save changes. Please try again.");

      return;

    }



    setSaved(true);

    setTimeout(() => setSaved(false), 3000);

  }



  if (!business) {

    return (

      <div className="animate-fadeIn">

        <div className="mb-8">

          <h1 className="text-2xl font-bold font-display text-white">Settings</h1>

          <p className="text-gray-400 text-sm mt-1">Manage your business profile and preferences</p>

        </div>

        <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-8 text-center">

          <p className="text-gray-400 text-sm">No business profile linked to your account yet.</p>

        </div>

      </div>

    );

  }



  return (

    <div className="animate-fadeIn">

      <div className="mb-8">

        <h1 className="text-2xl font-bold font-display text-white">Settings</h1>

        <p className="text-gray-400 text-sm mt-1">Manage your business profile and preferences</p>

      </div>



      <form onSubmit={handleSave} className="space-y-6 max-w-3xl">

        {error && (

          <div className="bg-red-500/10 border border-red-500/20 rounded-lg p-3 text-sm text-red-400">

            {error}

          </div>

        )}



        <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-6">

          <div className="flex items-center gap-2 mb-5">

            <ImagePlus size={16} className="text-[#00B488]" />

            <h3 className="font-semibold text-white font-display">Business Logo</h3>

          </div>



          <div className="flex items-center gap-5">

            <div

              className="w-20 h-20 rounded-2xl overflow-hidden flex items-center justify-center flex-shrink-0 border border-brand-ink-line"

              style={{ backgroundColor: `${business.color || "#00B488"}20` }}

            >

              {logoUrl ? (
                <BusinessLogoImage
                  logoUrl={logoUrl}
                  alt={`${business.name} logo`}
                  className="w-full h-full object-cover"
                  fallback={<span className="text-3xl">{business.icon || "🏪"}</span>}
                />
              ) : (

                <span className="text-3xl">{business.icon || "🏪"}</span>

              )}

            </div>



            <div>

              <input

                ref={fileInputRef}

                type="file"

                accept="image/jpeg,image/png,image/webp,image/gif"

                className="hidden"

                onChange={handleLogoSelect}

              />

              <button

                type="button"

                disabled={uploadingLogo}

                onClick={() => fileInputRef.current?.click()}

                className="flex items-center gap-2 bg-brand-ink-bg hover:bg-brand-ink-surface-2 disabled:opacity-60 border border-brand-ink-line text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors"

              >

                {uploadingLogo ? <Loader2 size={16} className="animate-spin" /> : <ImagePlus size={16} />}

                {uploadingLogo ? "Uploading..." : logoUrl ? "Change logo" : "Upload logo"}

              </button>

              <p className="text-xs text-gray-500 mt-2">

                Shown to customers in the QubyPay app. JPG, PNG, WebP, or GIF up to 2 MB.

              </p>

            </div>

          </div>

        </div>



        <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-6">

          <div className="flex items-center gap-2 mb-5">

            <Store size={16} className="text-[#00B488]" />

            <h3 className="font-semibold text-white font-display">Business Information</h3>

          </div>



          <div className="grid grid-cols-2 gap-4">

            <div className="col-span-2">

              <label className="block text-sm text-gray-400 mb-1.5">Business Name</label>

              <input

                name="businessName"

                value={form.businessName}

                onChange={handleChange}

                required

                className={inputClassName}

              />

            </div>



            <div>

              <label className="block text-sm text-gray-400 mb-1.5">Category</label>

              <select

                name="category"

                value={form.category}

                onChange={handleChange}

                className={inputClassName}

              >

                {CATEGORIES.map((cat) => (

                  <option key={cat} value={cat}>

                    {cat}

                  </option>

                ))}

              </select>

            </div>



            <div className="col-span-2">

              <label className="block text-sm text-gray-400 mb-1.5">Address</label>

              <AddressAutocomplete

                value={form.address}

                onChange={(value) => {

                  setForm((prev) => ({ ...prev, address: value }));

                  setLatitude(null);

                  setLongitude(null);

                }}

                onPlaceSelected={(place) => {

                  setForm((prev) => ({ ...prev, address: place.address }));

                  setLatitude(place.lat);

                  setLongitude(place.lng);

                }}

                placeholder="Search address to pin on map"

                className={inputClassName}

              />

              {latitude != null && longitude != null && (

                <p className="flex items-center gap-1.5 text-xs text-brand-green-bright mt-2">

                  <MapPin size={12} />

                  Pinned at {latitude.toFixed(5)}, {longitude.toFixed(5)}

                </p>

              )}

            </div>

          </div>

        </div>



        {business?.id && (
          <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-6">
            <div className="flex items-center gap-2 mb-5">
              <QrCode size={16} className="text-brand-green-bright" />
              <h3 className="font-semibold text-white font-display">Payment QR Codes</h3>
            </div>

            <p className="text-sm text-gray-400 mb-6">
              Customers scan these codes in the Quby app to pay you. Use the open amount code at checkout, or set a fixed amount for a specific bill.
            </p>

            <div className="grid md:grid-cols-2 gap-6">
              <div className="bg-brand-ink-bg border border-brand-ink-line rounded-xl p-5 text-center">
                <p className="text-sm font-medium text-white mb-3">Open amount</p>
                <img
                  src={paymentQrImageUrl(buildPaymentQrPayload(business.id))}
                  alt="Open amount payment QR code"
                  width={180}
                  height={180}
                  className="mx-auto rounded-lg bg-white p-2"
                />
                <p className="text-xs text-gray-500 mt-3">Customer enters the amount after scanning</p>
              </div>

              <div className="bg-brand-ink-bg border border-brand-ink-line rounded-xl p-5">
                <p className="text-sm font-medium text-white mb-3 text-center">Fixed amount</p>
                <label className="block text-xs text-gray-400 mb-1.5">Amount (USD)</label>
                <input
                  type="number"
                  min="0"
                  step="0.01"
                  value={fixedQrAmount}
                  onChange={(e) => setFixedQrAmount(e.target.value)}
                  placeholder="e.g. 12.50"
                  className={inputClassName}
                />
                {Number(fixedQrAmount) > 0 ? (
                  <img
                    src={paymentQrImageUrl(
                      buildPaymentQrPayload(business.id, Number(fixedQrAmount))
                    )}
                    alt="Fixed amount payment QR code"
                    width={180}
                    height={180}
                    className="mx-auto mt-4 rounded-lg bg-white p-2"
                  />
                ) : (
                  <p className="text-xs text-gray-500 mt-4 text-center">
                    Enter an amount to generate a fixed-price QR code
                  </p>
                )}
              </div>
            </div>
          </div>
        )}



        <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-xl p-6">

          <div className="flex items-center gap-2 mb-5">

            <Tag size={16} className="text-brand-green-bright" />

            <h3 className="font-semibold text-white font-display">Loyalty Offer</h3>

          </div>



          <div>

            <label className="block text-sm text-gray-400 mb-1.5">Current Offer</label>

            <input

              name="offer"

              value={form.offer}

              onChange={handleChange}

              placeholder="e.g. 10% off all drinks"

              className={inputClassName}

            />

            <p className="text-xs text-gray-500 mt-2">

              This offer is shown to customers in the QubyPay mobile app near your business.

            </p>

          </div>

        </div>



        <div className="flex items-center gap-4">

          <button

            type="submit"

            disabled={saving}

            className="flex items-center gap-2 bg-brand-green hover:bg-brand-green-bright disabled:opacity-60 text-white px-6 py-2.5 rounded-lg font-semibold text-sm transition-all"

          >

            <Save size={16} />

            {saving ? "Saving..." : "Save Changes"}

          </button>



          {saved && (

            <div className="flex items-center gap-2 text-sm text-brand-green-bright">

              <CheckCircle size={16} />

              Changes saved successfully!

            </div>

          )}

        </div>

      </form>

    </div>

  );

}

