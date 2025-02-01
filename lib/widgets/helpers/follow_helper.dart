import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../logics/follow/create_follow_logic/cubit.dart';
import '../../models/follow_model.dart';

Future<void> toggleFollow({
  required String userFollowed,
  required String currentUser,
  required bool isFollowed,
  required int follows,
  required CreateFollowCubit createFollowCubit,
  required CollectionReference collection,
}) async
{

  try {
    final snapshotUserFollowed = await collection.doc(userFollowed).get();
    final snapshotCurrentUser = await collection.doc(currentUser).get();
    if (snapshotUserFollowed.exists && snapshotCurrentUser.exists) {
      await collection.doc(userFollowed).update({'numberOfFollowers': follows});
      await collection.doc(currentUser).update({'numberOfFollowing': follows});
    } else {
      debugPrint('Document not found user Followed: $userFollowed');
      debugPrint('Document not found current User: $currentUser');
    }
  } catch (e) {
    debugPrint('Error updating document: $e');
  }

  createFollowCubit.toggleFollow(
    FollowsModel(
      userFollowed: userFollowed,
      userName: currentUser,
      followed: isFollowed,
    ),
  );
}
