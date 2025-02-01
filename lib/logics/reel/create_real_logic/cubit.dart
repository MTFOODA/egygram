import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/reel_model.dart';
import 'state.dart';

class CreateReelCubit extends Cubit<CreateReelStates> {
  CreateReelCubit() : super(CreateReelInitialStates());

  // create Post
  Future<void> createReel(ReelsModel reels) async {
    emit(CreateReelLoadingStates());
    try {
      await FirebaseFirestore.instance
          .collection("Reels")
          .doc(reels.reelID)
          .set(reels.toMap());
      emit(CreateReelSuccessStates());
    } catch (e) {
      emit(CreateReelErrorStates(e.toString()));
    }
  }
}
