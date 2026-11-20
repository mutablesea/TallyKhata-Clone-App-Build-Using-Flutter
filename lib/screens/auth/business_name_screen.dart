import 'package:flutter/material.dart';

import '../../core/constants/business_types.dart';
import '../../core/routes/app_routes.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';

/// "ব্যবসা প্রতিষ্ঠানের নাম দিন" -> নিশ্চিত.
class BusinessNameScreen extends StatefulWidget {
  const BusinessNameScreen({super.key});

  @override
  State<BusinessNameScreen> createState() => _BusinessNameScreenState();
}

class _BusinessNameScreenState extends State<BusinessNameScreen> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _confirm() {
    AppScope.read(context).addBusiness(_name.text.trim(), businessTypes.first);
    Navigator.pushReplacementNamed(context, AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'ব্যবসা প্রতিষ্ঠানের নাম দিন',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _name,
                label: 'ব্যবসা প্রতিষ্ঠানের নাম',
                autofocus: true,
                onChanged: (_) => setState(() {}),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'নিশ্চিত',
                onPressed: _name.text.trim().isEmpty ? null : _confirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
