import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/Story_model.dart';
import '../../utilities/fonts_dart.dart';

class TopRowWidget extends StatelessWidget {
  final StoriesModel story;
  final String currentUser;
  final bool isDarkMode;
  final VoidCallback onDelete;

  const TopRowWidget({
    super.key,
    required this.story,
    required this.currentUser,
    required this.isDarkMode,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 20.0,
            backgroundImage: story.profileImage!.isNotEmpty
                ? NetworkImage(story.profileImage!)
                : const AssetImage('assets/images/profile_picture.jpg') as ImageProvider,
            backgroundColor: const Color(0xFFFFF4F4),
          ),
          const SizedBox(width: 10),
          Text(story.userName,
              style: isDarkMode ? AppFonts.textW24bold : AppFonts.textB24bold),
          const SizedBox(width: 10),
          Text(
              "${story.time!.hour}:"
                  "${story.time!.minute.toString().padLeft(2, '0')}"
                  "${story.time!.hour >= 12 ? " PM" : " AM"}",
              style: isDarkMode ? AppFonts.textW11bold : AppFonts.textB11bold),
          const Spacer(),
          if (currentUser == story.userName)
            PopupMenuButton<String>(
              icon: const FaIcon(FontAwesomeIcons.ellipsis),
              iconSize: 25,
              onSelected: (String? value) async {
                if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Delete Post".tr()),
                      content: Text("Are you sure you want to delete this story ?".tr()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text("Cancel".tr()),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text("Delete".tr()),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    onDelete();
                  }
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete'.tr(),
                      style: isDarkMode ? AppFonts.textW14bold : AppFonts.textB14bold),
                ),
              ],
            ),
        ],
      ),
    );
  }
}