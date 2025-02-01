class SavesModel {
  String userName;
  String postId;
  bool saved;

  SavesModel({
    required this.userName,
    required this.postId,
    this.saved = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'postId': postId,
      'saved': saved,
    };
  }

  factory SavesModel.fromMap(Map<String, dynamic> map) {
    return SavesModel(
      userName: map['userName'],
      postId: map['postId'],
      saved: map['saved'],
    );
  }
}
