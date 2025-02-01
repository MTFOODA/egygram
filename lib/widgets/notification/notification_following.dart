import 'package:flutter/material.dart';
import 'notification_model.dart';
import 'notification_section.dart';

class NotificationFollowingScreen extends StatelessWidget {
  const NotificationFollowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: const Text(
              "Follow Requests",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // todo: Navigate to follow requests page
            },
          ),
          const Divider(),
          const NotificationSection(
            title: "New",
            items: [
              NotificationItem(
                profilePictureUrl: "https://via.placeholder.com/50",
                message: "karenne liked your photo.",
                time: "1h",
                postThumbnailUrl: "https://via.placeholder.com/50",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
