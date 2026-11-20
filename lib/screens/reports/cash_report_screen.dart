import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/bn.dart';
import '../../core/utils/cashbox_pdf.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';

/// ক্যাশ হিসাব screen with 3-column summary table, live numbers, and PDF export.
class CashReportScreen extends StatefulWidget {
  const CashReportScreen({super.key});

  @override
  State<CashReportScreen> createState() => _CashReportScreenState();
}

class _CashReportScreenState extends State<CashReportScreen> {
  DateTime _date = DateTime.now();
  bool _detailed = false;

  void _shift(int d) => setState(() => _date = _date.add(Duration(days: d)));

  Future<void> _pick() async {
    final p = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (p != null) setState(() => _date = p);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final dec = app.decimalOn;
    final from = AppState.dayStart(_date);
    final to = from.add(const Duration(days: 1));
    final s = app.cashSummary(from, to);

    final rows = <(String, bool, double)>[
      ('দিনের শুরুতে ক্যাশ', true, s['open'] ?? 0),
      ('ক্যাশ বেচা', true, s['cashSale'] ?? 0),
      ('বাকি আদায়', true, s['dueCollect'] ?? 0),
      ('মালিক দিল', true, s['ownerGave'] ?? 0),
      ('ক্যাশ কেনা', false, s['cashBuy'] ?? 0),
      ('পেমেন্ট দেয়া', false, s['supplierPay'] ?? 0),
      ('খরচ', false, s['expense'] ?? 0),
      ('মালিক নিল', false, s['ownerTook'] ?? 0),
    ];

    final dayEntries = app.cashEntries
        .where((c) => !c.date.isBefore(from) && c.date.isBefore(to))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('ক্যাশ হিসাব'),
          bottom: const TabBar(
            labelColor: AppColors.textDark,
            unselectedLabelColor: AppColors.textGrey,
            indicatorColor: AppColors.red,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: TextStyle(fontSize: 16),
            tabs: [
              Tab(text: 'ক্যাশবক্স রিপোর্ট'),
              Tab(text: 'ক্যাশ রিপোর্ট'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: ক্যাশবক্স রিপোর্ট
            Column(
              children: [
                // Date selector + বিস্তারিত checkbox
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.greyBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: _pick,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 16,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(bnDate(_date),
                                      style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _shift(-1),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.chevron_left,
                                    size: 18, color: Colors.black54),
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => _shift(1),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.chevron_right,
                                    size: 18, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Text('বিস্তারিত', style: TextStyle(fontSize: 15)),
                      Checkbox(
                        value: _detailed,
                        activeColor: AppColors.red,
                        onChanged: (v) =>
                            setState(() => _detailed = v ?? false),
                      ),
                    ],
                  ),
                ),

                // Table header with working PDF download button
                Container(
                  color: AppColors.greyBg,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Row(
                          children: [
                            const Text('বিবরণ', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 10),
                            InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => generateCashboxReportPdf(
                                app: app,
                                date: _date,
                                summary: s,
                              ),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE5E7EB),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.download_outlined,
                                  size: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Text(
                            'পেলাম',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const Expanded(
                        flex: 3,
                        child: Text(
                          'দিলাম',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

                // 8 rows
                Expanded(
                  child: ListView(
                    children: [
                      for (final r in rows)
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 11,
                                  ),
                                  child: Text(r.$1,
                                      style: const TextStyle(fontSize: 15.5)),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  color: const Color(0xFFF3F4F6),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 11,
                                  ),
                                  child: Text(
                                    r.$2 ? bnMoney(r.$3, decimal: dec) : '',
                                    style: const TextStyle(
                                      color: AppColors.green,
                                      fontSize: 15.5,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 11,
                                  ),
                                  child: Text(
                                    r.$2 ? '' : bnMoney(r.$3, decimal: dec),
                                    style: const TextStyle(
                                      color: AppColors.red,
                                      fontSize: 15.5,
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

                const Divider(),
                // মোট row
                IntrinsicHeight(
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 5,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          child: Text('মোট', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          color: const Color(0xFFF3F4F6),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 13,
                          ),
                          child: Text(
                            bnMoney(s['totalIn'] ?? 0, decimal: dec),
                            style: const TextStyle(
                                color: AppColors.green, fontSize: 15.5),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          child: Text(
                            bnMoney(s['totalOut'] ?? 0, decimal: dec),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                color: AppColors.red, fontSize: 15.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // ব্যালেন্স row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      const Text('ব্যালেন্স', style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      Text(
                        bnMoney(s['balance'] ?? 0, decimal: dec),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),

                // Rounded pill button
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: PrimaryButton(
                      label: 'ক্যাশবক্স মিলাই',
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ক্যাশবক্স মিলে গেছে')),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Tab 2: ক্যাশ রিপোর্ট (daily entries list)
            dayEntries.isEmpty
                ? const EmptyState(
                    icon: Icons.assignment_outlined,
                    message: 'কোন লেনদেন নেই।',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: dayEntries.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (_, i) {
                      final c = dayEntries[i];
                      return ListTile(
                        title: Text(
                          c.note.isEmpty ? c.type.label : c.note,
                          style: const TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          '${c.type.label} • ${bnFullDate(c.date)}',
                          style: const TextStyle(
                              fontSize: 12.5, color: AppColors.textGrey),
                        ),
                        trailing: Text(
                          '৳ ${bnMoney(c.amount, decimal: dec)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: c.type.isIn
                                ? AppColors.green
                                : AppColors.red,
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
