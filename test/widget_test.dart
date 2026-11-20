import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tallykhata_clone/core/state/app_state.dart';
import 'package:tallykhata_clone/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('TallyKhataApp renders splash screen smoke test', (
    WidgetTester tester,
  ) async {
    final state = AppState();
    await tester.pumpWidget(TallyKhataApp(state: state));
    expect(find.byType(TallyKhataApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    // Let google_fonts finish loading bundled fonts before the widget tree is disposed.
    await tester.runAsync(() => GoogleFonts.pendingFonts());
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
