"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { Logo } from "@/components/logo";
import { createClient } from "@/lib/supabase/client";
import { AlertCircle, ArrowLeft, CheckCircle, MapPin } from "lucide-react";
import { AddressAutocomplete } from "@/components/address-autocomplete";

const CATEGORIES = [
  "Food & Drink",
  "Beauty",
  "Electronics",
  "Health",
  "Retail",
  "Services",
];

export default function SignupForm() {
  const router = useRouter();
  const [name, setName] = useState("");
  const [businessName, setBusinessName] = useState("");
  const [category, setCategory] = useState(CATEGORIES[0]);
  const [address, setAddress] = useState("");
  const [latitude, setLatitude] = useState<number | null>(null);
  const [longitude, setLongitude] = useState<number | null>(null);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [confirmationSent, setConfirmationSent] = useState(false);

  const supabase = createClient();

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session) router.push("/dashboard");
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function handleSignup(e: React.FormEvent) {
    e.preventDefault();
    setError("");

    if (password !== confirmPassword) {
      setError("Passwords do not match");
      return;
    }

    if (password.length < 8) {
      setError("Password must be at least 8 characters");
      return;
    }

    if (!latitude || !longitude || !address.trim()) {
      setError("Please select your business address from the Google suggestions");
      return;
    }

    setLoading(true);

    try {
      const { data, error: authError } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            full_name: name,
            business_name: businessName,
            category,
            role: "business",
            address: address.trim(),
            latitude,
            longitude,
          },
        },
      });

      if (authError) {
        setError(
          authError.message.includes("already registered")
            ? "An account with this email already exists"
            : authError.message
        );
        setLoading(false);
        return;
      }

      if (!data.user) {
        setError("Sign up failed. Please try again.");
        setLoading(false);
        return;
      }

      if (data.session) {
        const { error: completeError } = await supabase.rpc("complete_business_signup");
        if (completeError) {
          setError(completeError.message);
          setLoading(false);
          return;
        }

        router.push("/dashboard");
        router.refresh();
        return;
      }

      setConfirmationSent(true);
      setLoading(false);
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "An unexpected error occurred. Please try again.";
      setError(message);
      setLoading(false);
    }
  }

  if (confirmationSent) {
    return (
      <div className="min-h-screen bg-brand-ink-bg flex items-center justify-center p-6">
        <div className="w-full max-w-md relative z-10 text-center">
          <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-2xl p-8">
            <div className="flex justify-center mb-4">
              <CheckCircle size={48} className="text-brand-green-bright" />
            </div>
            <h1 className="text-2xl font-bold font-display text-white mb-3">
              Check your email
            </h1>
            <p className="text-gray-400 text-sm mb-6">
              We sent a confirmation link to <span className="text-white">{email}</span>.
              Confirm your email, then sign in to access your business dashboard.
            </p>
            <Link
              href="/login"
              className="inline-flex items-center justify-center bg-brand-green hover:bg-brand-green-bright text-brand-on-green px-6 py-3 rounded-lg font-bold transition-all text-sm"
            >
              Go to Business Login
            </Link>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-brand-ink-bg flex items-center justify-center p-6">
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/3 left-1/2 -translate-x-1/2 w-[600px] h-[600px] rounded-full bg-brand-green/5 blur-[100px]" />
      </div>

      <div className="w-full max-w-md relative z-10">
        <Link
          href="/"
          className="inline-flex items-center gap-2 text-sm text-gray-500 hover:text-gray-300 transition-colors mb-8"
        >
          <ArrowLeft size={14} />
          Back to home
        </Link>

        <div className="bg-brand-ink-surface border border-brand-ink-surface-2 rounded-2xl p-8">
          <div className="text-center mb-8">
            <div className="flex justify-center mb-4">
              <Logo size="md" href={undefined} />
            </div>
            <h1 className="text-2xl font-bold font-display text-white mb-2">
              Sign up your business
            </h1>
            <p className="text-gray-400 text-sm">
              Create an account to accept payments and manage your business
            </p>
          </div>

          {error && (
            <div className="flex items-start gap-3 bg-red-500/10 border border-red-500/20 rounded-lg p-3 mb-5 text-sm text-red-400">
              <AlertCircle size={16} className="mt-0.5 flex-shrink-0" />
              <span>{error}</span>
            </div>
          )}

          <form onSubmit={handleSignup} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-1.5">
                Your name
              </label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Jane Smith"
                required
                className="w-full bg-brand-ink-bg border border-brand-ink-line rounded-lg px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:border-brand-green transition-colors text-sm"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-300 mb-1.5">
                Business name
              </label>
              <input
                type="text"
                value={businessName}
                onChange={(e) => setBusinessName(e.target.value)}
                placeholder="Green Leaf Cafe"
                required
                className="w-full bg-brand-ink-bg border border-brand-ink-line rounded-lg px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:border-brand-green transition-colors text-sm"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-300 mb-1.5">
                Category
              </label>
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                className="w-full bg-brand-ink-bg border border-brand-ink-line rounded-lg px-4 py-3 text-white focus:outline-none focus:border-brand-green transition-colors text-sm"
              >
                {CATEGORIES.map((cat) => (
                  <option key={cat} value={cat}>
                    {cat}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-300 mb-1.5">
                Business address
              </label>
              <AddressAutocomplete
                value={address}
                onChange={(value) => {
                  setAddress(value);
                  setLatitude(null);
                  setLongitude(null);
                }}
                onPlaceSelected={(place) => {
                  setAddress(place.address);
                  setLatitude(place.lat);
                  setLongitude(place.lng);
                }}
                placeholder="Search address to pin on map"
                required
                className="w-full bg-brand-ink-bg border border-brand-ink-line rounded-lg px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:border-brand-green transition-colors text-sm"
              />
              {latitude != null && longitude != null && (
                <p className="flex items-center gap-1.5 text-xs text-brand-green-bright mt-2">
                  <MapPin size={12} />
                  Pinned at {latitude.toFixed(5)}, {longitude.toFixed(5)}
                </p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-300 mb-1.5">
                Email address
              </label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="you@business.com"
                required
                className="w-full bg-brand-ink-bg border border-brand-ink-line rounded-lg px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:border-brand-green transition-colors text-sm"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-300 mb-1.5">
                Password
              </label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="At least 8 characters"
                required
                minLength={8}
                className="w-full bg-brand-ink-bg border border-brand-ink-line rounded-lg px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:border-brand-green transition-colors text-sm"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-300 mb-1.5">
                Confirm password
              </label>
              <input
                type="password"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                placeholder="••••••••"
                required
                minLength={8}
                className="w-full bg-brand-ink-bg border border-brand-ink-line rounded-lg px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:border-brand-green transition-colors text-sm"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-brand-green hover:bg-brand-green-bright disabled:opacity-60 disabled:cursor-not-allowed text-brand-on-green py-3 rounded-lg font-bold transition-all text-sm"
            >
              {loading ? "Creating account..." : "Create Business Account"}
            </button>
          </form>

          <p className="text-center text-xs text-gray-600 mt-6">
            Already have an account?{" "}
            <Link href="/login" className="text-[#00B488] hover:text-brand-green-bright">
              Business Login
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
