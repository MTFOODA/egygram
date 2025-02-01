import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/reel_model.dart';
import 'state.dart';

class EditReelCubit extends Cubit<EditReelsState> {
  EditReelCubit() : super(EditReelInitialState());

  // Edit Reels
  Future<void> editReel(String reelID, ReelsModel updatedReel) async {
    emit(EditReelLoadingState());

    try {
      final reelDoc = await FirebaseFirestore.instance
          .collection("Reels")
          .doc(reelID)
          .get();

      if (!reelDoc.exists) {
        emit(EditReelErrorState("Reel not found"));
        return;
      }

      await FirebaseFirestore.instance
          .collection("Reels")
          .doc(reelID)
          .update(updatedReel.toMap());

      emit(EditReelSuccessState(updatedReel));
    } catch (e) {
      emit(EditReelErrorState(e.toString()));
    }
  }
}
