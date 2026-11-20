import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/tk_app_bar.dart';

/// Screen 19: ব্যবসার নোট list + FAB "নোট যোগ করি".
class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      appBar: tkAppBar(context,
          title: 'ব্যবসার নোট',
          showBusiness: true,
          actions: const [HelpPill()]),
      body: app.notes.isEmpty
          ? const EmptyState(
              icon: Icons.assignment_outlined,
              iconColor: AppColors.red,
              message: 'পণ্য তালিকা বা প্রয়োজনীয় নোট লিখে\nরাখুন ও শেয়ার করুন।',
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 90),
              itemCount: app.notes.length,
              itemBuilder: (_, i) {
                final n = app.notes[i];
                return CheckboxListTile(
                  value: n.done,
                  activeColor: AppColors.red,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (_) => app.toggleNote(n),
                  title: Text(
                    n.text,
                    style: TextStyle(
                      fontSize: 19,
                      decoration:
                          n.done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.red,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('নোট যোগ করি', style: TextStyle(fontSize: 18)),
        onPressed: () => Navigator.pushNamed(context, AppRoutes.noteEditor),
      ),
    );
  }
}
