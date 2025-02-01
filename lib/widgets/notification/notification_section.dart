import 'package:flutter/material.dart';
import 'notification_model.dart';

class NotificationSection extends StatelessWidget {
  final String title;
  final List<NotificationItem> items;

  const NotificationSection(
      {super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Column(children: items),
      ],
    );
  }
}
