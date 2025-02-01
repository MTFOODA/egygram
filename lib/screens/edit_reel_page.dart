import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lottie/lottie.dart'; // Import Lottie
import 'dart:io';

import '../../../models/reel_model.dart';
import '../logics/reel/edit_reel_logic/cubit.dart';
import '../logics/reel/edit_reel_logic/state.dart';
import '../utilities/colors_dart.dart';

class EditReelPage extends StatefulWidget {
  final ReelsModel reelModel;

  const EditReelPage({super.key, required this.reelModel});

  @override
  State<EditReelPage> createState() => EditReelPageState();
}

class EditReelPageState extends State<EditReelPage> {
  late TextEditingController descriptionController;
  late VideoPlayerController videoController;
  File? newVideoFile;
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController(text: widget.reelModel.description);
    videoController = VideoPlayerController.networkUrl(Uri.parse(widget.reelModel.video))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    descriptionController.dispose();
    videoController.dispose();
    super.dispose();
  }

  Future<void> pickVideo() async {
    final XFile? videoFile = await picker.pickVideo(source: ImageSource.gallery);
    if (videoFile != null) {
      setState(() {
        newVideoFile = File(videoFile.path);
        videoController = VideoPlayerController.file(newVideoFile!)
          ..initialize().then((_) {
            setState(() {});
          });
      });
    }
  }

  Future<String?> _uploadVideo(File videoFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('reels/${DateTime.now().millisecondsSinceEpoch}.mp4');
      await storageRef.putFile(videoFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload video: $e")),
      );
      return null;
    }
  }

  Future<void> saveChanges() async {
    final updatedReel = ReelsModel(
      reelID: widget.reelModel.reelID,
      userName: widget.reelModel.userName,
      profileImage: widget.reelModel.profileImage,
      video: widget.reelModel.video,
      description: descriptionController.text,
      time: widget.reelModel.time,
      loves: widget.reelModel.loves,
      comments: widget.reelModel.comments,
      shares: widget.reelModel.shares,
    );

    if (newVideoFile != null) {
      final videoUrl = await _uploadVideo(newVideoFile!);
      if (videoUrl != null) {
        updatedReel.video = videoUrl;
      } else {
        return;
      }
    }
    context.read<EditReelCubit>().editReel(widget.reelModel.reelID, updatedReel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Reel"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              setState(() {
                isLoading = true;
              });

              await saveChanges();

              setState(() {
                isLoading = false;
              });

              if (!mounted) return;
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView( // Wrap the entire body in a SingleChildScrollView
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (videoController.value.isInitialized)
                    AspectRatio(
                      aspectRatio: videoController.value.aspectRatio,
                      child: VideoPlayer(videoController),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: pickVideo,
                    child: const Text("Replace Video"),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  BlocConsumer<EditReelCubit, EditReelsState>(
                    listener: (context, state) {
                      if (state is EditReelSuccessState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Reel updated successfully!")),
                        );
                      } else if (state is EditReelErrorState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.errorMessage)),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is EditReelLoadingState) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            if (isLoading) // Show loading indicator if isLoading is true
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 300.0),
                  child: Container(
                    color: AppColors.lightGrey,
                    child: Lottie.asset(
                      'assets/lottie/load2.json', // Path to your Lottie file
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}