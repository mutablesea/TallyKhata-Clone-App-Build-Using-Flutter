import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/models.dart';
import '../../core/routes/app_routes.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/tk_app_bar.dart';

/// Screen 38: বিস্তারিত (message detail + "বাংলা QR পেতে ট্যাপ করুন").
class InboxDetailScreen extends StatelessWidget {
  final InboxMessage message;
  const InboxDetailScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: tkAppBar(context, title: 'বিস্তারিত'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    height: 170,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE3EA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'মার্চেন্টের\nকোন খরচ নেই!',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '৳২,০০০ টাকা পর্যন্ত\nপেমেন্টে চার্জ ফ্রি!',
                            style: TextStyle(fontSize: 13.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(message.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('১৭ নভেম্বর ২০২৬ । ১১:০২ AM',
                      style: TextStyle(fontSize: 13.5, color: AppColors.textGrey)),
                  const SizedBox(height: 12),
                  Text(message.body,
                      style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.5,
                          color: AppColors.textGrey)),
                ],
              ),
            ),
            if (message.fromMerchantCampaign)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: PrimaryButton(
                  label: 'বাংলা QR পেতে ট্যাপ করুন ➔',
                  onPressed: () {
                    // go back to main shell and open TaliPay tab
                    AppScope.read(context).setTab(2);
                    Navigator.popUntil(
                        context, ModalRoute.withName(AppRoutes.main));
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
