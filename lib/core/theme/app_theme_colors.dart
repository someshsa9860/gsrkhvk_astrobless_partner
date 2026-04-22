import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Dynamic brand colors fetched from the backend and injected into ThemeData.
///
/// Access via `Theme.of(context).extension<AppThemeColors>()` or the
/// `context.colors` shorthand defined below.
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.primary,
    required this.accent,
    required this.bgDark,
    required this.cardDark,
    required this.surfaceDark,
    required this.borderDark,
    required this.success,
    required this.error,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Color primary;
  final Color accent;
  final Color bgDark;
  final Color cardDark;
  final Color surfaceDark;
  final Color borderDark;
  final Color success;
  final Color error;
  final Color textPrimary;
  final Color textSecondary;

  /// Fallback defaults matching the static [AppColors] constants.
  static const defaults = AppThemeColors(
    primary: AppColors.primary,
    accent: AppColors.accent,
    bgDark: AppColors.bgDark,
    cardDark: AppColors.cardDark,
    surfaceDark: AppColors.surfaceDark,
    borderDark: AppColors.borderDark,
    success: AppColors.success,
    error: AppColors.error,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
  );

  /// Parses a map of hex color strings from the backend API.
  factory AppThemeColors.fromConfig(Map<String, dynamic> config) {
    Color hex(String key, Color fallback) {
      final value = config[key];
      if (value is! String) return fallback;
      try {
        final cleaned = value.replaceAll('#', '');
        return Color(int.parse('FF$cleaned', radix: 16));
      } catch (_) {
        return fallback;
      }
    }

    return AppThemeColors(
      primary: hex('primary', AppColors.primary),
      accent: hex('accent', AppColors.accent),
      bgDark: hex('bgDark', AppColors.bgDark),
      cardDark: hex('cardDark', AppColors.cardDark),
      surfaceDark: hex('surfaceDark', AppColors.surfaceDark),
      borderDark: hex('borderDark', AppColors.borderDark),
      success: hex('success', AppColors.success),
      error: hex('error', AppColors.error),
      textPrimary: hex('textPrimary', AppColors.textPrimary),
      textSecondary: hex('textSecondary', AppColors.textSecondary),
    );
  }

  @override
  AppThemeColors copyWith({
    Color? primary,
    Color? accent,
    Color? bgDark,
    Color? cardDark,
    Color? surfaceDark,
    Color? borderDark,
    Color? success,
    Color? error,
    Color? textPrimary,
    Color? textSecondary,
  }) {
    return AppThemeColors(
      primary: primary ?? this.primary,
      accent: accent ?? this.accent,
      bgDark: bgDark ?? this.bgDark,
      cardDark: cardDark ?? this.cardDark,
      surfaceDark: surfaceDark ?? this.surfaceDark,
      borderDark: borderDark ?? this.borderDark,
      success: success ?? this.success,
      error: error ?? this.error,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  AppThemeColors lerp(AppThemeColors? other, double t) {
    if (other == null) return this;
    return AppThemeColors(
      primary: Color.lerp(primary, other.primary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      bgDark: Color.lerp(bgDark, other.bgDark, t)!,
      cardDark: Color.lerp(cardDark, other.cardDark, t)!,
      surfaceDark: Color.lerp(surfaceDark, other.surfaceDark, t)!,
      borderDark: Color.lerp(borderDark, other.borderDark, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}

/// `context.colors` — shorthand access to [AppThemeColors] from any widget.
extension AppThemeColorsX on BuildContext {
  AppThemeColors get colors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.defaults;
}
