import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/reel_model.dart';
import 'package:flutter_application_3/widgets/reel/create_reel_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../logics/reel/create_real_logic/cubit.dart';
import '../../logics/reel/create_real_logic/state.dart';
import '../../screens/navigation_screen.dart';

class CreateReel extends StatelessWidget {
  final TextEditingController reelDescriptionController;
  final XFile? selectedReelVideo;
  final String? profileImage;
  final String? userName;
  final Future<void> Function() onVideoPick;
  final Future<String?> Function(XFile video, String userName) uploadReelVideo;

  const CreateReel({
    required this.reelDescriptionController,
    required this.selectedReelVideo,
    required this.profileImage,
    required this.userName,
    required this.onVideoPick,
    required this.uploadReelVideo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateReelCubit(),
      child: BlocConsumer<CreateReelCubit, CreateReelStates>(
        listener: (context, state) {
          if (state is CreateReelSuccessStates) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Reel created successfully!".tr())),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => NavigationScreen(initialIndex: 0,userName: userName!,),
              ),
                  (Route<dynamic> route) => false,
            );
          } else if (state is CreateReelErrorStates) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage.toString())),
            );
          }
        },
        builder: (context, state) {
          return ReelUIWidget(
            descriptionController: reelDescriptionController,
            selectedVideo: selectedReelVideo,
            onVideoPick: onVideoPick,
            onReelCreate: () async {
              String reelId = FirebaseFirestore.instance.collection('Reels').doc().id;
              if (userName != null) {
                final videoUrl = await uploadReelVideo(selectedReelVideo!, userName!);

                context.read<CreateReelCubit>().createReel(ReelsModel(
                  reelID: reelId,
                  description: reelDescriptionController.text,
                  profileImage: profileImage,
                  userName: userName!,
                  time: DateTime.now(),
                  video: videoUrl!,
                ));
              }
            },
          );
        },
      ),
    );
  }
}
