import '../core/utils/date_parser.dart';

/// Domain model for a reel (short video), mapped to the `reels` table.
class ReelsModel {
  final String reelID;
  final String? userId;
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
    this.userId,
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
      "id": reelID,
      if (userId != null) "user_id": userId,
      "user_name": userName,
      "profile_image": profileImage,
      "video": video,
      "description": description,
      "loves": loves,
      "comments": comments,
      "shares": shares,
      "created_at": time.toIso8601String(),
    };
  }

  factory ReelsModel.fromMap(Map<String, dynamic> map) {
    return ReelsModel(
      reelID: (map["id"] ?? map["reelID"] ?? "") as String,
      userId: map["user_id"] as String?,
      userName: (map["user_name"] ?? map["userName"] ?? "") as String,
      description: (map["description"] ?? "") as String?,
      profileImage:
          (map["profile_image"] ?? map["profileImage"] ?? "") as String?,
      loves: (map["loves"] ?? 0) as int,
      comments: (map["comments"] ?? 0) as int,
      shares: (map["shares"] ?? 0) as int,
      video: (map["video"] ?? "") as String,
      time: parseDate(map["created_at"] ?? map["createdAt"]),
    );
  }
}
