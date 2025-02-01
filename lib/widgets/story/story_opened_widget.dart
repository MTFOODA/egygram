import 'package:flutter/material.dart';
import 'package:flutter_application_3/widgets/story/top_row.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_story_presenter/flutter_story_presenter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../logics/comments/create_comments_logic/cubit.dart';
import '../../logics/comments/create_comments_logic/state.dart';
import '../../logics/comments/get_comments_logic/cubit.dart';
import '../../logics/comments/get_comments_logic/state.dart';
import '../../logics/love/create_love_logic/cubit.dart';
import '../../logics/love/get_love_logic/cubit.dart';
import '../../logics/user/get_user_logic/cubit.dart';
import '../../models/Story_model.dart';
import 'package:flutter_story_presenter/flutter_story_presenter.dart' as story_presenter;
import '../../models/comment_model.dart';
import '../../utilities/notification_service.dart';
import '../../utilities/theme_provider.dart';
import '../helpers/comments_widget.dart';
import '../helpers/post_handel_button.dart';
import 'bottom_row.dart';

class StoryOpenedWidget extends StatefulWidget {
  final String currentUser;
  final String userName;
  final List<StoriesModel> allStories;

  const StoryOpenedWidget({
    super.key,
    required this.currentUser,
    required this.userName,
    required this.allStories,
  });

  @override
  State<StoryOpenedWidget> createState() => StoryOpenedWidgetState();
}

class StoryOpenedWidgetState extends State<StoryOpenedWidget> {
  late PageController pageController;
  final CollectionReference storiesCollection =
  FirebaseFirestore.instance.collection('Stories');
  int currentUserIndex = 0;
  int currentStoryIndex = 0; // Track the current story index

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    currentUserIndex = widget.allStories.indexWhere((story) => story.userName == widget.userName);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void goToNextUser() {
    if (currentUserIndex < widget.allStories.length - 1) {
      setState(() {
        currentUserIndex++;
        currentStoryIndex = 0;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void goToPreviousUser() {
    if (currentUserIndex > 0) {
      setState(() {
        currentUserIndex--;
        currentStoryIndex = 0;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream: storiesCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No stories available.'));
          }

          final stories = snapshot.data!.docs.map((doc) {
            return StoriesModel.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          // Filter stories for the specific user
          final userStories = stories
              .where((story) => story.userName == widget.allStories[currentUserIndex].userName)
              .toList();

          if (userStories.isEmpty) {
            return const Center(child: Text('No stories available.'));
          }

          return StoryViewWithFirebase(
            key: ValueKey(currentUserIndex), // Ensure the widget rebuilds when the user changes
            stories: userStories,
            currentUser: widget.currentUser,
            allStories: widget.allStories,
            currentUserIndex: currentUserIndex,
            currentStoryIndex: currentStoryIndex,
            onNextUser: goToNextUser,
            onPreviousUser: goToPreviousUser,
          );
        },
      ),
    );
  }
}

class StoryViewWithFirebase extends StatefulWidget {
  final List<StoriesModel> stories;
  final String currentUser;
  final List<StoriesModel> allStories;
  final int currentUserIndex;
  final int currentStoryIndex;
  final VoidCallback onNextUser;
  final VoidCallback onPreviousUser;

  const StoryViewWithFirebase({
    super.key,
    required this.stories,
    required this.currentUser,
    required this.allStories,
    required this.currentUserIndex,
    required this.currentStoryIndex,
    required this.onNextUser,
    required this.onPreviousUser,
  });

  @override
  State<StoryViewWithFirebase> createState() => StoryViewWithFirebaseState();
}

class StoryViewWithFirebaseState extends State<StoryViewWithFirebase> {
  late FlutterStoryController controller;
  bool isLoved = false;
  final CollectionReference storiesCollection =
  FirebaseFirestore.instance.collection('Stories');
  final TextEditingController commentController = TextEditingController();
  final CreateCommentCubit createCommentCubit = CreateCommentCubit();
  final GetCommentCubit getCommentCubit = GetCommentCubit();
  List<CommentsModel> commentsList = [];
  final NotificationService notificationService = NotificationService();
  int currentStoryIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = FlutterStoryController();
    currentStoryIndex = widget.currentStoryIndex; // Initialize with the passed index
    loadComments();
    loadCreateLove();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> deletePost(String storyID) async {
    try {
      await FirebaseFirestore.instance
          .collection('Stories')
          .doc(storyID)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Story deleted successfully")),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete story: $e")),
      );
    }
  }

  void loadCreateLove() {
    FirebaseFirestore.instance
        .collection('Stories')
        .doc(widget.stories.first.storyID)
        .get()
        .then((snapshot) {
      if (snapshot.exists && mounted) {
        setState(() {
          widget.stories.first.loves = snapshot.data()?['loves'] ?? 0;
        });
      }
    });

    context
        .read<GetLoveCubit>()
        .getLoveStatus(widget.stories.first.storyID, widget.currentUser)
        .then((status) {
      if (mounted) {
        setState(() => isLoved = status);
      }
    });
  }

  void loadComments() {
    getCommentCubit.getComments(widget.stories.first.storyID);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    const storyViewIndicatorConfig = StoryViewIndicatorConfig(
      height: 4,
      activeColor: Colors.red,
      backgroundCompletedColor: Colors.white,
      horizontalGap: 1,
      borderRadius: 1.5,
    );

    List<story_presenter.StoryItem> storyItems = [];

    for (var story in widget.stories) {
      if (story.imageUrls != null && story.imageUrls!.isNotEmpty) {
        final urls = story.imageUrls!.split(',');
        for (var url in urls) {
          storyItems.add(
            story_presenter.StoryItem(
              storyItemType: story.type == 'video'
                  ? story_presenter.StoryItemType.video
                  : story_presenter.StoryItemType.image,
              url: url,
            ),
          );
        }
      } else if (story.type == 'text') {
        storyItems.add(
          story_presenter.StoryItem(
            storyItemType: story_presenter.StoryItemType.text,
            url: story.imageUrls ?? '',
          ),
        );
      }
    }

    return BlocListener<CreateCommentCubit, CreateCommentStates>(
      bloc: createCommentCubit,
      listener: (context, state) {
        if (state is CreateCommentSuccessStates) {
          loadComments();
        }
      },
      child: BlocBuilder<GetCommentCubit, GetCommentsState>(
        bloc: getCommentCubit,
        builder: (context, state) {
          if (state is GetCommentLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GetCommentSuccessState) {
            commentsList = state.comments
                .where((c) => c.postId == widget.stories[currentStoryIndex].storyID)
                .toList();
            widget.stories[currentStoryIndex].comments = commentsList.length;
          }

          if (widget.stories.isEmpty) {
            return const Center(child: Text('No stories available.'));
          }

          return Scaffold(
            body: FlutterStoryPresenter(
              flutterStoryController: controller,
              items: storyItems,
              headerWidget: TopRowWidget(
                story: widget.stories[currentStoryIndex],
                currentUser: widget.currentUser,
                isDarkMode: isDarkMode,
                onDelete: () => deletePost(widget.stories[currentStoryIndex].storyID),
              ),
              footerWidget: BottomRowWidget(
                story: widget.stories[currentStoryIndex],
                currentUser: widget.currentUser,
                isDarkMode: isDarkMode,
                isLoved: isLoved,
                onCommentPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return MultiBlocProvider(
                        providers: [
                          BlocProvider(
                              create: (context) => GetUserCubit()..getUsers()),
                          BlocProvider(
                              create: (context) => GetCommentCubit()),
                          BlocProvider(
                              create: (context) => CreateCommentCubit()),
                        ],
                        child: CommentsSection(
                          postId: widget.stories.first.storyID,
                          currentUser: widget.currentUser,
                          initialCommentCount: widget.stories.first.comments,
                          collection: storiesCollection,
                          commentController: commentController,
                        ),
                      );
                    },
                  );
                },
                onLovePressed: () async {
                  final userSnapshot = await FirebaseFirestore
                      .instance
                      .collection('Users')
                      .doc(widget.stories.first.userName)
                      .get();

                  if (userSnapshot.exists) {
                    final userToken = userSnapshot.data()?['userToken'];

                    if (userToken != null) {
                      notificationService.sendNotification(
                        userToken,
                        "Someone loved your story!",
                      );
                    }
                  }
                  setState(() {
                    isLoved = !isLoved;
                    widget.stories.first.loves += isLoved ? 1 : -1;
                  });
                  toggleLove(
                    postID: widget.stories.first.storyID,
                    currentUser: widget.currentUser,
                    isLoved: isLoved,
                    loves: widget.stories.first.loves,
                    collection: storiesCollection,
                    createLoveCubit: context.read<CreateLoveCubit>(),
                  );
                },
              ),
              storyViewIndicatorConfig: storyViewIndicatorConfig,
              initialIndex: currentStoryIndex,
              onStoryChanged: (index) {
                Future.microtask(() {
                  setState(() {
                    currentStoryIndex = index;
                  });
                });
              },
              onPreviousCompleted: () async {
                widget.onPreviousUser();
              },
              onCompleted: () async {
                widget.onNextUser();
              },
            ),
          );
        },
      ),
    );
  }
}