import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/bn.dart';
import '../../core/widgets/tk_app_bar.dart';

class _Pack {
  final int count;
  final int price;
  final String? badge;
  const _Pack(this.count, this.price, [this.badge]);
}

/// Screen 23: টালি-মেসেজ কিনি.
class TaliMessageScreen extends StatelessWidget {
  const TaliMessageScreen({super.key});

  static const _packs = [
    _Pack(650, 350, 'অধিক সাশ্রয়ী'),
    _Pack(350, 200, 'সাশ্রয়ী'),
    _Pack(200, 120),
    _Pack(100, 70),
    _Pack(25, 20),
  ];

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      appBar: tkAppBar(
        context,
        title: 'টালি-মেসেজ কিনি',
        actions: [
          PinkPill(
            icon: Icons.description_outlined,
            label: 'রিপোর্ট',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('কোনো রিপোর্ট নেই')),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            color: AppColors.greyBg,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text('টালি-মেসেজ ব্যালেন্স',
                    style: TextStyle(fontSize: 16, color: AppColors.textGrey)),
                const Spacer(),
                Text(bn(app.messageBalance),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 18, 16, 10),
            child: Text('টালি-মেসেজ প্যাক সিলেক্ট করি',
                style: TextStyle(fontSize: 15.5)),
          ),
          for (final p in _packs)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('${bn(p.count)} টালি-মেসেজ কিনবেন?'),
                      content: Text('মূল্য ৳${bn(p.price)}'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('না')),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('কিনি',
                                style: TextStyle(color: AppColors.red))),
                      ],
                    ),
                  );
                  if (ok == true) app.buyMessages(p.count);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.sms_outlined,
                              color: AppColors.red, size: 36),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${bn(p.count)} টালি-মেসেজ',
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 12),
                                Text('টি${bn(p.count)}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textGrey)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.red,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text('৳ ${bn(p.price)}.০',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      if (p.badge != null)
                        Positioned(
                          right: -16,
                          top: -16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            color: const Color(0xFFFFD500),
                            child: Text(p.badge!,
                                style: const TextStyle(fontSize: 15)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
