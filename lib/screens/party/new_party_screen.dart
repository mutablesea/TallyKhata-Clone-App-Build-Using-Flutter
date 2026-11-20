import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/models.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/bn.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/tk_app_bar.dart';

/// নতুন কাস্টমার/সাপ্লায়ার creation form.
/// Uses the exact same AppTextField for নাম, মোবাইল নম্বর, and পূর্বের বাকি (জের)
/// so the font, floating label, icon alignment, and vertical spacing match 100%.
class NewPartyScreen extends StatefulWidget {
  const NewPartyScreen({super.key});

  @override
  State<NewPartyScreen> createState() => _NewPartyScreenState();
}

class _NewPartyScreenState extends State<NewPartyScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _openingDue = TextEditingController();
  bool _isCustomer = true;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _openingDue.dispose();
    super.dispose();
  }

  bool get _hasName => _name.text.trim().isNotEmpty;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final due = double.tryParse(_openingDue.text.trim()) ?? 0;
    AppScope.read(context).addParty(
      Party(name: name, phone: _phone.text.trim(), isCustomer: _isCustomer),
      openingDue: due,
      openingDate: _date,
    );
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PartyAddedSuccessScreen(partyName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: tkAppBar(context, title: 'নতুন কাস্টমার/সাপ্লায়ার'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              backgroundColor: Color(0xFFC8C8C8),
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.greyBg,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.photo_camera_outlined,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _radio('কাস্টমার', true)),
                        const SizedBox(width: 8),
                        Expanded(child: _radio('সাপ্লায়ার', false)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'ফোনবুক পারমিশন লাগবে (পরে যোগ হবে)',
                                ),
                              ),
                            ),
                        icon: const Icon(Icons.contacts_outlined, size: 20),
                        label: const Text(
                          'ফোনবুক থেকে যোগ করি',
                          style: TextStyle(fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greyBg,
                          foregroundColor: AppColors.textDark,
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _name,
                      label: 'নাম',
                      icon: Icons.person_outline,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _phone,
                      label: 'মোবাইল নম্বর',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      digitsOnly: true,
                      maxLength: 11,
                    ),
                    if (_hasName) ...[
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _openingDue,
                        label: 'পূর্বের বাকি (জের)',
                        prefixSymbol: '৳',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decimalNumber: true,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.greyBg,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 16,
                                    color: AppColors.textDark,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    bnDate(_date),
                                    style: const TextStyle(fontSize: 13.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () => ScaffoldMessenger.of(context)
                                .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'ছবি যোগ করার ফিচার শীঘ্রই আসছে',
                                    ),
                                  ),
                                ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.greyBg,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 16,
                                    color: AppColors.textDark,
                                  ),
                                  SizedBox(width: 6),
                                  Text('ছবি', style: TextStyle(fontSize: 13.5)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: PrimaryButton(
                label: 'নিশ্চিত',
                onPressed: _hasName ? _save : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _radio(String label, bool value) {
    final sel = _isCustomer == value;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _isCustomer = value),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: sel ? AppColors.red : Colors.grey.shade400,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              sel ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 19,
              color: sel ? AppColors.red : Colors.grey,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.5,
                  color: sel ? AppColors.red : AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Confirmation screen shown briefly after adding a new customer/supplier.
class PartyAddedSuccessScreen extends StatefulWidget {
  final String partyName;
  const PartyAddedSuccessScreen({super.key, required this.partyName});

  @override
  State<PartyAddedSuccessScreen> createState() =>
      _PartyAddedSuccessScreenState();
}

class _PartyAddedSuccessScreenState extends State<PartyAddedSuccessScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.green,
                child: Icon(Icons.check, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                '"${widget.partyName}"- কে টালিতে যোগ করা হয়েছে।',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppColors.textDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
