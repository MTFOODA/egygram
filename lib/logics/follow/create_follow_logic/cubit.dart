import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/follow_model.dart';
import 'state.dart';

class CreateFollowCubit extends Cubit<CreateFollowStates> {
  CreateFollowCubit() : super(CreateFollowInitialStates());

  Future<void> toggleFollow(FollowsModel follows) async {
    emit(CreateFollowLoadingStates());
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Follows')
          .where('userFollowed', isEqualTo: follows.userFollowed)
          .where('userName', isEqualTo: follows.userName)
          .get();

      if (snapshot.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('Follows').add(follows.toMap());
      } else {
        await FirebaseFirestore.instance
            .collection('Follows')
            .doc(snapshot.docs.first.id)
            .delete();
      }
      emit(CreateFollowSuccessStates());
    } catch (e) {
      emit(CreateFollowErrorStates(e.toString()));
    }
  }
}
