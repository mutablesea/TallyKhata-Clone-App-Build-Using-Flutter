import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/business_types.dart';
import '../../core/models/models.dart';
import '../../core/widgets/primary_button.dart';

/// Screens 34-35: "আপনার ব্যবসার ধরণ কি?" grid. Pops with chosen BusinessType.
class BusinessTypeScreen extends StatefulWidget {
  final BusinessType? selected;
  const BusinessTypeScreen({super.key, this.selected});

  @override
  State<BusinessTypeScreen> createState() => _BusinessTypeScreenState();
}

class _BusinessTypeScreenState extends State<BusinessTypeScreen> {
  BusinessType? _selected;
  bool _personal = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
    _personal = widget.selected?.id == personalType.id;
  }

  @override
  Widget build(BuildContext context) {
    final chosen = _personal ? personalType : _selected;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('আপনার ব্যবসার ধরণ কি?',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                  ),
                  IconButton.filled(
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                        backgroundColor: AppColors.greyBg,
                        foregroundColor: Colors.black54),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 28),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('ব্যক্তিগত হিসাব রাখি',
                        style: TextStyle(fontSize: 16)),
                  ),
                  Switch(
                    value: _personal,
                    activeTrackColor: AppColors.red,
                    onChanged: (v) => setState(() {
                      _personal = v;
                      if (v) _selected = null;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: businessTypes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.3,
                  ),
                  itemBuilder: (_, i) {
                    final t = businessTypes[i];
                    final isSel = !_personal && _selected?.id == t.id;
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(() {
                        _selected = t;
                        _personal = false;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isSel
                              ? AppColors.pinkBg
                              : const Color(0xFFF7F8F8),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSel ? AppColors.red : Colors.transparent,
                            width: 1.6,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(t.icon, size: 30, color: AppColors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(t.name,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'নিশ্চিত',
                onPressed:
                    chosen == null ? null : () => Navigator.pop(context, chosen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
