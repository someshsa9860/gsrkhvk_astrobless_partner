import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/core/error/app_exception.dart';

void main() {
  group('AppException subclasses', () {
    test('UnauthorizedException has correct code and default message', () {
      const ex = UnauthorizedException();
      expect(ex.code, 'AUTH_REQUIRED');
      expect(ex.message, 'Session expired. Please sign in again.');
    });

    test('ForbiddenException has correct code and default message', () {
      const ex = ForbiddenException();
      expect(ex.code, 'FORBIDDEN');
      expect(ex.message, 'You do not have permission.');
    });

    test('NotFoundException has correct code and default message', () {
      const ex = NotFoundException();
      expect(ex.code, 'NOT_FOUND');
      expect(ex.message, 'Not found.');
    });

    test('ValidationException carries fieldErrors', () {
      const ex = ValidationException(
        message: 'Invalid input',
        fieldErrors: {'email': 'Invalid email format'},
      );
      expect(ex.code, 'VALIDATION');
      expect(ex.message, 'Invalid input');
      expect(ex.fieldErrors['email'], 'Invalid email format');
    });

    test('ValidationException defaults to empty fieldErrors', () {
      const ex = ValidationException(message: 'Bad request');
      expect(ex.fieldErrors, isEmpty);
    });

    test('RateLimitException has correct code and optional retryAfterSeconds', () {
      const ex = RateLimitException(retryAfterSeconds: 60);
      expect(ex.code, 'RATE_LIMIT');
      expect(ex.retryAfterSeconds, 60);
    });

    test('RateLimitException retryAfterSeconds is null when not provided', () {
      const ex = RateLimitException();
      expect(ex.retryAfterSeconds, isNull);
    });

    test('OtpInvalidException has correct code and message', () {
      const ex = OtpInvalidException();
      expect(ex.code, 'OTP_INVALID');
      expect(ex.message, 'Incorrect code. Please try again.');
    });

    test('OtpExpiredException has correct code and message', () {
      const ex = OtpExpiredException();
      expect(ex.code, 'OTP_EXPIRED');
      expect(ex.message, 'Code expired. Request a new one.');
    });

    test('OtpAttemptsExceededException has correct code and message', () {
      const ex = OtpAttemptsExceededException();
      expect(ex.code, 'OTP_ATTEMPTS_EXCEEDED');
      expect(ex.message, 'Too many wrong attempts. Request a new code.');
    });

    test('ServerException has correct code and default message', () {
      const ex = ServerException();
      expect(ex.code, 'INTERNAL');
      expect(ex.message, 'Something went wrong. Please try again.');
    });

    test('NetworkException has correct code and message', () {
      const ex = NetworkException();
      expect(ex.code, 'NETWORK');
      expect(ex.message, 'No internet connection.');
    });

    test('ApiException carries arbitrary code and message', () {
      const ex = ApiException(code: 'WALLET_INSUFFICIENT', message: 'Not enough balance.');
      expect(ex.code, 'WALLET_INSUFFICIENT');
      expect(ex.message, 'Not enough balance.');
    });
  });

  group('AppException.toString', () {
    test('formats code and message', () {
      const ex = NotFoundException();
      expect(ex.toString(), 'AppException(NOT_FOUND): Not found.');
    });
  });

  group('AppException is an Exception', () {
    test('all subclasses are Exception', () {
      expect(const UnauthorizedException(), isA<Exception>());
      expect(const NetworkException(), isA<Exception>());
      expect(const OtpInvalidException(), isA<Exception>());
    });
  });
}
