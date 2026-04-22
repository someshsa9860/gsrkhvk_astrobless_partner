import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:partner_app/core/network/api_client.dart';
import 'package:partner_app/features/auth/data/auth_repository.dart';
import 'package:partner_app/features/auth/domain/auth_models.dart';

class MockApiClient extends Mock implements ApiClient {}

Map<String, dynamic> get loginData => {
      'accessToken': 'at-xyz',
      'refreshToken': 'rt-abc',
      'astrologer': {
        'id': 'astro-1',
        'displayName': 'Pandit Sharma',
        'kycStatus': 'approved',
      },
    };

void main() {
  late MockApiClient client;
  late AuthRepository repo;

  setUp(() {
    client = MockApiClient();
    repo = AuthRepository(client);
  });

  group('sendPhoneOtp', () {
    test('delegates to client and completes', () async {
      when(() => client.sendPhoneOtp(any())).thenAnswer((_) async {});

      await expectLater(repo.sendPhoneOtp('+919876543210'), completes);

      verify(() => client.sendPhoneOtp('+919876543210')).called(1);
    });

    test('propagates exception from client', () async {
      when(() => client.sendPhoneOtp(any())).thenThrow(Exception('rate limit'));

      await expectLater(
        repo.sendPhoneOtp('+919876543210'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('verifyPhoneOtp', () {
    test('returns LoginResult from client data', () async {
      when(() => client.verifyPhoneOtp(any(), any()))
          .thenAnswer((_) async => loginData);

      final result = await repo.verifyPhoneOtp('+919876543210', '123456');

      expect(result, isA<LoginResult>());
      expect(result.accessToken, 'at-xyz');
      expect(result.astrologer.id, 'astro-1');
    });

    test('propagates exception from client', () async {
      when(() => client.verifyPhoneOtp(any(), any()))
          .thenThrow(Exception('OTP_INVALID'));

      await expectLater(
        repo.verifyPhoneOtp('+91', 'wrong'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('emailSignup', () {
    test('delegates all fields to client and completes', () async {
      when(() => client.emailSignup(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenAnswer((_) async {});

      await expectLater(
        repo.emailSignup(
          email: 'test@example.com',
          password: 'Password1',
          displayName: 'Pandit',
        ),
        completes,
      );

      verify(() => client.emailSignup(
            email: 'test@example.com',
            password: 'Password1',
            displayName: 'Pandit',
          )).called(1);
    });
  });

  group('verifyEmailOtp', () {
    test('returns LoginResult from client data', () async {
      when(() => client.verifyEmailOtp(any(), any()))
          .thenAnswer((_) async => loginData);

      final result = await repo.verifyEmailOtp('test@example.com', '654321');

      expect(result.refreshToken, 'rt-abc');
    });
  });

  group('emailLogin', () {
    test('returns LoginResult from client data', () async {
      when(() => client.emailLogin(any(), any()))
          .thenAnswer((_) async => loginData);

      final result = await repo.emailLogin('test@example.com', 'Password1');

      expect(result.astrologer.displayName, 'Pandit Sharma');
    });

    test('propagates exception from client', () async {
      when(() => client.emailLogin(any(), any()))
          .thenThrow(Exception('WRONG_PASSWORD'));

      await expectLater(
        repo.emailLogin('test@example.com', 'wrong'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('forgotPassword', () {
    test('delegates to client and completes', () async {
      when(() => client.forgotPassword(any())).thenAnswer((_) async {});

      await expectLater(repo.forgotPassword('test@example.com'), completes);

      verify(() => client.forgotPassword('test@example.com')).called(1);
    });
  });

  group('logout', () {
    test('delegates to client and completes', () async {
      when(() => client.logout(any())).thenAnswer((_) async {});

      await expectLater(repo.logout('rt-abc'), completes);
    });
  });
}
