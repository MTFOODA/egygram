import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/widgets/story/create_story_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../logics/story/create_story_logic/cubit.dart';
import '../../logics/story/create_story_logic/state.dart';
import '../../models/story_model.dart';
import '../../screens/navigation_screen.dart';

class CreateStory extends StatelessWidget {
  final TextEditingController storyDescriptionController;
  final List<XFile> selectedStoryMedias;
  final String? profileImage;
  final String userName;
  final Future<void> Function() onMediaPick;
  final Future<List<String>> Function(List<XFile>, String userName)
  uploadStoryMedias;

  const CreateStory({
    required this.storyDescriptionController,
    required this.selectedStoryMedias,
    required this.profileImage,
    required this.userName,
    required this.onMediaPick,
    required this.uploadStoryMedias,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateStoryCubit(),
      child: BlocConsumer<CreateStoryCubit, CreateStoryStates>(
        listener: (context, state) {
          if (state is CreateStorySuccessStates) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Story created successfully!".tr())),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => NavigationScreen(
                    initialIndex: 0,
                    userName: userName),
              ),
                  (Route<dynamic> route) => false,
            );
          } else if (state is CreateStoryErrorStates) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage.toString())),
            );
          }
        },
        builder: (context, state) {
          return StoryUIWidget(
            selectedMedias: selectedStoryMedias,
            onMediaPick: onMediaPick,
            onStoryCreate: () async {
              try {
                String? imageUrls;
                String type = 'text';

                if (selectedStoryMedias.isNotEmpty) {
                  List<String> storyURIs =
                  await uploadStoryMedias(selectedStoryMedias, userName);
                  imageUrls = storyURIs.join(',');

                  String extension = selectedStoryMedias.first.path
                      .split('.')
                      .last
                      .toLowerCase();
                  if (extension == 'mp4' || extension == 'mov') {
                    type = 'video';
                  } else {
                    type = 'image';
                  }
                } else if (storyDescriptionController.text.isNotEmpty) {
                  type = 'text';
                }

                String storyId =
                    FirebaseFirestore.instance.collection('Stories').doc().id;

                StoriesModel story = StoriesModel(
                  storyID: storyId,
                  profileImage: profileImage,
                  userName: userName,
                  time: DateTime.now(),
                  imageUrls: imageUrls,
                  type: type,
                );

                context.read<CreateStoryCubit>().createStory(story);
              } catch (e) {
                debugPrint("Error creating story: $e");
              }
            },
            uploadStoryMedias: (medias) => uploadStoryMedias(medias, userName),
          );
        },
      ),
    );
  }
}