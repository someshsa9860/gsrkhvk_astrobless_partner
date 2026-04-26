import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/support_models.dart';

class SupportRepository {
  SupportRepository(this._client);
  final ApiClient _client;

  Future<List<SupportTicket>> fetchTickets({String? status}) async {
    final data = await _client.fetchSupportTickets(status: status);
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => SupportTicket.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SupportTicket> fetchTicket(String id) async {
    final data = await _client.fetchSupportTicket(id);
    return SupportTicket.fromJson(data);
  }

  Future<SupportTicket> createTicket({
    required String category,
    required String subject,
    required String description,
    String? linkedConsultationId,
  }) async {
    final data = await _client.createSupportTicket(
      category: category,
      subject: subject,
      description: description,
      linkedConsultationId: linkedConsultationId,
    );
    return SupportTicket.fromJson(data);
  }

  Future<SupportMessage> addMessage(String ticketId, String body) async {
    final data = await _client.addSupportTicketMessage(ticketId, body);
    return SupportMessage.fromJson(data);
  }

  Future<void> closeTicket(String ticketId) =>
      _client.closeSupportTicket(ticketId);
}

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepository(ref.read(apiClientProvider));
});

class TicketsNotifier extends AsyncNotifier<List<SupportTicket>> {
  @override
  Future<List<SupportTicket>> build() {
    return ref.read(supportRepositoryProvider).fetchTickets();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(supportRepositoryProvider).fetchTickets());
  }

  Future<SupportTicket> createTicket({
    required String category,
    required String subject,
    required String description,
  }) async {
    final ticket = await ref.read(supportRepositoryProvider).createTicket(
          category: category,
          subject: subject,
          description: description,
        );
    state = AsyncData([ticket, ...(state.valueOrNull ?? [])]);
    return ticket;
  }
}

final ticketsNotifierProvider =
    AsyncNotifierProvider<TicketsNotifier, List<SupportTicket>>(
        TicketsNotifier.new);

class TicketDetailNotifier
    extends FamilyAsyncNotifier<SupportTicket, String> {
  @override
  Future<SupportTicket> build(String ticketId) {
    return ref.read(supportRepositoryProvider).fetchTicket(ticketId);
  }

  Future<void> sendMessage(String body) async {
    final msg =
        await ref.read(supportRepositoryProvider).addMessage(arg, body);
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(SupportTicket(
      id: current.id,
      ticketNumber: current.ticketNumber,
      category: current.category,
      priority: current.priority,
      subject: current.subject,
      description: current.description,
      status: current.status,
      createdAt: current.createdAt,
      messages: [...current.messages, msg],
    ));
  }

  Future<void> close() async {
    await ref.read(supportRepositoryProvider).closeTicket(arg);
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(SupportTicket(
      id: current.id,
      ticketNumber: current.ticketNumber,
      category: current.category,
      priority: current.priority,
      subject: current.subject,
      description: current.description,
      status: 'closed',
      createdAt: current.createdAt,
      messages: current.messages,
    ));
  }
}

final ticketDetailProvider =
    AsyncNotifierProviderFamily<TicketDetailNotifier, SupportTicket, String>(
        TicketDetailNotifier.new);
