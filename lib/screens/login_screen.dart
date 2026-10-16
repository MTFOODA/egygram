import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/navigation_screen.dart';
import 'package:flutter_application_3/screens/signup_screen.dart';
import 'package:flutter_application_3/utilities/sp.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_3/logics/auth/login_logic/cubit.dart';
import 'package:flutter_application_3/logics/auth/login_logic/state.dart';
import 'package:flutter_application_3/utilities/fonts_dart.dart';
import 'package:flutter_application_3/utilities/decoration.dart';
import 'package:provider/provider.dart';
import '../core/di/service_locator.dart';
import '../utilities/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool obscurePassword = true;
  IconData iconPassword = Icons.visibility_off;

  void togglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword;
      iconPassword = obscurePassword ? Icons.visibility_off : Icons.visibility;
    });
  }

  /// Resolves the signed-in user's profile and caches their user name so the
  /// rest of the UI (which keys off user name) works immediately.
  Future<void> _cacheSignedInUserName() async {
    try {
      final userId = sl.authRepository.currentUserId;
      if (userId == null) return;
      final users = await sl.userRepository.watchUsers().first;
      final match = users.where((u) => u.id == userId).toList();
      if (match.isNotEmpty) {
        await CacheHelper.saveData('user', match.first.userName);
      }
    } catch (_) {
      // Non-fatal: navigation still works, profile lookups fall back to cache.
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final user = CacheHelper.getData('user');
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: Scaffold(
        body: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) async {
            if (state is LoginSuccessState) {
              // Resolve + cache the user name BEFORE navigating so the
              // navigation screen never receives a stale or null value.
              await _cacheSignedInUserName();
              final userName =
                  (CacheHelper.getData('user') ?? user) as String? ?? '';
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Login is successful".tr())));
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NavigationScreen(initialIndex: 0, userName: userName),
                ),
                (Route<dynamic> route) => false,
              );
            } else if (state is LoginErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 150),
                        Text("Welcome Back!".tr(),
                            style: isDarkMode
                                ? AppFonts.textW24bold
                                : AppFonts
                                    .textB24bold), // Conditional text style
                        const SizedBox(height: 50),
                        TextFormField(
                          style: isDarkMode
                              ? AppFonts.textW24bold
                              : AppFonts.textB24bold, // Conditional text style
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: emailInputDecoration(
                              context,
                              'Email'.tr(),
                              const Icon(CupertinoIcons.mail_solid)),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your email'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          style: isDarkMode
                              ? AppFonts.textW24bold
                              : AppFonts.textB24bold, // Conditional text style
                          controller: passwordController,
                          obscureText: obscurePassword,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: passwordInputDecoration(
                            obscurePassword: obscurePassword,
                            onTogglePassword: togglePasswordVisibility,
                            iconPassword: iconPassword,
                            labelText: 'Password'.tr(),
                            context: context,
                            prefixIcon: const Icon(CupertinoIcons.lock_fill),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your password'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () async {
                            final email = emailController.text.trim();
                            final password = passwordController.text;

                            if (formKey.currentState?.validate() ?? false) {
                              // Supabase persists the session automatically, so
                              // there is no need to cache the password. Only the
                              // non-secret user name is cached for the UI (the
                              // BlocConsumer listener resolves it on success).
                              await CacheHelper.saveData('email', email);
                              await context
                                  .read<LoginCubit>()
                                  .login(email, password);
                            }
                          },
                          child: Container(
                            width: 150,
                            height: 50,
                            decoration: customContainerDecoration(),
                            child: Center(
                              child: Text("Login".tr(),
                                  style: AppFonts
                                      .textW24bold), // Conditional text style
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignupScreen()),
                            );
                          },
                          child: Text(
                            'Don\'t have an account? Sign Up'.tr(),
                            style: isDarkMode
                                ? AppFonts.textW16bold
                                : AppFonts
                                    .textB16bold, // Conditional text style
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
