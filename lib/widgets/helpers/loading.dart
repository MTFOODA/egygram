import 'package:flutter/material.dart';
import 'package:flutter_application_3/widgets/helpers/root.dart';
import 'package:lottie/lottie.dart';
import '../../utilities/colors_dart.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigateToRootPage();
  }

  void navigateToRootPage() async {
    await Future.delayed(const Duration(seconds: 3)); // Duration of splash
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RootPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: Center(
        child: Lottie.asset(
          'assets/lottie/main.json',
          width: 400,
          height: 400,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
