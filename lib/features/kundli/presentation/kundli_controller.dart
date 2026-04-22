import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/kundli_repository.dart';
import '../domain/kundli_models.dart';

final kundliRequestsProvider =
    FutureProvider.family<List<KundliRequest>, String?>((ref, status) async {
  return ref.read(kundliRepositoryProvider).fetchRequests(status: status);
});

final kundliRequestDetailProvider =
    FutureProvider.family<KundliRequest, String>((ref, id) async {
  return ref.read(kundliRepositoryProvider).fetchRequest(id);
});
