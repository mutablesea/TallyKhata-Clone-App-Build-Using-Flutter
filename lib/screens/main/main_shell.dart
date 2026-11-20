import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/state/app_state.dart';
import '../cashbox/cashbox_screen.dart';
import '../home/home_screen.dart';
import '../tallypay/tallypay_screen.dart';
import 'menu_drawer.dart';

/// Bottom navigation shell (টালি / ক্যাশবক্স / টালিপে / মেনু) with subtle top grey border.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      key: _key,
      endDrawer: const MenuDrawer(),
      body: IndexedStack(
        index: app.tabIndex,
        children: const [HomeScreen(), CashboxScreen(), TallyPayScreen()],
      ),
      floatingActionButton: app.tabIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              icon: const Icon(Icons.person_add_alt_1_outlined, size: 28),
              label: const Text(
                'নতুন কাস্টমার/সাপ্লায়ার',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.newParty),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E2E2), width: 1)),
        ),
        child: NavigationBar(
          height: 80,
          selectedIndex: app.tabIndex,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.pinkBg,
          onDestinationSelected: (i) {
            if (i == 3) {
              _key.currentState?.openEndDrawer();
            } else {
              app.setTab(i);
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined, size: 22),
              selectedIcon: Icon(
                Icons.menu_book,
                color: AppColors.red,
                size: 22,
              ),
              label: 'টালি',
            ),
            NavigationDestination(
              icon: Icon(Icons.inbox_outlined, size: 22),
              selectedIcon: Icon(Icons.inbox, color: AppColors.red, size: 22),
              label: 'ক্যাশবক্স',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined, size: 22),
              selectedIcon: Icon(
                Icons.account_balance_wallet,
                color: AppColors.red,
                size: 22,
              ),
              label: 'টালিপে',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu, size: 22),
              label: 'মেনু',
            ),
          ],
        ),
      ),
    );
  }
}
