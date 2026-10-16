import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_application_3/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../../core/di/service_locator.dart';
import '../../utilities/fonts_dart.dart';
import '../../utilities/sp.dart';
import '../../utilities/theme_provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({super.key, required this.title});

  @override
  State<CustomAppBar> createState() => CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomAppBarState extends State<CustomAppBar>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _isDarkMode = themeProvider.isDarkMode;
    if (_isDarkMode) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> logout(BuildContext context) async {
    try {
      await CacheHelper.removeData('email'); // Clear cached email
      await CacheHelper.removeData('user');
      // Password is never cached (security). Sign-out is handled by Supabase.
      await sl.authRepository.signOut();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during logout: $e')),
      );
    }
  }

  void _toggleTheme() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });

    if (_isDarkMode) {
      _animationController.forward();
    } else {
      _animationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(widget.title.tr(),
          style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
      actions: [
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _toggleTheme,
          child: SizedBox(
            height: 50,
            width: 50,
            child: Center(
              child: Lottie.asset(
                'assets/lottie/dm.json',
                controller: _animationController,
                onLoaded: (composition) {
                  _animationController.duration = composition.duration;
                  if (_animationController.isCompleted) {
                    _animationController.reset();
                  }
                },
                repeat: false,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.logout, size: 40),
          onPressed: () async {
            await logout(context);
          },
        )
      ],
    );
  }
}
