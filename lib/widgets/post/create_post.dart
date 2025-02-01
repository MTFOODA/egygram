import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/post_model.dart';
import 'package:flutter_application_3/widgets/post/create_post_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../logics/post/create_post_logic/cubit.dart';
import '../../logics/post/create_post_logic/state.dart';
import '../../screens/navigation_screen.dart';

class CreatePost extends StatelessWidget {
  final TextEditingController postDescriptionController;
  final List<XFile> selectedPostImages;
  final String? profileImage;
  final String userName;
  final Future<void> Function() onImagePick;
  final Future<List<String>> Function(List<XFile>, String userName)
      uploadPostImages;

  const CreatePost({
    required this.postDescriptionController,
    required this.selectedPostImages,
    required this.profileImage,
    required this.userName,
    required this.onImagePick,
    required this.uploadPostImages,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreatePostCubit(),
      child: BlocConsumer<CreatePostCubit, CreatePostStates>(
        listener: (context, state) {
          if (state is CreatePostSuccessStates) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Post created successfully!".tr())),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => NavigationScreen(
                  initialIndex: 0,
                  userName: userName,
                ),
              ),
              (Route<dynamic> route) => false,
            );
          } else if (state is CreatePostErrorStates) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage.toString())),
            );
          }
        },
        builder: (context, state) {
          return PostUIWidget(
            descriptionController: postDescriptionController,
            selectedImages: selectedPostImages,
            onImagePick: onImagePick,
            onPostCreate: () async {
              try {
                List<String> uploadedImageUrls =
                    await uploadPostImages(selectedPostImages, userName);

                String postId =
                    FirebaseFirestore.instance.collection('Posts').doc().id;

                context.read<CreatePostCubit>().createPost(
                      PostsModel(
                        postID: postId,
                        profileImage: profileImage,
                        description: postDescriptionController.text,
                        userName: userName,
                        time: DateTime.now(),
                        imageUrls: uploadedImageUrls,
                      ),
                    );
              } catch (e) {
                debugPrint("Error creating post: $e");
              }
            },
            uploadPostImages: (images) => uploadPostImages(images, userName),
          );
        },
      ),
    );
  }
}
