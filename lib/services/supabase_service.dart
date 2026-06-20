import 'dart:convert';

import 'dart:io' show Platform;

import 'dart:math';

import 'package:crypto/crypto.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models.dart';

class SupabaseService {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static const _googleWebClientId =
      String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

  static const _googleIosClientId =
      String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  static bool _initialized = false;

  static SupabaseClient get _db => Supabase.instance.client;

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static Future<void> initialize() async {
    if (!isConfigured) return;

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

  static void _ensureAuthReady() {
    if (!isConfigured) {
      throw Exception(
        'Supabase is not configured. Copy dart-defines.json.example to '
        'dart-defines.json and run with '
        '--dart-define-from-file=dart-defines.json',
      );
    }

    if (!_initialized) {
      throw Exception(
        'Could not connect to Supabase. Check your URL and anon key.',
      );
    }
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
    _ensureAuthReady();

    final res =
        await _db.auth.signInWithPassword(email: email, password: password);

    if (res.user == null) throw Exception('Sign in failed');
  }

  static Future<bool> signUpWithEmail(String email, String password) async {
    _ensureAuthReady();

    final res = await _db.auth.signUp(email: email, password: password);

    if (res.user == null) throw Exception('Sign up failed');

    return res.session == null;
  }

  static Future<void> signInWithGoogle() async {
    _ensureAuthReady();

    if (_googleWebClientId.isEmpty) {
      throw Exception(
        'Google Sign-In is not configured. Run the app with '
        '--dart-define-from-file=dart-defines.json and set GOOGLE_WEB_CLIENT_ID.',
      );
    }

    final googleSignIn = GoogleSignIn(
      clientId: Platform.isIOS && _googleIosClientId.isNotEmpty
          ? _googleIosClientId
          : null,
      serverClientId: _googleWebClientId,
      scopes: const ['email', 'profile'],
    );

    try {
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) throw Exception('cancelled');

      final googleAuth = await googleUser.authentication;

      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception(
          'No ID token from Google. On Android, register your debug SHA-1 '
          'and package name com.quby.app in Google Cloud Console, and use '
          'the Web OAuth client ID as GOOGLE_WEB_CLIENT_ID.',
        );
      }

      await _db.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );
    } on PlatformException catch (e) {
      throw Exception(googleSignInErrorMessage(e));
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Maps Google Sign-In platform errors to actionable messages.
  static String googleSignInErrorMessage(Object error) {
    if (error is PlatformException) {
      final code = error.code;
      final message = (error.message ?? '').toLowerCase();

      if (code == 'sign_in_canceled' ||
          message.contains('cancel') ||
          message.contains('12501')) {
        return 'cancelled';
      }

      // Android DEVELOPER_ERROR — wrong package name or missing SHA-1.
      if (code == 'sign_in_failed' &&
          (message.contains('10') || message.contains('developer_error'))) {
        return 'Google Sign-In is misconfigured for Android. In Google Cloud '
            'Console, create an Android OAuth client for package '
            'com.quby.app and add your debug SHA-1 fingerprint '
            '(run: cd android && ./gradlew signingReport).';
      }

      if (error.message?.isNotEmpty == true) {
        return error.message!;
      }

      return 'Google Sign-In failed ($code).';
    }

    final msg = error.toString().replaceFirst('Exception: ', '');

    if (msg.contains('cancelled')) return 'cancelled';

    if (msg.contains('Unacceptable audience') ||
        msg.contains('invalid claim')) {
      return 'Google client ID mismatch. Use the same Web client ID in '
          'dart-defines.json (GOOGLE_WEB_CLIENT_ID) and in Supabase '
          'Auth → Providers → Google.';
    }

    if (msg.contains('No ID token')) return msg;

    return msg.isNotEmpty ? msg : 'Google sign-in failed. Please try again.';
  }

  static Future<void> signInWithApple() async {
    _ensureAuthReady();

    if (!Platform.isIOS) {
      throw UnsupportedError('Apple Sign In is only available on iOS');
    }

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
    String? name,
    String? handle,
    String? avatarColor,
  }) async {
    final uid = userId;

    if (uid == null) return;

    final data = <String, dynamic>{
      'id': uid,
      'balance': balance,
      'points': points,
      'is_dark': isDark,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (name != null) data['name'] = name;

    if (handle != null) data['handle'] = handle;

    if (avatarColor != null) data['avatar_color'] = avatarColor;

    await _db.from('profiles').upsert(data);
  }

  static Contact contactFromProfile(Map<String, dynamic> profile, String uid) =>
      Contact(
        id: uid,
        name: profile['name'] as String? ?? 'User',
        handle: profile['handle'] as String? ?? '',
        color: colorFromHex((profile['avatar_color'] as String?) ?? '#5B6CE0'),
      );

  static String? _nameFromAuthUser() {
    final user = _db.auth.currentUser;
    if (user == null) return null;

    final meta = user.userMetadata;
    if (meta == null) return null;

    for (final key in ['full_name', 'name']) {
      final value = meta[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }

  static String _resolveProfileName(Map<String, dynamic>? profile) {
    final fromProfile = profile?['name'] as String?;
    if (fromProfile != null &&
        fromProfile.isNotEmpty &&
        fromProfile != 'User') {
      return fromProfile;
    }

    return _nameFromAuthUser() ?? fromProfile ?? 'User';
  }

  static Future<void> ensureProfileNameFromAuth() async {
    final uid = userId;
    if (uid == null) return;

    final profile = await getProfile();
    final currentName = profile?['name'] as String? ?? 'User';
    if (currentName.isNotEmpty && currentName != 'User') return;

    final authName = _nameFromAuthUser();
    if (authName == null) return;

    await _db.from('profiles').update({
      'name': authName,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', uid);
  }

  // ── Contacts ───────────────────────────────────────────────────────────────

  static Future<List<Contact>> getContacts() async {
    final uid = userId;

    if (uid == null) return [];

    final rows =
        await _db.from('contacts').select().eq('owner_id', uid).order('name');

    return rows.map((r) => Contact.fromJson(r)).toList();
  }

  static Future<Contact> insertContact(Contact contact) async {
    final uid = userId!;

    final row = await _db
        .from('contacts')
        .insert(contact.toJson(uid))
        .select()
        .single();

    return Contact.fromJson(row);
  }

  static Future<Contact> getOrCreateSelfContact() async {
    final uid = userId!;

    final profile = await getProfile();

    final name = _resolveProfileName(profile);

    final handle = profile?['handle'] as String? ?? '';

    final color = (profile?['avatar_color'] as String?) ?? '#5B6CE0';

    final existing = await _db
        .from('contacts')
        .select()
        .eq('owner_id', uid)
        .eq('linked_user_id', uid)
        .maybeSingle();

    if (existing != null) {
      final contact = Contact.fromJson(existing);
      final profileColor = colorFromHex(color);

      if (contact.name != name ||
          contact.handle != handle ||
          contact.color != profileColor) {
        final row = await _db
            .from('contacts')
            .update({
              'name': name,
              'handle': handle.isEmpty ? null : handle,
              'color': color,
            })
            .eq('id', contact.id)
            .select()
            .single();

        return Contact.fromJson(row);
      }

      return contact;
    }

    final row = await _db
        .from('contacts')
        .insert({
          'owner_id': uid,
          'linked_user_id': uid,
          'name': name,
          'handle': handle.isEmpty ? null : handle,
          'color': color,
        })
        .select()
        .single();

    return Contact.fromJson(row);
  }

  // ── Businesses ─────────────────────────────────────────────────────────────

  static const _businessesBucket = 'businesses';

  static Map<String, String> get storageAuthHeaders => {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
      };

  /// Extract `{businessId}/logo.ext` from a stored logo URL or path.
  static String? businessLogoStoragePath(String logoUrl) {
    const markers = [
      '/storage/v1/object/public/$_businessesBucket/',
      '/storage/v1/object/authenticated/$_businessesBucket/',
      '/storage/v1/object/sign/$_businessesBucket/',
    ];

    for (final marker in markers) {
      final idx = logoUrl.indexOf(marker);
      if (idx != -1) {
        return logoUrl.substring(idx + marker.length).split('?').first;
      }
    }

    if (!logoUrl.contains('://') && logoUrl.contains('/')) {
      return logoUrl.split('?').first;
    }

    return null;
  }

  /// Private Supabase buckets need the authenticated object URL + anon headers.
  static String? resolveBusinessLogoUrl(String? logoUrl) {
    if (logoUrl == null || logoUrl.isEmpty) return null;

    final path = businessLogoStoragePath(logoUrl);
    if (path == null || !isConfigured) return logoUrl;

    return '$supabaseUrl/storage/v1/object/authenticated/$_businessesBucket/$path';
  }

  static Future<List<Business>> getBusinesses() async {
    if (!isConfigured || !_initialized) return [];

    try {
      final rows = await _db.from('businesses').select().order('name');
      final businesses = <Business>[];

      for (final row in rows) {
        try {
          businesses.add(Business.fromJson(row));
        } catch (_) {}
      }

      return businesses;
    } catch (_) {
      return [];
    }
  }

  static Future<Business?> getBusiness(String id) async {
    final row =
        await _db.from('businesses').select().eq('id', id).maybeSingle();

    return row != null ? Business.fromJson(row) : null;
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

  // ── Groups ─────────────────────────────────────────────────────────────────

  static Future<List<Group>> getGroups() async {
    _ensureAuthReady();
    final uid = userId;

    if (uid == null) return [];

    final groupRows = await _db
        .from('split_groups')
        .select()
        .eq('owner_id', uid)
        .order('created_at', ascending: false);

    final groups = <Group>[];

    for (final g in groupRows) {
      final groupId = g['id'] as String;

      final memberRows = await _db
          .from('group_members')
          .select('balance, contacts(*)')
          .eq('group_id', groupId);

      final members = memberRows.map((m) {
        final contact = Contact.fromJson(m['contacts'] as Map<String, dynamic>);

        return GroupMember(
          contact: contact,
          balance: (m['balance'] as num).toDouble(),
        );
      }).toList();

      final expenseRows = await _db
          .from('group_expenses')
          .select()
          .eq('group_id', groupId)
          .order('date', ascending: false);

      final expenses = <Expense>[];

      for (final e in expenseRows) {
        final expenseId = e['id'] as String;

        final paidById = e['paid_by_contact_id'] as String;

        final createdById = e['created_by_contact_id'] as String? ?? paidById;

        final paidByRow =
            await _db.from('contacts').select().eq('id', paidById).single();

        final createdByRow = createdById == paidById
            ? paidByRow
            : await _db
                .from('contacts')
                .select()
                .eq('id', createdById)
                .single();

        final splitRows = await _db
            .from('expense_splits')
            .select('contacts(*)')
            .eq('expense_id', expenseId);

        final splitWith = splitRows
            .map((s) => Contact.fromJson(s['contacts'] as Map<String, dynamic>))
            .toList();

        expenses.add(Expense(
          id: expenseId,
          title: e['title'] as String,
          amount: (e['amount'] as num).toDouble(),
          paidBy: Contact.fromJson(paidByRow),
          createdBy: Contact.fromJson(createdByRow),
          splitWith: splitWith,
          date: DateTime.parse(e['date'] as String),
          category: e['category'] as String?,
          editedAt: e['edited_at'] != null
              ? DateTime.parse(e['edited_at'] as String)
              : null,
        ));
      }

      groups.add(Group(
        id: groupId,
        name: g['name'] as String,
        members: members,
        expenses: expenses,
        color: colorFromHex(g['color'] as String),
        emoji: g['emoji'] as String?,
      ));
    }

    return groups;
  }

  static Future<Group> createGroup({
    required String name,
    required List<Contact> members,
    required Color color,
    String? emoji,
  }) async {
    _ensureAuthReady();
    final uid = userId;
    if (uid == null) {
      throw Exception('Sign in to create groups.');
    }

    final selfContact = await getOrCreateSelfContact();
    final memberContacts = <Contact>[];
    for (final contact in members) {
      if (!memberContacts.any((c) => c.id == contact.id)) {
        memberContacts.add(contact);
      }
    }
    if (!memberContacts.any((c) => c.id == selfContact.id)) {
      memberContacts.insert(0, selfContact);
    }

    final groupRow = await _db
        .from('split_groups')
        .insert({
          'owner_id': uid,
          'name': name,
          'emoji': emoji,
          'color': colorToHex(color),
        })
        .select()
        .single();

    final groupId = groupRow['id'] as String;

    final loadedMembers = <GroupMember>[];

    for (final contact in memberContacts) {
      await _db.from('group_members').insert({
        'group_id': groupId,
        'contact_id': contact.id,
        'balance': 0,
      });

      loadedMembers.add(GroupMember(contact: contact, balance: 0));
    }

    return Group(
      id: groupId,
      name: name,
      members: loadedMembers,
      expenses: const [],
      color: color,
      emoji: emoji,
    );
  }

  static Future<void> insertGroupExpense({
    required String groupId,
    required Expense expense,
    required List<GroupMember> updatedMembers,
  }) async {
    await _db.from('group_expenses').insert({
      'id': expense.id,
      'group_id': groupId,
      'title': expense.title,
      'amount': expense.amount,
      'paid_by_contact_id': expense.paidBy.id,
      'created_by_contact_id': expense.createdBy.id,
      'category': expense.category,
      'date': expense.date.toIso8601String(),
    });

    for (final contact in expense.splitWith) {
      await _db.from('expense_splits').insert({
        'expense_id': expense.id,
        'contact_id': contact.id,
      });
    }

    for (final member in updatedMembers) {
      await _db
          .from('group_members')
          .update({
            'balance': member.balance,
          })
          .eq('group_id', groupId)
          .eq('contact_id', member.contact.id);
    }
  }

  static Future<void> updateGroupExpense({
    required String groupId,
    required Expense expense,
    required List<GroupMember> updatedMembers,
  }) async {
    await _db.from('group_expenses').update({
      'title': expense.title,
      'amount': expense.amount,
      'category': expense.category,
      'edited_at': expense.editedAt?.toIso8601String(),
    }).eq('id', expense.id);

    await _db.from('expense_splits').delete().eq('expense_id', expense.id);

    for (final contact in expense.splitWith) {
      await _db.from('expense_splits').insert({
        'expense_id': expense.id,
        'contact_id': contact.id,
      });
    }

    for (final member in updatedMembers) {
      await _db
          .from('group_members')
          .update({
            'balance': member.balance,
          })
          .eq('group_id', groupId)
          .eq('contact_id', member.contact.id);
    }
  }

  static Future<void> updateMemberBalance({
    required String groupId,
    required String contactId,
    required double balance,
  }) async {
    await _db
        .from('group_members')
        .update({
          'balance': balance,
        })
        .eq('group_id', groupId)
        .eq('contact_id', contactId);
  }

  static Future<void> addGroupMembers({
    required String groupId,
    required List<Contact> contacts,
  }) async {
    for (final contact in contacts) {
      await _db.from('group_members').upsert({
        'group_id': groupId,
        'contact_id': contact.id,
        'balance': 0,
      });
    }
  }

  static Future<List<UserSearchResult>> searchUsers({
    required String query,
    String? groupId,
  }) async {
    _ensureAuthReady();

    final rows = await _db.rpc('search_users', params: {
      'p_query': query,
      'p_group_id': groupId,
    });

    if (rows is! List) return [];

    return rows
        .map((r) => UserSearchResult.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  static Future<Contact> addExistingUserToGroup({
    required String groupId,
    required String userId,
  }) async {
    _ensureAuthReady();

    final result = await _db.rpc('add_existing_user_to_group', params: {
      'p_group_id': groupId,
      'p_target_user_id': userId,
    });

    if (result is! Map) {
      throw Exception('Could not add user to group.');
    }

    return Contact.fromJson(Map<String, dynamic>.from(result));
  }

  static Future<Map<String, dynamic>> inviteUserToGroup({
    required String groupId,
    required String email,
  }) async {
    return invokeFunction(
      'invite-to-group',
      body: {
        'group_id': groupId,
        'email': email.trim().toLowerCase(),
      },
    );
  }

  static Future<void> acceptPendingGroupInvites() async {
    _ensureAuthReady();
    if (!isSignedIn) return;

    try {
      await _db.rpc('accept_my_group_invites');
    } catch (_) {}
  }

  // ── Rewards ────────────────────────────────────────────────────────────────

  static Future<List<Perk>> getPerks() async {
    final rows = await _db.from('perks').select().order('cost_points');

    return rows.map((r) => Perk.fromJson(r)).toList();
  }

  static Future<List<StampCard>> getStampCards() async {
    final uid = userId;

    if (uid == null) return [];

    final rows = await _db
        .from('user_stamps')
        .select('stamp_count, goal, businesses(*)')
        .eq('user_id', uid);

    return rows.map((r) {
      final biz = r['businesses'] as Map<String, dynamic>;

      return StampCard(
        businessId: biz['id'] as String,
        businessName: biz['name'] as String,
        businessIcon: biz['icon'] as String,
        businessColor: colorFromHex(biz['color'] as String),
        stampCount: r['stamp_count'] as int,
        goal: r['goal'] as int,
      );
    }).toList();
  }

  static Future<void> redeemPerk(Perk perk, int currentPoints) async {
    final uid = userId;

    if (uid == null) return;

    if (currentPoints < perk.cost) {
      throw Exception('Not enough points');
    }

    await _db.from('profiles').update({
      'points': currentPoints - perk.cost,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', uid);
  }

  static Future<void> incrementStamp(String businessId) async {
    final uid = userId;

    if (uid == null) return;

    final existing = await _db
        .from('user_stamps')
        .select()
        .eq('user_id', uid)
        .eq('business_id', businessId)
        .maybeSingle();

    if (existing == null) {
      await _db.from('user_stamps').insert({
        'user_id': uid,
        'business_id': businessId,
        'stamp_count': 1,
      });
    } else {
      await _db
          .from('user_stamps')
          .update({
            'stamp_count': (existing['stamp_count'] as int) + 1,
          })
          .eq('user_id', uid)
          .eq('business_id', businessId);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String friendlyError(Object error) {
    final msg = error.toString().toLowerCase();

    if (msg.contains('pgrst205') ||
        msg.contains('could not find the table') ||
        (msg.contains('split_groups') && msg.contains('does not exist')) ||
        (msg.contains('relation') && msg.contains('does not exist'))) {
      return 'Splits database not set up. Run migrations 002 and 003 in the Supabase SQL editor.';
    }

    if (msg.contains('not configured') || msg.contains('could not connect')) {
      return error.toString().replaceFirst('Exception: ', '');
    }

    if (msg.contains('jwt') || msg.contains('not authenticated')) {
      return 'Sign in again to continue.';
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  // ── Stripe ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> invokeFunction(
    String name, {
    Map<String, dynamic>? body,
  }) async {
    _ensureAuthReady();

    try {
      final response = await _db.functions.invoke(name, body: body ?? {});

      if (response.status != 200) {
        throw Exception(
            _functionErrorMessage(name, response.status, response.data));
      }

      final data = response.data;
      if (data is! Map) {
        throw Exception('Unexpected response from server.');
      }

      return Map<String, dynamic>.from(data);
    } on FunctionException catch (e) {
      throw Exception(_functionErrorMessage(name, e.status, e.details));
    }
  }

  static String _functionErrorMessage(
    String name,
    int status,
    dynamic details,
  ) {
    if (status == 404 ||
        details.toString().contains('NOT_FOUND') ||
        details.toString().contains('not found')) {
      return 'Payment service "$name" is not deployed. From the project root run: '
          'npx supabase link --project-ref tbsuulymqbxzlzzahvgc && '
          'npx supabase secrets set STRIPE_SECRET_KEY=sk_test_... && '
          'npx supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_... && '
          'npx supabase functions deploy create-payment-intent && '
          'npx supabase functions deploy stripe-webhook';
    }

    if (details is Map && details['error'] != null) {
      return details['error'] as String;
    }

    if (details is Map && details['message'] != null) {
      return details['message'] as String;
    }

    if (status == 401) {
      return 'Sign in again to continue.';
    }

    return 'Request failed ($status).';
  }

  static Future<bool> waitForStripePayment(
    String paymentIntentId, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    _ensureAuthReady();

    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      final row = await _db
          .from('stripe_payments')
          .select('status')
          .eq('stripe_payment_intent_id', paymentIntentId)
          .maybeSingle();

      if (row?['status'] == 'succeeded') return true;
      if (row?['status'] == 'failed') {
        throw Exception('Payment failed. Please try again.');
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    return false;
  }

  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';

    final random = Random.secure();

    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  static String _sha256(String input) {
    final bytes = utf8.encode(input);

    return sha256.convert(bytes).toString();
  }
}
