import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/bn.dart';
import '../../core/widgets/primary_button.dart';

/// Pure white bottom sheet radio list for selecting a business.
Future<String?> showBusinessPicker(BuildContext context) {
  final app = AppScope.read(context);
  final dec = app.decimalOn;
  String selected = app.current?.id ?? '';
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 10),
            child: InkWell(
              onTap: () => Navigator.pop(ctx),
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
                padding: const EdgeInsets.only(top: 10, bottom: 16),
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
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        'ব্যবসা সমূহ (${bn(app.businesses.length)}/${bn(5)})',
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final b in app.businesses)
                      InkWell(
                        onTap: () => setSheet(() => selected = b.id),
                        child: Container(
                          color: selected == b.id
                              ? const Color(0xFFF6F6F6)
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
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
                              Icon(
                                selected == b.id
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: selected == b.id
                                    ? AppColors.red
                                    : Colors.grey,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: PrimaryButton(
                        label: 'পরবর্তী',
                        onPressed: () => Navigator.pop(ctx, selected),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
