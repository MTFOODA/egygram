import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/user_model.dart';
import 'state.dart';

class CreateUserCubit extends Cubit<CreateUserStates> {
  CreateUserCubit() : super(CreateUserInitialStates());

  // create User
  Future createUser(UsersModel users) async {
    emit(CreateUserLoadingStates());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(users.userName)
            .set(users.toMap());
        emit(CreateUserSuccessStates());
      } else {
        emit(CreateUserErrorStates("User is not authenticated."));
      }
    } catch (e) {
      emit(CreateUserErrorStates(e.toString()));
    }
  }

}
