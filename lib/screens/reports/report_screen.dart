import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/bn.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/tk_app_bar.dart';

enum ReportKind { sales, expense, due, owner }

class _ReportLine {
  final DateTime date;
  final String label;
  final double c1;
  final double c2;
  const _ReportLine(this.date, this.label, this.c1, this.c2);
}

/// Reusable report screen with live data from AppState,
/// working day/month filter, date picker, and total footer.
class ReportScreen extends StatefulWidget {
  final String title;
  final List<String> columns;
  final ReportKind kind;
  final bool monthly;
  final String? checkboxLabel;

  const ReportScreen({
    super.key,
    required this.title,
    required this.columns,
    this.kind = ReportKind.sales,
    this.monthly = false,
    this.checkboxLabel,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late String _period = widget.monthly ? 'মাস' : 'দিন';
  DateTime _date = DateTime.now();
  bool _checked = false;

  bool get _isDay => _period == 'দিন';

  (DateTime, DateTime) get _range => _isDay
      ? (
          DateTime(_date.year, _date.month, _date.day),
          DateTime(_date.year, _date.month, _date.day + 1),
        )
      : (
          DateTime(_date.year, _date.month, 1),
          DateTime(_date.year, _date.month + 1, 1),
        );

  void _move(int step) {
    setState(() {
      _date = _isDay
          ? _date.add(Duration(days: step))
          : DateTime(_date.year, _date.month + step, 1);
    });
  }

  Future<void> _pick() async {
    final p = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (p != null) setState(() => _date = p);
  }

  List<_ReportLine> _lines(AppState app, DateTime from, DateTime to) {
    bool inRange(DateTime d) => !d.isBefore(from) && d.isBefore(to);
    final out = <_ReportLine>[];

    if (widget.kind == ReportKind.due) {
      final names = {for (final p in app.parties) p.id: p.name};
      for (final t in app.txns) {
        if (!inRange(t.date)) continue;
        final name = names[t.partyId] ?? '';
        final lbl = t.note.isEmpty ? name : '$name • ${t.note}';
        out.add(_ReportLine(t.date, lbl, t.isGave ? t.amount : 0,
            t.isGave ? 0 : t.amount));
      }
    } else {
      for (final c in app.cashEntries) {
        if (!inRange(c.date)) continue;
        final lbl = c.note.isEmpty ? c.type.label : c.note;
        switch (widget.kind) {
          case ReportKind.sales:
            if (c.type == CashType.cashSale) {
              out.add(_ReportLine(c.date, lbl, c.amount, 0));
            } else if (c.type == CashType.cashBuy) {
              out.add(_ReportLine(c.date, lbl, 0, c.amount));
            }
            break;
          case ReportKind.expense:
            if (c.type == CashType.expense) {
              out.add(_ReportLine(c.date, lbl, c.amount, 0));
            }
            break;
          case ReportKind.owner:
            if (c.type == CashType.ownerGave) {
              out.add(_ReportLine(c.date, lbl, c.amount, 0));
            } else if (c.type == CashType.ownerTook) {
              out.add(_ReportLine(c.date, lbl, 0, c.amount));
            }
            break;
          case ReportKind.due:
            break;
        }
      }
    }
    out.sort((a, b) => b.date.compareTo(a.date));
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final dec = app.decimalOn;
    final (from, to) = _range;
    final lines = _lines(app, from, to);
    final total1 = lines.fold(0.0, (s, l) => s + l.c1);
    final total2 = lines.fold(0.0, (s, l) => s + l.c2);

    return Scaffold(
      appBar: tkAppBar(context, title: widget.title),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                _periodDropdown(),
                const SizedBox(width: 8),
                Flexible(child: _dateChip()),
                if (widget.checkboxLabel != null) ...[
                  const SizedBox(width: 4),
                  Text(widget.checkboxLabel!,
                      style: const TextStyle(
                          fontSize: 15, color: AppColors.textGrey)),
                  Checkbox(
                    visualDensity: VisualDensity.compact,
                    value: _checked,
                    activeColor: AppColors.red,
                    onChanged: (v) => setState(() => _checked = v ?? false),
                  ),
                ],
              ],
            ),
          ),
          // table header
          Container(
            color: AppColors.greyBg,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Text('বিবরণ', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ডাউনলোড করার মতো ডাটা নেই')),
                  ),
                  child: const CircleAvatar(
                    radius: 13,
                    backgroundColor: Color(0xFFE2E4E4),
                    child: Icon(Icons.download_outlined, size: 15),
                  ),
                ),
                const Spacer(),
                for (final c in widget.columns)
                  SizedBox(
                    width: 86,
                    child: Text(c,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 15)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: lines.isEmpty
                ? const EmptyState(
                    icon: Icons.assignment_outlined,
                    message: 'কোন লেনদেন নেই।',
                  )
                : _checked
                    ? const SizedBox()
                    : ListView.separated(
                        itemCount: lines.length,
                        separatorBuilder: (_, _) => const Divider(),
                        itemBuilder: (_, i) {
                          final l = lines[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(l.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 15)),
                                      Text(bnDate(l.date),
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textGrey)),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 86,
                                  child: Text(
                                    l.c1 == 0
                                        ? ''
                                        : bnMoney(l.c1, decimal: dec),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: widget.kind == ReportKind.expense ||
                                              widget.kind == ReportKind.due
                                          ? AppColors.red
                                          : AppColors.green,
                                    ),
                                  ),
                                ),
                                if (widget.columns.length > 1)
                                  SizedBox(
                                    width: 86,
                                    child: Text(
                                      l.c2 == 0
                                          ? ''
                                          : bnMoney(l.c2, decimal: dec),
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: widget.kind == ReportKind.due
                                            ? AppColors.green
                                            : AppColors.red,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          if (lines.isNotEmpty)
            Container(
              color: AppColors.greyBg,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    const Text('মোট',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    SizedBox(
                      width: 86,
                      child: Text(
                        bnMoney(total1, decimal: dec),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: widget.kind == ReportKind.expense ||
                                  widget.kind == ReportKind.due
                              ? AppColors.red
                              : AppColors.green,
                        ),
                      ),
                    ),
                    if (widget.columns.length > 1)
                      SizedBox(
                        width: 86,
                        child: Text(
                          bnMoney(total2, decimal: dec),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: widget.kind == ReportKind.due
                                ? AppColors.green
                                : AppColors.red,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _periodDropdown() => Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F8),
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(24),
        ),
        child: DropdownButton<String>(
          value: _period,
          underline: const SizedBox(),
          style: const TextStyle(fontSize: 15, color: AppColors.textDark),
          items: const [
            DropdownMenuItem(value: 'দিন', child: Text('দিন')),
            DropdownMenuItem(value: 'মাস', child: Text('মাস')),
          ],
          onChanged: (v) => setState(() => _period = v ?? _period),
        ),
      );

  Widget _dateChip() => Container(
        height: 38,
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEDF0F6),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: _pick,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    _isDay ? bnDate(_date) : bnMonth(_date),
                    style: const TextStyle(fontSize: 14.5),
                  ),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 30, minHeight: 34),
              onPressed: () => _move(-1),
              icon: const Icon(Icons.chevron_left, size: 20),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 30, minHeight: 34),
              onPressed: () => _move(1),
              icon: const Icon(Icons.chevron_right, size: 20),
            ),
          ],
        ),
      );
}
