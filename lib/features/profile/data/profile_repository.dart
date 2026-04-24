import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/profile_models.dart';

/// Repository for the astrologer's own profile, presence, and pricing.
///
/// Delegates HTTP calls to [ApiClient]; path strings live in
/// [Endpoints.profile].
class ProfileRepository {
  const ProfileRepository(this._client);
  final ApiClient _client;

  /// Fetches the authenticated astrologer's full profile.
  Future<AstrologerProfile> fetchProfile() async {
    final data = await _client.fetchProfile();
    return AstrologerProfile.fromJson(data);
  }

  /// Updates profile fields. Only provided (non-null) fields are changed.
  Future<AstrologerProfile> updateProfile({
    String? displayName,
    String? bio,
    List<String>? languages,
    List<String>? specialties,
    String? profileImageUrl,
    int? experienceYears,
  }) async {
    final data = await _client.updateProfile(
      displayName: displayName,
      bio: bio,
      languages: languages,
      specialties: specialties,
      profileImageUrl: profileImageUrl,
      experienceYears: experienceYears,
    );
    return AstrologerProfile.fromJson(data);
  }

  /// Toggles the astrologer's online / offline presence.
  Future<void> setPresence(bool isOnline) async {
    await _client.setPresence(isOnline);
  }

  /// Updates per-minute chat and call pricing (stored as paise).
  Future<void> updatePricing({
    required int pricePerMinChat,
    required int pricePerMinCall,
  }) async {
    await _client.updatePricing(
      pricePerMinChat: pricePerMinChat,
      pricePerMinCall: pricePerMinCall,
    );
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.read(apiClientProvider));
});
