import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/bootstrap/supabase_bootstrap.dart';
import 'utilities/sp.dart';
import 'utilities/theme_provider.dart';
import 'widgets/helpers/loading.dart';
import 'widgets/helpers/startup_error_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await CacheHelper.init();

  // Supabase is the application backend. Configuration is supplied via
  // --dart-define (see .env.example). The bootstrap validates the config and
  // initializes the SDK + service locator. If it is missing or invalid we show
  // a clear, actionable error screen instead of crashing on a blank screen or
  // failing later with a misleading auth error.
  final bootstrap = await SupabaseBootstrap.run();

  runApp(EasyLocalization(
    supportedLocales: const [
      Locale('en'),
      Locale('ar'),
      Locale('fr'),
      Locale('de')
    ],
    path: "assets/lang",
    fallbackLocale: const Locale('en'),
    child: bootstrap.ok
        ? const MyApp()
        : StartupErrorScreen(message: bootstrap.message ?? 'Unknown error.'),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme:
                themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
