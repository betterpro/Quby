import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models.dart';

class SupabaseService {
  static const supabaseUrl = 'https://tbsuulymqbxzlzzahvgc.supabase.co';
  static const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRic3V1bHltcWJ4emx6emFodmdjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA4MDM2MzgsImV4cCI6MjA5NjM3OTYzOH0.ddoFGKVrd8Rt4U2ZfIEq71bin5kL47k_AvxaaZFSFkI';

  static SupabaseClient get _db => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  // ── Auth ───────────────────────────────────────────────────────────────────

  static Future<void> signInAnonymously() async {
    if (_db.auth.currentSession == null) {
      await _db.auth.signInAnonymously();
    }
  }

  static String get userId => _db.auth.currentUser!.id;

  // ── Profile ────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getProfile() async {
    return await _db
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  static Future<void> upsertProfile({
    required double balance,
    required int points,
    required bool isDark,
  }) async {
    await _db.from('profiles').upsert({
      'id': userId,
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
    final rows = await _db
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false)
        .limit(100);
    return rows.map((r) => Transaction.fromJson(r)).toList();
  }

  static Future<void> insertTransaction(Transaction tx) async {
    await _db.from('transactions').insert(tx.toJson(userId));
  }
}
