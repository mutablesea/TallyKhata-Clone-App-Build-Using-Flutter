import 'package:flutter/material.dart';

import '../../screens/auth/business_name_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/tallypay_intro_screen.dart';
import '../../screens/auth/welcome_screen.dart';
import '../../screens/backup/backup_screen.dart';
import '../../screens/business/business_settings_screen.dart';
import '../../screens/inbox/inbox_detail_screen.dart';
import '../../screens/inbox/inbox_screen.dart';
import '../../screens/main/main_shell.dart';
import '../../screens/message/tali_message_screen.dart';
import '../../screens/notes/note_editor_screen.dart';
import '../../screens/notes/notes_screen.dart';
import '../../screens/party/new_party_screen.dart';
import '../../screens/party/party_detail_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/reminder/reminder_screen.dart';
import '../../screens/reports/cash_report_screen.dart';
import '../../screens/reports/report_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/stock/new_product_screen.dart';
import '../../screens/stock/stock_screen.dart';
import '../../screens/support/support_screen.dart';
import '../models/models.dart';

/// All screen names live here.
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const businessName = '/business-name';
  static const welcome = '/welcome';
  static const tallypayIntro = '/tallypay-intro';
  static const main = '/main';

  static const stock = '/stock';
  static const newProduct = '/stock/new';
  static const notes = '/notes';
  static const noteEditor = '/notes/edit';
  static const reminder = '/reminder';
  static const backup = '/backup';
  static const taliMessage = '/tali-message';
  static const newParty = '/party/new';
  static const partyDetail = '/party/detail';

  static const inbox = '/inbox';
  static const inboxDetail = '/inbox/detail';
  static const support = '/support';

  static const settings = '/settings';
  static const profile = '/profile';
  static const businessSettings = '/business-settings';

  static const saleReport = '/report/sale';
  static const expenseReport = '/report/expense';
  static const dueReport = '/report/due';
  static const ownerReport = '/report/owner';
  static const cashReport = '/report/cash';

  static Route<dynamic> onGenerateRoute(RouteSettings s) {
    final Widget page;
    switch (s.name) {
      case splash:
        page = const SplashScreen();
        break;
      case login:
        page = const LoginScreen();
        break;
      case businessName:
        page = const BusinessNameScreen();
        break;
      case welcome:
        page = const WelcomeScreen();
        break;
      case tallypayIntro:
        page = const TallyPayIntroScreen();
        break;
      case main:
        page = const MainShell();
        break;
      case stock:
        page = const StockScreen();
        break;
      case newProduct:
        page = const NewProductScreen();
        break;
      case notes:
        page = const NotesScreen();
        break;
      case noteEditor:
        page = const NoteEditorScreen();
        break;
      case reminder:
        page = const ReminderScreen();
        break;
      case backup:
        page = const BackupScreen();
        break;
      case taliMessage:
        page = const TaliMessageScreen();
        break;
      case newParty:
        page = const NewPartyScreen();
        break;
      case partyDetail:
        page = PartyDetailScreen(partyId: s.arguments as String);
        break;
      case inbox:
        page = const InboxScreen();
        break;
      case inboxDetail:
        page = InboxDetailScreen(message: s.arguments as InboxMessage);
        break;
      case support:
        page = const SupportScreen();
        break;
      case profile:
        page = const ProfileScreen();
        break;
      case settings:
        page = const SettingsScreen();
        break;
      case businessSettings:
        page = const BusinessSettingsScreen();
        break;
      case saleReport:
        page = const ReportScreen(
          title: 'বেচা কেনা হিসাব',
          columns: ['বেচা', 'কেনা'],
          kind: ReportKind.sales,
          checkboxLabel: 'সংক্ষিপ্ত',
        );
        break;
      case expenseReport:
        page = const ReportScreen(
          title: 'খরচ',
          columns: ['দিলাম'],
          kind: ReportKind.expense,
        );
        break;
      case dueReport:
        page = const ReportScreen(
          title: 'বাকি হিসাব',
          columns: ['দিলাম', 'পেলাম'],
          kind: ReportKind.due,
        );
        break;
      case ownerReport:
        page = const ReportScreen(
          title: 'মালিকের রিপোর্ট',
          columns: ['মালিক দিল', 'মালিক নিল'],
          kind: ReportKind.owner,
          monthly: true,
        );
        break;
      case cashReport:
        page = const CashReportScreen();
        break;
      default:
        page = const SplashScreen();
    }
    return MaterialPageRoute(builder: (_) => page, settings: s);
  }
}
