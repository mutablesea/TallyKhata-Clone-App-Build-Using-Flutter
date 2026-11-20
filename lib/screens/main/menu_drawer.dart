import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/state/app_state.dart';

/// Right-side navigation drawer with profile header, reports, and app version footer.
class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  void _open(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final initials = app.initials;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.72,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top profile row
            InkWell(
              onTap: () => _open(context, AppRoutes.profile),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFF2C94C),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            app.phone.isEmpty
                                ? '+880'
                                : (app.phone.startsWith('+88')
                                      ? app.phone
                                      : '+88${app.phone}'),
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
            ),

            // Gold trial banner
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.gold, AppColors.goldLight],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.workspace_premium,
                      color: Color(0xFFB8860B),
                      size: 19,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'টালিখাতা গোল্ড (ট্রায়াল)',
                          style: TextStyle(fontSize: 13.5),
                        ),
                        Text(
                          'অবশিষ্ট: ৩০ দিন',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),

            // Indented menu list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(left: 20, right: 12, top: 4),
                children: [
                  _section('টালিখাতা'),
                  _item(
                    context,
                    Icons.sell_outlined,
                    'বেচা কেনা হিসাব',
                    AppRoutes.saleReport,
                  ),
                  _item(
                    context,
                    Icons.open_in_new_outlined,
                    'খরচ',
                    AppRoutes.expenseReport,
                  ),
                  _item(
                    context,
                    Icons.menu_book_outlined,
                    'বাকি হিসাব',
                    AppRoutes.dueReport,
                  ),
                  _item(
                    context,
                    Icons.inbox_outlined,
                    'ক্যাশ হিসাব',
                    AppRoutes.cashReport,
                  ),
                  _item(
                    context,
                    Icons.assignment_ind_outlined,
                    'মালিকের রিপোর্ট',
                    AppRoutes.ownerReport,
                  ),
                  _section('অন্যান্য'),
                  _item(
                    context,
                    Icons.settings_outlined,
                    'সেটিংস',
                    AppRoutes.settings,
                  ),
                  ListTile(
                    dense: true,
                    visualDensity: const VisualDensity(vertical: -1),
                    contentPadding: const EdgeInsets.only(left: 4),
                    leading: const Icon(Icons.share_outlined, size: 20),
                    title: const Text(
                      'টালিখাতা গোল্ড রেফার করুন',
                      style: TextStyle(fontSize: 14.5),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('রেফার লিংক শীঘ্রই আসছে')),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Footer (raised slightly above the bottom edge)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 16, 60),
              child: Row(
                children: [
                  Image.asset('assets/images/tallykhata_logo8.png', height: 30),
                  const Spacer(),
                  const Text(
                    'ভার্সন - ৭.১৮.১',
                    style: TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String t) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 4),
    child: Text(
      t,
      style: const TextStyle(
        color: AppColors.red,
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _item(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      contentPadding: const EdgeInsets.only(left: 4),
      leading: Icon(icon, size: 20, color: Colors.black87),
      title: Text(label, style: const TextStyle(fontSize: 14.5)),
      onTap: () => _open(context, route),
    );
  }
}
