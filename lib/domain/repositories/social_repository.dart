import '../../models/follow_model.dart';
import '../../models/love_model.dart';
import '../../models/save_model.dart';

/// Social interactions contract: follows, loves (likes) and saves.
///
/// Toggle methods are idempotent: calling them when the relationship already
/// exists removes it, otherwise it is created. Counters on the target content
/// are adjusted server-side via SECURITY DEFINER RPCs so RLS never blocks a
/// user from liking/saving someone else's post.
abstract class SocialRepository {
  // --- Follows ---
  Future<void> toggleFollow(FollowsModel follow);
  Future<List<FollowsModel>> getFollows(String userName);
  Future<bool> getFollowStatus(String userFollowed, String userName);

  // --- Loves (likes) ---
  Future<void> toggleLove(LovesModel love);
  Future<List<LovesModel>> getLoves(String userName);
  Future<bool> getLoveStatus(String postId, String userName);

  // --- Saves ---
  Future<void> toggleSave(SavesModel save);
  Future<List<SavesModel>> getSaves(String userName);
  Future<bool> getSaveStatus(String postId, String userName);
}
