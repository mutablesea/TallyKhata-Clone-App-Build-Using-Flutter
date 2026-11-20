import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/tk_app_bar.dart';

/// TallyPay QR intro screen (mycode layout + rounded pill PrimaryButton).
class TallyPayIntroScreen extends StatelessWidget {
  final bool fromHome;
  const TallyPayIntroScreen({super.key, this.fromHome = false});

  void _goHome(BuildContext context, int tab) {
    AppScope.read(context).setTab(tab);
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: fromHome ? tkAppBar(context, title: 'QR কোড') : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text(
                'টালিপে QR — ব্যবসায়ীদের জন্য\nসেরা বাংলা QR',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Material(
                color: const Color(0xFFFBF2F2),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'টালিপে QR একাউন্ট আবেদন',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '২টি সহজ ধাপে টালিপে QR একাউন্ট-এর আবেদন করুন',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          child: Icon(Icons.person_outline),
                        ),
                        title: Text('NID ও সেলফি'),
                      ),
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          child: Icon(Icons.storefront_outlined),
                        ),
                        title: Text('ব্যবসার ছবি ও তথ্য'),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Colors.black87,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'NID এবং ব্যবসার ছবি থাকলে ২ মিনিটে QR পাবেন।',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
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
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () => fromHome
                      ? Navigator.pop(context)
                      : _goHome(context, 0),
                  child: const Text(
                    'টালিখাতা ব্যবহার করবো',
                    style: TextStyle(
                      color: AppColors.red,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              PrimaryButton(
                label: 'টালিপে QR একাউন্ট খুলুন',
                onPressed: () => _goHome(context, 2),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                    children: [
                      TextSpan(
                        text:
                            'টালিপে QR একাউন্ট খোলার মাধ্যমে আপনি টালিপে QR\nএকাউন্ট-এর ',
                      ),
                      TextSpan(
                        text: 'শর্তাবলীতে',
                        style: TextStyle(
                          color: AppColors.red,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.red,
                        ),
                      ),
                      TextSpan(text: ' সম্মতি প্রদান করছেন।'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
