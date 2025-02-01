import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../logics/auth/signup_logic/cubit.dart';
import '../logics/auth/signup_logic/state.dart';
import '../logics/user/create_user_logic/cubit.dart';
import '../models/user_model.dart';
import '../utilities/fonts_dart.dart';
import '../utilities/theme_provider.dart';
import '../utilities/sp.dart';
import '../utilities/decoration.dart';
import '../widgets/helpers/password_widget.dart';
import 'navigation_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool obscurePassword = true;
  IconData iconPassword = Icons.visibility_off;
  bool containsUpperCase = false;
  bool containsLowerCase = false;
  bool containsNumber = false;
  bool containsSpecialChar = false;
  bool contains8Length = false;

  final RegExp specialCharRexExp = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  void togglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword;
      iconPassword =
      obscurePassword ? Icons.visibility_off : Icons.visibility;
    });
  }

  void checkPasswordStrength(String value) {
    setState(() {
      containsUpperCase = value.contains(RegExp(r'[A-Z]'));
      containsLowerCase = value.contains(RegExp(r'[a-z]'));
      containsNumber = value.contains(RegExp(r'[0-9]'));
      containsSpecialChar = value.contains(specialCharRexExp);
      contains8Length = value.length >= 8;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SignUpCubit(FirebaseAuth.instance)),
        BlocProvider(create: (context) => CreateUserCubit()),
      ],
      child: Scaffold(
        body: BlocConsumer<SignUpCubit, SignUpState>(
          listener: (context, state) {
            if (state is SignupSuccessState) {
              final userName = userController.text.trim();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Sign Up Successful!".tr())),
              );
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => NavigationScreen(initialIndex: 0, userName: userName),
                ),
                    (Route<dynamic> route) => false,
              );
            } else if (state is SignupErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${state.error}")),
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
                        const SizedBox(height: 100),
                        Text(
                          'Create New Account'.tr(),
                          style: isDarkMode
                              ? AppFonts.textW24bold
                              : AppFonts.textB24bold,
                        ),
                        const SizedBox(height: 50),
                        TextFormField(
                          style: isDarkMode
                              ? AppFonts.textW16bold
                              : AppFonts.textB16bold,
                          controller: userController,
                          decoration: emailInputDecoration(
                            context,
                            'User Name'.tr(),
                            const Icon(CupertinoIcons.person),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your User Name'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          style: isDarkMode
                              ? AppFonts.textW16bold
                              : AppFonts.textB16bold,
                          controller: emailController,
                          decoration: emailInputDecoration(
                            context,
                            'Email'.tr(),
                            const Icon(CupertinoIcons.mail_solid),
                          ),
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
                              ? AppFonts.textW16bold
                              : AppFonts.textB16bold,
                          controller: passwordController,
                          obscureText: obscurePassword,
                          onChanged: checkPasswordStrength,
                          decoration: passwordInputDecoration(
                            context: context,
                            labelText: 'Password'.tr(),
                            obscurePassword: obscurePassword,
                            onTogglePassword: togglePasswordVisibility,
                            iconPassword: iconPassword,
                            prefixIcon: const Icon(CupertinoIcons.lock_fill),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password'.tr();
                            }
                            if (!containsUpperCase) {
                              return 'Password must contain at least 1 uppercase letter'.tr();
                            }
                            if (!containsLowerCase) {
                              return 'Password must contain at least 1 lowercase letter'.tr();
                            }
                            if (!containsNumber) {
                              return 'Password must contain at least 1 number'.tr();
                            }
                            if (!containsSpecialChar) {
                              return 'Password must contain at least 1 special character'.tr();
                            }
                            if (!contains8Length) {
                              return 'Password must be at least 8 characters long'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        PasswordStrengthRow(
                          containsUpperCase: containsUpperCase,
                          containsLowerCase: containsLowerCase,
                          containsNumber: containsNumber,
                          containsSpecialChar: containsSpecialChar,
                          contains8Length: contains8Length,
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () async {
                            if (formKey.currentState?.validate() ?? false) {
                              final email = emailController.text.trim();
                              final password = passwordController.text.trim();
                              final userName = userController.text.trim();

                              await context
                                  .read<SignUpCubit>()
                                  .signUp(email, password);

                              final currentState =
                                  context.read<SignUpCubit>().state;
                              if (currentState is SignupSuccessState) {
                                final userModel = UsersModel(
                                  userName: userName,
                                  email: email,
                                );
                                context.read<CreateUserCubit>()
                                    .createUser(userModel);
                                await CacheHelper.saveData('email', email);
                                await CacheHelper.saveData('user', userName);
                                await CacheHelper.saveData('password', password);
                              }
                            }
                          },
                          child: Container(
                            width: 150,
                            height: 50,
                            decoration: customContainerDecoration(),
                            child: Center(
                              child: Text(
                                "Sign Up".tr(),
                                style: AppFonts.textW24bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                          child: Text(
                            'Already have an account? Login!'.tr(),
                            style: isDarkMode ? AppFonts.textW16bold : AppFonts.textB16bold,  // Apply theme-based style
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
