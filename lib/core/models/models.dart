import 'package:flutter/material.dart';

class BusinessType {
  final String id;
  final String name;
  final IconData icon;
  const BusinessType(this.id, this.name, this.icon);
}

class Business {
  final String id;
  String name;
  BusinessType type;
  bool isPrimary;

  Business({
    required this.id,
    required this.name,
    required this.type,
    this.isPrimary = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.id,
        'isPrimary': isPrimary,
      };
}

class Party {
  final String id;
  final String businessId;
  final String name;
  final String phone;
  final bool isCustomer; // false => supplier
  final DateTime createdAt;

  Party({
    String? id,
    this.businessId = '',
    required this.name,
    required this.phone,
    required this.isCustomer,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return '${parts[0].characters.first}${parts[1].characters.first}'
        .toUpperCase();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'businessId': businessId,
        'name': name,
        'phone': phone,
        'isCustomer': isCustomer,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Party.fromJson(Map<String, dynamic> j) => Party(
        id: j['id'] as String?,
        businessId: j['businessId'] as String? ?? '',
        name: j['name'] as String,
        phone: j['phone'] as String? ?? '',
        isCustomer: j['isCustomer'] as bool? ?? true,
        createdAt: j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt'] as String)
            : null,
      );
}

class PartyTxn {
  final String id;
  final String businessId;
  final String partyId;
  final bool isGave; // true = দিলাম/বেচা (pabo +), false = পেলাম (pabo -)
  final double amount;
  final String note;
  final DateTime date;

  PartyTxn({
    String? id,
    this.businessId = '',
    required this.partyId,
    required this.isGave,
    required this.amount,
    this.note = '',
    DateTime? date,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        date = date ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'businessId': businessId,
        'partyId': partyId,
        'isGave': isGave,
        'amount': amount,
        'note': note,
        'date': date.toIso8601String(),
      };

  factory PartyTxn.fromJson(Map<String, dynamic> j) => PartyTxn(
        id: j['id'] as String?,
        businessId: j['businessId'] as String? ?? '',
        partyId: j['partyId'] as String,
        isGave: j['isGave'] as bool,
        amount: (j['amount'] as num).toDouble(),
        note: j['note'] as String? ?? '',
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
      );
}

class CashEntry {
  final String id;
  final String businessId;
  final CashType type;
  final double amount;
  final String note;
  final DateTime date;

  CashEntry({
    String? id,
    this.businessId = '',
    required this.type,
    required this.amount,
    this.note = '',
    DateTime? date,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        date = date ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'businessId': businessId,
        'type': type.name,
        'amount': amount,
        'note': note,
        'date': date.toIso8601String(),
      };

  factory CashEntry.fromJson(Map<String, dynamic> j) => CashEntry(
        id: j['id'] as String?,
        businessId: j['businessId'] as String? ?? '',
        type: CashType.values.firstWhere(
          (t) => t.name == j['type'],
          orElse: () => CashType.cashSale,
        ),
        amount: (j['amount'] as num).toDouble(),
        note: j['note'] as String? ?? '',
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
      );
}

class Product {
  final String id;
  final String businessId;
  final String name;
  final String unit;
  Product({
    String? id,
    this.businessId = '',
    required this.name,
    required this.unit,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'businessId': businessId,
        'name': name,
        'unit': unit,
      };

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as String?,
        businessId: j['businessId'] as String? ?? '',
        name: j['name'] as String,
        unit: j['unit'] as String,
      );
}

class Note {
  final String id;
  final String businessId;
  String text;
  bool done;
  Note({
    String? id,
    this.businessId = '',
    required this.text,
    this.done = false,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'businessId': businessId,
        'text': text,
        'done': done,
      };

  factory Note.fromJson(Map<String, dynamic> j) => Note(
        id: j['id'] as String?,
        businessId: j['businessId'] as String? ?? '',
        text: j['text'] as String,
        done: j['done'] as bool? ?? false,
      );
}

enum InboxThumbType { qr2Min, reportDownload, noCost, tkBook, tkGold, groupTagada }

class InboxMessage {
  final String id;
  final String title;
  final String preview;
  final String time;
  final String body;
  final bool fromMerchantCampaign;
  final InboxThumbType thumb;
  bool isUnread;
  InboxMessage({
    required this.id,
    required this.title,
    required this.preview,
    required this.time,
    required this.body,
    this.fromMerchantCampaign = false,
    this.thumb = InboxThumbType.tkBook,
    this.isUnread = true,
  });
}

enum CashType { cashSale, cashBuy, expense, ownerGave, ownerTook }

extension CashTypeX on CashType {
  String get label {
    switch (this) {
      case CashType.cashSale:
        return 'ক্যাশ বেচা';
      case CashType.cashBuy:
        return 'ক্যাশ কেনা';
      case CashType.expense:
        return 'খরচ';
      case CashType.ownerGave:
        return 'মালিক দিল';
      case CashType.ownerTook:
        return 'মালিক নিল';
    }
  }

  /// true => money comes into the cashbox (green)
  bool get isIn => this == CashType.cashSale || this == CashType.ownerGave;
}
