import '../../../models/reel_model.dart';

abstract class EditReelsState {}

class EditReelInitialState extends EditReelsState {}

class EditReelLoadingState extends EditReelsState {}

class EditReelSuccessState extends EditReelsState {
  final ReelsModel updatedReel;
  EditReelSuccessState(this.updatedReel);
}

class EditReelErrorState extends EditReelsState {
  final String errorMessage;
  EditReelErrorState(this.errorMessage);
}
