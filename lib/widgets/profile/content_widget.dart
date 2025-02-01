import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../logics/user/get_user_logic/cubit.dart';
import '../../logics/user/get_user_logic/state.dart';
import '../../models/user_model.dart';
import '../../utilities/fonts_dart.dart';
import '../../utilities/theme_provider.dart';
import '../helpers/expandable_text.dart';

class ContentWidget extends StatefulWidget {
  final String currentUser;

  const ContentWidget({super.key, required this.currentUser});

  @override
  State<ContentWidget> createState() => ContentWidgetState();
}

class ContentWidgetState extends State<ContentWidget> {
  late UsersModel usersModel = UsersModel.defaultUser();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return BlocBuilder<GetUserCubit, GetUsersState>(
      builder: (context, state) {
        if (state is GetUserSuccessState) {
          final user = state.users.firstWhere(
                (user) => user.userName == widget.currentUser,
            orElse: () => UsersModel.defaultUser(),
          );
          usersModel = user;
        }
        return Flexible(
          flex: 3,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: usersModel.profileImage != null
                                    ? NetworkImage(usersModel.profileImage!)
                                    : const AssetImage("assets/images/profile_picture.jpg")
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  child: const CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.blue,
                                    child: FaIcon(
                                      FontAwesomeIcons.check,
                                      color: Colors.white,
                                      size: 12.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            usersModel.userName, style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold
                          ),
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "${usersModel.numberOfPosts}", style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold
                                  ),
                                  Text('Posts'.tr(), style: isDarkMode ? AppFonts.textW20bold : AppFonts.textB20bold),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Column(
                                children: [
                                  Text(
                                    "${usersModel.numberOfFollowers}", style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold
                                  ),
                                  Text('Followers'.tr(), style: isDarkMode ? AppFonts.textW20bold : AppFonts.textB20bold),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Column(
                                children: [
                                  Text(
                                    "${usersModel.numberOfFollowing}", style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold
                                  ),
                                  Text('Following'.tr(), style: isDarkMode ? AppFonts.textW20bold : AppFonts.textB20bold),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (usersModel.webpage != null && usersModel.webpage!.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ExpandableTextRow(ex: usersModel.webpage!),
                      ],
                    ),
                  const SizedBox(height: 10),
                  if (usersModel.bio != null && usersModel.bio!.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ExpandableTextRow(ex: usersModel.bio!),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
