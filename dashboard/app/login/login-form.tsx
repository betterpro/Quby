"use client";

import { useState, useEffect } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import { Logo } from "@/components/logo";
import { createClient } from "@/lib/supabase/client";
import { Eye, EyeOff, AlertCircle, ArrowLeft } from "lucide-react";

export default function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const isAdmin = searchParams.get("admin") === "true";

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const supabase = createClient();

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session) {
        router.push(isAdmin ? "/admin" : "/dashboard");
      }
    });
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function handleLogin(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      const { data, error: authError } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (authError) {
        setError(authError.message || "Invalid email or password");
        setLoading(false);
        return;
      }

      if (data.session) {
        router.push(isAdmin ? "/admin" : "/dashboard");
        router.refresh();
      }
    } catch {
      setError("An unexpected error occurred. Please try again.");
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen bg-[#0A1F15] flex items-center justify-center p-6">
      {/* Background glow */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/3 left-1/2 -translate-x-1/2 w-[600px] h-[600px] rounded-full bg-[#00B488]/5 blur-[100px]" />
      </div>

      <div className="w-full max-w-md relative z-10">
        {/* Back link */}
        <Link
          href="/"
          className="inline-flex items-center gap-2 text-sm text-gray-500 hover:text-gray-300 transition-colors mb-8"
        >
          <ArrowLeft size={14} />
          Back to home
        </Link>

        {/* Card */}
        <div className="bg-[#0F2518] border border-[#1E4030] rounded-2xl p-8">
          {/* Logo + title */}
          <div className="text-center mb-8">
            <div className="flex justify-center mb-4">
              <Logo size="md" href={undefined} />
            </div>
            <h1 className="text-2xl font-bold font-grotesk text-white mb-2">
              {isAdmin ? "Admin Login" : "Business Login"}
            </h1>
            <p className="text-gray-400 text-sm">
              {isAdmin
                ? "Sign in to access the admin dashboard"
                : "Sign in to manage your business"}
            </p>
          </div>

          {/* Demo credentials banner */}
          <div className="bg-[#F6B43C]/10 border border-[#F6B43C]/20 rounded-lg p-3 mb-6 text-xs text-[#F6B43C]">
            <p className="font-semibold mb-1">Demo Credentials</p>
            <p>Email: demo@qubypay.com</p>
            <p>Password: demo123456</p>
          </div>

          {/* Error */}
          {error && (
            <div className="flex items-start gap-3 bg-red-500/10 border border-red-500/20 rounded-lg p-3 mb-5 text-sm text-red-400">
              <AlertCircle size={16} className="mt-0.5 flex-shrink-0" />
              <span>{error}</span>
            </div>
          )}

          {/* Form */}
          <form onSubmit={handleLogin} className="space-y-5">
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
                className="w-full bg-[#0A1F15] border border-[#1A3828] rounded-lg px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:border-[#00B488] transition-colors text-sm"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-300 mb-1.5">
                Password
              </label>
              <div className="relative">
                <input
                  type={showPassword ? "text" : "password"}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  required
                  className="w-full bg-[#0A1F15] border border-[#1A3828] rounded-lg px-4 py-3 pr-10 text-white placeholder-gray-600 focus:outline-none focus:border-[#00B488] transition-colors text-sm"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-300 transition-colors"
                >
                  {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-[#00B488] hover:bg-[#00D193] disabled:opacity-60 disabled:cursor-not-allowed text-white py-3 rounded-lg font-semibold transition-all text-sm"
            >
              {loading ? (
                <span className="flex items-center justify-center gap-2">
                  <svg className="animate-spin w-4 h-4" viewBox="0 0 24 24" fill="none">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                  </svg>
                  Signing in...
                </span>
              ) : (
                "Sign In"
              )}
            </button>
          </form>

          <p className="text-center text-xs text-gray-600 mt-6">
            Don&apos;t have an account?{" "}
            <a href="mailto:hello@qubypay.com" className="text-[#00B488] hover:text-[#00D193]">
              Contact us
            </a>
          </p>
        </div>
      </div>
    </div>
  );
}
