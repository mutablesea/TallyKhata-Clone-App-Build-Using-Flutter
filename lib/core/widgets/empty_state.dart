import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Grey circle icon + message (used when a list is empty).
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                color: AppColors.greyBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: iconColor ?? Colors.grey),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppColors.textDark),
            ),
          ],
        ),
      ),
    );
  }
}
