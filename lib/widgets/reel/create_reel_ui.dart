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

class ReelUIWidget extends StatefulWidget {
  final TextEditingController descriptionController;
  final XFile? selectedVideo;
  final VoidCallback onVideoPick;
  final Future<void> Function() onReelCreate;

  const ReelUIWidget({
    required this.descriptionController,
    required this.selectedVideo,
    required this.onVideoPick,
    required this.onReelCreate,
    super.key,
  });

  @override
  ReelUIWidgetState createState() => ReelUIWidgetState();
}

class ReelUIWidgetState extends State<ReelUIWidget> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text("Create New Reel".tr(), style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: widget.onVideoPick,
                child: Text('Select Video'.tr()),
              ),
              if (widget.selectedVideo != null)
                Text("${"Video Selected:".tr()} + ${widget.selectedVideo!.name}",
                ),
              const SizedBox(height: 10),
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    TextFormField(
                      style: AppFonts.textB24bold,
                      controller: widget.descriptionController,
                      maxLines: 3,
                      decoration: emailInputDecoration(
                        context,
                        'Description'.tr(),
                        const Icon(CupertinoIcons.pencil),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  if (widget.selectedVideo == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select a video'.tr())),
                    );
                  } else {
                    setState(() {
                      isLoading = true;
                    });
                    await widget.onReelCreate();
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
                color:  AppColors.lightGrey,
                child: Lottie.asset(
                  'assets/lottie/load1.json', // Path to your Lottie file
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
