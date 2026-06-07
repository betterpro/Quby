import 'package:flutter/material.dart';

// ── Color helpers ─────────────────────────────────────────────────────────────

Color colorFromHex(String hex) =>
    Color(int.parse(hex.replaceFirst('#', '0xFF')));

String colorToHex(Color c) =>
    '#${c.value.toRadixString(16).substring(2).toUpperCase()}';

// ── Business ──────────────────────────────────────────────────────────────────

class Business {
  final String id;
  final String name;
  final String cat;
  final String icon;
  final Color color;
  final String dist;
  final String? offer;
  final String? addr;

  const Business({
    required this.id,
    required this.name,
    required this.cat,
    required this.icon,
    required this.color,
    required this.dist,
    this.offer,
    this.addr,
  });

  factory Business.fromJson(Map<String, dynamic> j) => Business(
        id: j['id'] as String,
        name: j['name'] as String,
        cat: j['category'] as String,
        icon: j['icon'] as String,
        color: colorFromHex(j['color'] as String),
        dist: j['distance'] as String,
        offer: j['offer'] as String?,
        addr: j['address'] as String?,
      );
}

// ── Contact ───────────────────────────────────────────────────────────────────

class Contact {
  final String id;
  final String name;
  final String handle;
  final Color color;

  const Contact({
    required this.id,
    required this.name,
    required this.handle,
    required this.color,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
}

// ── Transaction ───────────────────────────────────────────────────────────────

enum TransactionType { payment, topup, send, receive, refund }

class Transaction {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final bool isDebit;
  final DateTime date;
  final TransactionType type;
  final String? businessId;
  final String? icon;
  final Color? iconColor;

  const Transaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isDebit,
    required this.date,
    required this.type,
    this.businessId,
    this.icon,
    this.iconColor,
  });

  factory Transaction.fromJson(Map<String, dynamic> j) => Transaction(
        id: j['id'] as String,
        title: j['title'] as String,
        subtitle: j['subtitle'] as String,
        amount: (j['amount'] as num).toDouble(),
        isDebit: j['is_debit'] as bool,
        date: DateTime.parse(j['date'] as String),
        type: TransactionType.values.firstWhere(
          (t) => t.name == j['type'],
          orElse: () => TransactionType.payment,
        ),
        businessId: j['business_id'] as String?,
        icon: j['icon'] as String?,
        iconColor: j['icon_color'] != null
            ? colorFromHex(j['icon_color'] as String)
            : null,
      );

  Map<String, dynamic> toJson(String userId) => {
        'id': id,
        'user_id': userId,
        'title': title,
        'subtitle': subtitle,
        'amount': amount,
        'is_debit': isDebit,
        'date': date.toIso8601String(),
        'type': type.name,
        'business_id': businessId,
        'icon': icon,
        'icon_color': iconColor != null ? colorToHex(iconColor!) : null,
      };
}

// ── Group / Expense ───────────────────────────────────────────────────────────

class GroupMember {
  final Contact contact;
  final double balance; // positive = they owe you, negative = you owe them

  const GroupMember({
    required this.contact,
    required this.balance,
  });
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final Contact paidBy;
  final List<Contact> splitWith;
  final DateTime date;
  final String? category;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.splitWith,
    required this.date,
    this.category,
  });

  double get perPerson => amount / (splitWith.length + 1);
}

class Group {
  final String id;
  final String name;
  final List<GroupMember> members;
  final List<Expense> expenses;
  final Color color;
  final String? emoji;

  const Group({
    required this.id,
    required this.name,
    required this.members,
    required this.expenses,
    required this.color,
    this.emoji,
  });

  double get myBalance => members.fold(0.0, (sum, m) => sum + m.balance);
  double get totalSpend => expenses.fold(0.0, (sum, e) => sum + e.amount);
}
