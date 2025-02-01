import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/love_model.dart';
import 'state.dart';

class CreateLoveCubit extends Cubit<CreateLoveStates> {
  CreateLoveCubit() : super(CreateLoveInitialStates());

  Future<void> toggleLove(LovesModel loves) async {
    emit(CreateLoveLoadingStates());
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Loves')
          .where('postId', isEqualTo: loves.postId)
          .where('userName', isEqualTo: loves.userName)
          .get();

      if (snapshot.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('Loves').add(loves.toMap());
      } else {
        await FirebaseFirestore.instance
            .collection('Loves')
            .doc(snapshot.docs.first.id)
            .delete();
      }
      emit(CreateLoveSuccessStates());
    } catch (e) {
      emit(CreateLoveErrorStates(e.toString()));
    }
  }
}
