import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/follow_model.dart';
import 'state.dart';

class GetFollowCubit extends Cubit<GetFollowsState> {
  GetFollowCubit() : super(GetFollowInitialState());

  // Fetch all Follows for a specific user
  Future<void> getFollows(String userName) async {
    emit(GetFollowLoadingState());
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Follows')
          .where('userName', isEqualTo: userName)
          .get();

      final follows = snapshot.docs
          .map((doc) => FollowsModel.fromMap(doc.data()))
          .toList();

      emit(GetFollowSuccessState(follows: follows));
    } catch (e) {
      emit(GetFollowErrorState('Failed to fetch Follows: $e'));
    }
  }

  Future<bool> getFollowStatus(String userFollowed, String userName) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Follows')
          .where('userFollowed', isEqualTo: userFollowed)
          .where('userName', isEqualTo: userName)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception("Failed to fetch Follow status: $e");
    }
  }
}
