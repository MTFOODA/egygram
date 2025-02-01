import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_application_3/screens/settings.dart';
import 'package:provider/provider.dart';
import '../logics/auth/logout_logic/cubit.dart';
import '../logics/user/get_user_logic/cubit.dart';
import '../logics/user/get_user_logic/state.dart';
import '../models/user_model.dart';
import '../utilities/fonts_dart.dart';
import '../utilities/theme_provider.dart';
import '../widgets/profile/edit_container.dart';
import '../widgets/profile/followers_widget.dart';
import '../widgets/profile/content_widget.dart';
import '../widgets/profile/tapBar_widget.dart';

class ProfilePage extends StatefulWidget {
  final String currentUser;
  const ProfilePage({super.key, required this.currentUser});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> refreshContent(BuildContext context) async {
    context.read<GetUserCubit>().getUsers();
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GetUserCubit()..getUsers()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<GetUserCubit, GetUsersState>(
            buildWhen: (previous, current) {
              return current is GetUserSuccessState ||
                  (previous is GetUserSuccessState &&
                      current is GetUserSuccessState &&
                      previous.users
                          .firstWhere(
                            (user) => user.userName == widget.currentUser,
                        orElse: () => UsersModel.defaultUser(),
                      ) !=
                          current.users
                              .firstWhere(
                                (user) => user.userName == widget.currentUser,
                            orElse: () => UsersModel.defaultUser(),
                          ));
            },
            builder: (context, state) {
              if (state is GetUserLoadingState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is GetUserSuccessState) {
                final user = state.users.firstWhere(
                      (user) => user.userName == widget.currentUser,
                  orElse: () => UsersModel.defaultUser(),
                );
                return Text(user.userName, style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold);
              } else if (state is GetUserErrorState) {
                return const Text("Error");
              }
              return Text("Profile".tr(),style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold);
            },
          ),
          actions: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.squarePlus),
              onPressed: () {},
              iconSize: 30,
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.bars),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MultiBlocProvider(
                        providers: [
                          BlocProvider(create: (context) => LogoutCubit()),
                          BlocProvider(create: (context) => GetUserCubit()..getUsers()),
                        ],
                        child: SettingsScreen(currentUser: widget.currentUser)),
                  ),
                );
              },
            )
          ],
        ),
        body: Column(
          children: [
            ContentWidget(currentUser: widget.currentUser),
            const FollowersWidget(
              followers: [
                'assets/images/profile_picture.jpg',
                'assets/images/profile_picture.jpg',
                'assets/images/profile_picture.jpg',
                'assets/images/profile_picture.jpg',
              ],
              otherFollowersCount: 10,
            ),
            EditProfileWidget(currentUser: widget.currentUser),
            ProfileTapBarWidget(tabController: tabController)
          ],
        ),
      ),
    );
  }
}
