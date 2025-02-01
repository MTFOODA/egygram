import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/login_screen.dart';
import 'package:flutter_application_3/screens/navigation_screen.dart';
import 'package:flutter_application_3/utilities/sp.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = CacheHelper.getData('email');
    final user = CacheHelper.getData('user');
    final password = CacheHelper.getData('password');

    return (email != null && password != null)
        ? NavigationScreen(initialIndex: 0,userName: user,)
        : const LoginScreen();
  }
}
