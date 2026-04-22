import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/core/network/endpoints.dart';

void main() {
  group('Endpoints.auth', () {
    test('static paths are correct', () {
      expect(Endpoints.auth.sendPhoneOtp, '/auth/phone/send-otp');
      expect(Endpoints.auth.verifyPhoneOtp, '/auth/phone/verify-otp');
      expect(Endpoints.auth.emailSignup, '/auth/email/signup');
      expect(Endpoints.auth.verifyEmailOtp, '/auth/email/verify-otp');
      expect(Endpoints.auth.resendEmailOtp, '/auth/email/resend-otp');
      expect(Endpoints.auth.emailLogin, '/auth/email/login');
      expect(Endpoints.auth.forgotPassword, '/auth/email/forgot-password');
      expect(Endpoints.auth.refresh, '/auth/refresh');
      expect(Endpoints.auth.logout, '/auth/logout');
    });
  });

  group('Endpoints.profile', () {
    test('static paths are correct', () {
      expect(Endpoints.profile.me, '/profile');
      expect(Endpoints.profile.update, '/profile');
      expect(Endpoints.profile.presence, '/profile/presence');
      expect(Endpoints.profile.pricing, '/profile/pricing');
    });
  });

  group('Endpoints.consultations', () {
    test('static list path is correct', () {
      expect(Endpoints.consultations.list, '/consultations');
    });

    test('detail interpolates id correctly', () {
      expect(Endpoints.consultations.detail('c-123'), '/consultations/c-123');
    });

    test('messages interpolates id correctly', () {
      expect(Endpoints.consultations.messages('c-456'), '/consultations/c-456/messages');
    });

    test('accept interpolates id correctly', () {
      expect(Endpoints.consultations.accept('c-789'), '/consultations/c-789/accept');
    });

    test('reject interpolates id correctly', () {
      expect(Endpoints.consultations.reject('c-abc'), '/consultations/c-abc/reject');
    });

    test('end interpolates id correctly', () {
      expect(Endpoints.consultations.end('c-def'), '/consultations/c-def/end');
    });
  });

  group('Endpoints.earnings', () {
    test('static paths are correct', () {
      expect(Endpoints.earnings.summary, '/earnings/summary');
      expect(Endpoints.earnings.list, '/earnings');
      expect(Endpoints.earnings.payouts, '/payouts');
    });
  });

  group('Endpoints.kundli', () {
    test('static list path is correct', () {
      expect(Endpoints.kundli.list, '/kundli-requests');
    });

    test('detail interpolates id correctly', () {
      expect(Endpoints.kundli.detail('kr-1'), '/kundli-requests/kr-1');
    });

    test('accept interpolates id correctly', () {
      expect(Endpoints.kundli.accept('kr-2'), '/kundli-requests/kr-2/accept');
    });

    test('decline interpolates id correctly', () {
      expect(Endpoints.kundli.decline('kr-3'), '/kundli-requests/kr-3/decline');
    });

    test('submit interpolates id correctly', () {
      expect(Endpoints.kundli.submit('kr-4'), '/kundli-requests/kr-4/submit');
    });
  });

  group('Endpoints.notifications', () {
    test('static paths are correct', () {
      expect(Endpoints.notifications.list, '/notifications');
      expect(Endpoints.notifications.markAllRead, '/notifications/read-all');
      expect(Endpoints.notifications.registerFcmToken, '/notifications/fcm-token');
    });

    test('markRead interpolates id correctly', () {
      expect(Endpoints.notifications.markRead('notif-99'), '/notifications/notif-99/read');
    });
  });

  group('Endpoints.uploads', () {
    test('image path is correct', () {
      expect(Endpoints.uploads.image, '/upload/image');
    });
  });
}
