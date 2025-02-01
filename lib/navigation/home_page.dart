import 'dart:async'; // Import for Timer
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/screens/massage_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_3/logics/post/get_post_logic/cubit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../logics/love/create_love_logic/cubit.dart';
import '../logics/love/get_love_logic/cubit.dart';
import '../logics/post/get_post_logic/state.dart';
import '../logics/save/create_save_logic/cubit.dart';
import '../logics/save/get_save_logic/cubit.dart';
import '../logics/story/get_story_logic/cubit.dart';
import '../logics/story/get_story_logic/state.dart';
import '../logics/user/get_user_logic/cubit.dart';
import '../models/Story_model.dart';
import '../screens/notification_page.dart';
import '../utilities/fonts_dart.dart';
import '../utilities/theme_provider.dart';
import '../widgets/helpers/delete_story.dart';
import '../widgets/post/post_widget.dart';
import '../widgets/story/story_widget.dart';

class HomePage extends StatefulWidget {
  final String currentUser;

  const HomePage({super.key, required this.currentUser});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Timer? storyDeletionTimer;

  @override
  void initState() {
    super.initState();
    startStoryDeletionTimer(context);
  }

  @override
  void dispose() {
    storyDeletionTimer?.cancel();
    super.dispose();
  }

  void startStoryDeletionTimer(BuildContext context) {
    storyDeletionTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      await deleteOldStories(context);
    });
  }

  Future<void> refreshContent(BuildContext context) async {
    context.read<GetPostCubit>().subscribeToPosts();
    context.read<GetStoryCubit>().subscribeToStories();
    context.read<GetUserCubit>().getUsers();
    context.read<GetLoveCubit>();
    context.read<CreateLoveCubit>();
    context.read<GetSaveCubit>();
    context.read<CreateSaveCubit>();
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GetPostCubit()..subscribeToPosts()),
        BlocProvider(create: (context) => GetUserCubit()..getUsers()),
        BlocProvider(create: (context) => GetStoryCubit()..subscribeToStories()),
        BlocProvider(create: (context) => GetLoveCubit()),
        BlocProvider(create: (context) => CreateLoveCubit()),
        BlocProvider(create: (context) => GetSaveCubit()),
        BlocProvider(create: (context) => CreateSaveCubit()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text('Egygram'.tr(), style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
          actions: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.heart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.facebookMessenger),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                        create: (context) => GetUserCubit()..getUsers(),
                        child: MessageScreen(myUser: widget.currentUser)),
                  ),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => refreshContent(context),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: BlocBuilder<GetStoryCubit, GetStoriesState>(
                  builder: (context, state) {
                    if (state is GetStoryLoadingState) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is GetStorySuccessState) {
                      // Filter stories to ensure each user has only one story
                      final uniqueStories = state.stories
                          .fold<Map<String, StoriesModel>>({}, (map, story) {
                        if (!map.containsKey(story.userName)) {
                          map[story.userName] = story;
                        }
                        return map;
                      }).values.toList();

                      final StoriesModel? currentUserStory = uniqueStories
                          .firstWhereOrNull((story) => story.userName == widget.currentUser);

                      final otherStories = uniqueStories
                          .where((story) => story.userName != widget.currentUser)
                          .toList();

                      return StoryWidget(
                        currentUser: widget.currentUser,
                        currentUserStory: currentUserStory,
                        otherStories: otherStories,
                      );
                    } else if (state is GetStoryErrorState) {
                      return Center(
                        child: Text(
                          'Error: ${state.errorMessage}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
              Expanded(
                child: BlocBuilder<GetPostCubit, GetPostsState>(
                  builder: (context, state) {
                    if (state is GetPostLoadingState) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is GetPostSuccessState) {
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 10),
                        itemCount: state.posts.length,
                        itemBuilder: (context, index) {
                          return PostWidget(
                            posts: state.posts[index],
                            currentUser: widget.currentUser,
                          );
                        },
                      );
                    } else if (state is GetPostErrorState) {
                      return Center(
                        child: Text(
                          'Error: ${state.errorMessage}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else {
                      return Center(
                        child: Text('No posts found'.tr(), style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}