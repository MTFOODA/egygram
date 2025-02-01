import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../utilities/colors_dart.dart';
import '../../utilities/decoration.dart';
import '../../utilities/fonts_dart.dart';
import '../../utilities/theme_provider.dart';

class PostUIWidget extends StatefulWidget {
  final TextEditingController descriptionController;
  final List<XFile> selectedImages;
  final Future<void> Function() onPostCreate;
  final VoidCallback onImagePick;
  final Future<List<String>> Function(List<XFile>) uploadPostImages;

  const PostUIWidget({
    super.key,
    required this.descriptionController,
    required this.onPostCreate,
    required this.selectedImages,
    required this.uploadPostImages,
    required this.onImagePick,
  });

  @override
  PostUIWidgetState createState() => PostUIWidgetState();
}

class PostUIWidgetState extends State<PostUIWidget> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Create New Post".tr(), style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  iconSize: 50,
                  tooltip: 'Add Images'.tr(),
                  onPressed: widget.onImagePick,
                ),
                if (widget.selectedImages.isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey, width: 2),
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(widget.selectedImages[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        style: AppFonts.textB24bold,
                        controller: widget.descriptionController,
                        maxLines: 2,
                        decoration: emailInputDecoration(
                          context,
                          'Description'.tr(),
                          const Icon(CupertinoIcons.pencil),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    if (widget.selectedImages.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select images'.tr())),
                      );
                    } else {
                      setState(() {
                        isLoading = true;
                      });
                      await widget.onPostCreate();
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
        ),
        if (isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 300.0),
              child: Container(
                color:  AppColors.lightGrey,
                child: Lottie.asset(
                  'assets/lottie/load2.json', // Path to your Lottie file
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
