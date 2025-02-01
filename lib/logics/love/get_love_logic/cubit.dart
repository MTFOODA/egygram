import 'package:flutter_application_3/logics/love/get_love_logic/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/love_model.dart';

class GetLoveCubit extends Cubit<GetLovesState> {
  GetLoveCubit() : super(GetLoveInitialState());

  // Fetch all Loves for a specific user
  Future<void> getLoves(String userName) async {
    emit(GetLoveLoadingState());
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Loves')
          .where('userName', isEqualTo: userName)
          .get();

      final loves = snapshot.docs
          .map((doc) => LovesModel.fromMap(doc.data()))
          .toList();

      emit(GetLoveSuccessState(loves: loves));
    } catch (e) {
      emit(GetLoveErrorState('Failed to fetch Loves: $e'));
    }
  }

  Future<bool> getLoveStatus(String postId, String userName) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Loves')
          .where('postId', isEqualTo: postId)
          .where('userName', isEqualTo: userName)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception("Failed to fetch love status: $e");
    }
  }
}
