import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../logics/love/create_love_logic/cubit.dart';
import '../../../logics/save/create_save_logic/cubit.dart';
import '../../../models/love_model.dart';
import '../../../models/save_model.dart';

/// Like / save / share helpers.
///
/// Counters on the target post are adjusted server-side (SECURITY DEFINER RPC)
/// by the repositories, so these helpers only trigger the relationship toggle
/// or the share counter increment.
Future<void> toggleLove({
  required String postID,
  required String currentUser,
  required bool isLoved,
  required CreateLoveCubit createLoveCubit,
}) async {
  await createLoveCubit.toggleLove(
    LovesModel(
      postId: postID,
      userName: currentUser,
      loved: isLoved,
    ),
  );
}

Future<void> incrementShares({
  required String postID,
}) async {
  try {
    await sl.postRepository.adjustCounter(
      postId: postID,
      column: 'shares',
      delta: 1,
    );
  } catch (e) {
    friendlyError(e);
  }
}

void toggleSave({
  required String postID,
  required String currentUser,
  required bool isSaved,
  required CreateSaveCubit createSaveCubit,
}) {
  createSaveCubit.toggleSave(
    SavesModel(
      postId: postID,
      userName: currentUser,
      saved: isSaved,
    ),
  );
}
