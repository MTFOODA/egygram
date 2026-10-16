import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/login_screen.dart';
import 'package:flutter_application_3/screens/navigation_screen.dart';
import 'package:flutter_application_3/utilities/sp.dart';
import '../../core/di/service_locator.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = CacheHelper.getData('user');

    // Supabase persists the auth session automatically. If a session exists we
    // go straight to the app; otherwise we show the login screen.
    final bool hasSession = sl.authRepository.isAuthenticated;

    return hasSession
        ? NavigationScreen(
            initialIndex: 0,
            userName: user,
          )
        : const LoginScreen();
  }
}
