import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/earnings_repository.dart';
import '../domain/earnings_models.dart';

final earningsSummaryProvider = FutureProvider<EarningsSummary>((ref) async {
  return ref.read(earningsRepositoryProvider).fetchSummary();
});

final earningsTransactionsProvider =
    FutureProvider.family<List<EarningTransaction>, String>((ref, period) async {
  final repo = ref.read(earningsRepositoryProvider);
  final now = DateTime.now();
  DateTime? from;

  switch (period) {
    case 'week':
      from = now.subtract(const Duration(days: 7));
    case 'month':
      from = DateTime(now.year, now.month, 1);
  }

  try {
    return await repo.fetchTransactions(from: from);
  } catch (e) {
    throw extractException(e);
  }
});

final payoutsProvider = FutureProvider<List<Payout>>((ref) async {
  try {
    return await ref.read(earningsRepositoryProvider).fetchPayouts();
  } catch (e) {
    throw extractException(e);
  }
});
