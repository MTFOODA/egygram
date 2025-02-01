import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/utilities/colors_dart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../utilities/decoration.dart';
import '../../utilities/fonts_dart.dart';
import '../../utilities/theme_provider.dart';
import 'package:video_player/video_player.dart';

class StoryUIWidget extends StatefulWidget {
  final List<XFile> selectedMedias;
  final VoidCallback onMediaPick;
  final Future<void> Function() onStoryCreate;
  final Future<List<String>> Function(List<XFile>) uploadStoryMedias;

  const StoryUIWidget({
    required this.selectedMedias,
    required this.onMediaPick,
    required this.onStoryCreate,
    required this.uploadStoryMedias,
    super.key,
  });

  @override
  StoryUIWidgetState createState() => StoryUIWidgetState();
}

class StoryUIWidgetState extends State<StoryUIWidget> {
  bool isLoading = false;
  VideoPlayerController? videoController;

  @override
  void initState() {
    super.initState();
    initializeVideoController();
  }

  void initializeVideoController() {
    if (widget.selectedMedias.isNotEmpty) {
      final file = File(widget.selectedMedias.first.path);
      if (file.path.endsWith('.mp4') || file.path.endsWith('.mov')) {
        videoController = VideoPlayerController.file(file)
          ..initialize().then((_) {
            setState(() {});
          });
      }
    }
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  Widget buildMediaPreview() {
    if (widget.selectedMedias.isEmpty) {
      return const SizedBox.shrink();
    }

    final file = File(widget.selectedMedias.first.path);
    if (file.path.endsWith('.mp4') || file.path.endsWith('.mov')) {
      // Video preview
      if (videoController == null || !videoController!.value.isInitialized) {
        return const Center(child: CircularProgressIndicator());
      }
      return AspectRatio(
        aspectRatio: videoController!.value.aspectRatio,
        child: VideoPlayer(videoController!),
      );
    } else {
      // Image preview
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.selectedMedias.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(widget.selectedMedias[index].path),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text("Create New Story".tr(), style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
              const SizedBox(height: 20),
              IconButton(
                icon: const Icon(Icons.add_photo_alternate_outlined),
                iconSize: 50,
                tooltip: 'Add Medias'.tr(),
                onPressed: widget.onMediaPick,
              ),
              if (widget.selectedMedias.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  child: buildMediaPreview(),
                ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  if (widget.selectedMedias.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select Medias'.tr())),
                    );
                  } else {
                    setState(() {
                      isLoading = true;
                    });
                    await widget.onStoryCreate();
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                child: Container(
                  width: 150,
                  height: 50,
                  decoration: customContainerDecoration(),
                  child: Center(
                    child: Text("Create".tr(), style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 300.0),
              child: Container(
                color: AppColors.lightGrey,
                child: Lottie.asset(
                  'assets/lottie/load.json', // Path to your Lottie file
                  width: 150,
                  height: 150,
                ),
              ),
            ),
          ),
      ],
    );
  }
}