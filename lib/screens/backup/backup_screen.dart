import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/bn.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/tk_app_bar.dart';

/// Screen 22: ডাটা ব্যাকআপ. Button is active only when data changed.
class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final d = app.lastBackup;
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final time =
        '${bnDate(d)}, ${bn(hour12.toString().padLeft(2, '0'))}:${bn(d.minute.toString().padLeft(2, '0'))} $ampm';

    return Scaffold(
      appBar: tkAppBar(context, title: 'ডাটা ব্যাকআপ'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 115,
                height: 115,
                decoration: BoxDecoration(
                  color: app.needsBackup ? AppColors.orange : AppColors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  app.needsBackup ? Icons.cloud_upload : Icons.cloud_done,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                app.needsBackup
                    ? 'নতুন ডাটা ব্যাকআপ নেয়া হয়নি।'
                    : 'সব ডাটা ব্যাকআপ নেয়া আছে।',
                style: const TextStyle(fontSize: 16, color: AppColors.textGrey),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 4),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('সর্বশেষ ব্যাকআপঃ',
                        style: TextStyle(
                            fontSize: 14.5, color: AppColors.textGrey)),
                    const SizedBox(height: 4),
                    Text(time,
                        style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.green,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'ডাটা ব্যাকআপ করুন',
                onPressed: app.needsBackup
                    ? () {
                        app.backupNow();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ব্যাকআপ সম্পন্ন হয়েছে')),
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
