import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../logics/user/edit_user_logic/cubit.dart';
import '../../logics/user/get_user_logic/cubit.dart';
import '../../logics/user/get_user_logic/state.dart';
import '../../models/user_model.dart';
import '../../screens/edit_profile_page.dart';
import '../../utilities/fonts_dart.dart';
import '../../utilities/theme_provider.dart';

class EditProfileWidget extends StatefulWidget {
  final String currentUser;

  const EditProfileWidget({super.key, required this.currentUser});

  @override
  State<EditProfileWidget> createState() => EditProfileWidgetState();
}

class EditProfileWidgetState extends State<EditProfileWidget> {
  @override
  void initState() {
    super.initState();
    //context.read<GetUserCubit>().getUsers();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return SizedBox(
      child:Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      final state = context.read<GetUserCubit>().state;
                      if (state is GetUserSuccessState) {
                        final user = state.users.firstWhere(
                              (user) => user.userName == widget.currentUser,
                          orElse: () => UsersModel.defaultUser(),
                        );

                        if (user.userName != UsersModel.defaultUser().userName) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => EditUserCubit(),
                                child: EditProfilePage(userModel: user),
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('User not found'.tr()),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('User data not loaded yet'.tr()),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Edit Profile'.tr(), style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.black),
                  onPressed: () {
                    //TODO Additional action if needed
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
