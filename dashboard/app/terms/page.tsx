import Link from "next/link";
import { Logo } from "@/components/logo";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Terms of Service — Quby",
  description: "Quby Terms of Service",
};

const EFFECTIVE_DATE = "June 21, 2025";

export default function TermsPage() {
  return (
    <div className="min-h-screen bg-brand-ink-bg text-white">
      {/* Nav */}
      <nav className="border-b border-brand-ink-line bg-brand-ink-bg/80 backdrop-blur-md sticky top-0 z-50">
        <div className="max-w-4xl mx-auto px-6 py-4 flex items-center justify-between">
          <Link href="/"><Logo size="md" /></Link>
          <Link href="/privacy" className="text-sm text-gray-400 hover:text-white transition-colors">
            Privacy Policy
          </Link>
        </div>
      </nav>

      <main className="max-w-4xl mx-auto px-6 py-16">
        <div className="mb-12">
          <p className="text-sm text-brand-green-bright font-medium mb-3">Legal</p>
          <h1 className="text-4xl font-bold font-display mb-4">Terms of Service</h1>
          <p className="text-gray-400">Effective date: {EFFECTIVE_DATE}</p>
        </div>

        <div className="prose prose-invert prose-lg max-w-none space-y-10 text-gray-300 leading-relaxed">

          <Section title="1. Acceptance of Terms">
            <p>
              By downloading, installing, or using the Quby mobile application or any associated services
              (collectively, the "Service"), you agree to be bound by these Terms of Service ("Terms").
              If you do not agree to these Terms, do not use the Service.
            </p>
            <p>
              Quby reserves the right to modify these Terms at any time. We will notify you of material
              changes by posting the new Terms in the app or by email. Continued use of the Service
              after changes constitutes acceptance.
            </p>
          </Section>

          <Section title="2. Eligibility">
            <p>
              You must be at least 18 years old and legally capable of entering into contracts to use
              the Service. By using Quby, you represent and warrant that you meet these requirements.
            </p>
          </Section>

          <Section title="3. Account Registration">
            <p>
              You must create an account to access most features. You agree to:
            </p>
            <ul>
              <li>Provide accurate, current, and complete information during registration</li>
              <li>Maintain the security of your password and accept all risks of unauthorized access</li>
              <li>Promptly notify us if you discover or suspect unauthorized use of your account</li>
              <li>Not create more than one personal account</li>
            </ul>
            <p>
              We reserve the right to suspend or terminate accounts that violate these Terms.
            </p>
          </Section>

          <Section title="4. Wallet and Payments">
            <p>
              Quby provides a digital wallet and payment facilitation service. By using payment features:
            </p>
            <ul>
              <li>You authorize Quby to process transactions on your behalf</li>
              <li>You are responsible for ensuring sufficient funds before initiating payments</li>
              <li>Transaction records displayed in the app are for informational purposes</li>
              <li>Quby is not a bank and wallet balances are not bank deposits</li>
              <li>Payment processing is subject to third-party provider terms (including Stripe)</li>
            </ul>
          </Section>

          <Section title="5. Business Accounts">
            <p>
              Businesses that register on Quby agree to additional obligations:
            </p>
            <ul>
              <li>Providing accurate business information and maintaining its accuracy</li>
              <li>Complying with all applicable laws in your jurisdiction</li>
              <li>Not using the platform for fraudulent or deceptive purposes</li>
              <li>Accepting that Quby may review and approve or reject business applications</li>
            </ul>
          </Section>

          <Section title="6. Rewards and Loyalty Points">
            <p>
              Quby may offer loyalty points, cashback, or other rewards. These rewards:
            </p>
            <ul>
              <li>Have no cash value unless explicitly stated</li>
              <li>May expire or be modified at our discretion with reasonable notice</li>
              <li>Cannot be transferred or sold to third parties</li>
              <li>Are forfeited upon account termination for violations of these Terms</li>
            </ul>
          </Section>

          <Section title="7. Prohibited Conduct">
            <p>You agree not to:</p>
            <ul>
              <li>Use the Service for any unlawful purpose or in violation of any regulations</li>
              <li>Engage in money laundering, fraud, or other financial crimes</li>
              <li>Reverse engineer, decompile, or disassemble any part of the Service</li>
              <li>Transmit any harmful, offensive, or disruptive content</li>
              <li>Attempt to gain unauthorized access to any part of the Service</li>
              <li>Use automated tools to access or interact with the Service without permission</li>
            </ul>
          </Section>

          <Section title="8. Intellectual Property">
            <p>
              All content, features, and functionality of the Service — including but not limited to
              text, graphics, logos, and software — are owned by Quby or its licensors and are
              protected by intellectual property laws.
            </p>
            <p>
              We grant you a limited, non-exclusive, non-transferable license to use the Service for
              its intended personal or business purposes.
            </p>
          </Section>

          <Section title="9. Disclaimer of Warranties">
            <p>
              THE SERVICE IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTIES OF ANY KIND,
              EXPRESS OR IMPLIED. QUBY DOES NOT WARRANT THAT THE SERVICE WILL BE UNINTERRUPTED,
              ERROR-FREE, OR SECURE.
            </p>
          </Section>

          <Section title="10. Limitation of Liability">
            <p>
              TO THE MAXIMUM EXTENT PERMITTED BY LAW, QUBY SHALL NOT BE LIABLE FOR ANY INDIRECT,
              INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES ARISING FROM YOUR USE OF THE
              SERVICE, EVEN IF QUBY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
            </p>
            <p>
              OUR TOTAL LIABILITY FOR ANY CLAIM ARISING FROM THESE TERMS OR YOUR USE OF THE SERVICE
              SHALL NOT EXCEED THE AMOUNT YOU PAID TO US IN THE PAST 12 MONTHS.
            </p>
          </Section>

          <Section title="11. Termination">
            <p>
              We may suspend or terminate your access to the Service at any time, with or without
              cause, with or without notice. You may terminate your account at any time by contacting
              us. Upon termination, your right to use the Service will immediately cease.
            </p>
          </Section>

          <Section title="12. Governing Law">
            <p>
              These Terms are governed by and construed in accordance with applicable law. Any disputes
              arising from these Terms shall be resolved through binding arbitration, except where
              prohibited by law.
            </p>
          </Section>

          <Section title="13. Contact Us">
            <p>
              If you have any questions about these Terms, please contact us at:
            </p>
            <p className="font-medium text-white">
              support@quby.app
            </p>
          </Section>

        </div>
      </main>

      <Footer />
    </div>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section>
      <h2 className="text-xl font-semibold font-display text-white mb-4 pb-2 border-b border-brand-ink-line">
        {title}
      </h2>
      <div className="space-y-3 [&_ul]:list-disc [&_ul]:pl-6 [&_ul]:space-y-1.5 [&_li]:text-gray-300">
        {children}
      </div>
    </section>
  );
}

function Footer() {
  return (
    <footer className="border-t border-brand-ink-line mt-20 py-8">
      <div className="max-w-4xl mx-auto px-6 flex flex-col sm:flex-row items-center justify-between gap-4 text-sm text-gray-500">
        <span>© {new Date().getFullYear()} Quby. All rights reserved.</span>
        <div className="flex items-center gap-6">
          <Link href="/terms" className="hover:text-white transition-colors">Terms</Link>
          <Link href="/privacy" className="hover:text-white transition-colors">Privacy</Link>
          <a href="mailto:support@quby.app" className="hover:text-white transition-colors">Contact</a>
        </div>
      </div>
    </footer>
  );
}
