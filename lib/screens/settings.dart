import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/saved_posts_screen.dart';
import 'package:flutter_application_3/widgets/helpers/appBar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../logics/user/get_user_logic/cubit.dart';
import '../utilities/fonts_dart.dart';
import '../utilities/theme_provider.dart';
import 'loved_posts_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String currentUser;

  const SettingsScreen({super.key, required this.currentUser});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late String selectedLanguage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedLanguage = context.locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    final languages = {
      'en': 'English'.tr(),
      'ar': 'Arabic'.tr(),
      'fr': 'French'.tr(),
      'de': 'German'.tr(),
    };

    return Scaffold(
      appBar: CustomAppBar(title: 'Settings'.tr()),
      body: ListView(
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Manage Egygram'.tr(),style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.bookmark),
            title: Text('Saved'.tr(),style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                  MaterialPageRoute(builder: (context) => BlocProvider(
                      create: (context) => GetUserCubit()..getUsers(),
                      child: SavedPostsScreen(currentUser: widget.currentUser)
                  )
                ),
              );
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.heart),
            title: Text('Loves'.tr(),style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                  MaterialPageRoute(builder: (context) => BlocProvider(
                      create: (context) => GetUserCubit()..getUsers(),
                      child: LovedPostsScreen(currentUser: widget.currentUser)
                  )
                ),
              );
            },
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: selectedLanguage,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      selectedLanguage = value;
                      context.setLocale(Locale(value));
                    });
                  }
                },
                items: languages.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
