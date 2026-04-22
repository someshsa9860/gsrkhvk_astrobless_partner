import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_colors.dart';
import 'core/theme/theme_provider.dart';
import 'l10n/app_localizations.dart';

final _routerProvider = Provider((ref) => buildRouter());

class PartnerApp extends ConsumerWidget {
  const PartnerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    final themeAsync = ref.watch(appThemeColorsProvider);
    final colors = themeAsync.valueOrNull ?? AppThemeColors.defaults;

    return MaterialApp.router(
      title: 'Astrobless Partner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(colors),
      darkTheme: AppTheme.dark(colors),
      themeMode: ThemeMode.dark,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
