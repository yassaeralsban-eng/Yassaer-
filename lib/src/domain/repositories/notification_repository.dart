import '../entities/app_notification.dart';

/// Contract for notification operations (SAD section 19).
abstract interface class NotificationRepository {
  /// Streams notifications for a user.
  Stream<List<AppNotification>> watchNotifications(String userId);

  /// Marks a notification as read.
  Future<void> markAsRead(String notificationId);

  /// Marks all notifications as read.
  Future<void> markAllAsRead(String userId);
}
