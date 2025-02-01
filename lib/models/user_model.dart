import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_application_3/models/post_model.dart';

class UsersModel {
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
  List<String>? listOfReels;
  List<String>? listOfTaggedForMe;
  List<String>? listOfPosts;
  List<String>? listOfVideos;
  List<PostsModel>? listOfPostsSaved;
  List<PostsModel>? listOfPostsLoved;

  UsersModel({
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
    this.listOfReels,
    this.listOfTaggedForMe,
    this.listOfPosts,
    this.listOfVideos,
    List<PostsModel>? listOfPostsLoved = const[],
    List<PostsModel>? listOfPostsSaved = const[],
  });

  Future<void> initializeToken() async {
    userToken = await FirebaseMessaging.instance.getToken();
  }

  factory UsersModel.fromMap(Map<String, dynamic> map) {
    return UsersModel(
      userName: map['userName'],
      userToken: map['userToken'],
      bio: map['bio'],
      webpage: map['webpages'],
      profileImage: map['profileImage'],
      email: map['email'],
      phone: map['phone'],
      gender: map['gender'],
      numberOfPosts: map['numberOfPosts'] ?? 0,
      numberOfFollowers: map['numberOfFollowers'] ?? 0,
      numberOfFollowing: map['numberOfFollowing'] ?? 0,
      listOfReels: List<String>.from(map['listOfReels'] ?? []),
      listOfTaggedForMe: List<String>.from(map['listOfTaggedForMe'] ?? []),
      listOfPosts: List<String>.from(map['listOfPosts'] ?? []),
      listOfVideos: List<String>.from(map['listOfVideos'] ?? []),
      listOfPostsSaved: List<PostsModel>.from(map['listOfPosts'] ?? []),
      listOfPostsLoved: List<PostsModel>.from(map['listOfVideos'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'userToken': userToken,
      'bio': bio,
      'webpages': webpage,
      'profileImage': profileImage,
      'email': email,
      'phone': phone,
      'gender': gender,
      'numberOfPosts': numberOfPosts,
      'numberOfFollowers': numberOfFollowers,
      'numberOfFollowing': numberOfFollowing,
      'listOfReels': listOfReels,
      'listOfTaggedForMe': listOfTaggedForMe,
      'listOfPosts': listOfPosts,
      'listOfVideos': listOfVideos,
      'listOfPostsSaved': listOfPostsSaved,
      'listOfPostsLoved': listOfPostsLoved,
    };
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
}
