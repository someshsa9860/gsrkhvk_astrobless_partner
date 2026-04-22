import 'package:flutter_test/flutter_test.dart';
import 'package:partner_app/features/auth/domain/auth_models.dart';

Map<String, dynamic> get fullAstrologerJson => {
      'id': 'astro-1',
      'displayName': 'Pandit Sharma',
      'profileImageUrl': 'https://cdn.example.com/sharma.jpg',
      'kycStatus': 'approved',
      'isNewUser': false,
      'isOnline': true,
      'isVerified': true,
      'pricePerMinChatPaise': 300,
      'pricePerMinCallPaise': 500,
    };

void main() {
  group('AstrologerSummary.fromJson', () {
    test('parses all fields correctly', () {
      final a = AstrologerSummary.fromJson(fullAstrologerJson);

      expect(a.id, 'astro-1');
      expect(a.displayName, 'Pandit Sharma');
      expect(a.profileImageUrl, 'https://cdn.example.com/sharma.jpg');
      expect(a.kycStatus, 'approved');
      expect(a.isNewUser, isFalse);
      expect(a.isOnline, isTrue);
      expect(a.isVerified, isTrue);
      expect(a.pricePerMinChatPaise, 300);
      expect(a.pricePerMinCallPaise, 500);
    });

    test('defaults optional fields when absent', () {
      final a = AstrologerSummary.fromJson({'id': 'a-2', 'displayName': 'Test'});

      expect(a.profileImageUrl, isNull);
      expect(a.kycStatus, 'pending');
      expect(a.isNewUser, isFalse);
      expect(a.isOnline, isFalse);
      expect(a.isVerified, isFalse);
      expect(a.pricePerMinChatPaise, 0);
      expect(a.pricePerMinCallPaise, 0);
    });

    test('prices are stored as int (paise)', () {
      final a = AstrologerSummary.fromJson(fullAstrologerJson);
      expect(a.pricePerMinChatPaise, isA<int>());
      expect(a.pricePerMinCallPaise, isA<int>());
    });

    test('isNewUser parsed as true when present', () {
      final a = AstrologerSummary.fromJson({
        'id': 'a-3',
        'displayName': 'Newbie',
        'isNewUser': true,
      });
      expect(a.isNewUser, isTrue);
    });

    test('displayName defaults to empty string when absent', () {
      final a = AstrologerSummary.fromJson({'id': 'a-4'});
      expect(a.displayName, '');
    });
  });

  group('LoginResult.fromJson', () {
    test('parses all fields including nested astrologer', () {
      final json = {
        'accessToken': 'access-abc',
        'refreshToken': 'refresh-xyz',
        'astrologer': fullAstrologerJson,
      };
      final result = LoginResult.fromJson(json);

      expect(result.accessToken, 'access-abc');
      expect(result.refreshToken, 'refresh-xyz');
      expect(result.astrologer, isA<AstrologerSummary>());
      expect(result.astrologer.id, 'astro-1');
      expect(result.astrologer.displayName, 'Pandit Sharma');
    });
  });
}
