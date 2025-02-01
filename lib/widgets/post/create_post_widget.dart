import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../logics/post/create_post_logic/cubit.dart';
import '../../logics/user/get_user_logic/cubit.dart';
import '../../logics/user/get_user_logic/state.dart';
import '../../models/user_model.dart';
import 'create_post.dart';

class CreatePostWidget extends StatefulWidget {
  final String userName;
  const CreatePostWidget({super.key, required this.userName});

  @override
  State<CreatePostWidget> createState() => CreatePostWidgetState();
}

class CreatePostWidgetState extends State<CreatePostWidget> {
  final TextEditingController postDescriptionController = TextEditingController();
  List<XFile> selectedPostImages = [];

  @override
  void dispose() {
    postDescriptionController.dispose();
    super.dispose();
  }

  Future<void> selectPostImages() async {
    final picker = ImagePicker();
    try {
      final pickedMedia = await picker.pickMultipleMedia();
      setState(() {
        selectedPostImages.addAll(pickedMedia);
      });
    } catch (e) {
      debugPrint("Media Selection Error: $e");
    }
  }

  Future<List<String>> uploadPostImages(List<XFile> images, String userName) async {
    List<String> imageUrls = [];
    try {
      for (XFile image in images) {
        final isVideo = image.mimeType?.startsWith('video') ?? false;
        final extension = isVideo ? '.mp4' : '.jpg';
        final mediaTypeFolder = isVideo ? "videos" : "images";

        final storageRef = FirebaseStorage.instance
            .ref()
            .child("Posts/$userName/$mediaTypeFolder/${DateTime.now().millisecondsSinceEpoch}$extension");

        await storageRef.putFile(File(image.path));
        String mediaUrl = await storageRef.getDownloadURL();
        imageUrls.add(mediaUrl);
      }
    } catch (e) {
      debugPrint("Upload Error: $e");
    }
    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GetUserCubit()..getUsers()),
        BlocProvider(create: (context) => CreatePostCubit()),
      ],
      child: Scaffold(
        body: SingleChildScrollView(
          child: BlocBuilder<GetUserCubit, GetUsersState>(
            builder: (context, state) {
              String? profileImage;
              String? userName;

              if (state is GetUserSuccessState) {
                final user = state.users.firstWhere(
                      (user) => user.userName == widget.userName,
                  orElse: () => UsersModel.defaultUser(),
                );
                profileImage = user.profileImage;
                userName = user.userName;
              }

              if (userName == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  CreatePost(
                    postDescriptionController: postDescriptionController,
                    selectedPostImages: selectedPostImages,
                    profileImage: profileImage,
                    userName: userName,
                    onImagePick: selectPostImages,
                    uploadPostImages: uploadPostImages,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
