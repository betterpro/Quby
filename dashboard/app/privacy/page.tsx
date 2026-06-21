import Link from "next/link";
import { Logo } from "@/components/logo";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Privacy Policy — Quby",
  description: "Quby Privacy Policy",
};

const EFFECTIVE_DATE = "June 21, 2025";

export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-brand-ink-bg text-white">
      {/* Nav */}
      <nav className="border-b border-brand-ink-line bg-brand-ink-bg/80 backdrop-blur-md sticky top-0 z-50">
        <div className="max-w-4xl mx-auto px-6 py-4 flex items-center justify-between">
          <Link href="/"><Logo size="md" /></Link>
          <Link href="/terms" className="text-sm text-gray-400 hover:text-white transition-colors">
            Terms of Service
          </Link>
        </div>
      </nav>

      <main className="max-w-4xl mx-auto px-6 py-16">
        <div className="mb-12">
          <p className="text-sm text-brand-green-bright font-medium mb-3">Legal</p>
          <h1 className="text-4xl font-bold font-display mb-4">Privacy Policy</h1>
          <p className="text-gray-400">Effective date: {EFFECTIVE_DATE}</p>
        </div>

        <div className="prose prose-invert prose-lg max-w-none space-y-10 text-gray-300 leading-relaxed">

          <Section title="1. Introduction">
            <p>
              Quby ("we", "our", or "us") is committed to protecting your personal information.
              This Privacy Policy explains what data we collect, how we use it, and your rights
              regarding your information when you use the Quby app and related services.
            </p>
            <p>
              By using Quby, you agree to the collection and use of information as described in
              this policy.
            </p>
          </Section>

          <Section title="2. Information We Collect">
            <p><strong className="text-white">Information you provide directly:</strong></p>
            <ul>
              <li>Account information: name, email address, profile photo</li>
              <li>Business information: business name, category, address, description</li>
              <li>Payment information: processed securely through Stripe (we do not store card numbers)</li>
              <li>Communications: messages or support requests you send us</li>
            </ul>
            <p><strong className="text-white">Information collected automatically:</strong></p>
            <ul>
              <li>Location data (when you grant permission) to show nearby businesses and enable map features</li>
              <li>Device information: device type, operating system, app version</li>
              <li>Usage data: features used, screens viewed, transaction history</li>
              <li>Camera access (when you grant permission) for QR code scanning</li>
            </ul>
            <p><strong className="text-white">Information from third parties:</strong></p>
            <ul>
              <li>Google Sign-In: name, email, and profile picture from your Google account</li>
              <li>Apple Sign-In: name and email from your Apple ID</li>
              <li>Stripe: payment processing status and transaction metadata</li>
            </ul>
          </Section>

          <Section title="3. How We Use Your Information">
            <p>We use the information we collect to:</p>
            <ul>
              <li>Create and manage your account</li>
              <li>Process payments and maintain your wallet balance</li>
              <li>Show nearby businesses and personalize the Discover experience</li>
              <li>Display your transaction history and activity</li>
              <li>Manage loyalty points, rewards, and stamp cards</li>
              <li>Facilitate bill splitting and group expenses</li>
              <li>Send you important service updates and notifications</li>
              <li>Detect and prevent fraud, abuse, and security incidents</li>
              <li>Comply with legal obligations</li>
              <li>Improve and develop new features</li>
            </ul>
          </Section>

          <Section title="4. How We Share Your Information">
            <p>We do not sell your personal information. We may share it with:</p>
            <ul>
              <li>
                <strong className="text-white">Service providers</strong>: Supabase (database and authentication),
                Stripe (payment processing), Google (maps and sign-in), Apple (sign-in). These providers
                have their own privacy policies governing their use of your data.
              </li>
              <li>
                <strong className="text-white">Businesses</strong>: When you pay a business, they receive
                transaction details (amount, timestamp). They do not receive your payment method details.
              </li>
              <li>
                <strong className="text-white">Other users</strong>: In split/group features, your name and
                handle are visible to group members.
              </li>
              <li>
                <strong className="text-white">Legal requirements</strong>: When required by law, court order,
                or governmental authority.
              </li>
            </ul>
          </Section>

          <Section title="5. Location Data">
            <p>
              Quby requests access to your device location to show nearby businesses on the map and
              calculate distances. Location access is optional — you can use most features without it.
              We do not store precise location history on our servers.
            </p>
            <p>
              You can revoke location permission at any time in your device settings.
            </p>
          </Section>

          <Section title="6. Camera Access">
            <p>
              We request camera access solely for QR code scanning to facilitate payments. We do not
              store, transmit, or analyze images or video from your camera.
            </p>
          </Section>

          <Section title="7. Data Retention">
            <p>
              We retain your personal information for as long as your account is active or as needed
              to provide services. Transaction records may be retained for up to 7 years for financial
              compliance purposes. You may request deletion of your account and associated data at any time.
            </p>
          </Section>

          <Section title="8. Data Security">
            <p>
              We implement industry-standard security measures including:
            </p>
            <ul>
              <li>Encryption of data in transit (TLS) and at rest</li>
              <li>Secure authentication via Supabase with Row Level Security</li>
              <li>Payment processing handled exclusively by PCI-compliant Stripe</li>
              <li>Regular security reviews and access controls</li>
            </ul>
            <p>
              No method of transmission or storage is 100% secure. We cannot guarantee absolute security
              but are committed to protecting your information.
            </p>
          </Section>

          <Section title="9. Your Rights">
            <p>
              Depending on your location, you may have the right to:
            </p>
            <ul>
              <li><strong className="text-white">Access</strong>: Request a copy of your personal data</li>
              <li><strong className="text-white">Correction</strong>: Update inaccurate or incomplete information</li>
              <li><strong className="text-white">Deletion</strong>: Request deletion of your account and data</li>
              <li><strong className="text-white">Portability</strong>: Receive your data in a portable format</li>
              <li><strong className="text-white">Opt-out</strong>: Withdraw consent for optional data uses</li>
            </ul>
            <p>
              To exercise these rights, contact us at <span className="text-white font-medium">privacy@quby.app</span>.
              We will respond within 30 days.
            </p>
          </Section>

          <Section title="10. Children's Privacy">
            <p>
              The Service is not directed to children under 18. We do not knowingly collect personal
              information from children. If you believe a child has provided us personal information,
              please contact us and we will delete it promptly.
            </p>
          </Section>

          <Section title="11. Third-Party Links">
            <p>
              The Service may contain links to third-party websites or services. We are not responsible
              for the privacy practices of those third parties. We encourage you to review their privacy
              policies.
            </p>
          </Section>

          <Section title="12. Changes to This Policy">
            <p>
              We may update this Privacy Policy from time to time. We will notify you of significant
              changes by posting the new policy in the app or by email. Your continued use of the
              Service after changes constitutes acceptance.
            </p>
          </Section>

          <Section title="13. Contact Us">
            <p>
              If you have any questions, concerns, or requests regarding this Privacy Policy, please contact:
            </p>
            <p className="font-medium text-white">
              privacy@quby.app
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
