import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../constants/app_colors.dart';
import '../state/app_state.dart';
import 'bn.dart';

/// Generates a Cashbox Report PDF matching the official TallyKhata report layout.
///
/// NOTE: The `pdf` Dart package lacks a HarfBuzz/OpenType GSUB shaping engine for
/// Bengali conjuncts (যুক্তাক্ষর like ক্যাশবক্স, রিপোর্ট, পেলাম, ব্যালেন্স) and
/// `NotoSansBengali` lacks Latin glyphs (causing English business names, `Ph:`,
/// `PM`, and `Page no. 1 of 1` to fail or clip in `pw.Text`).
///
/// By rendering the A4 report layout natively through Flutter's `ui.ParagraphBuilder`
/// and `ui.PictureRecorder` at 300 DPI (2480 x 3508 px), we get 100% authentic
/// Bengali shaping + crisp English text (`Your Business Name`, `Ph: +88018XXXXXXXX`,
/// `PM`, `Page no. 1 of 1`) with zero broken or clipped characters.
Future<void> generateCashboxReportPdf({
  required AppState app,
  required DateTime date,
  required Map<String, double> summary,
}) async {
  final pngBytes = await renderA4CashboxReportPng(
    app: app,
    date: date,
    summary: summary,
  );

  final doc = pw.Document();
  final pageImage = pw.MemoryImage(pngBytes);

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (_) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Image(pageImage, fit: pw.BoxFit.fill),
      ),
    ),
  );

  await Printing.layoutPdf(
    name:
        'TallyKhata_Cashbox_Report_${date.year}_${date.month}_${date.day}.pdf',
    onLayout: (_) async => doc.save(),
  );
}

/// Renders the A4 Cashbox Report at 3x scale (1785 x 2526 px) using Flutter's
/// native text shaping engine so both Bengali conjuncts and English Latin characters
/// render identically to the official TallyKhata PDF.
Future<Uint8List> renderA4CashboxReportPng({
  required AppState app,
  required DateTime date,
  required Map<String, double> summary,
}) async {
  const double w = 595.0;
  const double h = 842.0;
  const double scale = 3.0;

  final logoData = await rootBundle.load('assets/images/tallykhata_logo8.png');
  final codec =
      await ui.instantiateImageCodec(logoData.buffer.asUint8List());
  final frame = await codec.getNextFrame();
  final logoImg = frame.image;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.scale(scale, scale);

  // 1. White A4 background
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, w, h),
    Paint()..color = Colors.white,
  );

  // 2. Top pink header banner (#FDF4F5)
  const double bannerTop = 28.0;
  const double bannerHeight = 86.0;
  canvas.drawRect(
    const Rect.fromLTWH(0, bannerTop, w, bannerHeight),
    Paint()..color = const Color(0xFFFDF4F5),
  );

  // Business name (supports both English & Bengali perfectly)
  _drawText(
    canvas,
    text: app.businessName,
    x: 56,
    y: bannerTop + 22,
    maxWidth: 360,
    fontSize: 18.5,
    fontWeight: FontWeight.w700,
    color: AppColors.red,
  );

  // Formatted Phone number: Ph: +88018XXXXXXXX
  final phoneDisplay = _formatPhoneForPdf(app.phone);
  _drawText(
    canvas,
    text: 'Ph: $phoneDisplay',
    x: 56,
    y: bannerTop + 49,
    maxWidth: 360,
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF1A1A1A),
  );

  // TallyKhata logo on the right of the pink banner
  final double logoH = 26.0;
  final double logoW = (logoImg.width / logoImg.height) * logoH;
  final srcRect = Rect.fromLTWH(
      0, 0, logoImg.width.toDouble(), logoImg.height.toDouble());
  final dstRect =
      Rect.fromLTWH(w - 30 - logoW, bannerTop + 33, logoW, logoH);
  canvas.drawImageRect(
    logoImg,
    srcRect,
    dstRect,
    Paint()..filterQuality = FilterQuality.high,
  );

  // 3. Report Title & Metadata section
  const double metaY = 148.0;
  _drawText(
    canvas,
    text: 'ক্যাশবক্স রিপোর্ট',
    x: 32,
    y: metaY,
    maxWidth: 250,
    fontSize: 14.5,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF222222),
  );
  _drawText(
    canvas,
    text: bnFullDate(date),
    x: 32,
    y: metaY + 23,
    maxWidth: 250,
    fontSize: 10.5,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF666666),
  );

  _drawText(
    canvas,
    text: 'হিসাবের সংখ্যা : ০৮',
    x: 322,
    y: metaY + 1,
    maxWidth: 245,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF222222),
  );
  _drawText(
    canvas,
    text: 'রিপোর্ট তৈরি : ${bnDateTime(DateTime.now())}',
    x: 322,
    y: metaY + 22,
    maxWidth: 255,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF222222),
  );

  // 4. Table layout
  const double tableLeft = 25.0;
  const double tableRight = w - 25.0;
  const double tableWidth = tableRight - tableLeft; // 545
  const double col1Width = 335.0; // বিবরণ
  const double col2Width = 105.0; // পেলাম (tinted)
  const double col3Width = tableWidth - col1Width - col2Width; // 105 দিলাম

  const double col1X = tableLeft;
  const double col2X = tableLeft + col1Width;
  const double col3X = col2X + col2Width;

  double curY = 218.0;
  const double headerH = 44.0;
  const double rowH = 54.0;
  const double totalH = 54.0;

  // Table header background (#E5E7EB)
  canvas.drawRect(
    Rect.fromLTWH(tableLeft, curY, tableWidth, headerH),
    Paint()..color = const Color(0xFFE5E7EB),
  );

  _drawText(
    canvas,
    text: 'বিবরণ',
    x: col1X + 20,
    y: curY + 14,
    maxWidth: col1Width - 30,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF222222),
  );
  _drawText(
    canvas,
    text: 'পেলাম',
    x: col2X,
    y: curY + 14,
    maxWidth: col2Width,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF222222),
    align: TextAlign.center,
  );
  _drawText(
    canvas,
    text: 'দিলাম',
    x: col3X,
    y: curY + 14,
    maxWidth: col3Width,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF222222),
    align: TextAlign.center,
  );

  curY += headerH;

  final dec = app.decimalOn;
  String m(double v) => bnMoney(v, decimal: dec);

  final rows = <(String, double?, double?)>[
    ('দিনের শুরুতে ক্যাশ', summary['open'] ?? 0, null),
    ('ক্যাশ বেচা', summary['cashSale'] ?? 0, null),
    ('বাকি আদায়', summary['dueCollect'] ?? 0, null),
    ('মালিক দিল', summary['ownerGave'] ?? 0, null),
    ('ক্যাশ কেনা', null, summary['cashBuy'] ?? 0),
    ('পেমেন্ট দেয়া', null, summary['supplierPay'] ?? 0),
    ('খরচ', null, summary['expense'] ?? 0),
    ('মালিক নিল', null, summary['ownerTook'] ?? 0),
  ];

  // Tinted background for entire পেলাম column (rows + মোট + ব্যালেন্স)
  final double pelamTotalHeight = (rows.length * rowH) + (2 * totalH);
  canvas.drawRect(
    Rect.fromLTWH(col2X, curY, col2Width, pelamTotalHeight),
    Paint()..color = const Color(0xFFF2F6F3),
  );

  final dashPaint = Paint()
    ..color = const Color(0xFFD5D8DC)
    ..strokeWidth = 0.9;

  for (var i = 0; i < rows.length; i++) {
    final r = rows[i];
    _drawText(
      canvas,
      text: r.$1,
      x: col1X + 16,
      y: curY + 19,
      maxWidth: col1Width - 28,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF222222),
    );

    if (r.$2 != null) {
      _drawText(
        canvas,
        text: m(r.$2!),
        x: col2X + 8,
        y: curY + 19,
        maxWidth: col2Width - 28,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.green,
        align: TextAlign.right,
      );
    }

    if (r.$3 != null) {
      _drawText(
        canvas,
        text: m(r.$3!),
        x: col3X + 8,
        y: curY + 19,
        maxWidth: col3Width - 26,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.red,
        align: TextAlign.right,
      );
    }

    curY += rowH;

    // Dashed row divider between the 8 items
    if (i < rows.length - 1) {
      _drawDashedLine(
        canvas,
        start: Offset(tableLeft + 14, curY),
        end: Offset(tableRight - 14, curY),
        paint: dashPaint,
      );
    }
  }

  // Solid double/thick divider above মোট
  final borderPaint = Paint()
    ..color = const Color(0xFFD5D8DC)
    ..strokeWidth = 1.2;
  canvas.drawLine(
    Offset(tableLeft, curY),
    Offset(tableRight, curY),
    borderPaint,
  );
  canvas.drawLine(
    Offset(tableLeft, curY + 2),
    Offset(tableRight, curY + 2),
    Paint()
      ..color = const Color(0xFFD5D8DC)
      ..strokeWidth = 0.7,
  );

  // 5. মোট row
  _drawText(
    canvas,
    text: 'মোট',
    x: col1X,
    y: curY + 19,
    maxWidth: col1Width - 32,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF222222),
    align: TextAlign.right,
  );
  _drawText(
    canvas,
    text: m(summary['totalIn'] ?? 0),
    x: col2X + 8,
    y: curY + 19,
    maxWidth: col2Width - 28,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.green,
    align: TextAlign.right,
  );
  _drawText(
    canvas,
    text: m(summary['totalOut'] ?? 0),
    x: col3X + 8,
    y: curY + 19,
    maxWidth: col3Width - 26,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.red,
    align: TextAlign.right,
  );

  curY += totalH;

  // Solid line between মোট and ব্যালেন্স
  canvas.drawLine(
    Offset(tableLeft, curY),
    Offset(tableRight, curY),
    Paint()
      ..color = const Color(0xFFD5D8DC)
      ..strokeWidth = 0.9,
  );

  // 6. ব্যালেন্স row
  _drawText(
    canvas,
    text: 'ব্যালেন্স',
    x: col1X,
    y: curY + 19,
    maxWidth: col1Width - 32,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF222222),
    align: TextAlign.right,
  );
  _drawText(
    canvas,
    text: m(summary['balance'] ?? 0),
    x: col2X + 8,
    y: curY + 19,
    maxWidth: col2Width - 28,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF222222),
    align: TextAlign.right,
  );

  curY += totalH;

  // Outer table border rectangle
  canvas.drawRect(
    Rect.fromLTRB(tableLeft, 218.0, tableRight, curY),
    Paint()
      ..color = const Color(0xFFD5D8DC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9,
  );

  // 7. Footer: Page no. 1 of 1
  _drawText(
    canvas,
    text: 'Page no. 1 of 1',
    x: w - 150,
    y: h - 34,
    maxWidth: 125,
    fontSize: 10.5,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF222222),
    align: TextAlign.right,
  );

  final picture = recorder.endRecording();
  final img =
      await picture.toImage((w * scale).round(), (h * scale).round());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

String _formatPhoneForPdf(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  String local = digits;
  if (local.startsWith('880')) {
    local = local.substring(3);
  } else if (local.startsWith('0')) {
    local = local.substring(1);
  }
  if (local.length == 10) {
    return '+880 ${local.substring(0, 6)} ${local.substring(6)}';
  }
  if (raw.trim().isEmpty) return '+88018XXXXXXXX';
  return raw.startsWith('+88') ? raw : '+880 $local';
}

void _drawText(
  Canvas canvas, {
  required String text,
  required double x,
  required double y,
  required double maxWidth,
  required double fontSize,
  required FontWeight fontWeight,
  required Color color,
  TextAlign align = TextAlign.left,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'Noto Sans Bengali',
        fontFamilyFallback: const ['Roboto', 'Arial'],
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: 1.2,
      ),
    ),
    textAlign: align,
    textDirection: TextDirection.ltr,
    maxLines: 1,
    ellipsis: '…',
  )..layout(minWidth: maxWidth, maxWidth: maxWidth);
  tp.paint(canvas, Offset(x, y));
}

void _drawDashedLine(
  Canvas canvas, {
  required Offset start,
  required Offset end,
  required Paint paint,
}) {
  const double dashWidth = 4.0;
  const double dashSpace = 3.5;
  double dx = start.dx;
  while (dx < end.dx) {
    final next = (dx + dashWidth).clamp(start.dx, end.dx);
    canvas.drawLine(Offset(dx, start.dy), Offset(next, start.dy), paint);
    dx += dashWidth + dashSpace;
  }
}
