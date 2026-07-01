import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tringo_app/Core/app_go_routes.dart';

/// Centralised session reset.
///
/// A bare `prefs.clear()` on logout / account deletion left the previous user's
/// in-memory Riverpod state (home, profile, wallet notifiers) alive, which then
/// leaked into the next login. `forceLogout()` additionally rebuilds the root
/// ProviderScope so every provider is recreated from scratch.
class SessionManager {
  SessionManager._();

  static bool _isResetting = false;
  static ValueNotifier<int>? _providerScopeResetSignal;

  /// Bound once from the app root (main.dart) to the ProviderScope seed.
  static void bindProviderScopeResetSignal(ValueNotifier<int> signal) {
    _providerScopeResetSignal = signal;
  }

  static void _resetProviderScope() {
    final signal = _providerScopeResetSignal;
    if (signal == null) return;
    signal.value = signal.value + 1;
  }

  static Future<void> _clearLocalUserData() async {
    final prefs = await SharedPreferences.getInstance();
    // Do not leak any user-specific leftovers (tokens, cached ids, flags).
    await prefs.clear();
  }

  /// Full local reset: clears prefs, recreates all Riverpod providers and
  /// returns to the login screen. Safe to call after logout OR account deletion
  /// (does not hit the backend).
  static Future<void> forceLogout() async {
    if (_isResetting) return;
    _isResetting = true;
    try {
      await _clearLocalUserData();
      _resetProviderScope();
      goRouter.go(AppRoutes.loginPath);
    } finally {
      _isResetting = false;
    }
  }
}
