import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/tk_app_bar.dart';

/// App settings screen (decimal toggle, sound/voice notifications, phone & PIN).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showVoice = false;
  Timer? _voiceTimer;

  @override
  void initState() {
    super.initState();
    _voiceTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _showVoice = true);
    });
  }

  @override
  void dispose() {
    _voiceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      appBar: tkAppBar(context, title: 'সেটিংস'),
      body: ListView(
        children: [
          _header('সাধারণ সেটিংস'),
          _switch('টাকার অংকে দশমিক', 'উদাহরণঃ ১২,০০০.০০', app.decimalOn,
              app.setDecimal),
          _switch('নোটিফিকেশন সাউন্ড', 'টালিখাতা নোটিফিকেশনে সাউন্ড এলার্ট',
              app.notificationSound, app.setNotificationSound),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: _showVoice
                ? _switch(
                    'ভয়েস নোটিফিকেশন',
                    'ভয়েসের মাধ্যমে পেমেন্ট এলার্ট',
                    app.voiceNotification,
                    app.setVoiceNotification,
                  )
                : const SizedBox.shrink(),
          ),
          const Divider(thickness: 6),
          _header('প্রোফাইল সেটিংস'),
          _tile(Icons.phone_outlined, 'মোবাইল নম্বর পরিবর্তন',
              () => _changePhone(context)),
          const Divider(thickness: 6),
          _header('অ্যাপ সিকিউরিটি'),
          _tile(Icons.key, 'PIN সেট করুন', () => _setPin(context)),
          const Divider(thickness: 6),
        ],
      ),
    );
  }

  Widget _header(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        child: Text(t,
            style: const TextStyle(fontSize: 13.5, color: AppColors.textGrey)),
      );

  Widget _switch(String t, String sub, bool v, ValueChanged<bool> onChanged) =>
      SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(t, style: const TextStyle(fontSize: 15.5)),
        subtitle: Text(sub,
            style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
        value: v,
        onChanged: onChanged,
      );

  Widget _tile(IconData i, String t, VoidCallback onTap) => ListTile(
        dense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Icon(i, size: 22),
        title: Text(t, style: const TextStyle(fontSize: 15.5)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      );

  void _changePhone(BuildContext context) {
    final app = AppScope.read(context);
    final c = TextEditingController();
    _sheet(
      context,
      'মোবাইল নম্বর পরিবর্তন',
      AppTextField(
        controller: c,
        label: 'নতুন মোবাইল নম্বর',
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
        digitsOnly: true,
        maxLength: 11,
        autofocus: true,
      ),
      () {
        if (c.text.length == 11) {
          app.phone = c.text;
          app.notifyListeners();
        }
      },
    );
  }

  void _setPin(BuildContext context) {
    final c = TextEditingController();
    _sheet(
      context,
      'PIN সেট করুন',
      AppTextField(
        controller: c,
        label: '৪ ডিজিটের PIN',
        icon: Icons.key,
        keyboardType: TextInputType.number,
        digitsOnly: true,
        maxLength: 4,
        autofocus: true,
      ),
      () {},
    );
  }

  void _sheet(
      BuildContext context, String title, Widget field, VoidCallback onSave) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
            const SizedBox(height: 14),
            field,
            const SizedBox(height: 14),
            PrimaryButton(
              label: 'নিশ্চিত',
              onPressed: () {
                onSave();
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
