import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Api/Repository/api_url.dart';
import 'package:tringo_app/Api/Repository/request.dart';
import 'package:tringo_app/Core/Const/app_logger.dart';
import 'package:tringo_app/Core/Utility/app_prefs.dart';
import 'package:tringo_app/Core/Utility/device_helper.dart';

/// Uploads the device FCM token to backend when the user is authenticated.
///
/// Goals:
/// - Avoid spamming backend (only send when token changes)
/// - Retry transient network/server failures
/// - Never log raw tokens
class FcmTokenUploader {
  static Future<bool> uploadIfPossible({
    required String fcmToken,
    bool force = false,
  }) async {
    final t = fcmToken.trim();
    if (t.isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    final authToken = (prefs.getString('token') ?? '').trim();
    if (authToken.isEmpty) {
      // Endpoint requires auth; skip until login.
      return false;
    }

    if (!force) {
      final lastSent = await AppPrefs.getLastSentFcmToken();
      if (lastSent != null && lastSent == t) return true;
    }

    final platform = Platform.isAndroid ? 'android' : 'ios';
    final deviceId = await DeviceIdHelper.getDeviceId();

    const delays = [1, 2, 4, 8]; // seconds
    for (final seconds in delays) {
      final result = await _tryUploadOnce(
        fcmToken: t,
        platform: platform,
        deviceId: deviceId,
      );
      if (result == _UploadResult.success) {
        await AppPrefs.setLastSentFcmToken(t);
        AppLogger.log.i(
          '✅ device-token synced: ${AppLogger.redact(t, showLast: 6)}',
        );
        return true;
      }
      if (result == _UploadResult.nonRetriableFailure) return false;
      await Future.delayed(Duration(seconds: seconds));
    }

    // Final attempt (no delay)
    final result = await _tryUploadOnce(
      fcmToken: t,
      platform: platform,
      deviceId: deviceId,
    );
    if (result == _UploadResult.success) {
      await AppPrefs.setLastSentFcmToken(t);
      AppLogger.log.i(
        '✅ device-token synced: ${AppLogger.redact(t, showLast: 6)}',
      );
      return true;
    }
    return false;
  }

  static bool _isRetriableDio(DioException e) {
    final code = e.response?.statusCode;
    if (code == 401 || code == 406) return false; // auth issues
    if (code != null && code >= 400 && code < 500) return false; // client error
    return true; // timeouts/network/5xx
  }

  static Future<_UploadResult> _tryUploadOnce({
    required String fcmToken,
    required String platform,
    required String deviceId,
  }) async {
    try {
      final resp = await Request.sendRequest(
        ApiUrl.fcmToken,
        {
          'fcmToken': fcmToken,
          'platform': platform,
          if (deviceId.trim().isNotEmpty) 'deviceId': deviceId,
        },
        'POST',
        true,
      );

      if (resp is! Response) return _UploadResult.retriableFailure;
      final data = resp.data;
      if (data is Map && data['status'] == true) return _UploadResult.success;

      final msg = (data is Map ? (data['message'] ?? '') : '').toString();
      if (msg.isNotEmpty) {
        AppLogger.log.w('device-token rejected: $msg');
      }
      return _UploadResult.nonRetriableFailure;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      AppLogger.log.w('device-token upload failed ($code): ${e.message}');
      return _isRetriableDio(e)
          ? _UploadResult.retriableFailure
          : _UploadResult.nonRetriableFailure;
    } catch (e, st) {
      AppLogger.log.w('device-token upload error: $e\n$st');
      return _UploadResult.retriableFailure;
    }
  }
}

enum _UploadResult { success, retriableFailure, nonRetriableFailure }

