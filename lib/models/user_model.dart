import '../core/utils/date_parser.dart';

/// Domain model for a user profile.
///
/// Serialized to the `profiles` table using snake_case column names. The app
/// identifies users by [userName] in the UI, while [id] holds the Supabase auth
/// UUID used for Row Level Security ownership checks.
class UsersModel {
  final String? id;
  String userName;
  String? userToken;
  String? bio;
  String? webpage;
  String? profileImage;
  String? email;
  String? phone;
  String? gender;
  int numberOfPosts;
  int numberOfFollowers;
  int numberOfFollowing;
  List<String> listOfReels;
  List<String> listOfTaggedForMe;
  List<String> listOfPosts;
  List<String> listOfVideos;
  DateTime? createdAt;

  UsersModel({
    this.id,
    required this.userName,
    this.userToken,
    this.bio,
    this.webpage,
    this.profileImage,
    this.email,
    this.phone,
    this.gender,
    this.numberOfPosts = 0,
    this.numberOfFollowers = 0,
    this.numberOfFollowing = 0,
    this.listOfReels = const [],
    this.listOfTaggedForMe = const [],
    this.listOfPosts = const [],
    this.listOfVideos = const [],
    this.createdAt,
  });

  /// Builds a model from a Supabase row (snake_case keys).
  factory UsersModel.fromMap(Map<String, dynamic> map) {
    return UsersModel(
      id: map['id'] as String?,
      userName: (map['user_name'] ?? map['userName'] ?? '') as String,
      userToken: map['user_token'] as String?,
      bio: map['bio'] as String?,
      webpage: map['webpage'] as String?,
      profileImage: map['profile_image'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      gender: map['gender'] as String?,
      numberOfPosts: (map['number_of_posts'] ?? 0) as int,
      numberOfFollowers: (map['number_of_followers'] ?? 0) as int,
      numberOfFollowing: (map['number_of_following'] ?? 0) as int,
      listOfReels: _toStringList(map['list_of_reels']),
      listOfTaggedForMe: _toStringList(map['list_of_tagged_for_me']),
      listOfPosts: _toStringList(map['list_of_posts']),
      listOfVideos: _toStringList(map['list_of_videos']),
      createdAt:
          map['created_at'] != null ? parseDate(map['created_at']) : null,
    );
  }

  /// Serializes to a Supabase row. `id`, when present, targets an existing row.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_name': userName,
      'user_token': userToken,
      'bio': bio,
      'webpage': webpage,
      'profile_image': profileImage,
      'email': email,
      'phone': phone,
      'gender': gender,
      'number_of_posts': numberOfPosts,
      'number_of_followers': numberOfFollowers,
      'number_of_following': numberOfFollowing,
      'list_of_reels': listOfReels,
      'list_of_tagged_for_me': listOfTaggedForMe,
      'list_of_posts': listOfPosts,
      'list_of_videos': listOfVideos,
    };
  }

  /// Returns a copy with selected fields replaced (used when editing a profile).
  UsersModel copyWith({
    String? id,
    String? userName,
    String? userToken,
    String? bio,
    String? webpage,
    String? profileImage,
    String? email,
    String? phone,
    String? gender,
    int? numberOfPosts,
    int? numberOfFollowers,
    int? numberOfFollowing,
  }) {
    return UsersModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userToken: userToken ?? this.userToken,
      bio: bio ?? this.bio,
      webpage: webpage ?? this.webpage,
      profileImage: profileImage ?? this.profileImage,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      numberOfPosts: numberOfPosts ?? this.numberOfPosts,
      numberOfFollowers: numberOfFollowers ?? this.numberOfFollowers,
      numberOfFollowing: numberOfFollowing ?? this.numberOfFollowing,
      listOfReels: listOfReels,
      listOfTaggedForMe: listOfTaggedForMe,
      listOfPosts: listOfPosts,
      listOfVideos: listOfVideos,
      createdAt: createdAt,
    );
  }

  static UsersModel defaultUser() {
    return UsersModel(
      userName: 'user',
      profileImage: '',
      numberOfPosts: 0,
      numberOfFollowers: 0,
      numberOfFollowing: 0,
      webpage: '',
      bio: '',
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }
}
