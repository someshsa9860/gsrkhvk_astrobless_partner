import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/dashboard_models.dart';

/// Repository that assembles the dashboard summary from the earnings and
/// profile endpoints in parallel.
///
/// Delegates HTTP calls to [ApiClient]; path strings live in [Endpoints].
class DashboardRepository {
  const DashboardRepository(this._client);
  final ApiClient _client;

  /// Fetches earnings summary and profile concurrently and merges them into
  /// a single [DashboardSummary].
  Future<DashboardSummary> fetchSummary() async {
    final results = await Future.wait([
      _client.fetchEarningsSummary(),
      _client.fetchProfile(),
    ]);

    final earningsData = results[0];
    final profileData = results[1];

    return DashboardSummary(
      todayEarnings: earningsData['todayPaise'] as int? ?? 0,
      weekEarnings: earningsData['weekPaise'] as int? ?? 0,
      totalConsultations: profileData['totalConsultations'] as int? ?? 0,
      activeConsultations: 0,
      ratingAvg: (profileData['ratingAvg'] as num?)?.toDouble() ?? 0.0,
      isOnline: profileData['isOnline'] as bool? ?? false,
    );
  }

  /// Toggles the astrologer's online / offline presence.
  Future<void> setPresence(bool isOnline) async {
    await _client.setPresence(isOnline);
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.read(apiClientProvider));
});
