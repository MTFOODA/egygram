import '../../models/notification_model.dart';

/// In-app notifications contract (push delivery is intentionally out of scope
/// for the client; see the project guide for the Edge Function approach).
abstract class NotificationRepository {
  Stream<List<NotificationModel>> watchNotifications(String userName);

  Future<void> createNotification(NotificationModel notification);
}
