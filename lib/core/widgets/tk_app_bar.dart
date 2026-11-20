import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../state/app_state.dart';

/// Standard top bar: back arrow + title (+ business name under it).
PreferredSizeWidget tkAppBar(
  BuildContext context, {
  required String title,
  bool showBusiness = false,
  List<Widget>? actions,
}) {
  final subtitle = showBusiness ? AppScope.of(context).businessName : null;
  return AppBar(
    title: subtitle == null
        ? Text(title)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
    actions: [...?actions, const SizedBox(width: 12)],
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(),
    ),
  );
}

/// Grey "? হেল্প" pill shown on the right of some app bars.
class HelpPill extends StatelessWidget {
  const HelpPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('হেল্প ভিডিও শীঘ্রই আসছে')),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.greyBg,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.help_outline, size: 20),
              SizedBox(width: 6),
              Text('হেল্প', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Soft red pill (e.g. "রিপোর্ট").
class PinkPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const PinkPill({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.pinkBg,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: AppColors.red),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(fontSize: 17, color: AppColors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
