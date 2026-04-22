import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/cache/cache_service.dart';
import '../data/dashboard_repository.dart';
import '../domain/dashboard_models.dart';

class DashboardNotifier extends StateNotifier<AsyncValue<DashboardSummary>> {
  DashboardNotifier(this._repo) : super(const AsyncLoading()) {
    _loadWithCache();
  }

  final DashboardRepository _repo;

  /// Load: show cached data immediately (fast start), then refresh in background.
  Future<void> _loadWithCache() async {
    // 1. Try cache first — instant display with no network wait
    final cached = CacheService.instance.get<Map<String, dynamic>>(CacheKeys.dashboardSummary);
    if (cached != null) {
      try {
        state = AsyncData(DashboardSummary.fromJson(cached));
      } catch (_) {
        // corrupt cache entry — ignore, proceed to network
      }
    }

    // 2. Fetch fresh data (background if cache hit, foreground if not)
    await load(showLoading: cached == null);
  }

  Future<void> load({bool showLoading = true}) async {
    if (showLoading) state = const AsyncLoading();
    try {
      final summary = await _repo.fetchSummary();
      if (mounted) {
        state = AsyncData(summary);
        // Update cache on success
        await CacheService.instance.set(
          CacheKeys.dashboardSummary,
          summary.toJson(),
          ttl: CacheTTL.dashboard,
        );
      }
    } catch (e) {
      if (mounted) {
        // If we already have cached data, keep showing it with an error indicator
        if (state is! AsyncData) {
          state = AsyncError(extractException(e), StackTrace.current);
        }
        // else silently fail — user sees stale data, offline banner explains why
      }
    }
  }

  Future<void> togglePresence() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final next = !current.isOnline;
    state = AsyncData(current.copyWith(isOnline: next));
    try {
      await _repo.setPresence(next);
      // Invalidate cache so next refresh picks up new presence state
      await CacheService.instance.delete(CacheKeys.dashboardSummary);
    } catch (e) {
      state = AsyncData(current.copyWith(isOnline: !next));
      rethrow;
    }
  }

  Future<void> refresh() => load(showLoading: false);
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, AsyncValue<DashboardSummary>>(
  (ref) => DashboardNotifier(ref.read(dashboardRepositoryProvider)),
);
