import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/realtime/socket_service.dart';
import '../../../core/network/api_client.dart';
import '../data/consultations_repository.dart';
import '../domain/consultation_models.dart';

// ── Incoming request stream (server pushes this) ──────────────────────────────
final incomingRequestProvider = StreamProvider<IncomingRequest>((ref) {
  return ref.watch(socketServiceProvider).onIncomingRequest;
});

// ── Call incoming stream ───────────────────────────────────────────────────────
final callIncomingProvider = StreamProvider<CallIncoming>((ref) {
  return ref.watch(socketServiceProvider).onCallIncoming;
});

// ── Billing tick stream for a specific consultation ───────────────────────────
final billingTickProvider = StreamProvider.family<BillingTick, String>((ref, id) {
  return ref
      .watch(socketServiceProvider)
      .onBillingTick
      .where((t) => t.consultationId == id);
});

// ── Consultation ended stream for a specific consultation ─────────────────────
final consultationEndedProvider =
    StreamProvider.family<Map<String, dynamic>, String>((ref, id) {
  return ref
      .watch(socketServiceProvider)
      .onConsultationEnded
      .where((e) => e['consultationId'] == id);
});

// ── Consultation history list ─────────────────────────────────────────────────
final consultationsProvider =
    FutureProvider.family<List<Consultation>, String?>((ref, status) async {
  final repo = ref.read(consultationsRepositoryProvider);
  return repo.fetchConsultations(status: status);
});

// ── Single consultation detail ────────────────────────────────────────────────
final consultationDetailProvider =
    FutureProvider.family<Consultation, String>((ref, id) async {
  return ref.read(consultationsRepositoryProvider).fetchConsultation(id);
});

// ── Chat messages with live socket updates ────────────────────────────────────
class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  ChatMessagesNotifier(this._repo, this._socket, this._consultationId)
      : super(const AsyncLoading()) {
    _load();
    _subscription = _socket.onNewMessage
        .where((m) => m.consultationId == _consultationId)
        .listen(_onNewMessage);
  }

  final ConsultationsRepository _repo;
  final SocketService _socket;
  final String _consultationId;
  StreamSubscription<ChatMessage>? _subscription;

  Future<void> _load() async {
    try {
      final messages = await _repo.fetchMessages(_consultationId);
      if (mounted) state = AsyncData(messages);
    } catch (e) {
      if (mounted) state = AsyncError(extractException(e), StackTrace.current);
    }
  }

  void _onNewMessage(ChatMessage msg) {
    state.whenData((messages) {
      // Deduplicate by id
      final exists = messages.any((m) => m.id == msg.id);
      if (!exists) {
        state = AsyncData([...messages, msg]);
      }
    });
  }

  void addOptimistic(ChatMessage msg) {
    state.whenData((messages) {
      state = AsyncData([...messages, msg]);
    });
  }

  void confirmDelivery(String clientMsgId, String serverId) {
    state.whenData((messages) {
      final updated = messages.map((m) {
        if (m.clientMsgId == clientMsgId) return m.copyWith(id: serverId);
        return m;
      }).toList();
      state = AsyncData(updated);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final chatMessagesProvider = StateNotifierProvider.family<
    ChatMessagesNotifier, AsyncValue<List<ChatMessage>>, String>(
  (ref, consultationId) => ChatMessagesNotifier(
    ref.read(consultationsRepositoryProvider),
    ref.read(socketServiceProvider),
    consultationId,
  ),
);
