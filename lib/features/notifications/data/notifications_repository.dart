import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/notification_model.dart';

/// Repository for in-app notifications and FCM token management.
///
/// Delegates HTTP calls to [ApiClient]; path strings live in
/// [Endpoints.notifications].
class NotificationsRepository {
  const NotificationsRepository(this._client);
  final ApiClient _client;

  /// Fetches a paginated list of in-app notifications.
  Future<List<AppNotification>> fetchNotifications({int page = 1}) async {
    final data = await _client.fetchNotifications(page: page);
    final list = data['notifications'] as List<dynamic>? ?? [];
    return list
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Marks a single notification as read.
  Future<void> markRead(String id) async {
    await _client.markNotificationRead(id);
  }

  /// Marks all notifications as read.
  Future<void> markAllRead() async {
    await _client.markAllNotificationsRead();
  }

  /// Registers or refreshes the FCM [token] for the given [platform].
  Future<void> registerFcmToken(String token, String platform) async {
    await _client.registerFcmToken(token, platform);
  }
}

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.read(apiClientProvider));
});
