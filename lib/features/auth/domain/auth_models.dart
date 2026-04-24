class AstrologerSummary {
  const AstrologerSummary({
    required this.id,
    required this.displayName,
    this.profileImageUrl,
    this.kycStatus = 'pending',
    this.isNewUser = false,
    this.isOnline = false,
    this.isVerified = false,
    this.pricePerMinChat = 0,
    this.pricePerMinCall = 0,
  });

  final String id;
  final String displayName;
  final String? profileImageUrl;
  final String kycStatus;
  final bool isNewUser;
  final bool isOnline;
  final bool isVerified;
  final int pricePerMinChat;
  final int pricePerMinCall;

  factory AstrologerSummary.fromJson(Map<String, dynamic> json) {
    return AstrologerSummary(
      id: json['id'] as String,
      displayName: json['displayName'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      kycStatus: json['kycStatus'] as String? ?? 'pending',
      isNewUser: json['isNewUser'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      pricePerMinChat: json['pricePerMinChat'] as int? ?? 0,
      pricePerMinCall: json['pricePerMinCall'] as int? ?? 0,
    );
  }
}

class LoginResult {
  const LoginResult({
    required this.accessToken,
    required this.refreshToken,
    required this.astrologer,
  });

  final String accessToken;
  final String refreshToken;
  final AstrologerSummary astrologer;

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      astrologer: AstrologerSummary.fromJson(
        json['astrologer'] as Map<String, dynamic>,
      ),
    );
  }
}
