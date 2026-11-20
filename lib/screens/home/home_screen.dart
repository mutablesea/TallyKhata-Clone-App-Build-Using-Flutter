import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/models.dart';
import '../../core/routes/app_routes.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/bn.dart';
import '../../core/utils/cashbox_pdf.dart';
import '../../core/widgets/gold_page.dart';
import '../../core/widgets/primary_button.dart';
import '../business/business_switcher_sheet.dart';

class _Action {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  _Action(this.icon, this.color, this.label, this.onTap);
}

enum _SortBy { none, amountAsc, amountDesc, dateDesc, dateAsc }

/// Tally Home tab with quick actions, animated Bangla QR banner, and collapsible customer sheet.
/// Uses NestedScrollView + ValueNotifier so "মোট পাবো / মোট দেবো" smoothly fades & shrinks out on slide-up.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _summaryProgress = ValueNotifier<double>(1.0);
  bool _filterCustomer = false;
  bool _filterSupplier = false;
  _SortBy _sortBy = _SortBy.none;

  static const _avatarColors = [
    Color(0xFFD5F5D8),
    Color(0xFFFBF3CE),
    Color(0xFFFBE0E6),
    Color(0xFFDCECFB),
  ];

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    // Fade and shrink out "মোট পাবো / মোট দেবো" over the first 125px of slide-up
    final p = (1.0 - (_scrollCtrl.offset / 125.0)).clamp(0.0, 1.0);
    if ((p - _summaryProgress.value).abs() > 0.004) {
      _summaryProgress.value = p;
    }
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _summaryProgress.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Party> _filteredParties(AppState app) {
    final q = _searchCtrl.text.trim().toLowerCase();
    var list = app.parties.where((p) {
      if (_filterCustomer && !_filterSupplier && !p.isCustomer) return false;
      if (_filterSupplier && !_filterCustomer && p.isCustomer) return false;
      if (q.isNotEmpty &&
          !p.name.toLowerCase().contains(q) &&
          !p.phone.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();

    switch (_sortBy) {
      case _SortBy.amountAsc:
        list.sort((a, b) =>
            app.partyBalance(a.id).abs().compareTo(app.partyBalance(b.id).abs()));
        break;
      case _SortBy.amountDesc:
        list.sort((a, b) =>
            app.partyBalance(b.id).abs().compareTo(app.partyBalance(a.id).abs()));
        break;
      case _SortBy.dateAsc:
        list.sort((a, b) =>
            app.partyLastActivity(a).compareTo(app.partyLastActivity(b)));
        break;
      case _SortBy.dateDesc:
      case _SortBy.none:
        list.sort((a, b) =>
            app.partyLastActivity(b).compareTo(app.partyLastActivity(a)));
        break;
    }
    return list;
  }

  /// Customer/Supplier filter & sort dialog.
  Future<void> _showFilterDialog() async {
    var cust = _filterCustomer;
    var supp = _filterSupplier;
    var sort = _sortBy;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          Widget sortPill(String label, _SortBy value) {
            final sel = sort == value;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => setD(() => sort = sel ? _SortBy.none : value),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.greyBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel ? AppColors.red : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        sel
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 18,
                        color: sel ? AppColors.red : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13.5, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Dialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'ফিল্টার',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => Navigator.pop(ctx),
                        child: const CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.greyBg,
                          child: Icon(Icons.close,
                              size: 16, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _filterCheckRow(
                      'কাস্টমার', cust, (v) => setD(() => cust = v)),
                  const SizedBox(height: 10),
                  _filterCheckRow(
                      'সাপ্লায়ার', supp, (v) => setD(() => supp = v)),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    'দেবো/পাবোর পরিমাণ',
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      sortPill('কম → বেশি', _SortBy.amountAsc),
                      const SizedBox(width: 10),
                      sortPill('বেশি → কম', _SortBy.amountDesc),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    'সর্বশেষ লেনদেন',
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      sortPill('নতুন → পুরাতন', _SortBy.dateDesc),
                      const SizedBox(width: 10),
                      sortPill('পুরাতন → নতুন', _SortBy.dateAsc),
                    ],
                  ),
                  const SizedBox(height: 18),
                  PrimaryButton(
                    label: 'নিশ্চিত',
                    onPressed: () {
                      setState(() {
                        _filterCustomer = cust;
                        _filterSupplier = supp;
                        _sortBy = sort;
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _filterCheckRow(
      String label, bool value, ValueChanged<bool> onChanged) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.greyBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey)),
            ),
            Checkbox(
              value: value,
              activeColor: AppColors.red,
              onChanged: (v) => onChanged(v ?? false),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    void push(String r) => Navigator.pushNamed(context, r);

    final actions = [
      _Action(Icons.menu_book_outlined, AppColors.green, 'মাল্টি ব্যবসা',
          () => showBusinessSwitcher(context)),
      _Action(Icons.inventory_2_outlined, AppColors.red, 'স্টক হিসাব',
          () => push(AppRoutes.stock)),
      _Action(Icons.fact_check_outlined, AppColors.orange, 'ব্যবসার নোট',
          () => push(AppRoutes.notes)),
      _Action(Icons.notifications_active_outlined, AppColors.green,
          'গ্রুপ তাগাদা', () => push(AppRoutes.reminder)),
      _Action(Icons.qr_code_2, AppColors.red, 'QR কোড', () => app.setTab(2)),
      _Action(Icons.cloud_upload_outlined, AppColors.green, 'ডাটা ব্যাকআপ',
          () => push(AppRoutes.backup)),
      _Action(Icons.sms_outlined, AppColors.red, 'টালি-মেসেজ',
          () => push(AppRoutes.taliMessage)),
      _Action(Icons.inbox_outlined, AppColors.orange, 'ক্যাশবক্স',
          () => app.setTab(1)),
    ];

    final filtered = _filteredParties(app);
    final dec = app.decimalOn;

    return GoldPage(
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        decoration: const BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            // ---- Animated Multi-Step Bangla QR Ads Banner ----
            // Bottom padding of 10px ensures the white card stops with a clean gap below the banner.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: _BanglaQrAdBanner(onTap: () => app.setTab(2)),
            ),

            // ---- Collapsible 4x2 grid + Slide-up White Customer Sheet (NestedScrollView) ----
            Expanded(
              child: NestedScrollView(
                controller: _scrollCtrl,
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(child: _quickGrid(actions)),
                ],
                body: Material(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(22)),
                  clipBehavior: Clip.antiAlias,
                  child: app.parties.isEmpty
                      ? CustomScrollView(
                          physics: const ClampingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          slivers: [
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'কাস্টমার ০ / সাপ্লায়ার ০',
                                    style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Align(
                                alignment: const Alignment(0, -0.35),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/images/tallykhata_logo9.jpg',
                                        width: 165,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'ব্যবহার শুরু করতে কাস্টমার/সাপ্লায়ার যোগ করুন।',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            // ---- Smoothly vanishing মোট পাবো | মোট দেবো summary on slide-up ----
                            ValueListenableBuilder<double>(
                              valueListenable: _summaryProgress,
                              builder: (context, progress, child) {
                                if (progress <= 0.01) {
                                  return const SizedBox.shrink();
                                }
                                return ClipRect(
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    heightFactor: progress,
                                    child: Opacity(
                                      opacity: progress,
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 14, 16, 4),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              bnCompact(app.totalReceivable,
                                                  decimal: dec),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.red,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            const Text(
                                              'মোট পাবো',
                                              style: TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                          width: 1, color: AppColors.divider),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              bnCompact(app.totalPayable,
                                                  decimal: dec),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.green,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            const Text(
                                              'মোট দেবো',
                                              style: TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // ---- Search + Filter + Download row ----
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 10, 14, 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: AppColors.greyBg,
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: TextField(
                                        controller: _searchCtrl,
                                        onChanged: (_) => setState(() {}),
                                        style: const TextStyle(fontSize: 14.5),
                                        decoration: const InputDecoration(
                                          hintText: 'খোঁজ',
                                          hintStyle: TextStyle(
                                              color: AppColors.textGrey,
                                              fontSize: 14.5),
                                          prefixIcon: Icon(Icons.search,
                                              size: 21,
                                              color: AppColors.textDark),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _circleBtn(
                                    icon: Icons.tune,
                                    active: _filterCustomer ||
                                        _filterSupplier ||
                                        _sortBy != _SortBy.none,
                                    onTap: _showFilterDialog,
                                  ),
                                  const SizedBox(width: 8),
                                  _circleBtn(
                                    icon: Icons.download_outlined,
                                    onTap: () => generateCashboxReportPdf(
                                      app: app,
                                      date: DateTime.now(),
                                      summary: app.todaySummary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ---- কাস্টমার X / সাপ্লায়ার Y ----
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                              child: Row(
                                children: [
                                  Text(
                                    'কাস্টমার ${bn(app.customerCount)} / সাপ্লায়ার ${bn(app.supplierCount)}',
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Text.rich(
                                    TextSpan(
                                      style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500),
                                      children: [
                                        TextSpan(
                                          text: 'পাবো',
                                          style:
                                              TextStyle(color: AppColors.red),
                                        ),
                                        TextSpan(text: ' / '),
                                        TextSpan(
                                          text: 'দেবো',
                                          style:
                                              TextStyle(color: AppColors.green),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ---- Scrollable Party List (slides entire white card up smoothly!) ----
                            Expanded(
                              child: ListView(
                                physics: const ClampingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                                padding: const EdgeInsets.only(bottom: 84),
                                children: [
                                  for (var i = 0; i < filtered.length; i++)
                                    _partyTile(app, filtered[i], i, dec),
                                  if (filtered.length == 1 &&
                                      app.partyTxns(filtered.first.id).isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          24, 12, 24, 16),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(14),
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          AppRoutes.partyDetail,
                                          arguments: filtered.first.id,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(18),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            border: Border.all(
                                              color: const Color(0xFFF3D7BE),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.swap_horiz_rounded,
                                                size: 36,
                                                color: AppColors.orange,
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'হিসাব শুরু করুন',
                                                      style: TextStyle(
                                                        fontSize: 16.5,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${filtered.first.name}-এর সাথে লেনদেন এন্ট্রি করতে ট্যাপ করুন।',
                                                      style: const TextStyle(
                                                        fontSize: 13.5,
                                                        color:
                                                            AppColors.textGrey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickGrid(List<_Action> actions) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 82,
      ),
      itemCount: actions.length,
      itemBuilder: (_, i) {
        final a = actions[i];
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: a.onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(a.icon, color: a.color, size: 28),
              const SizedBox(height: 6),
              Text(
                a.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Party list row with circular initials avatar and current balance.
  Widget _partyTile(AppState app, Party p, int idx, bool dec) {
    final bal = app.partyBalance(p.id);
    final last = app.partyLastActivity(p);
    final bg = _avatarColors[idx % _avatarColors.length];
    final amountColor = bal == 0
        ? AppColors.textDark
        : (bal > 0 ? AppColors.red : AppColors.green);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: bg,
        child: Text(
          p.initials,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        p.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          bnRelativeTime(last),
          style: const TextStyle(fontSize: 12.5, color: AppColors.textGrey),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            bnMoney(bal.abs(), decimal: dec),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, size: 20, color: AppColors.textDark),
        ],
      ),
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.partyDetail,
        arguments: p.id,
      ),
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(21),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: active ? AppColors.pinkBg : AppColors.greyBg,
          shape: BoxShape.circle,
          border: active ? Border.all(color: AppColors.red, width: 1.2) : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: active ? AppColors.red : AppColors.textDark,
        ),
      ),
    );
  }
}

/// Animated 5-step Bangla QR promotional banner.
class _BanglaQrAdBanner extends StatefulWidget {
  final VoidCallback onTap;
  const _BanglaQrAdBanner({required this.onTap});

  @override
  State<_BanglaQrAdBanner> createState() => _BanglaQrAdBannerState();
}

class _BanglaQrAdBannerState extends State<_BanglaQrAdBanner> {
  int _step = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1600), (_) {
      if (mounted) setState(() => _step = (_step + 1) % 5);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: widget.onTap,
      child: Container(
        height: 76,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFFCE8F1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5CFD8), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 4,
              offset: Offset(0, 1.5),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, anim) {
            final isIncoming = child.key == ValueKey<int>(_step);
            final offsetTween = isIncoming
                ? Tween<Offset>(
                    begin: const Offset(0.0, 1.0), end: Offset.zero)
                : Tween<Offset>(
                    begin: const Offset(0.0, -1.0), end: Offset.zero);
            return ClipRect(
              child: SlideTransition(
                position: offsetTween.animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
            );
          },
          child: _buildSlide(_step),
        ),
      ),
    );
  }

  Widget _buildSlide(int step) {
    if (step == 0) {
      return Container(
        key: const ValueKey<int>(0),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'বাংলা QR পেতে\nএখানে ট্যাপ করুন',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: Colors.black,
                ),
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 112,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  alignment: const Alignment(-0.2, 0),
                  child: const Icon(Icons.arrow_forward_rounded,
                      color: Color(0xFFFFC800), size: 32),
                ),
                const Positioned(
                  right: 10,
                  bottom: -4,
                  child: Icon(
                    Icons.touch_app,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget rightContent;
    switch (step) {
      case 1:
        rightContent = const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'যেভাবে ২ মিনিটেই পাবেন',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'টালিপে বাংলা QR',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: AppColors.red,
              ),
            ),
          ],
        );
        break;
      case 2:
        rightContent = const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded,
                size: 26, color: Color(0xFF1E88E5)),
            Text(
              'টালিখাতা ডাউনলোড করুন',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ],
        );
        break;
      case 3:
        rightContent = const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.badge_outlined, size: 26, color: AppColors.red),
            SizedBox(height: 2),
            Text(
              'জাতীয় পরিচয়পত্র ও সেলফি তুলুন',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ],
        );
        break;
      default:
        rightContent = const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined, size: 26, color: AppColors.red),
            SizedBox(height: 2),
            Text(
              'নিজের ব্যবসার ছবি দিন',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ],
        );
        break;
    }

    return Container(
      key: ValueKey<int>(step),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _QrFreeBadge(),
          const SizedBox(width: 10),
          Expanded(child: Center(child: rightContent)),
        ],
      ),
    );
  }
}

class _QrFreeBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 2,
            bottom: 2,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.redLight),
              ),
              child: const Icon(Icons.qr_code_2,
                  size: 50, color: AppColors.red),
            ),
          ),
          Positioned(
            right: -2,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD600),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: const Text(
                'ফ্রি',
                style: TextStyle(
                  color: AppColors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
