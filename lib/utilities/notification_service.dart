import '../core/di/service_locator.dart';
import '../core/errors/error_mapper.dart';
import '../models/notification_model.dart';

/// In-app notification helper backed by Supabase.
///
/// Push delivery (FCM/APNs) is intentionally NOT handled in the client. To send
/// real push notifications, deploy the `send-push` Edge Function documented in
/// the project guide and invoke it from a trusted server context. This class
/// records an in-app notification row so the notifications UI stays functional.
class NotificationService {
  /// Records an in-app notification for [targetUserName].
  ///
  /// Never throws to the caller: notification side-effects must not break the
  /// primary user action (liking, commenting, etc.).
  Future<void> notify({
    required String targetUserName,
    required String actorName,
    required String type,
    required String body,
    String? postId,
  }) async {
    try {
      await sl.notificationRepository.createNotification(
        NotificationModel(
          userName: targetUserName,
          actorName: actorName,
          type: type,
          body: body,
          postId: postId,
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      // Swallow errors deliberately (see doc comment). Kept as a single,
      // documented fallback rather than silent per-call try/catch sprawl.
      friendlyError(e);
    }
  }
}
