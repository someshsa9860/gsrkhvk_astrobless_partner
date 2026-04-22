import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'app_theme_colors.dart';

const _cacheKey = 'partner_theme_config';

final appThemeColorsProvider = FutureProvider<AppThemeColors>((ref) async {
  try {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.publicApiBaseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ));

    final response = await dio.get('/settings/theme');
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(data));

    return AppThemeColors.fromConfig(data);
  } catch (_) {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      try {
        return AppThemeColors.fromConfig(jsonDecode(cached) as Map<String, dynamic>);
      } catch (_) {}
    }
    return AppThemeColors.defaults;
  }
});
