import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models.dart';

class SupabaseService {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // Set to your Google OAuth Web Client ID from Google Cloud Console
  // https://console.cloud.google.com/apis/credentials
  static const _googleWebClientId = '';

  static bool _initialized = false;
  static SupabaseClient get _db => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        detectSessionInUri: false,
      ),
    );
    _initialized = true;
  }

  // ── Auth state ─────────────────────────────────────────────────────────────

  static bool get isSignedIn {
    if (!_initialized) return false;
    try {
      return _db.auth.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  static String? get userId => _initialized ? _db.auth.currentUser?.id : null;

  // ── Email auth ─────────────────────────────────────────────────────────────

  static Future<void> signInWithEmail(String email, String password) async {
    final res =
        await _db.auth.signInWithPassword(email: email, password: password);
    if (res.user == null) throw Exception('Sign in failed');
  }

  static Future<void> signUpWithEmail(String email, String password) async {
    final res = await _db.auth.signUp(email: email, password: password);
    if (res.user == null) throw Exception('Sign up failed');
  }

  // ── Google auth ────────────────────────────────────────────────────────────

  static Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      serverClientId: _googleWebClientId.isNotEmpty ? _googleWebClientId : null,
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception('cancelled');

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) throw Exception('No ID token received from Google');

    await _db.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: googleAuth.accessToken,
    );
  }

  // ── Apple auth (iOS only) ──────────────────────────────────────────────────

  static Future<void> signInWithApple() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256(rawNonce);

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) throw Exception('No identity token from Apple');

    await _db.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
  }

  static Future<void> signOut() async {
    await _db.auth.signOut();
  }

  // ── Profile ────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getProfile() async {
    final uid = userId;
    if (uid == null) return null;
    return await _db.from('profiles').select().eq('id', uid).maybeSingle();
  }

  static Future<void> upsertProfile({
    required double balance,
    required int points,
    required bool isDark,
  }) async {
    final uid = userId;
    if (uid == null) return;
    await _db.from('profiles').upsert({
      'id': uid,
      'balance': balance,
      'points': points,
      'is_dark': isDark,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ── Businesses ─────────────────────────────────────────────────────────────

  static Future<List<Business>> getBusinesses() async {
    final rows = await _db.from('businesses').select().order('name');
    return rows.map((r) => Business.fromJson(r)).toList();
  }

  // ── Transactions ───────────────────────────────────────────────────────────

  static Future<List<Transaction>> getTransactions() async {
    final uid = userId;
    if (uid == null) return [];
    final rows = await _db
        .from('transactions')
        .select()
        .eq('user_id', uid)
        .order('date', ascending: false)
        .limit(100);
    return rows.map((r) => Transaction.fromJson(r)).toList();
  }

  static Future<void> insertTransaction(Transaction tx) async {
    final uid = userId;
    if (uid == null) return;
    await _db.from('transactions').insert(tx.toJson(uid));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
            length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  static String _sha256(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
