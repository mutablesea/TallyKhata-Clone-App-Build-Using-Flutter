import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/bn.dart';
import 'business_form_screen.dart';

/// Bottom sheet opened from the gold business chip or মাল্টি ব্যবসা action.
/// Displays all businesses with active indicator and quick add/settings actions.
void showBusinessSwitcher(BuildContext context) {
  final nav = Navigator.of(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetCtx) {
      final app = AppScope.of(sheetCtx);
      final dec = app.decimalOn;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 10),
            child: InkWell(
              onTap: () => Navigator.pop(sheetCtx),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(Icons.close, size: 20, color: Colors.black87),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'ব্যবসা সমূহ (${bn(app.businesses.length)}/${bn(5)})',
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          height: 32,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(sheetCtx);
                              nav.pushNamed(AppRoutes.businessSettings);
                            },
                            icon:
                                const Icon(Icons.settings_outlined, size: 15),
                            label: const Text('সেটিংস',
                                style: TextStyle(fontSize: 12.5)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textDark,
                              side: BorderSide(color: Colors.grey.shade400),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              shape: const StadiumBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    for (final b in app.businesses)
                      InkWell(
                        onTap: () {
                          app.switchBusiness(b.id);
                          Navigator.pop(sheetCtx);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            b.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        if (b.isPrimary) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.pinkBg,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: const Text(
                                              'প্রাইমারি',
                                              style: TextStyle(
                                                color: AppColors.red,
                                                fontSize: 11.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'কাস্টমার ${bn(app.customerCountFor(b.id))}, সাপ্লায়ার ${bn(app.supplierCountFor(b.id))} | মোট পাবো ${bnMoney(app.totalReceivableFor(b.id), decimal: dec)}',
                                      style: const TextStyle(
                                        color: AppColors.textGrey,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (b.id == app.current?.id)
                                const Icon(Icons.check_circle,
                                    color: AppColors.green, size: 22),
                            ],
                          ),
                        ),
                      ),
                    const Divider(),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () {
                          if (app.businesses.length >= 5) {
                            ScaffoldMessenger.of(sheetCtx).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'সর্বোচ্চ ৫টি ব্যবসা যোগ করা যাবে')),
                            );
                            return;
                          }
                          Navigator.pop(sheetCtx);
                          nav.push(MaterialPageRoute(
                              builder: (_) => const BusinessFormScreen()));
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.red,
                          side: const BorderSide(
                              color: AppColors.red, width: 1.2),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          '+ নতুন ব্যবসা',
                          style: TextStyle(fontSize: 15.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
