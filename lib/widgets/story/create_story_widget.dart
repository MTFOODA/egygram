import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../logics/story/create_story_logic/cubit.dart';
import '../../logics/user/get_user_logic/cubit.dart';
import '../../logics/user/get_user_logic/state.dart';
import '../../models/user_model.dart';
import 'create_story.dart';

class CreateStoryWidget extends StatefulWidget {
  final String userName;
  const CreateStoryWidget({super.key, required  this.userName});

  @override
  State<CreateStoryWidget> createState() => CreateStoryWidgetState();
}

class CreateStoryWidgetState extends State<CreateStoryWidget> {
  final TextEditingController storyDescriptionController = TextEditingController();
  List<XFile> selectedStoryMedia = [];

  @override
  void dispose() {
    storyDescriptionController.dispose();
    super.dispose();
  }

  Future<void> selectStoryMedia() async {
    final picker = ImagePicker();
    try {
      final pickedMedia = await picker.pickMultipleMedia(); // Ensure your environment supports this
        setState(() {
          selectedStoryMedia.addAll(pickedMedia);
        });
    } catch (e) {
      print("Media Selection Error: $e");
    }
  }

  Future<List<String>> uploadStoryMedia(List<XFile> medias, String userName) async {
    List<String> mediaUrls = [];
    try {
      for (XFile media in medias) {
        final isVideo = media.mimeType?.startsWith('video') ?? false;
        final extension = isVideo ? '.mp4' : '.jpg';
        final mediaTypeFolder = isVideo ? "videos" : "images";

        final storageRef = FirebaseStorage.instance
            .ref()
            .child("storiesMedia/$userName/$mediaTypeFolder/${DateTime.now().millisecondsSinceEpoch}$extension");

        await storageRef.putFile(File(media.path));
        String mediaUrl = await storageRef.getDownloadURL();
        mediaUrls.add(mediaUrl);
      }
    } catch (e) {
      print("Upload Error: $e");
    }
    return mediaUrls;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GetUserCubit()..getUsers()),
        BlocProvider(create: (context) => CreateStoryCubit()),
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
                  CreateStory(
                    storyDescriptionController: storyDescriptionController,
                    selectedStoryMedias: selectedStoryMedia,
                    profileImage: profileImage,
                    userName: userName,
                    onMediaPick: selectStoryMedia,
                    uploadStoryMedias: uploadStoryMedia,
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
