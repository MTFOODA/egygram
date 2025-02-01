import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../logics/comments/create_comments_logic/cubit.dart';
import '../../logics/comments/get_comments_logic/cubit.dart';
import '../../logics/love/create_love_logic/cubit.dart';
import '../../logics/love/get_love_logic/cubit.dart';
import '../../logics/story/get_story_logic/cubit.dart';
import '../../logics/user/get_user_logic/cubit.dart';
import '../../logics/user/get_user_logic/state.dart';
import '../../models/Story_model.dart';
import '../../models/user_model.dart';
import '../../utilities/fonts_dart.dart';
import '../../utilities/theme_provider.dart';
import 'story_opened_widget.dart';
import 'create_story_widget.dart';

class StoryWidget extends StatefulWidget {
  final String currentUser;
  final StoriesModel? currentUserStory;
  final List<StoriesModel> otherStories;

  const StoryWidget({
    super.key,
    required this.currentUser,
    this.currentUserStory,
    required this.otherStories,
  });

  @override
  StoryWidgetState createState() => StoryWidgetState();
}

class StoryWidgetState extends State<StoryWidget> {
  String? profileImage;

  @override
  void initState() {
    super.initState();
    setProfileImage();
  }

  void setProfileImage() {
    final userState = context.read<GetUserCubit>().state;
    if (userState is GetUserSuccessState) {
      final user = userState.users.firstWhere(
            (user) => user.userName == widget.currentUser,
        orElse: () => UsersModel.defaultUser(),
      );
      setState(() {
        profileImage = user.profileImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return BlocListener<GetUserCubit, GetUsersState>(
      listener: (context, state) {
        if (state is GetUserSuccessState) {
          setProfileImage();
        }
      },
      child: SizedBox(
        height: 90,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateStoryWidget(userName: widget.currentUser),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 32.0,
                            backgroundColor: Colors.blue,
                            child: CircleAvatar(
                              radius: 29.0,
                              backgroundImage: (profileImage != null &&
                                  profileImage!.isNotEmpty)
                                  ? NetworkImage(profileImage!)
                                  : const AssetImage(
                                "assets/images/profile_picture.jpg",
                              ) as ImageProvider,
                            ),
                          ),
                          const Positioned(
                            bottom: 3,
                            right: 3,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.blue,
                                child: FaIcon(
                                  FontAwesomeIcons.plus,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(widget.currentUser, style: isDarkMode ? AppFonts.textW14bold : AppFonts.textB14bold),
                    ],
                  ),
                ),
              ),
              if (widget.currentUserStory != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                  create: (context) =>
                                  GetStoryCubit()..subscribeToStories()),
                              BlocProvider(create: (context) => GetLoveCubit()),
                              BlocProvider(
                                  create: (context) => CreateLoveCubit()),
                              BlocProvider(
                                  create: (context) => GetCommentCubit()),
                              BlocProvider(
                                  create: (context) => CreateCommentCubit()),
                            ],
                            child: StoryOpenedWidget(
                              currentUser: widget.currentUser,
                              userName: widget.currentUser,
                              allStories: [widget.currentUserStory!, ...widget.otherStories],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 32.0,
                          backgroundColor: Colors.redAccent,
                          child: CircleAvatar(
                            radius: 29.0,
                            backgroundImage: (widget.currentUserStory!.profileImage != null &&
                                widget.currentUserStory!.profileImage!.isNotEmpty)
                                ? NetworkImage(widget.currentUserStory!.profileImage!)
                                : const AssetImage(
                              "assets/images/profile_picture.jpg",
                            ) as ImageProvider,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.currentUser,
                          style: isDarkMode ? AppFonts.textW14bold : AppFonts.textB14bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ...widget.otherStories.map((story) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                  create: (context) =>
                                  GetStoryCubit()..subscribeToStories()),
                              BlocProvider(create: (context) => GetLoveCubit()),
                              BlocProvider(
                                  create: (context) => CreateLoveCubit()),
                              BlocProvider(
                                  create: (context) => GetCommentCubit()),
                              BlocProvider(
                                  create: (context) => CreateCommentCubit()),
                            ],
                            child: StoryOpenedWidget(
                              currentUser: widget.currentUser,
                              userName: story.userName,
                              allStories: [widget.currentUserStory!,...widget.otherStories],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 32.0,
                          backgroundColor: Colors.redAccent,
                          child: CircleAvatar(
                            radius: 29.0,
                            backgroundImage: (story.profileImage != null &&
                                story.profileImage!.isNotEmpty)
                                ? NetworkImage(story.profileImage!)
                                : const AssetImage(
                              "assets/images/profile_picture.jpg",
                            ) as ImageProvider,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          story.userName,
                          style: isDarkMode ? AppFonts.textW14bold : AppFonts.textB14bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}