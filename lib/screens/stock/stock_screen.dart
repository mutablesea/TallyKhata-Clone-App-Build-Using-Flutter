import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/tk_app_bar.dart';

/// Screen 17: স্টক হিসাব (empty -> product list) + FAB "নতুন প্রোডাক্ট".
class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      appBar: tkAppBar(context,
          title: 'স্টক হিসাব',
          showBusiness: true,
          actions: const [HelpPill()]),
      body: app.products.isEmpty
          ? const EmptyState(
              icon: Icons.inventory_2_outlined,
              message: 'প্রোডাক্ট যোগ করে স্টকের হিসাব রাখুন।',
            )
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: 90),
              itemCount: app.products.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (_, i) {
                final p = app.products[i];
                return ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(p.name, style: const TextStyle(fontSize: 19)),
                  trailing: Text(p.unit),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.red,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('নতুন প্রোডাক্ট', style: TextStyle(fontSize: 18)),
        onPressed: () => Navigator.pushNamed(context, AppRoutes.newProduct),
      ),
    );
  }
}
