import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/notifications_repository.dart';
import '../domain/notification_model.dart';

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<AppNotification>>> {
  NotificationsNotifier(this._repo) : super(const AsyncLoading()) {
    load();
  }

  final NotificationsRepository _repo;

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      final items = await _repo.fetchNotifications();
      if (mounted) state = AsyncData(items);
    } catch (e) {
      if (mounted) state = AsyncError(extractException(e), StackTrace.current);
    }
  }

  Future<void> markRead(String id) async {
    await _repo.markRead(id);
    state.whenData((items) {
      state = AsyncData(items.map((n) {
        if (n.id == id) return n.copyWith(readAt: DateTime.now());
        return n;
      }).toList());
    });
  }

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    state.whenData((items) {
      final now = DateTime.now();
      state = AsyncData(items.map((n) => n.copyWith(readAt: now)).toList());
    });
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier,
    AsyncValue<List<AppNotification>>>(
  (ref) => NotificationsNotifier(ref.read(notificationsRepositoryProvider)),
);
