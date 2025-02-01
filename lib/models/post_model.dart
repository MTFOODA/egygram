import 'package:cloud_firestore/cloud_firestore.dart';

class PostsModel {
  final String postID;
  final String userName;
  final String? profileImage;
  final String? description;
  final DateTime time;
  int loves;
  int comments;
  int shares;
  List<String> imageUrls;

  PostsModel({
    required this.postID,
    required this.userName,
    this.profileImage,
    this.description,
    this.loves = 0,
    this.comments = 0,
    this.shares = 0,
    required this.time,
    required this.imageUrls,
  });

  Map<String, dynamic> toMap() {
    return {
      "postID": postID,
      "userName": userName,
      "profileImage": profileImage,
      "imageUrls": imageUrls,
      "description": description,
      "loves": loves,
      "comments": comments,
      "shares": shares,
      "createdAt": time.toIso8601String(),
    };
  }

  factory PostsModel.fromMap(Map<String, dynamic> map) {
    return PostsModel(
      postID: map["postID"],
      userName: map["userName"],
      profileImage: map["profileImage"] ?? "",
      description: map["description"] ?? "",
      loves: map["loves"]?? 0,
      comments: map['comments']?? 0,
      shares: map['shares']?? 0,
      imageUrls: List<String>.from(map["imageUrls"] ?? []),
      time: map["createdAt"] is Timestamp
          ? (map["createdAt"] as Timestamp).toDate()
          : map["createdAt"] != null
          ? DateTime.parse(map["createdAt"])
          : DateTime.now(),
    );
  }
}
