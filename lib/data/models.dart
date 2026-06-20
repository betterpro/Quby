import 'package:flutter/material.dart';

// ── Color helpers ─────────────────────────────────────────────────────────────

Color colorFromHex(String hex) =>
    Color(int.parse(hex.replaceFirst('#', '0xFF')));

String colorToHex(Color c) =>
    '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

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
  final double? lat;
  final double? lng;
  final String? logoUrl;
  final String? ownerId;
  final String status;

  const Business({
    required this.id,
    required this.name,
    required this.cat,
    required this.icon,
    required this.color,
    required this.dist,
    this.offer,
    this.addr,
    this.lat,
    this.lng,
    this.logoUrl,
    this.ownerId,
    this.status = 'active',
  });

  bool get hasLocation => lat != null && lng != null;

  factory Business.fromJson(Map<String, dynamic> j) => Business(
        id: j['id'] as String,
        name: j['name'] as String,
        cat: j['category'] as String? ?? 'Services',
        icon: j['icon'] as String? ?? 'store',
        color: colorFromHex(j['color'] as String? ?? '#00B488'),
        dist: j['distance'] as String? ?? '—',
        offer: j['offer'] as String?,
        addr: j['address'] as String?,
        lat: (j['latitude'] as num?)?.toDouble(),
        lng: (j['longitude'] as num?)?.toDouble(),
        logoUrl: j['logo_url'] as String?,
        ownerId: j['owner_id'] as String?,
        status: j['status'] as String? ?? 'active',
      );
}

// ── BusinessRequest ───────────────────────────────────────────────────────────

class BusinessRequest {
  final String id;
  final String userId;
  final String name;
  final String category;
  final String? address;
  final String? description;
  final String status; // pending | approved | rejected
  final String? rejectionReason;
  final String? businessId;
  final DateTime createdAt;

  const BusinessRequest({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    this.address,
    this.description,
    required this.status,
    this.rejectionReason,
    this.businessId,
    required this.createdAt,
  });

  factory BusinessRequest.fromJson(Map<String, dynamic> j) => BusinessRequest(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        name: j['name'] as String,
        category: j['category'] as String,
        address: j['address'] as String?,
        description: j['description'] as String?,
        status: j['status'] as String,
        rejectionReason: j['rejection_reason'] as String?,
        businessId: j['business_id'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
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
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  factory Contact.fromJson(Map<String, dynamic> j) => Contact(
        id: j['id'] as String,
        name: j['name'] as String,
        handle: (j['handle'] as String?) ?? '',
        color: colorFromHex((j['color'] as String?) ?? '#5B6CE0'),
      );

  Map<String, dynamic> toJson(String ownerId) => {
        'owner_id': ownerId,
        'name': name,
        'handle': handle.isEmpty ? null : handle,
        'color': colorToHex(color),
      };

  Contact copyWith({String? id, String? name, String? handle, Color? color}) =>
      Contact(
        id: id ?? this.id,
        name: name ?? this.name,
        handle: handle ?? this.handle,
        color: color ?? this.color,
      );
}

class UserSearchResult {
  final String id;
  final String name;
  final String handle;
  final Color color;

  const UserSearchResult({
    required this.id,
    required this.name,
    required this.handle,
    required this.color,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> j) => UserSearchResult(
        id: j['id'] as String,
        name: j['name'] as String,
        handle: (j['handle'] as String?) ?? '',
        color: colorFromHex((j['avatar_color'] as String?) ?? '#5B6CE0'),
      );

  Contact toContact() => Contact(
        id: '',
        name: name,
        handle: handle,
        color: color,
      );

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
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
  final Contact createdBy;
  final List<Contact> splitWith;
  final DateTime date;
  final String? category;
  final DateTime? editedAt;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.createdBy,
    required this.splitWith,
    required this.date,
    this.category,
    this.editedAt,
  });

  bool get isEdited => editedAt != null;

  double get perPerson => amount / (splitWith.length + 1);

  Expense copyWith({
    String? title,
    double? amount,
    List<Contact>? splitWith,
    String? category,
    DateTime? editedAt,
  }) =>
      Expense(
        id: id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        paidBy: paidBy,
        createdBy: createdBy,
        splitWith: splitWith ?? this.splitWith,
        date: date,
        category: category ?? this.category,
        editedAt: editedAt ?? this.editedAt,
      );
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

  Group copyWith({
    List<GroupMember>? members,
    List<Expense>? expenses,
  }) =>
      Group(
        id: id,
        name: name,
        members: members ?? this.members,
        expenses: expenses ?? this.expenses,
        color: color,
        emoji: emoji,
      );
}

// ── Rewards ───────────────────────────────────────────────────────────────────

class Perk {
  final String id;
  final String? businessId;
  final String title;
  final String subtitle;
  final int cost;
  final String icon;
  final Color color;

  const Perk({
    required this.id,
    this.businessId,
    required this.title,
    required this.subtitle,
    required this.cost,
    required this.icon,
    required this.color,
  });

  factory Perk.fromJson(Map<String, dynamic> j) => Perk(
        id: j['id'] as String,
        businessId: j['business_id'] as String?,
        title: j['title'] as String,
        subtitle: j['subtitle'] as String,
        cost: j['cost_points'] as int,
        icon: j['icon'] as String,
        color: colorFromHex(j['color'] as String),
      );
}

class StampCard {
  final String businessId;
  final String businessName;
  final String businessIcon;
  final Color businessColor;
  final int stampCount;
  final int goal;

  const StampCard({
    required this.businessId,
    required this.businessName,
    required this.businessIcon,
    required this.businessColor,
    required this.stampCount,
    required this.goal,
  });
}
