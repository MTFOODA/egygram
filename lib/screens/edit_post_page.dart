import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/post_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../logics/post/edit_post_logic/cubit.dart';
import '../logics/post/edit_post_logic/state.dart';
import '../utilities/fonts_dart.dart';
import '../utilities/theme_provider.dart';
import 'navigation_screen.dart';

class EditPostPage extends StatefulWidget {
  final PostsModel postModel;

  const EditPostPage({super.key, required this.postModel});

  @override
  State<EditPostPage> createState() => EditPostPageState();
}

class EditPostPageState extends State<EditPostPage> {
  late TextEditingController descriptionController;
  late List<String> currentImageUrls;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController(text: widget.postModel.description);
    currentImageUrls = widget.postModel.imageUrls.isNotEmpty ? List.from(widget.postModel.imageUrls) : [];
  }

  Future<void> selectPostImages() async {
    final picker = ImagePicker();
    try {
      final pickedMedia = await picker.pickMultipleMedia();
      if (pickedMedia.isNotEmpty) {
        List<String> uploadedUrls = await uploadPostImages(pickedMedia, widget.postModel.userName);
        setState(() {
          currentImageUrls.addAll(uploadedUrls);
        });
      }
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

  void removeImage(String imageUrl) {
    setState(() {
      currentImageUrls.remove(imageUrl);
    });
  }

  void editPost(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final updatedPost = PostsModel(
      postID: widget.postModel.postID,
      profileImage: widget.postModel.profileImage,
      userName: widget.postModel.userName,
      time: widget.postModel.time,
      description: descriptionController.text,
      imageUrls: currentImageUrls.isNotEmpty ? currentImageUrls : widget.postModel.imageUrls,
    );

    await BlocProvider.of<EditPostCubit>(context).editPost(widget.postModel.postID, updatedPost);

    final state = BlocProvider.of<EditPostCubit>(context).state;

    setState(() {
      isLoading = false;
    });

    if (state is EditPostSuccessState) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated successfully')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationScreen(
            initialIndex: 0,
            userName: widget.postModel.userName,
          ),
        ),
            (Route<dynamic> route) => false,
      );
    } else if (state is EditPostErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Edit Post'.tr(), style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
        actions: [
          TextButton(
            onPressed: () => editPost(context),
            child: Text(
              'Done'.tr(),
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 300.0),
                  child: Container(
                    color: Colors.grey.shade200,
                    child: Lottie.asset(
                      'assets/lottie/load2.json',
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
              ),
            if (!isLoading) ...[
              if (currentImageUrls.isNotEmpty)
                Column(
                  children: [
                    // Display multiple images in a scrollable view
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: currentImageUrls.length,
                        itemBuilder: (context, index) {
                          String imageUrl = currentImageUrls[index];
                          return Stack(
                            children: [
                              Image.network(
                                imageUrl,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => removeImage(imageUrl),
                                  child: const CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.delete, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectPostImages,
                child: Text('Add Images'.tr()),  // Changed the text to reflect multiple images
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
