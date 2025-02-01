import 'package:cloud_firestore/cloud_firestore.dart';

class StoriesModel {
  final String storyID;
  final String userName;
  final String? profileImage;
  final DateTime? time;
  int loves;
  int comments;
  final String? imageUrls;
  final String type;


  StoriesModel({
    required this.storyID,
    required this.userName,
    this.profileImage,
    this.loves = 0,
    this.comments = 0,
    required this.time,
    this.imageUrls,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      "storyID": storyID,
      "userName": userName,
      "profileImage": profileImage,
      "loves": loves,
      "comments": comments,
      "imageUrls": imageUrls,
      "type": type,
      "createdAt": time?.toIso8601String(),
    };
  }

  factory StoriesModel.fromMap(Map<String, dynamic> map) {
    return StoriesModel(
      storyID: map["storyID"] ?? "",
      userName: map["userName"] ?? "",
      profileImage: map["profileImage"] ?? "",
      type: map["type"] ?? "",
      imageUrls: map["imageUrls"] ?? "",
      loves: map["loves"]?? 0,
      comments: map['comments']?? 0,
      time: map["createdAt"] is Timestamp
          ? (map["createdAt"] as Timestamp).toDate()
          : map["createdAt"] != null
          ? DateTime.parse(map["createdAt"])
          : DateTime.now(),
    );
  }
}
