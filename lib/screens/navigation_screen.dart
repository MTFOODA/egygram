import 'package:flutter/material.dart';
import 'package:flutter_application_3/navigation/home_page.dart';
import 'package:flutter_application_3/navigation/create_page.dart';
import 'package:flutter_application_3/navigation/profile_page.dart';
import 'package:flutter_application_3/navigation/reel_page.dart';
import 'package:flutter_application_3/navigation/search_page.dart';
import 'package:flutter_application_3/widgets/helpers/navigation_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logics/love/create_love_logic/cubit.dart';
import '../logics/love/get_love_logic/cubit.dart';
import '../logics/post/get_post_logic/cubit.dart';
import '../logics/reel/get_reel_logic/cubit.dart';
import '../logics/save/create_save_logic/cubit.dart';
import '../logics/save/get_save_logic/cubit.dart';
import '../logics/story/get_story_logic/cubit.dart';
import '../logics/user/get_user_logic/cubit.dart';

class NavigationScreen extends StatefulWidget {
  final int initialIndex;
  final String userName;

  const NavigationScreen(
      {super.key, required this.initialIndex, required this.userName});

  @override
  NavigationScreenState createState() => NavigationScreenState();
}

class NavigationScreenState extends State<NavigationScreen> {
  late int currentIndex;
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;

    pages = [
      MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => GetPostCubit()..subscribeToPosts()),
            BlocProvider(create: (context) => GetUserCubit()..getUsers()),
            BlocProvider(create: (context) => GetStoryCubit()..subscribeToStories()),
            BlocProvider(create: (context) => GetLoveCubit()),
            BlocProvider(create: (context) => CreateLoveCubit()),
            BlocProvider(create: (context) => GetSaveCubit()),
            BlocProvider(create: (context) => CreateSaveCubit()),
          ],
          child: HomePage(currentUser: widget.userName)),
      BlocProvider(
          create: (context) => GetUserCubit()..getUsers(),
          child: SearchPage(currentUser: widget.userName)),
      CreatePage(currentUser: widget.userName),
      ReelPage(currentUser: widget.userName),
      BlocProvider(
        create: (context) => GetUserCubit(),
        child: ProfilePage(currentUser: widget.userName),
      )
    ];
  }

  void onNavigationItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: CustomNavigationBar(
        onTap: onNavigationItemTapped,
        currentIndex: currentIndex,
      ),
    );
  }
}
