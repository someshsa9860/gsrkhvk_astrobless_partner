import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/kundli_models.dart';

/// Repository for Kundli report requests assigned to this astrologer.
///
/// Delegates HTTP calls to [ApiClient]; path strings live in
/// [Endpoints.kundli].
class KundliRepository {
  KundliRepository(this._client);
  final ApiClient _client;

  /// Lists kundli requests, optionally filtered by [status].
  Future<List<KundliRequest>> fetchRequests({String? status}) async {
    try {
      final list = await _client.fetchKundliRequests(status: status);
      return list
          .map((e) => KundliRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Exception catch (e) {
      throw extractException(e);
    }
  }

  /// Fetches a single kundli request by [id].
  Future<KundliRequest> fetchRequest(String id) async {
    try {
      final data = await _client.fetchKundliRequest(id);
      return KundliRequest.fromJson(data);
    } on Exception catch (e) {
      throw extractException(e);
    }
  }

  /// Accepts a kundli request and commits to a [slaDurationHours] (6, 12, 24).
  Future<void> acceptRequest(String id, int slaDurationHours) async {
    try {
      await _client.acceptKundliRequest(id, slaDurationHours);
    } on Exception catch (e) {
      throw extractException(e);
    }
  }

  /// Declines a kundli request with a mandatory [reason].
  Future<void> declineRequest(String id, String reason) async {
    try {
      await _client.declineKundliRequest(id, reason);
    } on Exception catch (e) {
      throw extractException(e);
    }
  }

  /// Submits the completed kundli report text.
  Future<void> submitReport(String id, String reportText) async {
    try {
      await _client.submitKundliReport(id, reportText);
    } on Exception catch (e) {
      throw extractException(e);
    }
  }
}

final kundliRepositoryProvider = Provider<KundliRepository>(
  (ref) => KundliRepository(ref.read(apiClientProvider)),
);
