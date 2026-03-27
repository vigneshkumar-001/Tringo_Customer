import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  AppPrefs._(); // no instance

  static const _kPhoneVerifyToken = 'primaryPhoneVerificationToken';
  static const String _token = 'token';
  static const String _refreshToken = 'refreshToken';
  static const String _sessionToken = 'sessionToken';
  static const String _role = 'role';
  static const String _isProfileCompleted = 'isProfileCompleted';
  static const String _callerIdOverlayEnabled = 'caller_id_overlay_enabled';
  static const String _overlaySettingsAutoOpenedOnce =
      'overlay_settings_auto_opened_once';

  static Future<void> setVerificationToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kPhoneVerifyToken, token);
  }

  static Future<void> setIsProfileCompleted(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_isProfileCompleted, value);
  }

  static Future<String?> getVerificationToken() async {
    final sp = await SharedPreferences.getInstance();
    final t = sp.getString(_kPhoneVerifyToken);
    return (t == null || t.isEmpty) ? null : t;
  }

  static Future<void> clearVerificationToken() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kPhoneVerifyToken);
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_token, token);
  }

  static Future<void> setRefreshToken(String businessProfileId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshToken, businessProfileId);
  }

  static Future<void> setSessionToken(String sessionToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionToken, sessionToken);
  }

  static Future<void> setRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_role, role);
  }

  /// Read
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_token);
  }

  static Future<bool?> getIsProfileComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isProfileCompleted);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshToken);
  }

  static Future<String?> getSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionToken);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_role);
  }

  static Future<void> clearIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_token);
    await prefs.remove(_role);
    await prefs.remove(_sessionToken);
    await prefs.remove(_refreshToken);
    // _cachedVerificationToken = null;
  }

  // Caller ID / Overlay feature toggle
  static Future<void> setCallerIdOverlayEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_callerIdOverlayEnabled, value);
  }

  static Future<bool> getCallerIdOverlayEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    // Default ON (user can disable from Profile).
    return prefs.getBool(_callerIdOverlayEnabled) ?? true;
  }

  static Future<bool> getOverlaySettingsAutoOpenedOnce() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_overlaySettingsAutoOpenedOnce) ?? false;
  }

  static Future<void> setOverlaySettingsAutoOpenedOnce(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_overlaySettingsAutoOpenedOnce, value);
  }
}
