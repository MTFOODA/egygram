import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/Story_model.dart';
import '../../utilities/fonts_dart.dart';

class BottomRowWidget extends StatelessWidget {
  final StoriesModel story;
  final String currentUser;
  final bool isDarkMode;
  final bool isLoved;
  final VoidCallback onCommentPressed;
  final VoidCallback onLovePressed;

  const BottomRowWidget({
    super.key,
    required this.story,
    required this.currentUser,
    required this.isDarkMode,
    required this.isLoved,
    required this.onCommentPressed,
    required this.onLovePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.comment),
          onPressed: onCommentPressed,
          iconSize: 25,
        ),
        Text("${story.comments}",
            style: isDarkMode ? AppFonts.textW14bold : AppFonts.textB14bold),
        const Spacer(),
        IconButton(
          icon: FaIcon(
            isLoved ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
            color: isLoved ? Colors.red : Colors.black,
          ),
          onPressed: onLovePressed,
          iconSize: 25,
        ),
        Text("${story.loves}",
            style: isDarkMode ? AppFonts.textW14bold : AppFonts.textB14bold),
      ],
    );
  }
}