import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';

/// Onboarding carousel (PageView) + phone number registration/login.
/// Edge-to-edge: top slide background extends behind the status bar.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pageCtrl = PageController();
  final _phoneCtrl = TextEditingController();
  int _page = 0;
  Timer? _timer;

  static const _slides = [
    (
      'QR কোড-এ পেমেন্ট নিন বিকাশ, রকেট সহ সকল ব্যাংক অ্যাপ থেকে।',
      'assets/images/tallykhata_logo5.jpg',
      Color(0xFFFDF0ED),
    ),
    (
      'ট্রান্সফার করুন নগদ, রকেট বা ব্যাংক একাউন্টে।',
      'assets/images/tallykhata_logo6.jpg',
      Color(0xFFFEF3E8),
    ),
    (
      'টালিখাতায় লেনদেন ১০০% নিরাপদ।',
      'assets/images/tallykhata_logo7.jpg',
      Color(0xFFEDFAEE),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_pageCtrl.hasClients) return;
      _pageCtrl.animateToPage(
        (_page + 1) % _slides.length,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool get _valid => _phoneCtrl.text.length == 11;

  void _next() {
    AppScope.read(context).phone = _phoneCtrl.text;
    Navigator.pushReplacementNamed(context, AppRoutes.businessName);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          if (!keyboardOpen) ...[
            SizedBox(
              height: 310 + topInset,
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => Container(
                  color: _slides[i].$3,
                  padding: EdgeInsets.only(top: topInset),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.asset(
                          _slides[i].$2,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                        child: Text(
                          _slides[i].$1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _slides.length; i++)
                  Container(
                    margin: const EdgeInsets.all(3),
                    width: i == _page ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: i == _page ? Colors.black87 : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
            const Divider(),
          ] else
            SizedBox(height: topInset),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'রেজিস্ট্রেশন/লগইন করুন',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _phoneCtrl,
                    label: 'মোবাইল নম্বর',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    digitsOnly: true,
                    maxLength: 11,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  const Text.rich(
                    TextSpan(
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                      children: [
                        TextSpan(text: 'রেজিস্ট্রেশন করতে আপনার '),
                        TextSpan(
                          text: 'NID দিয়ে নিবন্ধিত মোবাইল নম্বর',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        TextSpan(text: ' ব্যবহার করুন।'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  PrimaryButton(
                    label: 'পরবর্তী',
                    onPressed: _valid ? _next : null,
                  ),
                  const SizedBox(height: 8),
                  const Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                      children: [
                        TextSpan(
                          text: 'পরবর্তীতে যাওয়ার নির্দেশের মাধ্যমে আপনি টালিখাতার ',
                        ),
                        TextSpan(
                          text: 'শর্তাবলীতে',
                          style: TextStyle(
                            color: AppColors.red,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.red,
                          ),
                        ),
                        TextSpan(text: ' সম্মতি প্রদান করছেন।'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
