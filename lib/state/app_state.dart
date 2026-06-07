import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/seed_data.dart';

class AppState extends ChangeNotifier {
  double _balance = 42.60;
  int _points = 1840;
  late List<Transaction> _transactions;
  late List<Group> _groups;
  bool _isDark = false;

  AppState() {
    _transactions = List.from(SEED_TRANSACTIONS);
    _groups = buildSeedGroups();
  }

  double get balance => _balance;
  int get points => _points;
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<Group> get groups => List.unmodifiable(_groups);
  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  void pay({
    required String businessId,
    required double amount,
    required String method,
  }) {
    final biz = BUSINESSES.firstWhere(
      (b) => b.id == businessId,
      orElse: () => BUSINESSES.first,
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
  }

  void topUp({
    required double amount,
    required String source,
  }) {
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
  }

  void send({
    required Contact contact,
    required double amount,
    String? note,
  }) {
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
  }

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

    // Update member balances
    final updatedMembers = group.members.map((m) {
      if (splitWith.any((c) => c.id == m.contact.id)) {
        return GroupMember(
          contact: m.contact,
          balance: m.balance + perPerson,
        );
      }
      return m;
    }).toList();

    final updatedGroup = Group(
      id: group.id,
      name: group.name,
      members: updatedMembers,
      expenses: [expense, ...group.expenses],
      color: group.color,
      emoji: group.emoji,
    );

    _groups = [
      ..._groups.sublist(0, groupIndex),
      updatedGroup,
      ..._groups.sublist(groupIndex + 1),
    ];

    notifyListeners();
  }

  void settleDebt({
    required String groupId,
    required String memberId,
  }) {
    final groupIndex = _groups.indexWhere((g) => g.id == groupId);
    if (groupIndex == -1) return;

    final group = _groups[groupIndex];
    final member = group.members.firstWhere(
      (m) => m.contact.id == memberId,
      orElse: () => group.members.first,
    );

    final settlementAmount = member.balance.abs();
    if (member.balance < 0) {
      // We owe them — pay them
      _balance -= settlementAmount;
    }

    final updatedMembers = group.members.map((m) {
      if (m.contact.id == memberId) {
        return GroupMember(contact: m.contact, balance: 0.0);
      }
      return m;
    }).toList();

    final updatedGroup = Group(
      id: group.id,
      name: group.name,
      members: updatedMembers,
      expenses: group.expenses,
      color: group.color,
      emoji: group.emoji,
    );

    _groups = [
      ..._groups.sublist(0, groupIndex),
      updatedGroup,
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
      members: members
          .map((c) => GroupMember(contact: c, balance: 0.0))
          .toList(),
      expenses: [],
      color: color,
      emoji: emoji,
    );

    _groups = [group, ..._groups];
    notifyListeners();
  }
}

