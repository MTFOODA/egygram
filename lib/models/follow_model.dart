class FollowsModel {
  String userName;
  String userFollowed;
  bool followed;

  FollowsModel({
    required this.userName,
    required this.userFollowed,
    this.followed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'userFollowed': userFollowed,
      'followed': followed,
    };
  }

  factory FollowsModel.fromMap(Map<String, dynamic> map) {
    return FollowsModel(
      userName: map['userName'],
      userFollowed: map['userFollowed'],
      followed: map['followed'],
    );
  }
}
