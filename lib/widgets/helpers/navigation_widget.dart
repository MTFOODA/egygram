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

  const CustomNavigationBar(
      {super.key, required this.onTap, required int currentIndex});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return CurvedNavigationBar(
      backgroundColor: AppColors.trans,
      items: [
        CurvedNavigationBarItem(
            child: const FaIcon(FontAwesomeIcons.house),
            label: 'Home'.tr(),
            labelStyle:
                isDarkMode ? AppFonts.textW16bold : AppFonts.textB16bold),
        CurvedNavigationBarItem(
            child: const FaIcon(FontAwesomeIcons.magnifyingGlass),
            label: 'Search'.tr(),
            labelStyle:
                isDarkMode ? AppFonts.textW16bold : AppFonts.textB16bold),
        CurvedNavigationBarItem(
            child: const FaIcon(FontAwesomeIcons.squarePlus),
            label: 'Create'.tr(),
            labelStyle:
                isDarkMode ? AppFonts.textW16bold : AppFonts.textB16bold),
        CurvedNavigationBarItem(
            child: const FaIcon(FontAwesomeIcons.clapperboard),
            label: 'Reels'.tr(),
            labelStyle:
                isDarkMode ? AppFonts.textW16bold : AppFonts.textB16bold),
        CurvedNavigationBarItem(
            child: const FaIcon(FontAwesomeIcons.user),
            label: 'Profile'.tr(),
            labelStyle:
                isDarkMode ? AppFonts.textW16bold : AppFonts.textB16bold),
      ],
      onTap: onTap,
    );
  }
}
