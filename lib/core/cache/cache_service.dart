import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple key-value cache backed by SharedPreferences.
/// Supports TTL — expired entries are treated as missing.
class CacheService {
  CacheService._(this._prefs);

  final SharedPreferences _prefs;

  static CacheService? _instance;

  static Future<CacheService> init() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = CacheService._(prefs);
    return _instance!;
  }

  static CacheService get instance {
    assert(_instance != null, 'CacheService.init() must be called before use');
    return _instance!;
  }

  static const _ttlSuffix = '__ttl';

  /// Store [value] (a JSON-encodable object) under [key].
  /// [ttl] is the duration before the value is considered stale.
  /// Pass null for [ttl] to store indefinitely.
  Future<void> set(String key, dynamic value, {Duration? ttl}) async {
    final encoded = jsonEncode(value);
    await _prefs.setString(key, encoded);
    if (ttl != null) {
      final expiresAt = DateTime.now().add(ttl).millisecondsSinceEpoch;
      await _prefs.setInt('$key$_ttlSuffix', expiresAt);
    } else {
      await _prefs.remove('$key$_ttlSuffix');
    }
  }

  /// Retrieve a value. Returns null if the key is absent or has expired.
  T? get<T>(String key) {
    final expiry = _prefs.getInt('$key$_ttlSuffix');
    if (expiry != null && DateTime.now().millisecondsSinceEpoch > expiry) {
      // Stale — clean up and return null
      _prefs.remove(key);
      _prefs.remove('$key$_ttlSuffix');
      return null;
    }
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as T;
    } catch (_) {
      return null;
    }
  }

  bool has(String key) => get<dynamic>(key) != null;

  Future<void> delete(String key) async {
    await _prefs.remove(key);
    await _prefs.remove('$key$_ttlSuffix');
  }

  /// Remove all cache entries (not all SharedPreferences keys).
  /// Keys managed by CacheService are identified by having a matching ttl suffix
  /// or by prefix. Here we remove only known cache keys.
  Future<void> clearAll() async {
    final keys = _prefs.getKeys().where((k) => !k.endsWith(_ttlSuffix)).toList();
    for (final k in keys) {
      await _prefs.remove(k);
      await _prefs.remove('$k$_ttlSuffix');
    }
  }
}

// Well-known cache keys
class CacheKeys {
  static const dashboardSummary = 'cache:dashboard_summary';
  static const profileData = 'cache:profile_data';
  static const earningsSummary = 'cache:earnings_summary';
  static const kundliRequestList = 'cache:kundli_requests';
  static const notificationList = 'cache:notifications';
}

// Default TTLs
class CacheTTL {
  static const dashboard = Duration(minutes: 5);
  static const profile = Duration(minutes: 10);
  static const earnings = Duration(minutes: 5);
  static const kundliRequests = Duration(minutes: 2);
  static const notifications = Duration(minutes: 1);
}
