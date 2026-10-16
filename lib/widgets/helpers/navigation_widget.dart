import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/utilities/colors_dart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../utilities/fonts_dart.dart';
import '../../utilities/theme_provider.dart';

class CustomNavigationBar extends StatelessWidget {
  final ValueChanged<int> onTap;

  const CustomNavigationBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;

        return CurvedNavigationBar(
          backgroundColor: AppColors.trans,
          color: isDarkMode ? Colors.black : Colors.white,
          items: [
            CurvedNavigationBarItem(
              child: FaIcon(FontAwesomeIcons.house,
                  color: isDarkMode ? Colors.white : Colors.black),
              label: 'Home'.tr(),
              labelStyle:
                  isDarkMode ? AppFonts.textW16bold : AppFonts.textB16bold,
            ),
            CurvedNavigationBarItem(
              child: FaIcon(FontAwesomeIcons.magnifyingGlass,
                  color: isDarkMode ? Colors.white : Colors.black),
              label: 'Search'.tr(),
              labelStyle:
                  isDarkMode ? AppFonts.textW16bold : AppFonts.textB16bold,
            ),
            CurvedNavigationBarItem(
              child: FaIcon(FontAwesomeIcons.squarePlus,
                  color: isDarkMode ? Colors.white : Colors.black),
              label: 'Create'.tr(),
              labelStyle:
                  isDarkMode ? AppFonts.textW16bold : AppFonts.textB16bold,
            ),
            CurvedNavigationBarItem(
              child: FaIcon(FontAwesomeIcons.clapperboard,
                  color: isDarkMode ? Colors.white : Colors.black),
              label: 'Reels'.tr(),
              labelStyle:
                  isDarkMode ? AppFonts.textW16bold : AppFonts.textB16bold,
            ),
            CurvedNavigationBarItem(
              child: FaIcon(FontAwesomeIcons.user,
                  color: isDarkMode ? Colors.white : Colors.black),
              label: 'Profile'.tr(),
              labelStyle:
                  isDarkMode ? AppFonts.textW16bold : AppFonts.textB16bold,
            ),
          ],
          onTap: onTap,
        );
      },
    );
  }
}
