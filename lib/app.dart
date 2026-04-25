import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'core/auth/token_storage.dart';
import 'core/realtime/socket_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_colors.dart';
import 'core/theme/theme_provider.dart';
import 'l10n/app_localizations.dart';

final _routerProvider = Provider((ref) => buildRouter());

class PartnerApp extends ConsumerStatefulWidget {
  const PartnerApp({super.key});

  @override
  ConsumerState<PartnerApp> createState() => _PartnerAppState();
}

class _PartnerAppState extends ConsumerState<PartnerApp> {
  @override
  void initState() {
    super.initState();
    _reconnectSocketIfAuthenticated();
  }

  Future<void> _reconnectSocketIfAuthenticated() async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      ref.read(socketServiceProvider).connect(accessToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(_routerProvider);
    final themeAsync = ref.watch(appThemeColorsProvider);
    final colors = themeAsync.valueOrNull ?? AppThemeColors.defaults;

    return GetMaterialApp.router(
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
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
