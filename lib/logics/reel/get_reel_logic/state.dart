import 'package:flutter_application_3/models/reel_model.dart';

abstract class GetReelsState {}

class GetReelInitialState extends GetReelsState {}

class GetReelLoadingState extends GetReelsState {}

class GetReelSuccessState extends GetReelsState {
  final List<ReelsModel> reels;
  GetReelSuccessState(this.reels);
}

class GetReelErrorState extends GetReelsState {
  final String errorMessage;
  GetReelErrorState(this.errorMessage);
}
