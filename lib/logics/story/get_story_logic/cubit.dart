import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_3/logics/story/get_story_logic/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/Story_model.dart';

class GetStoryCubit extends Cubit<GetStoriesState> {
  GetStoryCubit() : super(GetStoryInitialState());

  // Stream subscription to listen for real-time updates
  Stream<List<StoriesModel>> _getStoryStream() {
    return FirebaseFirestore.instance
        .collection("Stories")
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => StoriesModel.fromMap(doc.data()))
        .toList());
  }

  // Subscribe to snapshot changes
  void subscribeToStories() {
    emit(GetStoryLoadingState());

    _getStoryStream().listen(
          (stories) {
        emit(GetStorySuccessState(stories));
      },
      onError: (error) {
        emit(GetStoryErrorState(error.toString()));
      },
    );
  }
}
