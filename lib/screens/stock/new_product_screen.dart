import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/tk_app_bar.dart';

/// নতুন প্রোডাক্ট screen with 16-unit draggable bottom sheet selector.
class NewProductScreen extends StatefulWidget {
  const NewProductScreen({super.key});

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  static const _units = [
    'কেজি',
    'পিস',
    'লিটার',
    'টি',
    'ডজন',
    'বস্তা',
    'সেট',
    'গজ',
    'প্যাকেট',
    'কার্টন',
    'স্কোয়ার মিটার',
    'স্কোয়ার ফিট',
    'ফুট',
    'ইঞ্চি',
    'মিটার',
    'অন্যান্য',
  ];

  final _name = TextEditingController();
  String? _unit;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _valid => _name.text.trim().isNotEmpty && _unit != null;

  Future<void> _pickUnit() async {
    FocusScope.of(context).unfocus();
    final chosen = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        snap: true,
        snapSizes: const [0.62, 0.92],
        builder: (_, scrollCtrl) => Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'প্রোডাক্ট এর ইউনিট সিলেক্ট করি',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: _units.length,
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  title:
                      Text(_units[i], style: const TextStyle(fontSize: 15.5)),
                  trailing: const Icon(Icons.chevron_right, size: 19),
                  onTap: () => Navigator.pop(ctx, _units[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (chosen != null) setState(() => _unit = chosen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: tkAppBar(context, title: 'নতুন প্রোডাক্ট'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AppTextField(
                controller: _name,
                label: 'প্রোডাক্ট এর নাম',
                icon: Icons.inventory_2_outlined,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _pickUnit,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: _unit != null ? 'প্রোডাক্ট এর ইউনিট' : null,
                    floatingLabelStyle: const TextStyle(
                        color: AppColors.red, fontSize: 13.5),
                    prefixIcon: const Icon(Icons.archive_outlined,
                        color: AppColors.textDark, size: 22),
                    suffixIcon: const Icon(Icons.keyboard_arrow_down),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.border, width: 1.1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.border, width: 1.1),
                    ),
                  ),
                  child: Text(
                    _unit ?? 'প্রোডাক্ট এর ইউনিট',
                    style: TextStyle(
                      fontSize: 15.5,
                      color:
                          _unit != null ? AppColors.textDark : AppColors.textGrey,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'নিশ্চিত',
                onPressed: _valid
                    ? () {
                        AppScope.read(context).addProduct(
                            Product(name: _name.text.trim(), unit: _unit!));
                        Navigator.pop(context);
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
