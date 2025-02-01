import 'package:flutter/material.dart';
import '../utilities/notification_service.dart';

class NotificationTest extends StatefulWidget {
  const NotificationTest({super.key});

  @override
  State<NotificationTest> createState() => NotificationTestState();
}

class NotificationTestState extends State<NotificationTest> {
  final NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    notificationService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Egygram Notification Test"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                notificationService.sendNotification(
                  "TOKEN_1",
                  "Message Body for Notification 1",
                );
              },
              child: const Text("Send Notification 1"),
            ),
            ElevatedButton(
              onPressed: () {
                notificationService.sendNotification(
                  "TOKEN_2",
                  "Message Body for Notification 2",
                );
              },
              child: const Text("Send Notification 2"),
            ),
            ElevatedButton(
              onPressed: () {
                notificationService.sendNotification(
                  "TOKEN_3",
                  "Message Body for Notification 3",
                );
              },
              child: const Text("Send Notification 3"),
            ),
          ],
        ),
      ),
    );
  }
}
