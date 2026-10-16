import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/media_upload_helper.dart';
import '../../logics/reel/create_real_logic/cubit.dart';
import '../../logics/user/get_user_logic/cubit.dart';
import '../../logics/user/get_user_logic/state.dart';
import '../../models/user_model.dart';
import 'create_reel.dart';

class CreateReelWidget extends StatefulWidget {
  final String userName;
  const CreateReelWidget({super.key, required this.userName});

  @override
  State<CreateReelWidget> createState() => CreateReelWidgetState();
}

class CreateReelWidgetState extends State<CreateReelWidget> {
  final TextEditingController reelDescriptionController =
      TextEditingController();
  XFile? selectedReelVideo;

  @override
  void dispose() {
    reelDescriptionController.dispose();
    super.dispose();
  }

  Future<void> selectReelVideo() async {
    final picker = ImagePicker();
    selectedReelVideo = await picker.pickVideo(source: ImageSource.gallery);
    setState(() {});
  }

  Future<String?> uploadReelVideo(XFile video, String userName) {
    return MediaUploadHelper.uploadVideo(
      video: video,
      folder: StorageBuckets.reelsFolder,
      owner: userName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GetUserCubit()..getUsers()),
        BlocProvider(create: (context) => CreateReelCubit()),
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
                  CreateReel(
                    reelDescriptionController: reelDescriptionController,
                    selectedReelVideo: selectedReelVideo,
                    profileImage: profileImage,
                    userName: userName,
                    onVideoPick: selectReelVideo,
                    uploadReelVideo: uploadReelVideo,
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
