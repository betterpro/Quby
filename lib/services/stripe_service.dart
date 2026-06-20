import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'supabase_service.dart';

class StripeService {
  static const publishableKey =
      String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

  static bool get isConfigured =>
      publishableKey.isNotEmpty && publishableKey.startsWith('pk_');

  static const _setupHint =
      'Add your Stripe test publishable key (pk_test_…) to '
      'dart-defines.json as STRIPE_PUBLISHABLE_KEY, then restart with '
      '--dart-define-from-file=dart-defines.json. Also set STRIPE_SECRET_KEY '
      'and STRIPE_WEBHOOK_SECRET in Supabase Edge Function secrets.';

  static Future<void> initialize() async {
    if (!isConfigured) return;
    Stripe.publishableKey = publishableKey;
    Stripe.urlScheme = 'quby';
    await Stripe.instance.applySettings();
  }

  /// Creates a PaymentIntent via Supabase Edge Function and presents
  /// the Stripe Payment Sheet. Returns the payment intent id on success.
  static Future<String> presentTopUpSheet({
    required double amount,
    required bool isDark,
  }) async {
    if (!isConfigured) {
      throw Exception('Stripe is not configured. $_setupHint');
    }

    if (!SupabaseService.isSignedIn) {
      throw Exception('Sign in to add money to your wallet.');
    }

    final amountCents = (amount * 100).round();
    if (amountCents < 50) {
      throw Exception('Minimum top-up is \$0.50.');
    }

    final response = await SupabaseService.invokeFunction(
      'create-payment-intent',
      body: {
        'amount_cents': amountCents,
        'currency': 'usd',
        'purpose': 'topup',
      },
    );

    final clientSecret = response['client_secret'] as String?;
    final paymentIntentId = response['payment_intent_id'] as String?;

    if (clientSecret == null ||
        clientSecret.isEmpty ||
        paymentIntentId == null ||
        paymentIntentId.isEmpty) {
      throw Exception('Could not start payment. Please try again.');
    }

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Quby',
        returnURL: 'quby://stripe-redirect',
        style: isDark ? ThemeMode.dark : ThemeMode.light,
        appearance: PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
            primary: isDark ? const Color(0xFF00D193) : const Color(0xFF00B488),
          ),
        ),
      ),
    );

    await Stripe.instance.presentPaymentSheet();

    final credited =
        await SupabaseService.waitForStripePayment(paymentIntentId);
    if (!credited) {
      throw Exception(
        'Payment received but wallet is still updating. Pull to refresh in a moment.',
      );
    }

    return paymentIntentId;
  }

  static String friendlyError(Object error) {
    if (error is StripeException) {
      final code = error.error.code;
      if (code == FailureCode.Canceled) {
        return 'Payment cancelled.';
      }
      return error.error.localizedMessage ??
          'Payment failed. Please try again.';
    }

    final raw = error.toString().replaceFirst('Exception: ', '');
    if (raw.contains('Stripe is not configured')) return raw;
    if (raw.contains('Payment service') && raw.contains('not deployed')) {
      return raw;
    }
    if (raw.contains('Stripe is not configured on the server')) {
      return 'Stripe is not configured on the server. Set STRIPE_SECRET_KEY '
          'in Supabase → Project Settings → Edge Functions → Secrets, then '
          'redeploy create-payment-intent and stripe-webhook.';
    }
    if (raw.contains('Sign in')) return raw;
    return raw.isNotEmpty ? raw : 'Payment failed. Please try again.';
  }
}
