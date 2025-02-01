import 'package:flutter/material.dart';
import 'package:flutter_application_3/logics/follow/get_follow_logic/cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logics/follow/create_follow_logic/cubit.dart';
import '../logics/user/get_user_logic/cubit.dart';
import '../models/user_model.dart';
import '../widgets/profile/follow_container.dart';
import '../widgets/profile/followers_widget.dart';
import '../widgets/profile/content_widget.dart';
import '../widgets/profile/tapBar_widget.dart';

class OthersProfilePage extends StatefulWidget {
  final String currentUser;
  final String passedUser;
  const OthersProfilePage({super.key, required this.currentUser, required this.passedUser});

  @override
  OthersProfilePageState createState() => OthersProfilePageState();
}

class OthersProfilePageState extends State<OthersProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  UsersModel? passedUserModel;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    fetchPassedUser();
  }

  void fetchPassedUser() {
    setState(() {
      passedUserModel = UsersModel(
        userName: widget.passedUser,
      );
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  BlocProvider(
      create: (context) => GetUserCubit()..getUsers(),
      child: Scaffold(
        appBar: AppBar(title: Text(widget.passedUser)),
        body: Column(
          children: [
            ContentWidget(currentUser: widget.passedUser),
            const FollowersWidget(
              followers: [
                'assets/images/profile_picture.jpg',
                'assets/images/profile_picture.jpg',
                'assets/images/profile_picture.jpg',
                'assets/images/profile_picture.jpg',
              ],
              otherFollowersCount: 10,
            ),
            Expanded(
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(create: (context) => GetFollowCubit()),
                  BlocProvider(create: (context) => CreateFollowCubit()),
                ],
                child: FollowContainer(
                  currentUser: widget.currentUser,
                  passedUser: passedUserModel!,
                ),
              ),
            ),
            ProfileTapBarWidget(tabController: tabController),
          ],
        ),
      ),
    );
  }
}
