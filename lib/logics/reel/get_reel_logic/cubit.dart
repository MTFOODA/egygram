import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/reel_model.dart';
import 'state.dart';

class GetReelCubit extends Cubit<GetReelsState> {
  GetReelCubit() : super(GetReelInitialState());

  // Stream subscription to listen for real-time updates
  Stream<List<ReelsModel>> getReelStream() {
    return FirebaseFirestore.instance
        .collection("Reels")
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ReelsModel.fromMap(doc.data()))
        .toList());
  }

  // Subscribe to snapshot changes
  void subscribeToReels() {
    emit(GetReelLoadingState());

    getReelStream().listen(
          (reels) {
        emit(GetReelSuccessState(reels));
      },
      onError: (error) {
        emit(GetReelErrorState(error.toString()));
      },
    );
  }
}
