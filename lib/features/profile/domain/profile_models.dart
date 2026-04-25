class AstrologerProfile {
  const AstrologerProfile({
    required this.id,
    required this.displayName,
    required this.isOnline,
    required this.kycStatus,
    required this.ratingAvg,
    required this.ratingCount,
    required this.totalConsultations,
    required this.pricePerMinChat,
    required this.pricePerMinCall,
    this.bio,
    this.profileImageUrl,
    this.languages = const [],
    this.specialties = const [],
    this.experienceYears = 0,
    this.email,
    this.phone,
  });

  final String id;
  final String displayName;
  final bool isOnline;
  final String kycStatus; // pending | approved | rejected
  final double ratingAvg;
  final int ratingCount;
  final int totalConsultations;
  final double pricePerMinChat;
  final double pricePerMinCall;
  final String? bio;
  final String? profileImageUrl;
  final List<String> languages;
  final List<String> specialties;
  final int experienceYears;
  final String? email;
  final String? phone;

  factory AstrologerProfile.fromJson(Map<String, dynamic> json) {
    return AstrologerProfile(
      id: json['id'] as String,
      displayName: json['displayName'] as String? ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
      kycStatus: json['kycStatus'] as String? ?? 'pending',
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['ratingCount'] as int? ?? 0,
      totalConsultations: json['totalConsultations'] as int? ?? 0,
      pricePerMinChat: (json['pricePerMinChat'] as num?)?.toDouble() ?? 30.0,
      pricePerMinCall: (json['pricePerMinCall'] as num?)?.toDouble() ?? 40.0,
      bio: json['bio'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      languages: (json['languages'] as List<dynamic>?)?.cast<String>() ?? [],
      specialties: (json['specialties'] as List<dynamic>?)?.cast<String>() ?? [],
      experienceYears: json['experienceYears'] as int? ?? 0,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }
}
