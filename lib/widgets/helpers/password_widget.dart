import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utilities/fonts_dart.dart';
import '../../utilities/theme_provider.dart';

class PasswordStrengthRow extends StatelessWidget {
  final bool containsUpperCase;
  final bool containsLowerCase;
  final bool containsNumber;
  final bool containsSpecialChar;
  final bool contains8Length;

  const PasswordStrengthRow({
    super.key,
    required this.containsUpperCase,
    required this.containsLowerCase,
    required this.containsNumber,
    required this.containsSpecialChar,
    required this.contains8Length,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    TextStyle textStyle = isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "⚈  1 uppercase".tr(),
              style: textStyle.copyWith(
                color: containsUpperCase
                    ? Colors.green
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              "⚈  1 lowercase".tr(),
              style: textStyle.copyWith(
                color: containsLowerCase
                    ? Colors.green
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              "⚈  1 number".tr(),
              style: textStyle.copyWith(
                color: containsNumber
                    ? Colors.green
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              "⚈  1 special character".tr(),
              style: textStyle.copyWith(
                color: containsSpecialChar
                    ? Colors.green
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              "⚈  8 minimum characters".tr(),
              style: textStyle.copyWith(
                color: contains8Length
                    ? Colors.green
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
