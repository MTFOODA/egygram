import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/user_model.dart';
import 'state.dart';

class GetUserCubit extends Cubit<GetUsersState> {
  GetUserCubit() : super(GetUserInitialState());

  // Stream subscription to listen for real-time updates
  Stream<List<UsersModel>> getUserStream() {
    return FirebaseFirestore.instance
        .collection("Users")
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UsersModel.fromMap(doc.data()))
        .toList());
  }

  // Subscribe to snapshot changes
  void getUsers() {
    emit(GetUserLoadingState());

    getUserStream().listen(
          (users) {
        emit(GetUserSuccessState(users));
      },
      onError: (error) {
        emit(GetUserErrorState(error.toString()));
      },
    );
  }
}
