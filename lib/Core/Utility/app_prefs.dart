import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  AppPrefs._(); // no instance

  static const String _token = 'token';
  static const String _refreshToken = 'refreshToken';
  static const String _sessionToken = 'sessionToken';
  static const String _role = 'role';

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
}
