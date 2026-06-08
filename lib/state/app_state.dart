import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/seed_data.dart';
import '../services/supabase_service.dart';

class AppState extends ChangeNotifier {
  double _balance = 150.00;
  int _points = 1240;
  List<Transaction> _transactions = [];
  List<Business> _businesses = List.from(BUSINESSES);
  late List<Group> _groups;
  bool _isDark = false;
  bool _initialized = true;
  bool _loading = false;

  AppState() {
    _groups = buildSeedGroups();
    _transactions = List.from(SEED_TRANSACTIONS);
  }

  double get balance => _balance;
  int get points => _points;
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<Business> get businesses => List.unmodifiable(_businesses);
  List<Group> get groups => List.unmodifiable(_groups);
  bool get isDark => _isDark;
  bool get initialized => _initialized;
  bool get loading => _loading;

  // ── Boot ───────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (SupabaseService.isSignedIn) {
      await _loadFromSupabase();
    }
    _loading = false;
    _initialized = true;
    notifyListeners();
  }

  Future<void> reload() async {
    _loading = true;
    notifyListeners();
    await _loadFromSupabase();
    _loading = false;
    notifyListeners();
  }

  Future<void> _loadFromSupabase() async {
    try {
      final profile = await SupabaseService.getProfile();
      if (profile != null) {
        _balance = (profile['balance'] as num).toDouble();
        _points = profile['points'] as int;
        _isDark = profile['is_dark'] as bool? ?? false;
      } else {
        await SupabaseService.upsertProfile(
          balance: _balance,
          points: _points,
          isDark: _isDark,
        );
      }

      final remoteBiz = await SupabaseService.getBusinesses();
      if (remoteBiz.isNotEmpty) _businesses = remoteBiz;

      final remoteTx = await SupabaseService.getTransactions();
      if (remoteTx.isNotEmpty) _transactions = remoteTx;
    } catch (_) {
      // Stay with seed data on error
    }
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
    final biz = _businesses.firstWhere(
      (b) => b.id == businessId,
      orElse: () => _businesses.first,
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

  // ── Groups ─────────────────────────────────────────────────────────────────

  void addExpense({
    required String groupId,
    required String title,
    required double amount,
    required List<Contact> splitWith,
    String? category,
  }) {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return;

    final group = _groups[groupIndex];
    final perPerson = amount / (splitWith.length + 1);

    final expense = Expense(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      amount: amount,
      paidBy: ME,
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

    _groups = [
      ..._groups.sublist(0, groupIndex),
      Group(
        id: group.id,
        name: group.name,
        members: updatedMembers,
        expenses: [expense, ...group.expenses],
        color: group.color,
        emoji: group.emoji,
      ),
      ..._groups.sublist(groupIndex + 1),
    ];

    notifyListeners();
  }

  void settleDebt({required String groupId, required String memberId}) {
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
      Group(
        id: group.id,
        name: group.name,
        members: updatedMembers,
        expenses: group.expenses,
        color: group.color,
        emoji: group.emoji,
      ),
      ..._groups.sublist(groupIndex + 1),
    ];

    notifyListeners();
  }

  void createGroup({
    required String name,
    required List<Contact> members,
    required Color color,
    String? emoji,
  }) {
    final group = Group(
      id: 'grp_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      members: members.map((c) => GroupMember(contact: c, balance: 0.0)).toList(),
      expenses: [],
      color: color,
      emoji: emoji,
    );

    _groups = [group, ..._groups];
    notifyListeners();
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
      );
    } catch (_) {}
  }
}
