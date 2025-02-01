import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsModel {
  String userName;
  final String? profileImage;
  String postId;
  String content;
  final DateTime time;

  CommentsModel({
    required this.userName,
    this.profileImage,
    required this.postId,
    required this.content,
    required this.time,
  });

  // Convert model to map
  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      "profileImage": profileImage,
      'postId': postId,
      'content': content,
      "createdAt": time.toIso8601String(),
    };
  }

  // Create model from map
  factory CommentsModel.fromMap(Map<String, dynamic> map) {
    return CommentsModel(
      userName: map['userName'],
      profileImage: map["profileImage"] ?? "",
      postId: map['postId'],
      content: map['content'],
      time: map["createdAt"] is Timestamp
          ? (map["createdAt"] as Timestamp).toDate()
          : map["createdAt"] != null
          ? DateTime.parse(map["createdAt"])
          : DateTime.now(),
    );
  }
}
