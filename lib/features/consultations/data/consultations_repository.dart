import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/consultation_models.dart';

/// Repository for consultation lifecycle management.
///
/// Delegates HTTP calls to [ApiClient]; path strings live in
/// [Endpoints.consultations].
class ConsultationsRepository {
  const ConsultationsRepository(this._client);
  final ApiClient _client;

  /// Fetches consultations with an optional [status] filter.
  Future<List<Consultation>> fetchConsultations({String? status}) async {
    final data = await _client.fetchConsultations(status: status);
    final list = data['consultations'] as List<dynamic>? ?? [];
    return list
        .map((e) => Consultation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a single consultation by [id].
  Future<Consultation> fetchConsultation(String id) async {
    final data = await _client.fetchConsultation(id);
    return Consultation.fromJson(
        data['consultation'] as Map<String, dynamic>);
  }

  /// Fetches chat messages for consultation [id], optionally paginated after
  /// [afterId].
  Future<List<ChatMessage>> fetchMessages(String id,
      {String? afterId}) async {
    final data =
        await _client.fetchMessages(id, afterId: afterId);
    final list = data['messages'] as List<dynamic>? ?? [];
    return list
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Accepts an incoming consultation request.
  Future<void> acceptConsultation(String id) async {
    await _client.acceptConsultation(id);
  }

  /// Rejects an incoming consultation request with an optional [reason].
  Future<void> rejectConsultation(String id,
      {String reason = 'busy'}) async {
    await _client.rejectConsultation(id, reason: reason);
  }

  /// Ends an active consultation.
  Future<void> endConsultation(String id,
      {String reason = 'astrologerEnded'}) async {
    await _client.endConsultation(id, reason: reason);
  }
}

final consultationsRepositoryProvider =
    Provider<ConsultationsRepository>((ref) {
  return ConsultationsRepository(ref.read(apiClientProvider));
});
