import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/tk_app_bar.dart';
import 'business_type_screen.dart';

/// Screens 11 & 33/35: used for BOTH "new business" and "edit business".
/// editing == null  => new
class BusinessFormScreen extends StatefulWidget {
  final Business? editing;
  const BusinessFormScreen({super.key, this.editing});

  @override
  State<BusinessFormScreen> createState() => _BusinessFormScreenState();
}

class _BusinessFormScreenState extends State<BusinessFormScreen> {
  late final TextEditingController _name;
  BusinessType? _type;

  bool get _isEdit => widget.editing != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.editing?.name ?? '');
    _type = widget.editing?.type;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _valid => _name.text.trim().isNotEmpty && _type != null;

  Future<void> _pickType() async {
    final t = await Navigator.push<BusinessType>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => BusinessTypeScreen(selected: _type),
      ),
    );
    if (t != null) setState(() => _type = t);
  }

  void _save() {
    final app = AppScope.read(context);
    if (_isEdit) {
      app.editBusiness(widget.editing!.id, _name.text.trim(), _type!);
    } else {
      app.addBusiness(_name.text.trim(), _type!);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: tkAppBar(context, title: _isEdit ? 'ব্যবসা এডিট' : 'নতুন ব্যবসা'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              AppTextField(
                controller: _name,
                label: 'ব্যবসা প্রতিষ্ঠানের নাম',
                icon: Icons.storefront_outlined,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickType,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEDED),
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(_type?.icon ?? Icons.store_mall_directory_outlined,
                          size: 30),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(_type?.name ?? 'ব্যবসার ধরণ',
                            style: const TextStyle(fontSize: 16)),
                      ),
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFFCFCFCF),
                        child: Icon(Icons.chevron_right,
                            size: 20, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'নিশ্চিত',
                onPressed: _valid ? _save : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
