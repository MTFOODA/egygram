import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_3/models/post_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../logics/comments/create_comments_logic/cubit.dart';
import '../../logics/comments/create_comments_logic/state.dart';
import '../../logics/comments/get_comments_logic/cubit.dart';
import '../../logics/comments/get_comments_logic/state.dart';
import '../../logics/love/create_love_logic/cubit.dart';
import '../../logics/love/get_love_logic/cubit.dart';
import '../../logics/post/edit_post_logic/cubit.dart';
import '../../logics/save/create_save_logic/cubit.dart';
import '../../logics/save/get_save_logic/cubit.dart';
import '../../logics/user/get_user_logic/cubit.dart';
import '../../logics/user/get_user_logic/state.dart';
import '../../models/comment_model.dart';
import '../../models/user_model.dart';
import '../../screens/edit_post_page.dart';
import '../../utilities/decoration.dart';
import '../../utilities/fonts_dart.dart';
import '../../utilities/notification_service.dart';
import '../../utilities/theme_provider.dart';
import '../helpers/comments_widget.dart';
import '../helpers/post_handel_button.dart';
import '../helpers/expandable_text.dart';
import '../helpers/full_screen_image.dart';

class PostDetailsPage extends StatefulWidget {
  final String currentUser;
  final PostsModel posts;

  const PostDetailsPage({super.key, required this.currentUser, required this.posts});

  @override
  PostDetailsPageState createState() => PostDetailsPageState();
}

class PostDetailsPageState extends State<PostDetailsPage> {
  final TextEditingController commentController = TextEditingController();
  final CreateCommentCubit createCommentCubit = CreateCommentCubit();
  final GetCommentCubit getCommentCubit = GetCommentCubit();
  List<CommentsModel> commentsList = [];
  bool isLoved = false;
  bool isSaved = false;
  late PostsModel post;
  final CollectionReference postsCollection = FirebaseFirestore.instance.collection('Posts');
  final NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    post = widget.posts;

    FirebaseFirestore.instance
        .collection('Posts')
        .doc(post.postID)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          widget.posts.loves = snapshot.data()?['loves'] ?? 0;
        });
      }
    });

    context
        .read<GetLoveCubit>()
        .getLoveStatus(post.postID, widget.currentUser)
        .then((status) {
      setState(() {
        isLoved = status;
      });
    });

    context
        .read<GetSaveCubit>()
        .getSaveStatus(post.postID, widget.currentUser)
        .then((status) {
      setState(() {
        isSaved = status;
      });
    });
    loadComments();
  }

  void loadComments() {
    getCommentCubit.getComments(widget.posts.postID);
  }

  Future<void> handleAddComment() async {
    if (commentController.text.isNotEmpty) {
      String profileImage = '';
      final userState = context.read<GetUserCubit>().state;
      if (userState is GetUserSuccessState) {
        final user = userState.users.firstWhere(
              (user) => user.userName == widget.currentUser,
          orElse: () => UsersModel.defaultUser(),
        );
        profileImage = user.profileImage ?? "assets/images/profile_picture.jpg";
      }
      final newComment = CommentsModel(
        userName: widget.currentUser,
        profileImage: profileImage,
        postId: widget.posts.postID,
        content: commentController.text,
        time: DateTime.now(),
      );

      await CommentOperations.addComment(
        comment: newComment,
        currentCommentCount: widget.posts.comments,
        postId: widget.posts.postID,
        collection: postsCollection,
      );
        final userSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(post.userName)
            .get();

        if (userSnapshot.exists) {
          final userToken = userSnapshot.data()?['userToken'];

          if (userToken != null) {
            // Send a notification
            notificationService.sendNotification(
              userToken,
              "Someone comment on your post!",
            );
          }
        }
      setState(() {
        widget.posts.comments++;
      });

      commentController.clear();
    }
  }

  Future<void> deletePost(String postID) async {
    try {
      await FirebaseFirestore.instance.collection('Posts').doc(postID).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post deleted successfully")),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete post: $e")),
      );
    }
  }
  @override
  void dispose() {
    commentController.dispose();
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
                .where((c) => c.postId == widget.posts.postID)
                .toList();
            widget.posts.comments = commentsList.length;
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(widget.posts.userName, style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: noteContainerDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Center(
                                      child: Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundImage: widget.posts.profileImage != null
                                                ? NetworkImage(widget.posts.profileImage!)
                                                : const AssetImage(
                                                "assets/images/profile_picture.jpg"),
                                            backgroundColor: const Color(0xFFFFF4F4),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: () {},
                                              child: const CircleAvatar(
                                                radius: 5.5,
                                                backgroundColor: Colors.blue,
                                                child: FaIcon(
                                                  FontAwesomeIcons.check,
                                                  color: Colors.white,
                                                  size: 7.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(widget.posts.userName, style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 15),
                                          child: Text(
                                            "${widget.posts.time.hour}:${widget.posts.time.minute}${widget.posts.time.hour >= 12 ? " PM" : " AM"}",
                                            style: isDarkMode ? AppFonts.textW11bold : AppFonts.textB11bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    if (widget.currentUser == widget.posts.userName)
                                      PopupMenuButton<String>(
                                        icon: const FaIcon(
                                          FontAwesomeIcons.ellipsis,
                                          size: 25,
                                        ),
                                        onSelected: (String value) async {
                                          if (value == 'edit') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => BlocProvider(
                                                  create: (context) => EditPostCubit(),
                                                  child: EditPostPage(
                                                    postModel: post,
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else if (value == 'delete') {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text("Delete Post".tr()),
                                                content: Text("Are you sure you want to delete this post?".tr()),
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
                                              await deletePost(post.postID);
                                            }
                                          }
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
                                const SizedBox(height: 20),
                                Center(
                                  child: Container(
                                    width: double.infinity,
                                    height: 250,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: widget.posts.imageUrls.isNotEmpty
                                        ? PageView.builder(
                                      itemCount: widget.posts.imageUrls.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => FullScreenImage(
                                                    imageUrl: widget.posts.imageUrls[index],
                                                  ),
                                                ),
                                              );
                                            },
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                widget.posts.imageUrls[index],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                        : Center(
                                      child: Text(
                                        "No images available".tr(), style: isDarkMode ? AppFonts.textW16bold : AppFonts.textB16bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: FaIcon(
                                          isLoved
                                              ? FontAwesomeIcons.solidHeart
                                              : FontAwesomeIcons.heart,
                                          color: isLoved ? Colors.red : Colors.black,
                                        ),
                                        onPressed: () async {
                                          final userSnapshot = await FirebaseFirestore.instance
                                              .collection('Users')
                                              .doc(post.userName)
                                              .get();

                                          if (userSnapshot.exists) {
                                            final userToken = userSnapshot.data()?['userToken'];

                                            if (userToken != null) {
                                              // Send a notification
                                              notificationService.sendNotification(
                                                userToken,
                                                "Someone loved your post!",
                                              );
                                            }
                                          }
                                          setState(() {
                                            isLoved = !isLoved;
                                            widget.posts.loves += isLoved ? 1 : -1;
                                          });
                                          toggleLove(
                                            postID: post.postID,
                                            currentUser: widget.currentUser,
                                            isLoved: isLoved,
                                            loves: widget.posts.loves,
                                            collection: postsCollection,
                                            createLoveCubit: context.read<CreateLoveCubit>(),
                                          );
                                        },
                                        iconSize: 25,
                                      ),
                                      Text("${widget.posts.loves}", style: isDarkMode ? AppFonts.textW14bold : AppFonts.textB14bold),
                                      const SizedBox(width: 10),
                                      IconButton(
                                        icon: const FaIcon(FontAwesomeIcons.comment),
                                        onPressed: () {setState(() {});},
                                        iconSize: 25,
                                      ),
                                      Text("${widget.posts.comments}", style: isDarkMode ? AppFonts.textW14bold : AppFonts.textB14bold),
                                      const SizedBox(width: 10),
                                      IconButton(
                                        icon: const FaIcon(FontAwesomeIcons.paperPlane),
                                        onPressed: () {
                                          setState(() {
                                            widget.posts.shares++;
                                          });
                                          incrementShares(
                                            postID: post.postID,
                                            shares: widget.posts.shares,
                                            collection: postsCollection,
                                          );
                                          Share.share(post.postID);
                                        },
                                        iconSize: 25,
                                      ),
                                      Text("${widget.posts.shares}", style: isDarkMode ? AppFonts.textW14bold : AppFonts.textB14bold),
                                      const Spacer(),
                                      IconButton(
                                        icon: FaIcon(
                                          isSaved
                                              ? FontAwesomeIcons.solidBookmark
                                              : FontAwesomeIcons.bookmark,
                                          color: isSaved ? Colors.red : Colors.black,
                                        ),
                                        onPressed: () async {
                                          final userSnapshot = await FirebaseFirestore.instance
                                              .collection('Users')
                                              .doc(post.userName)
                                              .get();

                                          if (userSnapshot.exists) {
                                            final userToken = userSnapshot.data()?['userToken'];

                                            if (userToken != null) {
                                              // Send a notification
                                              notificationService.sendNotification(
                                                userToken,
                                                "Someone loved your post!",
                                              );
                                            }
                                          }
                                          setState(() {
                                            isSaved = !isSaved;
                                          });
                                          toggleSave(
                                            postID: post.postID,
                                            currentUser: widget.currentUser,
                                            isSaved: isSaved,
                                            collection: postsCollection,
                                            createSaveCubit: context.read<CreateSaveCubit>(),
                                          );
                                        },
                                        iconSize: 25,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: [
                                      const SizedBox(height: 20),
                                      Expanded(child: ExpandableTextRow(ex: widget.posts.description ?? "")
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Comments".tr(), style: isDarkMode ? AppFonts.textW16bold : AppFonts.textB16bold
                                    ),
                                    Text(
                                        "${widget.posts.comments} + ${"Comments".tr()}",
                                        style: isDarkMode ? AppFonts.textW16bold : AppFonts.textB16bold
                                    ),
                                  ],
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: commentsList.length,
                                  itemBuilder: (context, index) {
                                    if (commentsList.isEmpty) {
                                      return Center(child: Text("No comments yet".tr(), style: isDarkMode ? AppFonts.textW16bold : AppFonts.textB16bold));
                                    }
                                    final comment = commentsList[index];
                                    return BlocBuilder<GetUserCubit, GetUsersState>(
                                      builder: (context, userState) {
                                        return Card(
                                          margin: const EdgeInsets.symmetric(vertical: 8),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: const Color(0xFFFFF4F4),
                                              backgroundImage: comment.profileImage!.isNotEmpty
                                                  ? NetworkImage(comment.profileImage!)
                                                  : const AssetImage(
                                                  "assets/images/profile_picture.jpg"),
                                            ),
                                            title: Text(comment.userName),
                                            subtitle: Text(comment.content),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: searchInputDecoration(
                              context,
                              'Comment...'.tr(),
                              const Icon(CupertinoIcons.tag),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: handleAddComment,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
