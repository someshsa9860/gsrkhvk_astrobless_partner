import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _chatRateCtrl = TextEditingController(text: '30');
  final _callRateCtrl = TextEditingController(text: '40');

  final _selectedSpecialties = <String>{};
  final _selectedLanguages = <String>{'Hindi', 'English'};

  bool _isSubmitting = false;

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
    _pageController.dispose();
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _chatRateCtrl.dispose();
    _callRateCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    if (_page > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  bool get _canAdvance => switch (_page) {
        0 => _nameCtrl.text.trim().isNotEmpty,
        1 => _selectedSpecialties.isNotEmpty,
        2 => _selectedLanguages.isNotEmpty,
        3 => _chatRateCtrl.text.isNotEmpty && _callRateCtrl.text.isNotEmpty,
        _ => true,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar + back
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  if (_page > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: _back,
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Row(
                      children: List.generate(4, (i) {
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
                            decoration: BoxDecoration(
                              color: i <= _page
                                  ? AppColors.primary
                                  : AppColors.borderDark,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _Step0(nameCtrl: _nameCtrl, bioCtrl: _bioCtrl, onChanged: () => setState(() {})),
                  _Step1(
                    specialties: _allSpecialties,
                    selected: _selectedSpecialties,
                    onChanged: (s, v) => setState(() => v ? _selectedSpecialties.add(s) : _selectedSpecialties.remove(s)),
                  ),
                  _Step2(
                    languages: _allLanguages,
                    selected: _selectedLanguages,
                    onChanged: (l, v) => setState(() => v ? _selectedLanguages.add(l) : _selectedLanguages.remove(l)),
                  ),
                  _Step3(
                    chatRateCtrl: _chatRateCtrl,
                    callRateCtrl: _callRateCtrl,
                    onChanged: () => setState(() {}),
                  ),
                ],
              ),
            ),

            // Bottom CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: AppButton(
                label: _page == 3 ? l10n.getStarted : l10n.continueButton,
                loading: _isSubmitting,
                onPressed: _canAdvance ? _next : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step0 extends StatelessWidget {
  const _Step0({required this.nameCtrl, required this.bioCtrl, required this.onChanged});
  final TextEditingController nameCtrl;
  final TextEditingController bioCtrl;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text('👤', style: TextStyle(fontSize: 48)).animate().scale(),
          const SizedBox(height: 16),
          Text(
            l10n.buildProfile,
            style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
          const SizedBox(height: 8),
          Text(
            l10n.buildProfileSubtitle,
            style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 32),
          AppTextField(
            controller: nameCtrl,
            label: l10n.nameAlias,
            hint: l10n.nameAliasHint,
            autofocus: true,
            onChanged: (_) => onChanged(),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          AppTextField(
            controller: bioCtrl,
            label: l10n.bioLabel,
            hint: l10n.bioDescHint,
            maxLines: 4,
            onChanged: (_) => onChanged(),
          ).animate().fadeIn(delay: 250.ms),
        ],
      ),
    );
  }
}

class _Step1 extends StatelessWidget {
  const _Step1({required this.specialties, required this.selected, required this.onChanged});
  final List<String> specialties;
  final Set<String> selected;
  final void Function(String, bool) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text('🔮', style: TextStyle(fontSize: 48)).animate().scale(),
          const SizedBox(height: 16),
          Text(
            l10n.yourSpecialties,
            style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 8),
          Text(
            l10n.specialtiesHint,
            style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 28),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: specialties.asMap().entries.map((e) {
              final s = e.value;
              final isSelected = selected.contains(s);
              return GestureDetector(
                onTap: () => onChanged(s, !isSelected),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.cardDark,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.borderDark,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    s,
                    style: tt.bodyMedium?.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ).animate(delay: Duration(milliseconds: e.key * 30)).fadeIn().scale(begin: const Offset(0.9, 0.9)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Step2 extends StatelessWidget {
  const _Step2({required this.languages, required this.selected, required this.onChanged});
  final List<String> languages;
  final Set<String> selected;
  final void Function(String, bool) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text('🗣️', style: TextStyle(fontSize: 48)).animate().scale(),
          const SizedBox(height: 16),
          Text(
            l10n.languagesYouSpeak,
            style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 8),
          Text(
            l10n.languagesHint,
            style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 28),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: languages.asMap().entries.map((e) {
              final l = e.value;
              final isSelected = selected.contains(l);
              return GestureDetector(
                onTap: () => onChanged(l, !isSelected),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent.withValues(alpha: 0.12)
                        : AppColors.cardDark,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.borderDark,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    l,
                    style: tt.bodyMedium?.copyWith(
                      color: isSelected ? AppColors.accent : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ).animate(delay: Duration(milliseconds: e.key * 30)).fadeIn(),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Step3 extends StatelessWidget {
  const _Step3({required this.chatRateCtrl, required this.callRateCtrl, required this.onChanged});
  final TextEditingController chatRateCtrl;
  final TextEditingController callRateCtrl;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text('💰', style: TextStyle(fontSize: 48)).animate().scale(),
          const SizedBox(height: 16),
          Text(
            l10n.setYourRates,
            style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 8),
          Text(
            l10n.ratesSubtitle,
            style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 32),
          _RateCard(
            emoji: '💬',
            label: l10n.chatRateTitle,
            subtitle: l10n.chatRateDesc,
            controller: chatRateCtrl,
            onChanged: onChanged,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          _RateCard(
            emoji: '📞',
            label: l10n.callRateTitle,
            subtitle: l10n.callRateDesc,
            controller: callRateCtrl,
            onChanged: onChanged,
          ).animate().fadeIn(delay: 250.ms),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.minRateHint,
                    style: tt.bodySmall?.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

class _RateCard extends StatelessWidget {
  const _RateCard({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.controller,
    required this.onChanged,
  });

  final String emoji;
  final String label;
  final String subtitle;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(subtitle, style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text('₹', style: tt.titleMedium?.copyWith(color: AppColors.accent, fontWeight: FontWeight.w700)),
          SizedBox(
            width: 64,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (_) => onChanged(),
              style: tt.titleLarge?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                fillColor: Colors.transparent,
                filled: false,
              ),
            ),
          ),
          Text('/min', style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
