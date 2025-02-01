import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/reel_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import '../../logics/comments/create_comments_logic/cubit.dart';
import '../../logics/comments/create_comments_logic/state.dart';
import '../../logics/comments/get_comments_logic/cubit.dart';
import '../../logics/comments/get_comments_logic/state.dart';
import '../../logics/love/create_love_logic/cubit.dart';
import '../../logics/love/get_love_logic/cubit.dart';
import '../../logics/reel/edit_reel_logic/cubit.dart';
import '../../logics/save/create_save_logic/cubit.dart';
import '../../logics/save/get_save_logic/cubit.dart';
import '../../logics/user/get_user_logic/cubit.dart';
import '../../models/comment_model.dart';
import '../../screens/edit_reel_page.dart';
import '../../utilities/colors_dart.dart';
import '../../utilities/fonts_dart.dart';
import '../../utilities/notification_service.dart';
import '../../utilities/theme_provider.dart';
import '../helpers/comments_widget.dart';
import '../helpers/expandable_text.dart';
import '../helpers/post_handel_button.dart';

class ReelWidget extends StatefulWidget {
  final ReelsModel reels;
  final String currentUser;

  const ReelWidget({
    super.key,
    required this.reels,
    required this.currentUser
  });

  @override
  State<ReelWidget> createState() => ReelWidgetState();
}

class ReelWidgetState extends State<ReelWidget> {
  late VideoPlayerController videoController;
  late ReelsModel reel;
  bool isLoved = false;
  bool isSaved = false;
  final CollectionReference reelsCollection =
  FirebaseFirestore.instance.collection('Reels');
  TextEditingController commentController = TextEditingController();
  List<CommentsModel> commentsList = [];
  final CreateCommentCubit createCommentCubit = CreateCommentCubit();
  final GetCommentCubit getCommentCubit = GetCommentCubit();
  final NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    reel = widget.reels;

    FirebaseFirestore.instance
        .collection('Reels')
        .doc(reel.reelID)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          widget.reels.loves = snapshot.data()?['loves'] ?? 0;
        });
      }
    });

    context
        .read<GetLoveCubit>()
        .getLoveStatus(reel.reelID, widget.currentUser)
        .then((status) {
      setState(() {
        isLoved = status;
      });
    });

    context
        .read<GetSaveCubit>()
        .getSaveStatus(reel.reelID, widget.currentUser)
        .then((status) {
      setState(() {
        isSaved = status;
      });
    });

    videoController = VideoPlayerController.networkUrl(Uri.parse(widget.reels.video))
      ..initialize().then((_) {
        setState(() {});
        videoController.play();
        videoController.setLooping(true);
      });
    loadComments();
  }

  Future<void> deletePost(String reelID) async {
    try {
      await FirebaseFirestore.instance.collection('Reels').doc(reelID).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reel deleted successfully")),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete Reel: $e")),
      );
    }
  }

  void togglePlayPause() {
    setState(() {
      if (videoController.value.isPlaying) {
        videoController.pause();
      } else {
        videoController.play();
      }
    });
  }

  void loadComments() {
    getCommentCubit.getComments(widget.reels.reelID);
  }

  @override
  void dispose() {
    commentController.dispose();
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

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
                .where((c) => c.postId == widget.reels.reelID)
                .toList();
            widget.reels.comments = commentsList.length;
          }

          return Scaffold(
            backgroundColor: AppColors.lightGrey,
            appBar: AppBar(
              backgroundColor: AppColors.trans,
              title: Text("Reels".tr(), style: AppFonts.textB24bold)),
            body: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: double.maxFinite,
                    child: videoController.value.isInitialized
                        ? GestureDetector(
                      onTap: togglePlayPause,
                      child: AspectRatio(
                        aspectRatio: videoController.value.aspectRatio,
                        child: VideoPlayer(videoController),
                      ),
                    )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ),
                Positioned(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 410),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20.0,
                                      backgroundImage: widget.reels.profileImage!.isNotEmpty
                                          ? NetworkImage(
                                          widget.reels.profileImage!)
                                          : const AssetImage(
                                          'assets/images/profile_picture.jpg'),
                                      backgroundColor: const Color(0xFFFFF4F4),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(widget.reels.userName, style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
                                        Text(
                                          "${widget.reels.time.hour}:${widget.reels.time.minute.toString().padLeft(2, '0')} ${widget.reels.time.hour >= 12 ? "PM" : "AM"}", style: isDarkMode ? AppFonts.textW11bold : AppFonts.textB11bold
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: Row(
                                      children: [
                                        ExpandableTextRow(
                                            ex: widget.reels.description!),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: FaIcon(
                                  isLoved
                                      ? FontAwesomeIcons.solidHeart
                                      : FontAwesomeIcons.heart,
                                  color: isLoved ? Colors.red : Colors.white,
                                ),
                                onPressed: () async {
                                  final userSnapshot = await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(reel.userName)
                                      .get();

                                  if (userSnapshot.exists) {
                                    final userToken = userSnapshot.data()?['userToken'];

                                    if (userToken != null) {
                                      // Send a notification
                                      notificationService.sendNotification(
                                        userToken,
                                        "Someone loved your Reel!",
                                      );
                                    }
                                  }
                                  setState(() {
                                    isLoved = !isLoved;
                                    widget.reels.loves += isLoved ? 1 : -1;
                                  });
                                  toggleLove(
                                    postID: reel.reelID,
                                    currentUser: widget.currentUser,
                                    isLoved: isLoved,
                                    loves: widget.reels.loves,
                                    collection: reelsCollection,
                                    createLoveCubit:
                                    context.read<CreateLoveCubit>(),
                                  );
                                },
                                iconSize: 25,
                              ),
                              Text("${widget.reels.loves}", style: isDarkMode ? AppFonts.textW14bold : AppFonts.textB14bold),
                              IconButton(
                                icon: const FaIcon(FontAwesomeIcons.comment, color: Colors.white),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return MultiBlocProvider(
                                        providers: [
                                          BlocProvider(
                                              create: (context) =>
                                              GetUserCubit()..getUsers()),
                                          BlocProvider(
                                              create: (context) =>
                                                  GetCommentCubit()),
                                          BlocProvider(
                                              create: (context) =>
                                                  CreateCommentCubit()),
                                        ],
                                        child: CommentsSection(
                                          postId: widget.reels.reelID,
                                          currentUser: widget.currentUser,
                                          initialCommentCount:
                                          widget.reels.comments,
                                          collection: reelsCollection,
                                          commentController: commentController,
                                        ),
                                      );
                                    },
                                  );
                                },
                                iconSize: 25,
                              ),
                              Text("${widget.reels.comments}", style: isDarkMode ? AppFonts.textW14bold : AppFonts.textB14bold),
                              IconButton(
                                icon: const FaIcon(FontAwesomeIcons.paperPlane, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    widget.reels.shares++;
                                  });
                                  incrementShares(
                                    postID: reel.reelID,
                                    shares: widget.reels.shares,
                                    collection: reelsCollection,
                                  );
                                  Share.share(reel.reelID);
                                },
                                iconSize: 25,
                              ),
                              Text("${widget.reels.shares}", style: isDarkMode ? AppFonts.textW14bold : AppFonts.textB14bold),
                              IconButton(
                                icon: FaIcon(
                                  isSaved
                                      ? FontAwesomeIcons.solidBookmark
                                      : FontAwesomeIcons.bookmark,
                                  color: isSaved ? Colors.red : Colors.white,
                                ),
                                onPressed: () async {
                                  final userSnapshot = await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(reel.userName)
                                      .get();

                                  if (userSnapshot.exists) {
                                    final userToken = userSnapshot.data()?['userToken'];

                                    if (userToken != null) {
                                      // Send a notification
                                      notificationService.sendNotification(
                                        userToken,
                                        "Someone saved your Reel!",
                                      );
                                    }
                                  }
                                  setState(() {
                                    isSaved = !isSaved;
                                  });
                                  toggleSave(
                                    postID: reel.reelID,
                                    currentUser: widget.currentUser,
                                    isSaved: isSaved,
                                    collection: reelsCollection,
                                    createSaveCubit:
                                    context.read<CreateSaveCubit>(),
                                  );
                                },
                                iconSize: 25,
                              ),
                              if (widget.currentUser == widget.reels.userName)
                                PopupMenuButton<String>(
                                  icon: const FaIcon(
                                    FontAwesomeIcons.ellipsis,
                                    size: 25,
                                    color: Colors.white
                                  ),
                                  onSelected: (String value) async {
                                    if (value == 'edit') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BlocProvider(
                                            create: (context) => EditReelCubit(),
                                            child: EditReelPage(reelModel: reel),
                                          ),
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text("Delete Post".tr()),
                                          content: Text("Are you sure you want to delete this reel ?".tr()),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: Text("Cancel".tr()),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: Text("Delete".tr()),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        await deletePost(reel.reelID);
                                      }                                              }
                                  },
                                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                    PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Text('Edit'.tr(), style: isDarkMode ? AppFonts.textW14bold : AppFonts.textB14bold),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Text('Delete'.tr(), style: isDarkMode ? AppFonts.textW14bold : AppFonts.textB14bold),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
