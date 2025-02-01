import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/save_model.dart';
import 'state.dart';

class CreateSaveCubit extends Cubit<CreateSaveStates> {
  CreateSaveCubit() : super(CreateSaveInitialStates());

  Future<void> toggleSave(SavesModel saves) async {
    emit(CreateSaveLoadingStates());
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Saves')
          .where('postId', isEqualTo: saves.postId)
          .where('userName', isEqualTo: saves.userName)
          .get();

      if (snapshot.docs.isEmpty) {
        // Add love
        await FirebaseFirestore.instance.collection('Saves').add(saves.toMap());
      } else {
        // Remove love
        await FirebaseFirestore.instance
            .collection('Saves')
            .doc(snapshot.docs.first.id)
            .delete();
      }
      emit(CreateSaveSuccessStates());
    } catch (e) {
      emit(CreateSaveErrorStates(e.toString()));
    }
  }
}
