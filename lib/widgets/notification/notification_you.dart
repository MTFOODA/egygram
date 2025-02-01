import 'package:flutter/material.dart';
import 'notification_model.dart';
import 'notification_section.dart';

class NotificationYouScreen extends StatelessWidget {
  const NotificationYouScreen({super.key});

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
          const NotificationSection(
            title: "Today",
            items: [
              NotificationItem(
                profilePictureUrl: "https://via.placeholder.com/50",
                message: "kiero_d, zackjohn and 26 others liked your photo.",
                time: "3h",
                postThumbnailUrl: "https://via.placeholder.com/50",
              ),
            ],
          ),
          const NotificationSection(
            title: "This Week",
            items: [
              NotificationItem(
                profilePictureUrl: "https://via.placeholder.com/50",
                message:
                    "craig_love mentioned you in a comment: @jacob_w exactly..",
                time: "2d",
                postThumbnailUrl: "https://via.placeholder.com/50",
                isComment: true,
              ),
              NotificationItem(
                profilePictureUrl: "https://via.placeholder.com/50",
                message: "martini_rond started following you.",
                time: "3d",
                showActionButton: true,
                actionButtonText: "Message",
              ),
              NotificationItem(
                profilePictureUrl: "https://via.placeholder.com/50",
                message: "maxjacobson started following you.",
                time: "3d",
                showActionButton: true,
                actionButtonText: "Message",
              ),
              NotificationItem(
                profilePictureUrl: "https://via.placeholder.com/50",
                message: "mis_potter started following you.",
                time: "3d",
                showActionButton: true,
                actionButtonText: "Follow",
              ),
            ],
          ),
          const NotificationSection(
            title: "This Month",
            items: [
              NotificationItem(
                profilePictureUrl: "https://via.placeholder.com/50",
                message:
                    "craig_love mentioned you in a comment: @jacob_w exactly..",
                time: "2m",
                postThumbnailUrl: "https://via.placeholder.com/50",
                isComment: true,
              ),
              NotificationItem(
                profilePictureUrl: "https://via.placeholder.com/50",
                message: "martini_rond started following you.",
                time: "3m",
                showActionButton: true,
                actionButtonText: "Message",
              ),
              NotificationItem(
                profilePictureUrl: "https://via.placeholder.com/50",
                message: "maxjacobson started following you.",
                time: "3m",
                showActionButton: true,
                actionButtonText: "Message",
              ),
              NotificationItem(
                profilePictureUrl: "https://via.placeholder.com/50",
                message: "mis_potter started following you.",
                time: "3m",
                showActionButton: true,
                actionButtonText: "Follow",
              ),
            ],
          ),
          const NotificationSection(
            title: "This Year",
            items: [
              NotificationItem(
                profilePictureUrl: "https://via.placeholder.com/50",
                message:
                    "craig_love mentioned you in a comment: @jacob_w exactly..",
                time: "2m",
                postThumbnailUrl: "https://via.placeholder.com/50",
                isComment: true,
              ),
              NotificationItem(
                profilePictureUrl: "https://via.placeholder.com/50",
                message: "martini_rond started following you.",
                time: "3m",
                showActionButton: true,
                actionButtonText: "Message",
              ),
              NotificationItem(
                profilePictureUrl: "https://via.placeholder.com/50",
                message: "maxjacobson started following you.",
                time: "3m",
                showActionButton: true,
                actionButtonText: "Message",
              ),
              NotificationItem(
                profilePictureUrl: "https://via.placeholder.com/50",
                message: "mis_potter started following you.",
                time: "3m",
                showActionButton: true,
                actionButtonText: "Follow",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
