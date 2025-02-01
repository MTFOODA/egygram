import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> deleteOldStories(BuildContext context) async {
  try {
    DateTime now = DateTime.now();

    DateTime fiveMinutesAgo = now.subtract(const Duration(minutes: 50));

    String fiveMinutesAgoString = fiveMinutesAgo.toIso8601String();

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Stories')
        .where('createdAt', isLessThan: fiveMinutesAgoString)
        .get();

    for (var doc in snapshot.docs) {
      await FirebaseFirestore.instance.collection('Stories').doc(doc.id).delete();
    }

    if (snapshot.docs.isNotEmpty) {
      debugPrint("Stories older than 10 minutes have been deleted.");
    } else {
      debugPrint("No stories to delete.");
    }
  } catch (e) {
    // Show an error message if something went wrong
    debugPrint("Error deleting stories: $e");
  }
}