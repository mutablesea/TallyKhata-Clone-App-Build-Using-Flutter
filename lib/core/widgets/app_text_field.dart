import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';

/// Outlined text field with floating red label (consistent font & spacing across all fields).
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final IconData? icon;
  final String? prefixSymbol;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final int? maxLength;
  final bool digitsOnly;
  final bool decimalNumber;
  final bool autofocus;

  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    this.icon,
    this.prefixSymbol,
    this.keyboardType,
    this.onChanged,
    this.maxLength,
    this.digitsOnly = false,
    this.decimalNumber = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final inputFormatters = <TextInputFormatter>[
      if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
      if (decimalNumber) FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
    ];

    Widget? leading;
    if (icon != null) {
      leading = Icon(icon, color: AppColors.textDark, size: 22);
    } else if (prefixSymbol != null) {
      leading = SizedBox(
        width: 48,
        child: Center(
          child: Text(
            prefixSymbol!,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
      );
    }

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      autofocus: autofocus,
      inputFormatters: inputFormatters,
      cursorColor: AppColors.red,
      style: const TextStyle(
        fontSize: 16.5,
        letterSpacing: 0,
        color: AppColors.textDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textGrey,
          fontSize: 16,
          letterSpacing: 0,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.red,
          fontSize: 14,
          letterSpacing: 0,
        ),
        prefixIcon: leading,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border, width: 1.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.red, width: 1.6),
        ),
      ),
    );
  }
}
