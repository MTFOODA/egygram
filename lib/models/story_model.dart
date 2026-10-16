import '../core/utils/date_parser.dart';

/// Domain model for a story, mapped to the `stories` table.
class StoriesModel {
  final String storyID;
  final String? userId;
  final String userName;
  final String? profileImage;
  final DateTime time;
  int loves;
  int comments;
  final String? imageUrls;
  final String type;

  StoriesModel({
    required this.storyID,
    this.userId,
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
      "id": storyID,
      if (userId != null) "user_id": userId,
      "user_name": userName,
      "profile_image": profileImage,
      "loves": loves,
      "comments": comments,
      "image_urls": imageUrls,
      "type": type,
      "created_at": time.toIso8601String(),
    };
  }

  factory StoriesModel.fromMap(Map<String, dynamic> map) {
    return StoriesModel(
      storyID: (map["id"] ?? map["storyID"] ?? "") as String,
      userId: map["user_id"] as String?,
      userName: (map["user_name"] ?? map["userName"] ?? "") as String,
      profileImage:
          (map["profile_image"] ?? map["profileImage"] ?? "") as String?,
      type: (map["type"] ?? "") as String,
      imageUrls: (map["image_urls"] ?? map["imageUrls"] ?? "") as String?,
      loves: (map["loves"] ?? 0) as int,
      comments: (map["comments"] ?? 0) as int,
      time: parseDate(map["created_at"] ?? map["createdAt"]),
    );
  }
}
