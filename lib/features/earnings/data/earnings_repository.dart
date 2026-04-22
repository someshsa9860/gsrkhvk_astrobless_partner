import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/earnings_models.dart';

/// Repository for earnings summaries, transaction history, and payouts.
///
/// Delegates HTTP calls to [ApiClient]; path strings live in
/// [Endpoints.earnings].
class EarningsRepository {
  const EarningsRepository(this._client);
  final ApiClient _client;

  /// Fetches the aggregated earnings summary (today, week, all-time).
  Future<EarningsSummary> fetchSummary() async {
    final data = await _client.fetchEarningsSummary();
    return EarningsSummary.fromJson(data);
  }

  /// Fetches a paginated list of individual earning transactions.
  ///
  /// Optionally filter by [from] and [to] date range.
  Future<List<EarningTransaction>> fetchTransactions({
    int page = 1,
    int limit = 20,
    DateTime? from,
    DateTime? to,
  }) async {
    final data = await _client.fetchEarnings(
        page: page, limit: limit, from: from, to: to);
    final list = data['earnings'] as List<dynamic>? ?? [];
    return list
        .map((e) => EarningTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches the astrologer's payout history.
  Future<List<Payout>> fetchPayouts() async {
    final data = await _client.fetchPayouts();
    final list = data['payouts'] as List<dynamic>? ?? [];
    return list
        .map((e) => Payout.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final earningsRepositoryProvider = Provider<EarningsRepository>((ref) {
  return EarningsRepository(ref.read(apiClientProvider));
});
