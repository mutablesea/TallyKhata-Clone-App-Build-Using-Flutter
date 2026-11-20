import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/gold_page.dart';
import '../../core/widgets/primary_button.dart';

/// টালিপে tab with dimmed feature grid and QR onboarding card.
/// - Top dimmed 4x2 feature grid
/// - Centered tallykhata_logo10.jpg illustration (prominent size)
/// - 2 checkmark points and rounded red button centered in the middle column (not full-bleed)
class TallyPayScreen extends StatelessWidget {
  const TallyPayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.add_card, 'অ্যাড মানি'),
      (Icons.currency_exchange, 'সেন্ড মানি'),
      (Icons.account_balance_outlined, 'ব্যাংক ট্রান্সফার'),
      (Icons.account_balance_wallet_outlined, 'ওয়ালেট\nট্রান্সফার'),
      (Icons.phone_android, 'মোবাইল রিচার্জ'),
      (Icons.shopping_bag_outlined, 'পেমেন্ট'),
      (Icons.qr_code_2, 'QR কোড'),
      (Icons.lightbulb_outline, 'বিল পেমেন্ট'),
    ];

    return GoldPage(
      showPlan: true,
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        decoration: const BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Opacity(
                opacity: 0.35,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisExtent: 82,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final it = items[i];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(it.$1, size: 26, color: Colors.black54),
                        const SizedBox(height: 5),
                        Text(
                          it.$2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11.5, height: 1.15),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
          body: Material(
            color: Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            clipBehavior: Clip.antiAlias,
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 44, vertical: 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 270),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/tallykhata_logo10.jpg',
                              width: 245,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 18),
                            _check(
                              'টালিপে QR-এ পেমেন্ট নিন বিকাশ, রকেট সহ যেকোন ব্যাংক বা মোবাইল ওয়ালেট থেকে।',
                            ),
                            const SizedBox(height: 10),
                            _check(
                              'ইনস্ট্যান্ট টাকা ট্রান্সফার করুন যেকোন ব্যাংক বা মোবাইল ওয়ালেটে',
                            ),
                            const SizedBox(height: 22),
                            PrimaryButton(
                              label: 'টালিপে QR একাউন্ট খুলুন',
                              onPressed: () => Navigator.pushNamed(
                                  context, AppRoutes.tallypayIntro),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _check(String t) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_outline,
                size: 18, color: AppColors.textDark),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              t,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textDark,
                height: 1.35,
              ),
            ),
          ),
        ],
      );
}
