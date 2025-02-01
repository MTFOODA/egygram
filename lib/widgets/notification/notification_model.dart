import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final String profilePictureUrl;
  final String message;
  final String time;
  final String? postThumbnailUrl;
  final bool showActionButton;
  final String actionButtonText;
  final bool isComment;

  const NotificationItem({
    super.key,
    required this.profilePictureUrl,
    required this.message,
    required this.time,
    this.postThumbnailUrl,
    this.showActionButton = false,
    this.actionButtonText = "",
    this.isComment = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(profilePictureUrl),
      ),
      title: RichText(
        text: TextSpan(
          text: message,
          style: const TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: " $time",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
      trailing: isComment
          ? const Icon(Icons.comment, color: Colors.grey)
          : showActionButton
              ? TextButton(
                  onPressed: () {},
                  child: Text(actionButtonText),
                )
              : postThumbnailUrl != null
                  ? Image.network(postThumbnailUrl!, width: 50, height: 50)
                  : null,
    );
  }
}
