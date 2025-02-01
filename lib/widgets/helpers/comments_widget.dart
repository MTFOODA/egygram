import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../logics/comments/create_comments_logic/cubit.dart';
import '../../logics/comments/create_comments_logic/state.dart';
import '../../logics/comments/get_comments_logic/cubit.dart';
import '../../logics/comments/get_comments_logic/state.dart';
import '../../logics/user/get_user_logic/cubit.dart';
import '../../logics/user/get_user_logic/state.dart';
import '../../models/comment_model.dart';
import '../../models/user_model.dart';
import '../../utilities/decoration.dart';
import '../../utilities/fonts_dart.dart';
import '../../utilities/notification_service.dart';
import '../../utilities/theme_provider.dart';

class CommentOperations {
  static Future<void> addComment({
    required CommentsModel comment,
    required int currentCommentCount,
    required String postId,
    required CollectionReference collection,
  }) async
  {
    try {
      await FirebaseFirestore.instance.collection('Comments').add(comment.toMap());

      final updatedCount = currentCommentCount + 1;
      await collection
          .doc(postId)
          .update({'comments': updatedCount});
    } catch (e) {
      debugPrint("Error adding comment: $e");
    }
  }
}

class CommentsSection extends StatefulWidget {
  final String postId;
  final String currentUser;
  final int initialCommentCount;
  final CollectionReference collection;
  final TextEditingController commentController;

  const CommentsSection({
    super.key,
    required this.postId,
    required this.currentUser,
    required this.initialCommentCount,
    required this.collection,
    required this.commentController,
  });

  @override
  State<CommentsSection> createState() => CommentsSectionState();
}

class CommentsSectionState extends State<CommentsSection> {
  List<CommentsModel> commentsList = [];
  final GetCommentCubit getCommentCubit = GetCommentCubit();
  final CreateCommentCubit createCommentCubit = CreateCommentCubit();
  final NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Future<void> handleAddComment() async {
    if (widget.commentController.text.isNotEmpty) {
      String? profileImage;
      String? userToken;

      final userState = context.read<GetUserCubit>().state;
      if (userState is GetUserSuccessState) {
        final user = userState.users.firstWhere(
              (user) => user.userName == widget.currentUser,
          orElse: () => UsersModel.defaultUser(),
        );
        profileImage = user.profileImage ?? "assets/images/profile_picture.jpg";
        userToken = user.userToken;
      }

      final newComment = CommentsModel(
        profileImage: profileImage,
        userName: widget.currentUser,
        postId: widget.postId,
        content: widget.commentController.text,
        time: DateTime.now(),
      );

      if (userToken != null) {
        // Send a notification
        notificationService.sendNotification(
          userToken,
          "Someone comment on your reel !",
        );
      }

      await CommentOperations.addComment(
        comment: newComment,
        currentCommentCount: widget.initialCommentCount,
        postId: widget.postId,
        collection: widget.collection,
      );

      setState(() {
        loadComments();
      });

      widget.commentController.clear();
    }
  }

  void loadComments() {
    getCommentCubit.getComments(widget.postId);
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
            commentsList = state.comments.where((c) => c.postId == widget.postId).toList();
          }
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Comments".tr(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${commentsList.length} + ${"Comments".tr()}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: commentsList.isEmpty ? 1 : commentsList.length,
                    itemBuilder: (context, index) {
                      if (commentsList.isEmpty) {
                        return Center(child: Text("No comments yet".tr(),style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold));
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
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widget.commentController,
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
          );
        },
      ),
    );
  }
}
