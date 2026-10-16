import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/media_upload_helper.dart';
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
  final TextEditingController postDescriptionController =
      TextEditingController();
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

  Future<List<String>> uploadPostImages(List<XFile> images, String userName) {
    return MediaUploadHelper.uploadMedia(
      files: images,
      folder: StorageBuckets.postsFolder,
      owner: userName,
    );
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
