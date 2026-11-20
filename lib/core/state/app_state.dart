import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/business_types.dart';
import '../models/models.dart';

/// App-wide ChangeNotifier holding all business, ledger, cashbox, stock & note data.
/// Everything is persisted automatically to SharedPreferences.
class AppState extends ChangeNotifier {
  // ---------- profile ----------
  String phone = '';
  String ownerName = '';
  String nid = '';
  String businessAge = '';
  String address = '';

  bool get isRegistered => phone.isNotEmpty && businesses.isNotEmpty;

  String get displayName => ownerName.isNotEmpty ? ownerName : businessName;

  String get initials {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .take(2);
    final r = parts.map((e) => e.characters.first.toUpperCase()).join();
    return r.isEmpty ? '?' : r;
  }

  void saveProfile({
    required String name,
    required String nid,
    required String age,
    required String address,
  }) {
    ownerName = name;
    this.nid = nid;
    businessAge = age;
    this.address = address;
    _dirty();
  }

  void logout() {
    phone = '';
    tabIndex = 0;
    notifyListeners();
  }

  // ---------- navigation (bottom tabs: 0 Tally, 1 Cashbox, 2 TaliPay) ----------
  int tabIndex = 0;
  void setTab(int i) {
    tabIndex = i;
    notifyListeners();
  }

  // ---------- businesses ----------
  final List<Business> businesses = [];
  String? currentId;

  Business? get current {
    if (businesses.isEmpty) return null;
    return businesses.firstWhere(
      (b) => b.id == currentId,
      orElse: () => businesses.first,
    );
  }

  String get activeBusinessId => current?.id ?? '';
  String get businessName => current?.name ?? 'আমার ব্যবসা';

  void addBusiness(String name, BusinessType type) {
    final b = Business(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      type: type,
      isPrimary: businesses.isEmpty,
    );
    businesses.add(b);
    currentId = b.id;
    _dirty();
  }

  void switchBusiness(String id) {
    currentId = id;
    notifyListeners();
  }

  void setPrimary(String id) {
    for (final b in businesses) {
      b.isPrimary = b.id == id;
    }
    _dirty();
  }

  void editBusiness(String id, String name, BusinessType type) {
    final b = businesses.firstWhere((e) => e.id == id);
    b.name = name;
    b.type = type;
    _dirty();
  }

  bool deleteBusiness(String id) {
    if (businesses.length <= 1) return false;
    businesses.removeWhere((b) => b.id == id);
    _allParties.removeWhere((p) => p.businessId == id);
    _allTxns.removeWhere((t) => t.businessId == id);
    _allProducts.removeWhere((p) => p.businessId == id);
    _allNotes.removeWhere((n) => n.businessId == id);
    _allCashEntries.removeWhere((c) => c.businessId == id);
    if (!businesses.any((b) => b.isPrimary)) businesses.first.isPrimary = true;
    if (currentId == id) currentId = businesses.first.id;
    _dirty();
    return true;
  }

  // ---------- per-business storage lists ----------
  final List<Party> _allParties = [];
  final List<PartyTxn> _allTxns = [];
  final List<Product> _allProducts = [];
  final List<Note> _allNotes = [];
  final List<CashEntry> _allCashEntries = [];

  bool _belongsTo(String itemBizId, String bizId) =>
      itemBizId.isEmpty || itemBizId == bizId;

  // ---------- customers / suppliers ----------
  List<Party> partiesFor(String bizId) =>
      _allParties.where((p) => _belongsTo(p.businessId, bizId)).toList();

  List<Party> get parties => partiesFor(activeBusinessId);

  int customerCountFor(String bizId) =>
      partiesFor(bizId).where((p) => p.isCustomer).length;

  int supplierCountFor(String bizId) =>
      partiesFor(bizId).where((p) => !p.isCustomer).length;

  int get customerCount => customerCountFor(activeBusinessId);
  int get supplierCount => supplierCountFor(activeBusinessId);

  Party addParty(Party p, {double openingDue = 0, DateTime? openingDate}) {
    final saved = Party(
      id: p.id,
      businessId: p.businessId.isEmpty ? activeBusinessId : p.businessId,
      name: p.name,
      phone: p.phone,
      isCustomer: p.isCustomer,
      createdAt: p.createdAt,
    );
    _allParties.add(saved);
    if (openingDue > 0) {
      _allTxns.add(PartyTxn(
        businessId: saved.businessId,
        partyId: saved.id,
        isGave: true,
        amount: openingDue,
        note: 'পূর্বের বাকি (জের)',
        date: openingDate ?? DateTime.now(),
      ));
    }
    _dirty();
    return saved;
  }

  void deleteParty(String partyId) {
    _allParties.removeWhere((p) => p.id == partyId);
    _allTxns.removeWhere((t) => t.partyId == partyId);
    _dirty();
  }

  Party? partyById(String partyId) {
    for (final p in _allParties) {
      if (p.id == partyId) return p;
    }
    return null;
  }

  // ---------- party transactions (ledger) ----------
  List<PartyTxn> get txns => _allTxns
      .where((t) => _belongsTo(t.businessId, activeBusinessId))
      .toList();

  List<PartyTxn> partyTxns(String partyId) {
    final list = _allTxns.where((t) => t.partyId == partyId).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Positive = পাবো (receivable), Negative = দেবো (payable)
  double partyBalance(String partyId) {
    var b = 0.0;
    for (final t in _allTxns) {
      if (t.partyId != partyId) continue;
      b += t.isGave ? t.amount : -t.amount;
    }
    return b;
  }

  DateTime partyLastActivity(Party p) {
    DateTime latest = p.createdAt;
    for (final t in _allTxns) {
      if (t.partyId == p.id && t.date.isAfter(latest)) {
        latest = t.date;
      }
    }
    return latest;
  }

  double totalReceivableFor(String bizId) {
    var s = 0.0;
    for (final p in partiesFor(bizId)) {
      final b = partyBalance(p.id);
      if (b > 0) s += b;
    }
    return s;
  }

  double totalPayableFor(String bizId) {
    var s = 0.0;
    for (final p in partiesFor(bizId)) {
      final b = partyBalance(p.id);
      if (b < 0) s += b.abs();
    }
    return s;
  }

  double get totalReceivable => totalReceivableFor(activeBusinessId);
  double get totalPayable => totalPayableFor(activeBusinessId);

  void addPartyTxn({
    required String partyId,
    required bool isGave,
    required double amount,
    String note = '',
    DateTime? date,
    bool sendMessage = false,
  }) {
    if (amount <= 0) return;
    _allTxns.add(PartyTxn(
      businessId: activeBusinessId,
      partyId: partyId,
      isGave: isGave,
      amount: amount,
      note: note,
      date: date ?? DateTime.now(),
    ));
    if (sendMessage && messageBalance > 0) {
      messageBalance--;
    }
    _dirty();
  }

  void deletePartyTxn(String txnId) {
    _allTxns.removeWhere((t) => t.id == txnId);
    _dirty();
  }

  // ---------- stock ----------
  List<Product> get products => _allProducts
      .where((p) => _belongsTo(p.businessId, activeBusinessId))
      .toList();

  void addProduct(Product p) {
    _allProducts.add(Product(
      id: p.id,
      businessId: p.businessId.isEmpty ? activeBusinessId : p.businessId,
      name: p.name,
      unit: p.unit,
    ));
    _dirty();
  }

  void deleteProduct(String id) {
    _allProducts.removeWhere((p) => p.id == id);
    _dirty();
  }

  // ---------- notes ----------
  List<Note> get notes => _allNotes
      .where((n) => _belongsTo(n.businessId, activeBusinessId))
      .toList();

  void addNote(String text) {
    _allNotes.add(Note(businessId: activeBusinessId, text: text));
    _dirty();
  }

  void toggleNote(Note n) {
    n.done = !n.done;
    _dirty();
  }

  void deleteNote(String id) {
    _allNotes.removeWhere((n) => n.id == id);
    _dirty();
  }

  // ---------- cashbox ----------
  List<CashEntry> get cashEntries => _allCashEntries
      .where((c) => _belongsTo(c.businessId, activeBusinessId))
      .toList();

  void addCash(CashType type, double amount, {String note = '', DateTime? date}) {
    if (amount <= 0) return;
    _allCashEntries.add(CashEntry(
      businessId: activeBusinessId,
      type: type,
      amount: amount,
      note: note,
      date: date ?? DateTime.now(),
    ));
    _dirty();
  }

  static DateTime dayStart(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Full cashbox summary for [from, to) including opening cash before [from].
  Map<String, double> cashSummary(DateTime from, DateTime to) {
    final m = <String, double>{
      'open': 0,
      'cashSale': 0,
      'dueCollect': 0,
      'ownerGave': 0,
      'cashBuy': 0,
      'supplierPay': 0,
      'expense': 0,
      'ownerTook': 0,
    };

    for (final c in cashEntries) {
      if (c.date.isBefore(from)) {
        m['open'] = m['open']! + (c.type.isIn ? c.amount : -c.amount);
      } else if (c.date.isBefore(to)) {
        m[c.type.name] = (m[c.type.name] ?? 0) + c.amount;
      }
    }

    final partyTypes = {for (final p in parties) p.id: p.isCustomer};
    for (final t in txns) {
      final isCust = partyTypes[t.partyId];
      if (isCust == null) continue;
      if (isCust && !t.isGave) {
        // Customer paid due => cash inflow
        if (t.date.isBefore(from)) {
          m['open'] = m['open']! + t.amount;
        } else if (t.date.isBefore(to)) {
          m['dueCollect'] = m['dueCollect']! + t.amount;
        }
      } else if (!isCust && t.isGave) {
        // Paid supplier => cash outflow
        if (t.date.isBefore(from)) {
          m['open'] = m['open']! - t.amount;
        } else if (t.date.isBefore(to)) {
          m['supplierPay'] = m['supplierPay']! + t.amount;
        }
      }
    }

    final totalIn = m['open']! +
        m['cashSale']! +
        m['dueCollect']! +
        m['ownerGave']!;
    final totalOut = m['cashBuy']! +
        m['supplierPay']! +
        m['expense']! +
        m['ownerTook']!;
    m['totalIn'] = totalIn;
    m['totalOut'] = totalOut;
    m['todayIn'] = m['cashSale']! + m['dueCollect']! + m['ownerGave']!;
    m['todayOut'] = totalOut;
    m['balance'] = totalIn - totalOut;
    return m;
  }

  Map<String, double> get todaySummary {
    final from = dayStart(DateTime.now());
    final to = from.add(const Duration(days: 1));
    return cashSummary(from, to);
  }

  double todayCashOf(CashType type) => todaySummary[type.name] ?? 0;
  double get todaySale => todaySummary['cashSale'] ?? 0;
  double get todayDueCollect => todaySummary['dueCollect'] ?? 0;
  double get todaySupplierPay => todaySummary['supplierPay'] ?? 0;
  double get totalIn => todaySummary['todayIn'] ?? 0;
  double get totalOut => todaySummary['todayOut'] ?? 0;
  double get currentCash => todaySummary['balance'] ?? 0;

  // ---------- inbox notifications ----------
  final Set<String> _readInboxIds = {'m18', 'm19'};

  int get unread => inbox.where((m) => m.isUnread).length;

  void markMessageRead(InboxMessage msg) {
    if (!msg.isUnread) return;
    msg.isUnread = false;
    _readInboxIds.add(msg.id);
    notifyListeners();
  }

  void markAllRead() {
    for (final m in inbox) {
      m.isUnread = false;
      _readInboxIds.add(m.id);
    }
    notifyListeners();
  }

  static const String _qrBody =
      'টালিখাতা ও টালিপে সার্ভিসে স্বাগতম! ৳২,০০০ পর্যন্ত বাংলা QR '
      'পেমেন্টে চার্জ একদম ফ্রি*।\n\n'
      '📌 পেমেন্ট নিন বাংলা QR-এ:\n'
      '•৳২,০০০ পর্যন্ত পেমেন্টে মার্চেন্ট এর সার্ভিস চার্জ নেই।\n'
      '•ডিজিটাল পেমেন্টের সুযোগ দিলে বিক্রি ও আয় বাড়ে।\n'
      '•ভাংতির ঝামেলা বা ক্যাশ হারানোর সমস্যা নাই।\n'
      '•জাল টাকার ভয় নাই।\n'
      '•ক্যাশ থেকে টাকা গড়মিল হয় না।\n\n'
      '📌 ৫ কারনে টালিপে বাংলা QR সেরা:\n'
      '•পেমেন্ট নেয়ার সাথে সাথে তা ট্রান্সফার করা যায় MFS ও ব্যাংকে।\n'
      '•মালিক ও স্টাফ দুইজনই নোটিফিকেশন পায়।\n'
      '•পেমেন্ট এলেই ভয়েস সাউন্ড কনফার্মেশন।\n'
      '•মোবাইল রিচার্জে ১.৮% কমিশন।\n'
      '•আনলিমিটেড বিল পেমেন্ট।';

  final List<InboxMessage> inbox = [
    InboxMessage(
      id: 'm1',
      title: '২ মিনিটেই পাবেন বাংলা QR!',
      preview: 'অ্যাপে ফর্ম পূরণ করুন।',
      time: '১১ মিনিট আগে',
      fromMerchantCampaign: true,
      thumb: InboxThumbType.qr2Min,
      body: _qrBody,
    ),
    InboxMessage(
      id: 'm2',
      title: 'টালিখাতা গোল্ডে বেশি সুবিধা🤗',
      preview: 'কাস্টমারকে মাসের হিসাব এক রিপোর্টে পাঠানো যায়।',
      time: '২৬ মিনিট আগে',
      thumb: InboxThumbType.reportDownload,
      body: 'টালিখাতা গোল্ড ব্যবহার করে কাস্টমারকে মাসের হিসাব এক রিপোর্টে পাঠান সহজেই।',
    ),
    InboxMessage(
      id: 'm3',
      title: 'বাংলা QR নিন মাত্র ২ মিনিটেই।',
      preview: '৳২,০০০ পর্যন্ত বাংলা QR পেমেন্টে চার্জ একদম ফ্রি*!',
      time: '৪১ মিনিট আগে',
      fromMerchantCampaign: true,
      thumb: InboxThumbType.noCost,
      body: _qrBody,
    ),
    InboxMessage(
      id: 'm4',
      title: 'ব্যবসার সকল হিসাব এক অ্যাপে!',
      preview: 'হিসাব থাকবে ক্লিয়ার, আপনি থাকবেন ঝামেলাযুক্ত।',
      time: '১ ঘণ্টা আগে',
      thumb: InboxThumbType.tkBook,
      body: 'ব্যবসার সকল হিসাব এক অ্যাপে! হিসাব থাকবে ক্লিয়ার, আপনি থাকবেন ঝামেলা মুক্ত।',
    ),
    InboxMessage(
      id: 'm5',
      title: '২ মিনিটেই পাবেন বাংলা QR!',
      preview: 'অ্যাপে ফর্ম পূরণ করুন।',
      time: '৪ ঘণ্টা আগে',
      fromMerchantCampaign: true,
      thumb: InboxThumbType.qr2Min,
      body: _qrBody,
    ),
    InboxMessage(
      id: 'm6',
      title: 'বাকির পাই-টু-পাই হিসাব রাখতে চান?',
      preview: 'পুরানো খাতা থেকে বাকির সব কাস্টমার টালিখাতায় যোগ করুন।',
      time: '৪ ঘণ্টা আগে',
      thumb: InboxThumbType.tkBook,
      body: 'পুরানো খাতা থেকে বাকির সব কাস্টমার টালিখাতায় যোগ করুন এবং পাই-টু-পাই হিসাব রাখুন।',
    ),
    InboxMessage(
      id: 'm7',
      title: 'বাকি নিয়ে কাস্টমারের সাথে ভুল বোঝাবুঝি',
      preview: 'টালিখাতা অ্যাপে বাকির হিসাব রাখুন, ভুল বোঝাবুঝি দূর করুন।',
      time: '২০ ঘণ্টা আগে',
      thumb: InboxThumbType.tkBook,
      body: 'টালিখাতা অ্যাপে বাকির হিসাব রাখুন, কাস্টমারের সাথে ভুল বোঝাবুঝি দূর করুন।',
    ),
    InboxMessage(
      id: 'm8',
      title: 'স্টক হিসাবের মাধ্যমে মালামাল লিস্ট করছে',
      preview: 'ঢাকার ফখরুল ভাই। আপনিও টালিখাতা গোল্ড নিন আর ব্যবহার করুন স্টক হিসাব।',
      time: '২২ ঘণ্টা আগে',
      thumb: InboxThumbType.tkGold,
      body: 'ঢাকার ফখরুল ভাই স্টক হিসাবের মাধ্যমে মালামাল লিস্ট করছেন। আপনিও টালিখাতা গোল্ড নিন।',
    ),
    InboxMessage(
      id: 'm9',
      title: 'টালিখাতায় বাকির হিসাব রাখুন ঝামেলা ছাড়াই!',
      preview: 'সহজেই কাস্টমারের বাকির হিসাব রাখুন এবং নিরাপদে ব্যবসা করুন।',
      time: '২২ ঘণ্টা আগে',
      thumb: InboxThumbType.tkBook,
      body: 'সহজেই কাস্টমারের বাকির হিসাব রাখুন এবং নিরাপদে ব্যবসা করুন।',
    ),
    InboxMessage(
      id: 'm10',
      title: 'ফোন হারালেও হারাবেনা হিসাব!📕☂️',
      preview: 'টালিখাতা অ্যাপে আপনার ব্যবসার হিসাব থাকবে আজীবন সুরক্ষিত।',
      time: '১ দিন আগে',
      thumb: InboxThumbType.tkBook,
      body: 'ডাটা ব্যাকআপ নিয়ে রাখলে ফোন হারালেও আপনার ব্যবসার হিসাব থাকবে আজীবন সুরক্ষিত।',
    ),
    InboxMessage(
      id: 'm11',
      title: 'মুন্সিগঞ্জের মেরাজ ভাই তাগাদা মেসেজ পাঠিয়ে',
      preview: 'বাকি আদায় করছেন খুব সহজেই!',
      time: '১ দিন আগে',
      thumb: InboxThumbType.tkBook,
      body: 'মুন্সিগঞ্জের মেরাজ ভাই তাগাদা মেসেজ পাঠিয়ে বাকি আদায় করছেন খুব সহজেই!',
    ),
    InboxMessage(
      id: 'm12',
      title: 'টালিখাতা গোল্ডে বেশি সুবিধা',
      preview: 'একসাথে একাধিক বাকির কাস্টমারকে তাগাদা পাঠানো যায়, সময় বাঁচে।',
      time: '১ দিন আগে',
      thumb: InboxThumbType.groupTagada,
      body: 'গ্রুপ তাগাদা ফিচারের মাধ্যমে একসাথে একাধিক বাকির কাস্টমারকে তাগাদা পাঠানো যায়।',
    ),
    InboxMessage(
      id: 'm13',
      title: 'বাকির হিসাব এন্ট্রি দিলেই কাস্টমার পাবে SMS🧧✉️',
      preview: 'SMS এ পাঠান বাকির তথ্য, কাস্টমারের সাথে সম্পর্ক থাকবে ঝামেলা মুক্ত।',
      time: '১ দিন আগে',
      thumb: InboxThumbType.tkBook,
      body: 'SMS এ পাঠান বাকির তথ্য, কাস্টমারের সাথে সম্পর্ক থাকবে ঝামেলা মুক্ত।',
    ),
    InboxMessage(
      id: 'm14',
      title: 'অভিনন্দন!🥳🌟',
      preview: 'আপনি ৩০ দিনের টালিখাতা গোল্ড ফ্রি ট্রায়াল ব্যবহার করছেন।',
      time: '২ দিন আগে',
      thumb: InboxThumbType.tkGold,
      body: 'অভিনন্দন! আপনি ৩০ দিনের টালিখাতা গোল্ড ফ্রি ট্রায়াল ব্যবহার করছেন।',
    ),
    InboxMessage(
      id: 'm15',
      title: 'পুরানো বাকি আদায় এখন অনেক সহজ।',
      preview: 'ঢাকার সুমন ভাইয়ের দেড় বছরের পুরানো বাকি আদায় হয়েছে টালিখাতা অ্যাপে!',
      time: '২ দিন আগে',
      thumb: InboxThumbType.tkBook,
      body: 'ঢাকার সুমন ভাইয়ের দেড় বছরের পুরানো বাকি আদায় হয়েছে টালিখাতা অ্যাপে!',
    ),
    InboxMessage(
      id: 'm16',
      title: 'আপনার অ্যাপে চালু হয়েছে টালিখাতা গোল্ড।✨',
      preview: 'পাচ্ছেন মাল্টি ব্যবসা, স্টক হিসাব ও আনলিমিটেড লেনদেন সুবিধা।',
      time: '২ দিন আগে',
      thumb: InboxThumbType.tkGold,
      body: 'আপনার অ্যাপে চালু হয়েছে টালিখাতা গোল্ড। পাচ্ছেন মাল্টি ব্যবসা, স্টক হিসাব ও আনলিমিটেড লেনদেন সুবিধা।',
    ),
    InboxMessage(
      id: 'm17',
      title: 'SMS এর মাধ্যমে বাকি লেনদেনের রশিদ পাচ্ছে কাস্টমার!',
      preview: 'টালিখাতার মাধ্যমে মেসেজে বাকির রশিদ পাঠিয়ে টাকা আদায় করুন।',
      time: '৩ দিন আগে',
      thumb: InboxThumbType.tkBook,
      body: 'টালিখাতার মাধ্যমে মেসেজে বাকির রশিদ পাঠিয়ে টাকা আদায় করুন।',
    ),
    InboxMessage(
      id: 'm18',
      title: 'বাংলা QR নিন মাত্র ২ মিনিটেই।',
      preview: '৳২,০০০ পর্যন্ত বাংলা QR পেমেন্টে চার্জ একদম ফ্রি*!',
      time: '৩ দিন আগে',
      fromMerchantCampaign: true,
      thumb: InboxThumbType.noCost,
      isUnread: false,
      body: _qrBody,
    ),
    InboxMessage(
      id: 'm19',
      title: '৫০ লাখ ব্যবসায়ীর আস্থা!💥✌️',
      preview: 'দেশজুড়ে ব্যবসায়ীদের সবচেয়ে বড় নেটওয়ার্ক টালিখাতা অ্যাপ।',
      time: '৩ দিন আগে',
      thumb: InboxThumbType.tkBook,
      isUnread: false,
      body: 'দেশজুড়ে ব্যবসায়ীদের সবচেয়ে বড় নেটওয়ার্ক টালিখাতা অ্যাপ।',
    ),
  ];

  // ---------- tali-message ----------
  int messageBalance = 10;
  void buyMessages(int n) {
    messageBalance += n;
    notifyListeners();
  }

  // ---------- settings ----------
  bool decimalOn = true;
  bool notificationSound = true;
  bool voiceNotification = true;

  void setDecimal(bool v) {
    decimalOn = v;
    notifyListeners();
  }

  void setNotificationSound(bool v) {
    notificationSound = v;
    notifyListeners();
  }

  void setVoiceNotification(bool v) {
    voiceNotification = v;
    notifyListeners();
  }

  // ---------- backup ----------
  bool needsBackup = false;
  DateTime lastBackup = DateTime(2026, 11, 16, 20, 0);

  void backupNow() {
    needsBackup = false;
    lastBackup = DateTime.now();
    notifyListeners();
  }

  void _dirty() {
    needsBackup = true;
    notifyListeners();
  }

  // ---------- permanent storage (shared_preferences) ----------
  static const _storeKey = 'tallykhata_state_v2';
  SharedPreferences? _prefs;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw =
        _prefs!.getString(_storeKey) ?? _prefs!.getString('tallykhata_state_v1');
    if (raw == null) return;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      phone = j['phone'] as String? ?? '';
      ownerName = j['ownerName'] as String? ?? '';
      nid = j['nid'] as String? ?? '';
      businessAge = j['businessAge'] as String? ?? '';
      address = j['address'] as String? ?? '';
      currentId = j['currentId'] as String?;

      BusinessType typeOf(String id) => id == personalType.id
          ? personalType
          : businessTypes.firstWhere((t) => t.id == id,
              orElse: () => businessTypes.last);

      businesses
        ..clear()
        ..addAll((j['businesses'] as List? ?? []).map((e) {
          final m = e as Map<String, dynamic>;
          return Business(
            id: m['id'] as String,
            name: m['name'] as String,
            type: typeOf(m['type'] as String),
            isPrimary: m['isPrimary'] as bool? ?? false,
          );
        }));
      _allParties
        ..clear()
        ..addAll((j['parties'] as List? ?? [])
            .map((e) => Party.fromJson(e as Map<String, dynamic>)));
      _allTxns
        ..clear()
        ..addAll((j['txns'] as List? ?? [])
            .map((e) => PartyTxn.fromJson(e as Map<String, dynamic>)));
      _allProducts
        ..clear()
        ..addAll((j['products'] as List? ?? [])
            .map((e) => Product.fromJson(e as Map<String, dynamic>)));
      _allNotes
        ..clear()
        ..addAll((j['notes'] as List? ?? [])
            .map((e) => Note.fromJson(e as Map<String, dynamic>)));
      _allCashEntries
        ..clear()
        ..addAll((j['cashEntries'] as List? ?? [])
            .map((e) => CashEntry.fromJson(e as Map<String, dynamic>)));

      // Migrate legacy map cash entries if present
      if (_allCashEntries.isEmpty && j['cash'] is Map) {
        final c = j['cash'] as Map<String, dynamic>;
        for (final t in CashType.values) {
          final v = (c[t.name] as num?)?.toDouble() ?? 0;
          if (v > 0) {
            _allCashEntries.add(CashEntry(
              businessId: activeBusinessId,
              type: t,
              amount: v,
            ));
          }
        }
      }

      final readIds = (j['readInboxIds'] as List?)?.cast<String>();
      if (readIds != null) {
        _readInboxIds
          ..clear()
          ..addAll(readIds);
        for (final m in inbox) {
          m.isUnread = !_readInboxIds.contains(m.id);
        }
      }
      messageBalance = j['messageBalance'] as int? ?? messageBalance;
      decimalOn = j['decimalOn'] as bool? ?? true;
      notificationSound = j['notificationSound'] as bool? ?? true;
      voiceNotification = j['voiceNotification'] as bool? ?? true;
      needsBackup = j['needsBackup'] as bool? ?? false;
      final lb = j['lastBackup'] as String?;
      if (lb != null) lastBackup = DateTime.parse(lb);
    } catch (_) {
      // start fresh if corrupted
    }
  }

  void _persist() {
    final prefs = _prefs;
    if (prefs == null) return;
    final j = <String, dynamic>{
      'phone': phone,
      'ownerName': ownerName,
      'nid': nid,
      'businessAge': businessAge,
      'address': address,
      'currentId': currentId,
      'businesses': businesses.map((e) => e.toJson()).toList(),
      'parties': _allParties.map((e) => e.toJson()).toList(),
      'txns': _allTxns.map((e) => e.toJson()).toList(),
      'products': _allProducts.map((e) => e.toJson()).toList(),
      'notes': _allNotes.map((e) => e.toJson()).toList(),
      'cashEntries': _allCashEntries.map((e) => e.toJson()).toList(),
      'readInboxIds': _readInboxIds.toList(),
      'messageBalance': messageBalance,
      'decimalOn': decimalOn,
      'notificationSound': notificationSound,
      'voiceNotification': voiceNotification,
      'needsBackup': needsBackup,
      'lastBackup': lastBackup.toIso8601String(),
    };
    prefs.setString(_storeKey, jsonEncode(j));
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    _persist();
  }

  BusinessType get personal => personalType;
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
  }

  static AppState read(BuildContext context) {
    return context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
  }
}
