import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/models.dart';
import '../../core/routes/app_routes.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/tk_app_bar.dart';
import '../../core/widgets/tk_logo.dart';

/// Inbox notification list with campaign thumbnails and dashed dividers.
class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: tkAppBar(context, title: 'ইনবক্স'),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: app.inbox.length,
        separatorBuilder: (_, _) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: _DashedDivider(),
        ),
        itemBuilder: (_, i) {
          final m = app.inbox[i];
          return Material(
            color: m.isUnread ? const Color(0xFFEEEEEE) : Colors.white,
            child: InkWell(
              onTap: () {
                app.markMessageRead(m);
                Navigator.pushNamed(context, AppRoutes.inboxDetail,
                    arguments: m);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InboxThumb(type: m.thumb),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.title,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m.preview,
                            style: const TextStyle(
                              fontSize: 14.5,
                              color: AppColors.textGrey,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            m.time,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Custom 62x62 rounded thumbnail for campaign notification badges.
class _InboxThumb extends StatelessWidget {
  final InboxThumbType type;
  const _InboxThumb({required this.type});

  @override
  Widget build(BuildContext context) {
    final isWhite = type == InboxThumbType.tkBook;
    return Container(
      width: 62,
      height: 62,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isWhite ? Colors.white : const Color(0xFFFCE8F1),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(child: _content()),
    );
  }

  Widget _content() {
    switch (type) {
      case InboxThumbType.qr2Min:
        return const Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 8.5, height: 1.25, fontWeight: FontWeight.w700),
            children: [
              TextSpan(
                text: '২ মিনিটেই\n',
                style: TextStyle(color: Colors.black87),
              ),
              TextSpan(
                text: 'পাবেন টালিপে\nবাংলা QR।',
                style: TextStyle(color: AppColors.red),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        );
      case InboxThumbType.reportDownload:
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download_rounded, size: 22, color: Colors.black87),
            SizedBox(height: 3),
            Text(
              'রিপোর্ট ডাউনলোড',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 7, fontWeight: FontWeight.w600),
            ),
          ],
        );
      case InboxThumbType.noCost:
        return const Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 8.5, height: 1.15, fontWeight: FontWeight.w800),
            children: [
              TextSpan(
                text: 'মার্চেন্টের\n',
                style: TextStyle(color: Colors.black87),
              ),
              TextSpan(
                text: 'কোন\n',
                style: TextStyle(color: AppColors.red, fontSize: 7.5),
              ),
              TextSpan(
                text: 'খরচ নেই!',
                style: TextStyle(
                  color: Color(0xFFE65100),
                  backgroundColor: Color(0xFFFFEB3B),
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        );
      case InboxThumbType.tkGold:
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TkLogo(size: 11),
            SizedBox(width: 2),
            Flexible(
              child: Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800),
                  children: [
                    TextSpan(
                        text: 'টালিখাতা ',
                        style: TextStyle(color: AppColors.red)),
                    TextSpan(
                        text: 'গোল্ড',
                        style: TextStyle(color: Color(0xFFD99B16))),
                  ],
                ),
              ),
            ),
          ],
        );
      case InboxThumbType.groupTagada:
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_active_outlined,
                size: 22, color: AppColors.green),
            SizedBox(height: 3),
            Text(
              'গ্রুপ তাগাদা',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w600),
            ),
          ],
        );
      case InboxThumbType.tkBook:
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TkLogo(size: 32),
            SizedBox(height: 2),
            Text(
              'টালিখাতা™',
              style: TextStyle(
                color: AppColors.red,
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        );
    }
  }
}

/// Dashed horizontal divider line between inbox messages.
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DashedLinePainter(),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBDBDBD)
      ..strokeWidth = 1.1;
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    var startX = 0.0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset((startX + dashWidth).clamp(0.0, size.width), 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
