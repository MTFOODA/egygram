import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../logics/love/create_love_logic/cubit.dart';
import '../../logics/save/create_save_logic/cubit.dart';
import '../../models/love_model.dart';
import '../../models/save_model.dart';

Future<void> toggleLove({
  required String postID,
  required String currentUser,
  required bool isLoved,
  required int loves,
  required CreateLoveCubit createLoveCubit,
  required CollectionReference collection,
}) async
{
  final updatedLoves = loves;
  final documentRef = collection.doc(postID);

  try {
    final snapshot = await documentRef.get();
    if (snapshot.exists) {
      await documentRef.update({'loves': updatedLoves});
    } else {
      debugPrint('Document not found: $postID');
    }
  } catch (e) {
    debugPrint('Error updating document: $e');
  }

  createLoveCubit.toggleLove(
    LovesModel(
      postId: postID,
      userName: currentUser,
      loved: isLoved,
    ),
  );
}

Future<void> incrementShares({
  required String postID,
  required int shares,
  required CollectionReference collection,
}) async
{
  final updatedShares = shares;
  final documentRef = collection.doc(postID);

  try {
    final snapshot = await documentRef.get();
    if (snapshot.exists) {
      await documentRef.update({'shares': updatedShares});
    } else {
      debugPrint('Document not found: $postID');
    }
  } catch (e) {
    debugPrint('Error updating shares in Fire store: $e');
  }
}

void toggleSave({
  required String postID,
  required String currentUser,
  required bool isSaved,
  required CreateSaveCubit createSaveCubit,
  required CollectionReference collection,
})
{
  createSaveCubit.toggleSave(
    SavesModel(
      postId: postID,
      userName: currentUser,
      saved: isSaved,
    ),
  );
}
