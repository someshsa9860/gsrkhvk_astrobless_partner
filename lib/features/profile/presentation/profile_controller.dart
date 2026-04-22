import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/profile_repository.dart';
import '../domain/profile_models.dart';

final profileProvider = FutureProvider<AstrologerProfile>((ref) async {
  try {
    return await ref.read(profileRepositoryProvider).fetchProfile();
  } catch (e) {
    throw extractException(e);
  }
});

class ProfileEditNotifier extends StateNotifier<AsyncValue<void>> {
  ProfileEditNotifier(this._repo) : super(const AsyncData(null));

  final ProfileRepository _repo;

  Future<void> save({
    String? displayName,
    String? bio,
    List<String>? languages,
    List<String>? specialties,
    String? profileImageUrl,
    int? experienceYears,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.updateProfile(
        displayName: displayName,
        bio: bio,
        languages: languages,
        specialties: specialties,
        profileImageUrl: profileImageUrl,
        experienceYears: experienceYears,
      );
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(extractException(e), StackTrace.current);
      rethrow;
    }
  }
}

final profileEditProvider =
    StateNotifierProvider<ProfileEditNotifier, AsyncValue<void>>(
  (ref) => ProfileEditNotifier(ref.read(profileRepositoryProvider)),
);
