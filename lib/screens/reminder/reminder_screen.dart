import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/state/app_state.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/tk_app_bar.dart';

/// Screen 21: তাগাদা পাঠাই (list of customers).
class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final customers = app.parties.where((p) => p.isCustomer).toList();
    return Scaffold(
      appBar: tkAppBar(context,
          title: 'তাগাদা পাঠাই',
          showBusiness: true,
          actions: const [HelpPill()]),
      body: customers.isEmpty
          ? const EmptyState(
              icon: Icons.chat_bubble_outline,
              message: 'কোনো কাস্টমার পাওয়া যায়নি।',
            )
          : ListView.separated(
              itemCount: customers.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (_, i) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(customers[i].name,
                    style: const TextStyle(fontSize: 19)),
                subtitle: Text(customers[i].phone),
                trailing: TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('${customers[i].name}-কে তাগাদা পাঠানো হয়েছে')),
                  ),
                  child: const Text('পাঠাই',
                      style: TextStyle(color: AppColors.red, fontSize: 17)),
                ),
              ),
            ),
    );
  }
}
