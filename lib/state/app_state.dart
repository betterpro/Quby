import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models.dart';
import '../services/supabase_service.dart';

const _uuid = Uuid();

class AppState extends ChangeNotifier {
  double _balance = 0;
  int _points = 0;
  List<Transaction> _transactions = [];
  List<Business> _businesses = [];
  List<Group> _groups = [];
  List<Contact> _contacts = [];
  List<Perk> _perks = [];
  List<StampCard> _stampCards = [];
  Contact? _me;
  bool _isDark = false;
  bool _initialized = false;
  bool _loading = false;

  double get balance => _balance;
  int get points => _points;
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<Business> get businesses => List.unmodifiable(_businesses);
  List<Group> get groups => List.unmodifiable(_groups);
  List<Contact> get contacts => List.unmodifiable(_contacts);
  List<Perk> get perks => List.unmodifiable(_perks);
  List<StampCard> get stampCards => List.unmodifiable(_stampCards);
  Contact get me =>
      _me ??
      const Contact(
        id: '',
        name: 'User',
        handle: '',
        color: Color(0xFF5B6CE0),
      );
  bool get isDark => _isDark;
  bool get initialized => _initialized;
  bool get loading => _loading;

  // ── Boot ───────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();
    await _loadBusinessesFromSupabase();
    if (SupabaseService.isSignedIn) {
      await _loadUserDataFromSupabase();
    }
    _loading = false;
    _initialized = true;
    notifyListeners();
  }

  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    await _loadBusinessesFromSupabase();
    if (SupabaseService.isSignedIn) {
      await _loadUserDataFromSupabase();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> refreshBusinesses() async {
    await _loadBusinessesFromSupabase();
    notifyListeners();
  }

  Future<Business?> resolveBusiness(String id) async {
    for (final biz in _businesses) {
      if (biz.id == id) return biz;
    }

    try {
      final fetched = await SupabaseService.getBusiness(id);
      if (fetched != null) {
        _businesses = [..._businesses, fetched];
        notifyListeners();
      }
      return fetched;
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    _balance = 0;
    _points = 0;
    _transactions = [];
    _businesses = [];
    _groups = [];
    _contacts = [];
    _perks = [];
    _stampCards = [];
    _me = null;
    _isDark = false;
    notifyListeners();
  }

  Future<void> _loadBusinessesFromSupabase() async {
    _businesses = await SupabaseService.getBusinesses();
  }

  Future<void> _loadUserDataFromSupabase() async {
    if (!SupabaseService.isSignedIn) return;

    try {
      await SupabaseService.ensureProfileNameFromAuth();
      final profile = await SupabaseService.getProfile();
      final uid = SupabaseService.userId;

      if (profile != null && uid != null) {
        _balance = (profile['balance'] as num?)?.toDouble() ?? 0;
        _points = profile['points'] as int? ?? 0;
        _isDark = profile['is_dark'] as bool? ?? false;
        _me = SupabaseService.contactFromProfile(profile, uid);
      } else if (uid != null) {
        await SupabaseService.upsertProfile(
          balance: _balance,
          points: _points,
          isDark: _isDark,
        );
      }
    } catch (_) {}

    try {
      _me = await SupabaseService.getOrCreateSelfContact();
    } catch (_) {}

    try {
      _transactions = await SupabaseService.getTransactions();
    } catch (_) {}

    try {
      _contacts = await SupabaseService.getContacts();
    } catch (_) {}

    try {
      await SupabaseService.acceptPendingGroupInvites();
    } catch (_) {}

    try {
      _groups = await SupabaseService.getGroups();
    } catch (_) {}

    try {
      _perks = await SupabaseService.getPerks();
    } catch (_) {}

    try {
      _stampCards = await SupabaseService.getStampCards();
    } catch (_) {}
  }

  // ── Theme ──────────────────────────────────────────────────────────────────

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
    _syncProfile();
  }

  // ── Payments ───────────────────────────────────────────────────────────────

  void pay({
    required String businessId,
    required double amount,
    required String method,
  }) {
    if (amount > _balance) {
      throw StateError('Insufficient balance. Top up your wallet first.');
    }

    final biz = _businesses.firstWhere(
      (b) => b.id == businessId,
      orElse: () => _businesses.isNotEmpty
          ? _businesses.first
          : throw StateError('No businesses available'),
    );

    _balance -= amount;
    _points += (amount * 10).round();

    final tx = Transaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: biz.name,
      subtitle: '${biz.cat} · Just now',
      amount: amount,
      isDebit: true,
      date: DateTime.now(),
      type: TransactionType.payment,
      businessId: businessId,
      icon: biz.icon,
      iconColor: biz.color,
    );

    _transactions.insert(0, tx);
    notifyListeners();
    _persistTransaction(tx);
    _syncProfile();
    _incrementStampAsync(businessId);
  }

  void topUp({required double amount, required String source}) {
    _balance += amount;

    final tx = Transaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Top Up',
      subtitle: '$source · Just now',
      amount: amount,
      isDebit: false,
      date: DateTime.now(),
      type: TransactionType.topup,
      icon: 'up',
      iconColor: const Color(0xFF00B488),
    );

    _transactions.insert(0, tx);
    notifyListeners();
    _persistTransaction(tx);
    _syncProfile();
  }

  void send({required Contact contact, required double amount, String? note}) {
    _balance -= amount;

    final tx = Transaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: contact.name,
      subtitle: 'Sent · Just now',
      amount: amount,
      isDebit: true,
      date: DateTime.now(),
      type: TransactionType.send,
      icon: 'send',
      iconColor: contact.color,
    );

    _transactions.insert(0, tx);
    notifyListeners();
    _persistTransaction(tx);
    _syncProfile();
  }

  Future<void> redeemPerk(Perk perk) async {
    if (_points < perk.cost) return;
    _points -= perk.cost;
    notifyListeners();
    try {
      await SupabaseService.redeemPerk(perk, _points + perk.cost);
      await _syncProfile();
    } catch (_) {
      _points += perk.cost;
      notifyListeners();
    }
  }

  // ── Groups ─────────────────────────────────────────────────────────────────

  Future<void> addExpense({
    required String groupId,
    required String title,
    required double amount,
    required List<Contact> splitWith,
    String? category,
  }) async {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return;

    final group = _groups[groupIndex];
    final perPerson = amount / (splitWith.length + 1);

    final expense = Expense(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      paidBy: _me!,
      createdBy: _me!,
      splitWith: splitWith,
      date: DateTime.now(),
      category: category,
    );

    final updatedMembers = group.members.map((m) {
      if (splitWith.any((c) => c.id == m.contact.id)) {
        return GroupMember(contact: m.contact, balance: m.balance + perPerson);
      }
      return m;
    }).toList();

    final updatedGroup = group.copyWith(
      members: updatedMembers,
      expenses: [expense, ...group.expenses],
    );

    _groups = [
      ..._groups.sublist(0, groupIndex),
      updatedGroup,
      ..._groups.sublist(groupIndex + 1),
    ];
    notifyListeners();

    try {
      await SupabaseService.insertGroupExpense(
        groupId: groupId,
        expense: expense,
        updatedMembers: updatedMembers,
      );
    } catch (_) {}
  }

  Future<void> updateExpense({
    required String groupId,
    required Expense original,
    required String title,
    required double amount,
    required List<Contact> splitWith,
    String? category,
  }) async {
    if (original.createdBy.id != _me?.id) return;

    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return;

    final group = _groups[groupIndex];
    final oldPerPerson = original.perPerson;
    final newPerPerson = amount / (splitWith.length + 1);

    var updatedMembers = group.members.map((m) {
      if (original.splitWith.any((c) => c.id == m.contact.id)) {
        return GroupMember(
          contact: m.contact,
          balance: m.balance - oldPerPerson,
        );
      }
      return m;
    }).toList();

    updatedMembers = updatedMembers.map((m) {
      if (splitWith.any((c) => c.id == m.contact.id)) {
        return GroupMember(
          contact: m.contact,
          balance: m.balance + newPerPerson,
        );
      }
      return m;
    }).toList();

    final updatedExpense = original.copyWith(
      title: title,
      amount: amount,
      splitWith: splitWith,
      category: category,
      editedAt: DateTime.now(),
    );

    final updatedExpenses = group.expenses
        .map((e) => e.id == original.id ? updatedExpense : e)
        .toList();

    final updatedGroup = group.copyWith(
      members: updatedMembers,
      expenses: updatedExpenses,
    );

    _groups = [
      ..._groups.sublist(0, groupIndex),
      updatedGroup,
      ..._groups.sublist(groupIndex + 1),
    ];
    notifyListeners();

    try {
      await SupabaseService.updateGroupExpense(
        groupId: groupId,
        expense: updatedExpense,
        updatedMembers: updatedMembers,
      );
    } catch (_) {}
  }

  Future<void> settleDebt({
    required String groupId,
    required String memberId,
  }) async {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return;

    final group = _groups[groupIndex];
    final member = group.members.firstWhere(
      (m) => m.contact.id == memberId,
      orElse: () => group.members.first,
    );

    if (member.balance < 0) _balance -= member.balance.abs();

    final updatedMembers = group.members
        .map((m) => m.contact.id == memberId
            ? GroupMember(contact: m.contact, balance: 0.0)
            : m)
        .toList();

    _groups = [
      ..._groups.sublist(0, groupIndex),
      group.copyWith(members: updatedMembers),
      ..._groups.sublist(groupIndex + 1),
    ];

    notifyListeners();
    _syncProfile();

    try {
      await SupabaseService.updateMemberBalance(
        groupId: groupId,
        contactId: memberId,
        balance: 0,
      );
    } catch (_) {}
  }

  Future<String?> createGroup({
    required String name,
    required List<Contact> members,
    required Color color,
    String? emoji,
  }) async {
    if (!SupabaseService.isSignedIn) {
      return 'Sign in to create groups.';
    }

    try {
      final group = await SupabaseService.createGroup(
        name: name,
        members: members,
        color: color,
        emoji: emoji,
      );
      _groups = [group, ..._groups];
      notifyListeners();
      return null;
    } catch (e) {
      return SupabaseService.friendlyError(e);
    }
  }

  Future<String?> addMembersToGroup({
    required String groupId,
    required List<Contact> members,
  }) async {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return 'Group not found.';

    final group = _groups[groupIndex];
    final existingIds = group.members.map((m) => m.contact.id).toSet();
    final newContacts =
        members.where((c) => !existingIds.contains(c.id)).toList();

    if (newContacts.isEmpty) return 'No new members to add.';

    final updatedMembers = [
      ...group.members,
      ...newContacts.map((c) => GroupMember(contact: c, balance: 0)),
    ];

    _groups = [
      ..._groups.sublist(0, groupIndex),
      group.copyWith(members: updatedMembers),
      ..._groups.sublist(groupIndex + 1),
    ];
    notifyListeners();

    try {
      await SupabaseService.addGroupMembers(
        groupId: groupId,
        contacts: newContacts,
      );
      return null;
    } catch (e) {
      return SupabaseService.friendlyError(e);
    }
  }

  Future<List<UserSearchResult>> searchUsers({
    required String query,
    String? groupId,
  }) async {
    try {
      return await SupabaseService.searchUsers(
        query: query,
        groupId: groupId,
      );
    } catch (_) {
      return [];
    }
  }

  Future<String?> addExistingUserToGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      final contact = await SupabaseService.addExistingUserToGroup(
        groupId: groupId,
        userId: userId,
      );

      _upsertContact(contact);
      _addContactToGroupLocally(groupId: groupId, contact: contact);
      return null;
    } catch (e) {
      return SupabaseService.friendlyError(e);
    }
  }

  Future<String?> inviteUserToGroup({
    required String groupId,
    required String email,
  }) async {
    try {
      final result = await SupabaseService.inviteUserToGroup(
        groupId: groupId,
        email: email,
      );

      if (result['status'] == 'added') {
        final contactMap = result['contact'];
        if (contactMap is Map) {
          final contact =
              Contact.fromJson(Map<String, dynamic>.from(contactMap));
          _upsertContact(contact);
          _addContactToGroupLocally(groupId: groupId, contact: contact);
        }
      }

      return null;
    } catch (e) {
      return SupabaseService.friendlyError(e);
    }
  }

  void _upsertContact(Contact contact) {
    final index = _contacts.indexWhere((c) => c.id == contact.id);
    if (index == -1) {
      _contacts = [..._contacts, contact];
    } else {
      _contacts = [
        ..._contacts.sublist(0, index),
        contact,
        ..._contacts.sublist(index + 1),
      ];
    }
  }

  void _addContactToGroupLocally({
    required String groupId,
    required Contact contact,
  }) {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return;

    final group = _groups[groupIndex];
    if (group.members.any((m) => m.contact.id == contact.id)) return;

    _groups = [
      ..._groups.sublist(0, groupIndex),
      group.copyWith(members: [
        ...group.members,
        GroupMember(contact: contact, balance: 0),
      ]),
      ..._groups.sublist(groupIndex + 1),
    ];
    notifyListeners();
  }

  Future<Contact?> addContact({
    required String name,
    String handle = '',
    Color? color,
  }) async {
    try {
      final contact = await SupabaseService.insertContact(Contact(
        id: '',
        name: name,
        handle: handle,
        color: color ?? const Color(0xFF5B6CE0),
      ));
      _contacts = [..._contacts, contact];
      notifyListeners();
      return contact;
    } catch (_) {
      return null;
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _persistTransaction(Transaction tx) async {
    try {
      await SupabaseService.insertTransaction(tx);
    } catch (_) {}
  }

  Future<void> _syncProfile() async {
    try {
      await SupabaseService.upsertProfile(
        balance: _balance,
        points: _points,
        isDark: _isDark,
        name: _me?.name,
        handle: _me?.handle,
        avatarColor: _me != null ? colorToHex(_me!.color) : null,
      );
    } catch (_) {}
  }

  Future<void> _incrementStampAsync(String businessId) async {
    try {
      await SupabaseService.incrementStamp(businessId);
      _stampCards = await SupabaseService.getStampCards();
      notifyListeners();
    } catch (_) {}
  }
}
