import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../routes/app_routes.dart';
import '../state/app_state.dart';
import '../../screens/business/business_switcher_sheet.dart';

/// Gold gradient header with dynamic business name pill and unread inbox badge.
class GoldPage extends StatelessWidget {
  final Widget child;
  final bool showPlan;
  const GoldPage({super.key, required this.child, this.showPlan = true});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final unreadCount = app.unread;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.gold, AppColors.goldLight],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 10, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---- Business Name Pill Widget ----
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => showBusinessSwitcher(context),
                            child: Container(
                              // constraints: const BoxConstraints(maxHeight: 50),
                              height: 25,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.workspace_premium,
                                    color: Color(0xFFB8860B),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 3.0,
                                      ),
                                      child: Text(
                                        app.businessName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 17,
                                    color: AppColors.textDark,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (showPlan)
                          const Padding(
                            padding: EdgeInsets.only(left: 6, top: 6),
                            child: Text(
                              'গোল্ড (ট্রায়াল)',
                              style: TextStyle(
                                color: AppColors.goldText,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _HeaderButton(
                    icon: Icons.mark_email_unread_outlined,
                    label: 'ইনবক্স',
                    badge: unreadCount,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.inbox),
                  ),
                  _HeaderButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'সাপোর্ট',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.support),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int badge;
  final VoidCallback onTap;
  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 23, color: AppColors.textDark),
                if (badge > 0)
                  Positioned(
                    right: -7,
                    top: -6,
                    child: Container(
                      width: 19,
                      height: 19,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE52421),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
