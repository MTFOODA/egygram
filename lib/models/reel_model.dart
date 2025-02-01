import 'package:cloud_firestore/cloud_firestore.dart';

class ReelsModel {
  final String reelID;
  final String userName;
  final String? profileImage;
  final String? description;
  final DateTime time;
  int loves;
  int comments;
  int shares;
  String video;

  ReelsModel({
    required this.reelID,
    required this.userName,
    this.profileImage,
    this.description,
    this.loves = 0,
    this.comments = 0,
    this.shares = 0,
    required this.time,
    required this.video,
  });

  Map<String, dynamic> toMap() {
    return {
      "reelID": reelID,
      "userName": userName,
      "profileImage": profileImage,
      "video": video,
      "description": description,
      "loves": loves,
      "comments": comments,
      "shares": shares,
      "createdAt": time.toIso8601String(),
    };
  }

  factory ReelsModel.fromMap(Map<String, dynamic> map) {
    return ReelsModel(
      reelID: map["reelID"] ?? "",
      userName: map["userName"] ?? "",
      description: map["description"] ?? "",
      profileImage: map["profileImage"] ?? "",
      loves: map["loves"]?? 0,
      comments: map['comments']?? 0,
      shares: map['shares']?? 0,
      video: map["video"] ?? "",
      time: map["createdAt"] is Timestamp
          ? (map["createdAt"] as Timestamp).toDate()
          : map["createdAt"] != null
          ? DateTime.parse(map["createdAt"])
          : DateTime.now(),
    );
  }
}
