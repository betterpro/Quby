import { Suspense } from "react";
import LoginForm from "./login-form";

export default function LoginPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-brand-ink-bg flex items-center justify-center">
        <div className="w-8 h-8 border-2 border-[#00B488] border-t-transparent rounded-full animate-spin" />
      </div>
    }>
      <LoginForm />
    </Suspense>
  );
}
