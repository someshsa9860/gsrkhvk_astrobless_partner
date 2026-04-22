sealed class AppException implements Exception {
  const AppException({required this.code, required this.message});
  final String code;
  final String message;

  @override
  String toString() => 'AppException($code): $message';
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({super.message = 'Session expired. Please sign in again.'})
      : super(code: 'AUTH_REQUIRED');
}

class ForbiddenException extends AppException {
  const ForbiddenException({super.message = 'You do not have permission.'})
      : super(code: 'FORBIDDEN');
}

class NotFoundException extends AppException {
  const NotFoundException({super.message = 'Not found.'})
      : super(code: 'NOT_FOUND');
}

class ValidationException extends AppException {
  const ValidationException({required super.message, this.fieldErrors = const {}})
      : super(code: 'VALIDATION');
  final Map<String, String> fieldErrors;
}

class RateLimitException extends AppException {
  const RateLimitException({super.message = 'Too many attempts. Try again later.', this.retryAfterSeconds})
      : super(code: 'RATE_LIMIT');
  final int? retryAfterSeconds;
}

class OtpInvalidException extends AppException {
  const OtpInvalidException() : super(code: 'OTP_INVALID', message: 'Incorrect code. Please try again.');
}

class OtpExpiredException extends AppException {
  const OtpExpiredException() : super(code: 'OTP_EXPIRED', message: 'Code expired. Request a new one.');
}

class OtpAttemptsExceededException extends AppException {
  const OtpAttemptsExceededException()
      : super(code: 'OTP_ATTEMPTS_EXCEEDED', message: 'Too many wrong attempts. Request a new code.');
}

class ServerException extends AppException {
  const ServerException({super.message = 'Something went wrong. Please try again.'})
      : super(code: 'INTERNAL');
}

class NetworkException extends AppException {
  const NetworkException() : super(code: 'NETWORK', message: 'No internet connection.');
}

class ApiException extends AppException {
  const ApiException({required super.code, required super.message});
}
