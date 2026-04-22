import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/upload_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../l10n/app_localizations.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _displayNameCtrl = TextEditingController(text: 'Pandit Ramesh Ji');
  final _bioCtrl = TextEditingController(
    text: 'Experienced Vedic astrologer with 8+ years of practice. Specializing in birth chart analysis, marriage compatibility, and career guidance.',
  );
  final _experienceCtrl = TextEditingController(text: '8');

  final _selectedSpecialties = <String>{'Vedic', 'Numerology'};
  final _selectedLanguages = <String>{'Hindi', 'English'};

  final _chatRateCtrl = TextEditingController(text: '30');
  final _callRateCtrl = TextEditingController(text: '40');

  bool _isSaving = false;

  // Photo upload state
  File? _pickedPhoto;
  String? _uploadedTempKey;
  bool _isUploadingPhoto = false;
  double _uploadProgress = 0;

  static const _allSpecialties = [
    'Vedic', 'Tarot', 'Numerology', 'Vastu', 'KP System',
    'Nadi Astrology', 'Prashna', 'Muhurta', 'Gemstone', 'Palmistry',
  ];

  static const _allLanguages = [
    'Hindi', 'English', 'Tamil', 'Telugu', 'Bengali',
    'Marathi', 'Gujarati', 'Kannada', 'Malayalam', 'Punjabi',
  ];

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _bioCtrl.dispose();
    _experienceCtrl.dispose();
    _chatRateCtrl.dispose();
    _callRateCtrl.dispose();
    super.dispose();
  }

  // ── Photo pick + immediate presign upload ─────────────────────────────────

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (picked == null || !mounted) return;

    final file = File(picked.path);
    setState(() {
      _pickedPhoto = file;
      _isUploadingPhoto = true;
      _uploadProgress = 0;
      _uploadedTempKey = null;
    });

    try {
      final tempKey = await ref.read(uploadServiceProvider).presignAndUpload(
        file: file,
        category: 'profiles',
        contentType: 'image/jpeg',
        onProgress: (sent, total) {
          if (total > 0 && mounted) {
            setState(() => _uploadProgress = sent / total);
          }
        },
      );
      if (mounted) {
        setState(() {
          _uploadedTempKey = tempKey;
          _isUploadingPhoto = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _pickedPhoto = null;
          _isUploadingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo upload failed. Please try again.')),
        );
      }
    }
  }

  // ── Avatar widget ─────────────────────────────────────────────────────────

  Widget _buildAvatar(TextTheme tt) {
    final hasPhoto = _pickedPhoto != null;

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            backgroundImage: hasPhoto ? FileImage(_pickedPhoto!) : null,
            child: hasPhoto
                ? null
                : Text(
                    'P',
                    style: tt.displaySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          // Upload progress ring
          if (_isUploadingPhoto)
            Positioned.fill(
              child: CircularProgressIndicator(
                value: _uploadProgress > 0 ? _uploadProgress : null,
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
          // Upload done checkmark
          if (_uploadedTempKey != null && !_isUploadingPhoto)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 12, color: Colors.white),
              ),
            ),
          // Camera button
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _isUploadingPhoto
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text(l10n.editProfileTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAvatar(tt),
          const SizedBox(height: 24),

          _Section(
            title: l10n.basicInfo,
            child: Column(
              children: [
                AppTextField(
                  controller: _displayNameCtrl,
                  label: l10n.displayName,
                  hint: l10n.displayNameHint,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _bioCtrl,
                  label: l10n.bioLabel,
                  hint: l10n.bioHint,
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _experienceCtrl,
                  label: l10n.yearsExperience,
                  hint: '0',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 50.ms),

          const SizedBox(height: 16),

          _Section(
            title: l10n.specialties,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allSpecialties.map((s) {
                final selected = _selectedSpecialties.contains(s);
                return FilterChip(
                  label: Text(s),
                  selected: selected,
                  onSelected: (val) => setState(() => val
                      ? _selectedSpecialties.add(s)
                      : _selectedSpecialties.remove(s)),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                  labelStyle: tt.labelMedium?.copyWith(
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  side: BorderSide(
                    color: selected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.borderDark,
                  ),
                  backgroundColor: AppColors.inputDark,
                );
              }).toList(),
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 16),

          _Section(
            title: l10n.languagesLabel,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allLanguages.map((l) {
                final selected = _selectedLanguages.contains(l);
                return FilterChip(
                  label: Text(l),
                  selected: selected,
                  onSelected: (val) => setState(() => val
                      ? _selectedLanguages.add(l)
                      : _selectedLanguages.remove(l)),
                  selectedColor: AppColors.accent.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.accent,
                  labelStyle: tt.labelMedium?.copyWith(
                    color: selected ? AppColors.accent : AppColors.textSecondary,
                  ),
                  side: BorderSide(
                    color: selected ? AppColors.accent.withValues(alpha: 0.5) : AppColors.borderDark,
                  ),
                  backgroundColor: AppColors.inputDark,
                );
              }).toList(),
            ),
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 16),

          _Section(
            title: l10n.pricingPerMin,
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _chatRateCtrl,
                    label: l10n.chatRateLabel,
                    hint: '30',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _callRateCtrl,
                    label: l10n.callRateLabel,
                    hint: '40',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          AppButton(
            label: l10n.saveChanges,
            loading: _isSaving,
            onPressed: _isUploadingPhoto ? null : _save,
          ).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isSaving = true);
    try {
      // TODO: call profileEditProvider.save() with _uploadedTempKey as profileImageUrl
      // The backend will call moveFromTempIfNeeded(_uploadedTempKey) to finalize the upload.
      // Example:
      // await ref.read(profileEditProvider.notifier).save(
      //   displayName: _displayNameCtrl.text.trim(),
      //   bio: _bioCtrl.text.trim(),
      //   languages: _selectedLanguages.toList(),
      //   specialties: _selectedSpecialties.toList(),
      //   profileImageUrl: _uploadedTempKey,
      //   experienceYears: int.tryParse(_experienceCtrl.text),
      // );
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileUpdated)),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save profile. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: tt.labelSmall?.copyWith(
                color: AppColors.textDisabled,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: child,
        ),
      ],
    );
  }
}
