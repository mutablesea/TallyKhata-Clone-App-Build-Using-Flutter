import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/models.dart';
import '../../core/routes/app_routes.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/bn.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/gold_page.dart';
import '../../core/widgets/primary_button.dart';

/// Cashbox tab: daily sales, current cash, inflow/outflow summary, and entry categories.
class CashboxScreen extends StatefulWidget {
  const CashboxScreen({super.key});

  @override
  State<CashboxScreen> createState() => _CashboxScreenState();
}

class _CashboxScreenState extends State<CashboxScreen> {
  bool _hide = false;

  String _num(double v, {required bool decimal, bool compactZero = false}) {
    if (_hide) return '- - -';
    if (compactZero && v == 0) return '০';
    return bnMoney(v, decimal: decimal);
  }

  void _addEntry(CashType type) {
    final amtCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    DateTime date = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(sheetCtx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    type.label,
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      final p = await showDatePicker(
                        context: sheetCtx,
                        initialDate: date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (p != null) setSheet(() => date = p);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.greyBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 15),
                          const SizedBox(width: 6),
                          Text(bnDate(date),
                              style: const TextStyle(fontSize: 13.5)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amtCtrl,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                cursorColor: type.isIn ? AppColors.green : AppColors.red,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: type.isIn ? AppColors.green : AppColors.red,
                ),
                decoration: InputDecoration(
                  labelText: 'টাকার পরিমাণ',
                  prefixText: '৳ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: type.isIn ? AppColors.green : AppColors.red,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: noteCtrl,
                label: 'বিবরণ (ঐচ্ছিক)',
                icon: Icons.notes_outlined,
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'নিশ্চিত',
                onPressed: () {
                  final v = double.tryParse(amtCtrl.text.trim()) ?? 0;
                  if (v > 0) {
                    AppScope.read(context).addCash(
                      type,
                      v,
                      note: noteCtrl.text.trim(),
                      date: date,
                    );
                  }
                  Navigator.pop(sheetCtx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final dec = app.decimalOn;

    return GoldPage(
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        decoration: const BoxDecoration(
          color: Color(0xFFEFE6CA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            // Row 1: আজকের বেচা | বর্তমান ক্যাশ
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            _num(app.todaySale,
                                decimal: dec, compactZero: true),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'আজকের বেচা',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, color: const Color(0xFFDCCBA0)),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            _num(app.currentCash,
                                decimal: dec, compactZero: true),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'বর্তমান ক্যাশ',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Row 2 + White sheet nested inside #F9F5E7 so corners merge seamlessly (no gold leak!)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF9F5E7),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                ),
                child: Column(
                  children: [
                    // আজ পেলাম | আজ দিলাম summary row
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'আজ পেলাম  ',
                                    style: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    _num(app.totalIn,
                                        decimal: dec, compactZero: true),
                                    style: const TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, color: const Color(0xFFE6DEC5)),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'আজ দিলাম  ',
                                    style: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    _num(app.totalOut,
                                        decimal: dec, compactZero: true),
                                    style: const TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // White bottom sheet
                    Expanded(
                      child: Material(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(22)),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 14, 14, 10),
                              child: Row(
                                children: [
                                  InkWell(
                                    borderRadius: BorderRadius.circular(22),
                                    onTap: () => Navigator.pushNamed(
                                        context, AppRoutes.cashReport),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8D5A5),
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.description_outlined,
                                              size: 18),
                                          SizedBox(width: 6),
                                          Text(
                                            'রিপোর্ট',
                                            style: TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(22),
                                    onTap: () => Navigator.pushNamed(
                                        context, AppRoutes.cashReport),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.greyBg,
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.swap_horiz, size: 18),
                                          SizedBox(width: 6),
                                          Text(
                                            'ক্যাশবক্স মিলাই',
                                            style: TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () =>
                                        setState(() => _hide = !_hide),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: const BoxDecoration(
                                        color: AppColors.greyBg,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _hide
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 19,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 4, 16, 12),
                              child: Row(
                                children: [
                                  const Text(
                                    'বাকি আদায়  ',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textDark),
                                  ),
                                  Text(
                                    _num(app.todayDueCollect,
                                        decimal: dec, compactZero: true),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.green,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Text(
                                    'পেমেন্ট দেয়া  ',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textDark),
                                  ),
                                  Text(
                                    _num(app.todaySupplierPay,
                                        decimal: dec, compactZero: true),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(height: 5, color: AppColors.greyBg),
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.only(top: 6),
                                children: [
                                  for (final t in [
                                    CashType.cashSale,
                                    CashType.cashBuy,
                                    CashType.expense,
                                    CashType.ownerGave,
                                    CashType.ownerTook,
                                  ])
                                    ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 5),
                                      leading: CircleAvatar(
                                        radius: 23,
                                        backgroundColor: t.isIn
                                            ? AppColors.greenSoft
                                            : const Color(0xFFF6DCDE),
                                        child: _HandCashIcon(
                                          isIn: t.isIn,
                                          color: t.isIn
                                              ? AppColors.green
                                              : AppColors.red,
                                        ),
                                      ),
                                      title: Text(
                                        t.label,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _num(app.todayCashOf(t),
                                                decimal: dec),
                                            style: TextStyle(
                                              color: t.isIn
                                                  ? AppColors.green
                                                  : AppColors.red,
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.chevron_right,
                                              size: 20),
                                        ],
                                      ),
                                      onTap: () => _addEntry(t),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom hand-with-arrow cashflow icon.
class _HandCashIcon extends StatelessWidget {
  final bool isIn;
  final Color color;
  const _HandCashIcon({required this.isIn, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(25, 25),
      painter: _HandCashPainter(isIn: isIn, color: color),
    );
  }
}

class _HandCashPainter extends CustomPainter {
  final bool isIn;
  final Color color;
  const _HandCashPainter({required this.isIn, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final hand = Path()
      ..moveTo(w * 0.14, h * 0.64)
      ..lineTo(w * 0.14, h * 0.86)
      ..lineTo(w * 0.30, h * 0.86)
      ..lineTo(w * 0.30, h * 0.64)
      ..close();
    canvas.drawPath(hand, p);

    final palm = Path()
      ..moveTo(w * 0.30, h * 0.68)
      ..lineTo(w * 0.56, h * 0.68)
      ..quadraticBezierTo(w * 0.68, h * 0.68, w * 0.86, h * 0.62)
      ..quadraticBezierTo(w * 0.88, h * 0.72, w * 0.74, h * 0.80)
      ..lineTo(w * 0.50, h * 0.86)
      ..lineTo(w * 0.30, h * 0.84);
    canvas.drawPath(palm, p);

    if (isIn) {
      canvas.drawLine(
          Offset(w * 0.72, h * 0.16), Offset(w * 0.52, h * 0.44), p);
      canvas.drawLine(
          Offset(w * 0.52, h * 0.44), Offset(w * 0.52, h * 0.28), p);
      canvas.drawLine(
          Offset(w * 0.52, h * 0.44), Offset(w * 0.67, h * 0.42), p);
    } else {
      canvas.drawLine(
          Offset(w * 0.52, h * 0.44), Offset(w * 0.72, h * 0.16), p);
      canvas.drawLine(
          Offset(w * 0.72, h * 0.16), Offset(w * 0.57, h * 0.18), p);
      canvas.drawLine(
          Offset(w * 0.72, h * 0.16), Offset(w * 0.72, h * 0.32), p);
    }
  }

  @override
  bool shouldRepaint(covariant _HandCashPainter old) =>
      old.isIn != isIn || old.color != color;
}
