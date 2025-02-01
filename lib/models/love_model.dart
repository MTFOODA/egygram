class LovesModel {
  String userName;
  String postId;
  bool loved;

  LovesModel({
    required this.userName,
    required this.postId,
    this.loved = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'postId': postId,
      'loved': loved,
    };
  }

  factory LovesModel.fromMap(Map<String, dynamic> map) {
    return LovesModel(
      userName: map['userName'],
      postId: map['postId'],
      loved: map['loved'],
    );
  }
}
