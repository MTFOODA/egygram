import 'package:flutter_application_3/logics/save/get_save_logic/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/save_model.dart';

class GetSaveCubit extends Cubit<GetSavesState> {
  GetSaveCubit() : super(GetSaveInitialState());

  // Fetch all saves for a specific user
  Future<void> getSaves(String userName) async {
    emit(GetSaveLoadingState());
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Saves')
          .where('userName', isEqualTo: userName)
          .get();

      final saves = snapshot.docs
          .map((doc) => SavesModel.fromMap(doc.data()))
          .toList();

      emit(GetSaveSuccessState(saves: saves));
    } catch (e) {
      emit(GetSaveErrorState('Failed to fetch saves: $e'));
    }
  }

  // Check if a specific post is saved by a user
  Future<bool> getSaveStatus(String postId, String userName) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Saves')
          .where('postId', isEqualTo: postId)
          .where('userName', isEqualTo: userName)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception("Failed to fetch save status: $e");
    }
  }
}