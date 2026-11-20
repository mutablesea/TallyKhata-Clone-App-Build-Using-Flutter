import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/tk_app_bar.dart';
import 'business_form_screen.dart';
import 'business_picker_sheet.dart';

/// ব্যবসার সেটিংস screen for managing primary, editing, and deleting businesses.
class BusinessSettingsScreen extends StatelessWidget {
  const BusinessSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    Future<void> setPrimary() async {
      final id = await showBusinessPicker(context);
      if (id == null || !context.mounted) return;
      app.setPrimary(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('প্রাইমারি ব্যবসা সেট হয়েছে')),
      );
    }

    Future<void> edit() async {
      final id = await showBusinessPicker(context);
      if (id == null || !context.mounted) return;
      final b = app.businesses.firstWhere((e) => e.id == id);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BusinessFormScreen(editing: b)),
      );
    }

    Future<void> delete() async {
      final id = await showBusinessPicker(context);
      if (id == null || !context.mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('ব্যবসা ডিলিট করবেন?'),
          content: const Text('এই ব্যবসার সব তথ্য মুছে যাবে।'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('না')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('হ্যাঁ',
                    style: TextStyle(color: AppColors.red))),
          ],
        ),
      );
      if (ok != true || !context.mounted) return;
      final done = app.deleteBusiness(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(done
                ? 'ব্যবসা ডিলিট হয়েছে'
                : 'কমপক্ষে একটি ব্যবসা থাকতে হবে')),
      );
    }

    Widget tile(String t, VoidCallback onTap) => ListTile(
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
          title: Text(t, style: const TextStyle(fontSize: 15)),
          trailing: const Icon(Icons.chevron_right, size: 20),
          onTap: onTap,
        );

    return Scaffold(
      appBar: tkAppBar(context, title: 'ব্যবসার সেটিংস'),
      body: ListView(
        padding: const EdgeInsets.only(top: 4),
        children: [
          tile('প্রাইমারি ব্যবসা সেট করুন', setPrimary),
          tile('ব্যবসা এডিট করুন', edit),
          tile('ব্যবসা ডিলিট করুন', delete),
        ],
      ),
    );
  }
}
