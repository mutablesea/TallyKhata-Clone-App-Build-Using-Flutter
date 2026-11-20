import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.red,
        primary: AppColors.red,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
    );
    final rawTheme = GoogleFonts.notoSansBengaliTextTheme(base.textTheme);
    TextStyle? noLetterSpace(TextStyle? s) => s?.copyWith(letterSpacing: 0);
    final bengaliTextTheme = TextTheme(
      displayLarge: noLetterSpace(rawTheme.displayLarge),
      displayMedium: noLetterSpace(rawTheme.displayMedium),
      displaySmall: noLetterSpace(rawTheme.displaySmall),
      headlineLarge: noLetterSpace(rawTheme.headlineLarge),
      headlineMedium: noLetterSpace(rawTheme.headlineMedium),
      headlineSmall: noLetterSpace(rawTheme.headlineSmall),
      titleLarge: noLetterSpace(rawTheme.titleLarge),
      titleMedium: noLetterSpace(rawTheme.titleMedium),
      titleSmall: noLetterSpace(rawTheme.titleSmall),
      bodyLarge: noLetterSpace(rawTheme.bodyLarge),
      bodyMedium: noLetterSpace(rawTheme.bodyMedium),
      bodySmall: noLetterSpace(rawTheme.bodySmall),
      labelLarge: noLetterSpace(rawTheme.labelLarge),
      labelMedium: noLetterSpace(rawTheme.labelMedium),
      labelSmall: noLetterSpace(rawTheme.labelSmall),
    );

    return base.copyWith(
      textTheme: bengaliTextTheme,
      primaryTextTheme:
          GoogleFonts.notoSansBengaliTextTheme(base.primaryTextTheme),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        modalBackgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.notoSansBengali(
          color: AppColors.textDark,
          fontSize: 17.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.green
                : Colors.grey.shade400),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.pinkBg,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.notoSansBengali(
            fontSize: 12,
            color: AppColors.textDark,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
