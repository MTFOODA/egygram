import '../core/utils/date_parser.dart';

/// Domain model for a post, mapped to the `posts` table.
class PostsModel {
  final String postID;
  final String? userId;
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
    this.userId,
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
      "id": postID,
      if (userId != null) "user_id": userId,
      "user_name": userName,
      "profile_image": profileImage,
      "image_urls": imageUrls,
      "description": description,
      "loves": loves,
      "comments": comments,
      "shares": shares,
      "created_at": time.toIso8601String(),
    };
  }

  factory PostsModel.fromMap(Map<String, dynamic> map) {
    return PostsModel(
      postID: (map["id"] ?? map["postID"] ?? '') as String,
      userId: map["user_id"] as String?,
      userName: (map["user_name"] ?? map["userName"] ?? '') as String,
      profileImage:
          (map["profile_image"] ?? map["profileImage"] ?? "") as String?,
      description: (map["description"] ?? "") as String?,
      loves: (map["loves"] ?? 0) as int,
      comments: (map["comments"] ?? 0) as int,
      shares: (map["shares"] ?? 0) as int,
      imageUrls: _toStringList(map["image_urls"] ?? map["imageUrls"]),
      time: parseDate(map["created_at"] ?? map["createdAt"]),
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}
