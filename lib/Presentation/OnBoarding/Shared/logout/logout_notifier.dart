import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Api/api_providers.dart';
import 'package:tringo_app/Api/Repository/logout_repository.dart';
import 'package:tringo_app/Core/Const/app_logger.dart';
import 'package:tringo_app/Core/Utility/app_prefs.dart';
import 'package:tringo_app/Core/app_go_routes.dart';
import 'package:go_router/go_router.dart';

class LogoutState {
  final bool isLoggingOut;

  const LogoutState({this.isLoggingOut = false});

  LogoutState copyWith({bool? isLoggingOut}) {
    return LogoutState(isLoggingOut: isLoggingOut ?? this.isLoggingOut);
  }
}

class LogoutNotifier extends Notifier<LogoutState> {
  late final LogoutRepository _repo;

  @override
  LogoutState build() {
    _repo = ref.read(logoutRepositoryProvider);
    return const LogoutState();
  }

  /// Logs out locally immediately (no UI blocking), navigates to login (no back),
  /// and triggers remote logout in background if refreshToken exists.
  Future<void> logoutNow(BuildContext context) async {
    if (state.isLoggingOut) return;
    state = state.copyWith(isLoggingOut: true);

    final refreshToken = (await AppPrefs.getRefreshToken() ?? '').trim();
    final sessionToken = (await AppPrefs.getSessionToken() ?? '').trim();

    // Always perform local logout safely, regardless of remote API outcome.
    await AppPrefs.clearAuthAndUserCache();

    // Navigate immediately (do not wait for API).
    try {
      if (context.mounted) {
        context.goNamed(AppRoutes.login);
      }
    } catch (_) {
      // Ignore navigation errors (e.g. context disposed).
    }

    // Fire remote logout in background. If it fails (expired/revoked/invalid),
    // we still consider logout successful locally.
    if (refreshToken.isNotEmpty) {
      unawaited(
        _repo.logoutRemote(
          refreshToken: refreshToken,
          sessionToken: sessionToken.isEmpty ? null : sessionToken,
        ),
      );
    } else {
      AppLogger.log.w('logoutNow: refreshToken missing, skipped remote logout');
    }

    state = state.copyWith(isLoggingOut: false);
  }
}

final logoutNotifierProvider = NotifierProvider<LogoutNotifier, LogoutState>(
  LogoutNotifier.new,
);

