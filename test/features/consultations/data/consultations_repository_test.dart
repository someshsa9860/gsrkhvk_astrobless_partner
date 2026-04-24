import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:partner_app/core/network/api_client.dart';
import 'package:partner_app/features/consultations/data/consultations_repository.dart';
import 'package:partner_app/features/consultations/domain/consultation_models.dart';

class MockApiClient extends Mock implements ApiClient {}

Map<String, dynamic> consultationJson(String id, String status) => {
      'id': id,
      'customerName': 'Rahul',
      'type': 'chat',
      'status': status,
      'pricePerMin': 300,
      'requestedAt': '2026-04-10T10:00:00.000Z',
      'durationSeconds': 0,
      'totalCharged': 0,
      'astrologerEarning': 0,
    };

Map<String, dynamic> messageJson(String id, String body) => {
      'id': id,
      'consultationId': 'c-1',
      'senderType': 'customer',
      'body': body,
      'type': 'text',
      'createdAt': '2026-04-10T10:05:00.000Z',
    };

void main() {
  late MockApiClient client;
  late ConsultationsRepository repo;

  setUp(() {
    client = MockApiClient();
    repo = ConsultationsRepository(client);
  });

  group('fetchConsultations', () {
    test('returns mapped Consultation list from consultations key', () async {
      when(() => client.fetchConsultations(status: any(named: 'status')))
          .thenAnswer((_) async => {
                'consultations': [
                  consultationJson('c-1', 'ended'),
                  consultationJson('c-2', 'active'),
                ],
              });

      final list = await repo.fetchConsultations();

      expect(list, hasLength(2));
      expect(list.first, isA<Consultation>());
      expect(list.first.id, 'c-1');
      expect(list.last.status, 'active');
    });

    test('returns empty list when consultations key is absent', () async {
      when(() => client.fetchConsultations(status: any(named: 'status')))
          .thenAnswer((_) async => {});

      final list = await repo.fetchConsultations();

      expect(list, isEmpty);
    });

    test('passes status filter to client', () async {
      when(() => client.fetchConsultations(status: 'active'))
          .thenAnswer((_) async => {
                'consultations': [consultationJson('c-3', 'active')],
              });

      final list = await repo.fetchConsultations(status: 'active');

      expect(list.first.status, 'active');
      verify(() => client.fetchConsultations(status: 'active')).called(1);
    });
  });

  group('fetchConsultation', () {
    test('returns a single Consultation from consultation key', () async {
      when(() => client.fetchConsultation('c-1')).thenAnswer(
        (_) async => {'consultation': consultationJson('c-1', 'active')},
      );

      final c = await repo.fetchConsultation('c-1');

      expect(c.id, 'c-1');
      expect(c.type, 'chat');
    });

    test('propagates exceptions from client', () async {
      when(() => client.fetchConsultation(any()))
          .thenThrow(Exception('not found'));

      await expectLater(
        repo.fetchConsultation('c-missing'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('fetchMessages', () {
    test('returns mapped ChatMessage list from messages key', () async {
      when(() => client.fetchMessages('c-1', afterId: any(named: 'afterId')))
          .thenAnswer((_) async => {
                'messages': [
                  messageJson('m-1', 'Hello'),
                  messageJson('m-2', 'How are you?'),
                ],
              });

      final msgs = await repo.fetchMessages('c-1');

      expect(msgs, hasLength(2));
      expect(msgs.first, isA<ChatMessage>());
      expect(msgs.first.id, 'm-1');
      expect(msgs.first.body, 'Hello');
    });

    test('returns empty list when messages key is absent', () async {
      when(() => client.fetchMessages(any(), afterId: any(named: 'afterId')))
          .thenAnswer((_) async => {});

      final msgs = await repo.fetchMessages('c-1');

      expect(msgs, isEmpty);
    });
  });

  group('acceptConsultation', () {
    test('delegates to client and completes', () async {
      when(() => client.acceptConsultation(any())).thenAnswer((_) async {});

      await expectLater(repo.acceptConsultation('c-1'), completes);

      verify(() => client.acceptConsultation('c-1')).called(1);
    });
  });

  group('rejectConsultation', () {
    test('delegates to client with default reason', () async {
      when(() => client.rejectConsultation(any(), reason: any(named: 'reason')))
          .thenAnswer((_) async {});

      await expectLater(repo.rejectConsultation('c-1'), completes);

      verify(() =>
              client.rejectConsultation('c-1', reason: 'busy'))
          .called(1);
    });
  });

  group('endConsultation', () {
    test('delegates to client with default reason', () async {
      when(() => client.endConsultation(any(), reason: any(named: 'reason')))
          .thenAnswer((_) async {});

      await expectLater(repo.endConsultation('c-1'), completes);

      verify(() => client.endConsultation('c-1', reason: 'astrologerEnded'))
          .called(1);
    });

    test('passes custom reason to client', () async {
      when(() => client.endConsultation(any(), reason: any(named: 'reason')))
          .thenAnswer((_) async {});

      await repo.endConsultation('c-2', reason: 'lowBalance');

      verify(() => client.endConsultation('c-2', reason: 'lowBalance'))
          .called(1);
    });
  });
}
