import Link from "next/link";
import { Logo } from "@/components/logo";
import { ArrowRight, Zap, Heart, BarChart3, Shield, Globe, Star } from "lucide-react";

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-[#0A1F15] text-white">
      {/* Nav */}
      <nav className="border-b border-[#1A3828] bg-[#091A11]/80 backdrop-blur-md sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
          <Logo size="md" />
          <div className="hidden md:flex items-center gap-8 text-sm text-gray-400">
            <a href="#features" className="hover:text-white transition-colors">Features</a>
            <a href="#pricing" className="hover:text-white transition-colors">Pricing</a>
            <a href="#about" className="hover:text-white transition-colors">About</a>
          </div>
          <div className="flex items-center gap-3">
            <Link
              href="/login"
              className="text-sm text-gray-300 hover:text-white transition-colors px-4 py-2"
            >
              Business Login
            </Link>
            <a
              href="mailto:hello@qubypay.com"
              className="text-sm bg-[#00B488] hover:bg-[#00D193] text-white px-4 py-2 rounded-lg transition-colors font-medium"
            >
              Get Started
            </a>
          </div>
        </div>
      </nav>

      {/* Hero */}
      <section className="relative overflow-hidden pt-24 pb-32 px-6">
        {/* Background glow */}
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <div className="absolute top-1/4 left-1/2 -translate-x-1/2 w-[800px] h-[800px] rounded-full bg-[#00B488]/5 blur-[120px]" />
          <div className="absolute top-0 right-1/4 w-[400px] h-[400px] rounded-full bg-[#F6B43C]/3 blur-[80px]" />
        </div>

        <div className="max-w-7xl mx-auto text-center relative z-10">
          {/* Badge */}
          <div className="inline-flex items-center gap-2 bg-[#00B488]/10 border border-[#00B488]/30 rounded-full px-4 py-1.5 mb-8 text-sm text-[#00D193]">
            <Zap size={14} />
            <span>Powering 500+ local businesses</span>
          </div>

          <h1 className="text-5xl md:text-7xl font-bold font-grotesk mb-6 leading-tight">
            The Smart Payment Platform
            <br />
            <span className="gradient-text">for Local Business</span>
          </h1>

          <p className="text-xl text-gray-400 max-w-2xl mx-auto mb-10 leading-relaxed">
            Accept payments seamlessly, build lasting customer loyalty, and unlock
            powerful analytics — all in one beautifully simple platform.
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <Link
              href="/login"
              className="flex items-center gap-2 bg-[#00B488] hover:bg-[#00D193] text-white px-8 py-4 rounded-xl font-semibold text-lg transition-all hover:shadow-[0_0_30px_rgba(0,180,136,0.3)]"
            >
              Business Login
              <ArrowRight size={20} />
            </Link>
            <a
              href="mailto:hello@qubypay.com?subject=Get Started with QubyPay"
              className="flex items-center gap-2 border border-[#1A3828] hover:border-[#00B488]/40 text-gray-300 hover:text-white px-8 py-4 rounded-xl font-semibold text-lg transition-all"
            >
              Get Started Free
            </a>
          </div>

          {/* Stats row */}
          <div className="mt-20 grid grid-cols-3 gap-8 max-w-lg mx-auto">
            {[
              { value: "$2.4M+", label: "Processed Monthly" },
              { value: "10K+", label: "Active Users" },
              { value: "500+", label: "Businesses" },
            ].map((stat) => (
              <div key={stat.label} className="text-center">
                <p className="text-2xl font-bold text-white font-grotesk">{stat.value}</p>
                <p className="text-sm text-gray-500 mt-1">{stat.label}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Features */}
      <section id="features" className="py-24 px-6 bg-[#0D2B1C]/40">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold font-grotesk mb-4">
              Everything you need to grow
            </h2>
            <p className="text-gray-400 text-lg max-w-xl mx-auto">
              From first transaction to a loyal community — QubyPay has you covered.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-6">
            {[
              {
                icon: Zap,
                color: "#00B488",
                title: "Accept Payments",
                description:
                  "Process payments instantly with our secure, fast payment infrastructure. Support for all major payment methods with real-time confirmation.",
                features: ["Instant processing", "Zero downtime", "PCI compliant"],
              },
              {
                icon: Heart,
                color: "#F6B43C",
                title: "Build Loyalty",
                description:
                  "Create custom loyalty programs that keep customers coming back. Points, rewards, and exclusive offers tailored to your business.",
                features: ["Custom point systems", "Reward tiers", "Push notifications"],
              },
              {
                icon: BarChart3,
                color: "#6366F1",
                title: "Track Analytics",
                description:
                  "Get deep insights into your business performance with beautiful, real-time dashboards. Make data-driven decisions with confidence.",
                features: ["Real-time data", "Revenue charts", "Customer insights"],
              },
            ].map((feature) => (
              <div
                key={feature.title}
                className="bg-[#0F2518] border border-[#1E4030] rounded-2xl p-8 hover:border-[#00B488]/30 transition-all group"
              >
                <div
                  className="w-14 h-14 rounded-xl flex items-center justify-center mb-6"
                  style={{ backgroundColor: `${feature.color}15` }}
                >
                  <feature.icon size={28} style={{ color: feature.color }} />
                </div>
                <h3 className="text-xl font-semibold font-grotesk mb-3 text-white">
                  {feature.title}
                </h3>
                <p className="text-gray-400 leading-relaxed mb-6">{feature.description}</p>
                <ul className="space-y-2">
                  {feature.features.map((f) => (
                    <li key={f} className="flex items-center gap-2 text-sm text-gray-300">
                      <div className="w-1.5 h-1.5 rounded-full bg-[#00B488]" />
                      {f}
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Trust section */}
      <section className="py-24 px-6">
        <div className="max-w-7xl mx-auto">
          <div className="grid md:grid-cols-2 gap-16 items-center">
            <div>
              <h2 className="text-4xl font-bold font-grotesk mb-6">
                Trusted by local businesses{" "}
                <span className="gradient-text">everywhere</span>
              </h2>
              <p className="text-gray-400 text-lg leading-relaxed mb-8">
                From coffee shops to hair salons, tech repair to fitness studios —
                QubyPay powers the local economy with enterprise-grade technology
                made simple.
              </p>
              <div className="grid grid-cols-2 gap-4">
                {[
                  { icon: Shield, text: "Bank-level security" },
                  { icon: Globe, text: "Works everywhere" },
                  { icon: Star, text: "5-star rated" },
                  { icon: Zap, text: "Instant setup" },
                ].map((item) => (
                  <div key={item.text} className="flex items-center gap-3 text-gray-300">
                    <item.icon size={16} className="text-[#00B488]" />
                    <span className="text-sm">{item.text}</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              {[
                { name: "Green Leaf Cafe", category: "Food & Drink", revenue: "+34% revenue", icon: "☕" },
                { name: "Urban Cuts", category: "Beauty & Style", revenue: "200+ loyal customers", icon: "✂️" },
                { name: "Tech Repair Hub", category: "Electronics", revenue: "Real-time insights", icon: "📱" },
                { name: "Sunrise Bakery", category: "Food & Drink", revenue: "3x repeat visits", icon: "🥐" },
              ].map((biz) => (
                <div
                  key={biz.name}
                  className="bg-[#0F2518] border border-[#1E4030] rounded-xl p-4"
                >
                  <div className="text-2xl mb-3">{biz.icon}</div>
                  <p className="font-semibold text-white text-sm font-grotesk">{biz.name}</p>
                  <p className="text-xs text-gray-500 mb-2">{biz.category}</p>
                  <p className="text-xs text-[#00D193]">{biz.revenue}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="py-24 px-6 bg-gradient-to-b from-[#0D2B1C]/40 to-[#0A1F15]">
        <div className="max-w-3xl mx-auto text-center">
          <h2 className="text-4xl md:text-5xl font-bold font-grotesk mb-6">
            Ready to grow your business?
          </h2>
          <p className="text-gray-400 text-lg mb-10">
            Join hundreds of local businesses using QubyPay to accept payments,
            reward customers, and grow their revenue.
          </p>
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <a
              href="mailto:hello@qubypay.com?subject=Get Started with QubyPay"
              className="flex items-center gap-2 bg-[#00B488] hover:bg-[#00D193] text-white px-8 py-4 rounded-xl font-semibold text-lg transition-all hover:shadow-[0_0_30px_rgba(0,180,136,0.3)]"
            >
              Get Started Free
              <ArrowRight size={20} />
            </a>
            <Link
              href="/login"
              className="text-gray-300 hover:text-white transition-colors px-8 py-4 text-lg"
            >
              Business Login →
            </Link>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-[#1A3828] py-12 px-6">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row items-center justify-between gap-6">
          <Logo size="sm" />
          <div className="flex items-center gap-8 text-sm text-gray-500">
            <a href="#" className="hover:text-gray-300 transition-colors">Privacy</a>
            <a href="#" className="hover:text-gray-300 transition-colors">Terms</a>
            <a href="mailto:hello@qubypay.com" className="hover:text-gray-300 transition-colors">Contact</a>
          </div>
          <p className="text-sm text-gray-600">
            © {new Date().getFullYear()} QubyPay. All rights reserved.
          </p>
        </div>
      </footer>
    </div>
  );
}
