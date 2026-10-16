import 'package:flutter/cupertino.dart';
import '../../logics/follow/create_follow_logic/cubit.dart';
import '../../models/follow_model.dart';

/// Toggles the follow relationship.
///
/// Follower/following counters on both profiles are adjusted server-side by
/// the repository (SECURITY DEFINER RPC), so no direct profile writes happen
/// here — that previously conflicted with row-level security.
Future<void> toggleFollow({
  required String userFollowed,
  required String currentUser,
  required bool isFollowed,
  int follows = 0,
  required CreateFollowCubit createFollowCubit,
}) async {
  try {
    await createFollowCubit.toggleFollow(
      FollowsModel(
        userFollowed: userFollowed,
        userName: currentUser,
        followed: isFollowed,
      ),
    );
  } catch (e) {
    debugPrint('Error toggling follow: $e');
  }
}
