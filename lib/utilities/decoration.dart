import 'package:flutter/material.dart';
import 'package:flutter_application_3/utilities/colors_dart.dart';
import 'package:flutter_application_3/utilities/fonts_dart.dart';
import 'package:flutter_application_3/utilities/theme_provider.dart';
import 'package:provider/provider.dart';

InputDecoration emailInputDecoration(BuildContext context, String labelText, Icon prefixIcon) {
  final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

  return InputDecoration(
    filled: true,
    fillColor: Colors.transparent,
    labelText: labelText,
    labelStyle: isDarkMode
        ? AppFonts.textW24bold
        : AppFonts.textB24bold,
    prefixIcon: prefixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.grey),
    ),
  );
}

InputDecoration passwordInputDecoration({
  required BuildContext context,
  required String labelText,
  required bool obscurePassword,
  required VoidCallback onTogglePassword,
  required IconData iconPassword,
  required Icon prefixIcon,  // Accepting custom prefixIcon
}) {
  final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

  return InputDecoration(
    filled: true,
    fillColor: Colors.transparent,
    labelText: labelText,
    labelStyle: isDarkMode
        ? AppFonts.textW24bold
        : AppFonts.textB24bold,
    prefixIcon: prefixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    suffixIcon: IconButton(
      onPressed: onTogglePassword,
      icon: Icon(iconPassword),
    ),
  );
}

InputDecoration searchInputDecoration(BuildContext context, String labelText, Icon prefixIcon) {
  final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

  return InputDecoration(
    filled: true,
    fillColor: Colors.transparent,
    labelText: labelText,
    labelStyle: isDarkMode
        ? AppFonts.textW24bold
        : AppFonts.textB24bold,
    prefixIcon: prefixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: const BorderSide(color: Colors.blueAccent),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: const BorderSide(color: Colors.blueAccent),
    ),
    contentPadding: const EdgeInsets.symmetric(
        vertical: 12, horizontal: 16),
  );
}

BoxDecoration customContainerDecoration({
  Color color = AppColors.lightGrey,
  double borderRadius = 5.0,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(borderRadius),
  );
}

BoxDecoration noteContainerDecoration({
  Color color = AppColors.lightGrey,
}) {
  return BoxDecoration(
    color: color,
  );
}
