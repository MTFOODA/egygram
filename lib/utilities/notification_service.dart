import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await firebaseMessaging.requestPermission();
    getToken();

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Foreground Notification Received:");
      debugPrint("Title: ${message.notification?.title}");
      debugPrint("Body: ${message.notification?.body}");
    });

    // Handle notification taps when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification opened:");
      debugPrint("Title: ${message.notification?.title}");
      debugPrint("Body: ${message.notification?.body}");
    });
  }

  Future<void> getToken() async {
    try {
      String? token = await firebaseMessaging.getToken();
      if (token != null) {
        debugPrint("FCM Token: $token");
      }
    } catch (e) {
      debugPrint("Error retrieving FCM token: $e");
    }
  }

  Future<void> sendNotification(String token, String body) async {
    //todo find it to be work
    const String serverKey = 'YOUR_SERVER_KEY_HERE'; // Replace with your FCM Server Key.
    const String fcmEndpoint = 'https://fcm.googleapis.com/fcm/send';

    try {
      final message = {
        'to': token,
        'notification': {
          'title': "Egygram",
          'body': body,
        },
        'priority': 'high',
      };

      final response = await http.post(
        Uri.parse(fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        debugPrint("Notification sent successfully: ${response.body}");
      } else {
        debugPrint("Failed to send notification: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error sending notification: $e");
    }
  }
}