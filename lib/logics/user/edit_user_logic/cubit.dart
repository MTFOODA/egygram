import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/user_model.dart';
import 'state.dart';

class EditUserCubit extends Cubit<EditUsersState> {
  EditUserCubit() : super(EditUserInitialState());

  // Edit Users
  Future<void> editUser(String userName, UsersModel updatedUser) async {
    emit(EditUserLoadingState());

    try {
      final userQuery = await FirebaseFirestore.instance
          .collection("Users")
          .where('userName', isEqualTo: userName)
          .get();

      if (userQuery.docs.isEmpty) {
        emit(EditUserErrorState("User not found"));
        return;
      }

      final userDoc = userQuery.docs.first;
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userDoc.id)
          .update(updatedUser.toMap());

      emit(EditUserSuccessState(updatedUser));
    } catch (e) {
      emit(EditUserErrorState(e.toString()));
    }
  }
}
