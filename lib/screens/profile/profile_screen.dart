import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/tk_app_bar.dart';
import '../business/business_type_screen.dart';

/// Screen 43: আপনার তথ্য সমূহ (opened by tapping the profile in the menu drawer).
/// Pencil icon switches between view mode and edit mode.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  final _name = TextEditingController();
  final _nid = TextEditingController();
  final _age = TextEditingController();
  final _address = TextEditingController();
  BusinessType? _type;

  @override
  void dispose() {
    _name.dispose();
    _nid.dispose();
    _age.dispose();
    _address.dispose();
    super.dispose();
  }

  void _startEdit(AppState app) {
    _name.text = app.ownerName;
    _nid.text = app.nid;
    _age.text = app.businessAge;
    _address.text = app.address;
    _type = app.current?.type;
    setState(() => _editing = true);
  }

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

  void _save(AppState app) {
    app.saveProfile(
      name: _name.text.trim(),
      nid: _nid.text.trim(),
      age: _age.text.trim(),
      address: _address.text.trim(),
    );
    final b = app.current;
    if (b != null && _type != null) app.editBusiness(b.id, b.name, _type!);
    setState(() => _editing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('তথ্য সংরক্ষণ হয়েছে')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      appBar: tkAppBar(context, title: 'আপনার তথ্য সমূহ'),
      body: SafeArea(
        child: Column(
          children: [
            // top: avatar + business name + phone
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFFCCB22),
                    child: Text(app.initials,
                        style: const TextStyle(fontSize: 19)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app.businessName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(app.phone, style: const TextStyle(fontSize: 14.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 6),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('অন্যান্য তথ্য',
                            style: TextStyle(
                                fontSize: 19, color: AppColors.textGrey)),
                      ),
                      IconButton.filled(
                        onPressed: () => _editing
                            ? setState(() => _editing = false)
                            : _startEdit(app),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.greyBg,
                          foregroundColor: AppColors.textDark,
                        ),
                        icon: Icon(_editing ? Icons.close : Icons.edit_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_editing) ..._editForm(app) else ..._viewInfo(app),
                ],
              ),
            ),
            if (_editing)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: PrimaryButton(
                    label: 'নিশ্চিত', onPressed: () => _save(app)),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _viewInfo(AppState app) => [
        _info('নাম', app.ownerName),
        _info('ব্যবসার ধরণ', app.current?.type.name ?? ''),
        _info('NID নম্বর', app.nid),
        _info('ব্যবসা প্রতিষ্ঠানের আনুমানিক বয়স (বছর)', app.businessAge),
        _info('ব্যবসা প্রতিষ্ঠানের ঠিকানা', app.address),
      ];

  Widget _info(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14.5, color: AppColors.textGrey)),
            if (value.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(value,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w500)),
            ],
          ],
        ),
      );

  List<Widget> _editForm(AppState app) => [
        AppTextField(controller: _name, label: 'নাম'),
        const SizedBox(height: 18),
        InkWell(
          onTap: _pickType,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border, width: 1.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(_type?.name ?? 'ব্যবসার ধরণ',
                      style: const TextStyle(fontSize: 19)),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        AppTextField(
          controller: _nid,
          label: 'NID নম্বর',
          keyboardType: TextInputType.number,
          digitsOnly: true,
          maxLength: 17,
        ),
        const SizedBox(height: 18),
        AppTextField(
          controller: _age,
          label: 'ব্যবসা প্রতিষ্ঠানের আনুমানিক বয়স (বছর)',
          keyboardType: TextInputType.number,
          digitsOnly: true,
          maxLength: 2,
        ),
        const SizedBox(height: 18),
        AppTextField(controller: _address, label: 'ব্যবসা প্রতিষ্ঠানের ঠিকানা'),
      ];
}
