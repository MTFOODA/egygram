import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_3/logics/story/create_story_logic/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/story_model.dart';

class CreateStoryCubit extends Cubit<CreateStoryStates> {
  CreateStoryCubit() : super(CreateStoryInitialStates());

  // create Story
  Future createStory(StoriesModel stories) async {
    emit(CreateStoryLoadingStates());
    try {
      await FirebaseFirestore.instance
          .collection("Stories")
          .doc(stories.storyID)
          .set(stories.toMap());
      emit(CreateStorySuccessStates());
    } catch (e) {
      emit(CreateStoryErrorStates(e.toString()));
    }
  }
}
