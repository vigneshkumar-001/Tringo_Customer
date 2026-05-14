// firebase_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Core/Const/app_logger.dart';
import 'package:tringo_app/Core/Firebase_service/fcm_token_uploader.dart';
import 'package:tringo_app/Core/Firebase_service/push_notification_handler.dart';
import 'package:tringo_app/Core/Utility/app_prefs.dart';

class FirebaseService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'flutter_notification',
    'flutter_notification_title',
    description: 'Default notifications channel',
    importance: Importance.high,
    enableLights: true,
    showBadge: true,
    playSound: true,
  );

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> initializeFirebase() async {
    // Local notifications init
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    // ✅ v20.x uses `settings:` (NOT `initializationSettings:`)
    await flutterLocalNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        AppLogger.log.i('🔔 Notification tapped. payload: ${response.payload}');
        final payload = (response.payload ?? '').trim();
        if (payload.isEmpty) return;

        try {
          final decoded = jsonDecode(payload);
          if (decoded is Map) {
            PushNotificationHandler.handleData(
              decoded.map((k, v) => MapEntry(k.toString(), v)),
            );
          }
        } catch (e, st) {
          AppLogger.log.w('Invalid notification payload: $e\n$st');
        }
      },
    );

    // Create Android channel (Android 8+)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _requestNotificationPermission();

    // Keep local token in sync. We don't call the backend from here because it may
    // require auth; instead we clear the "last sent" marker so the next
    // authenticated flow can re-send.
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      try {
        final t = token.trim();
        if (t.isEmpty) return;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcmToken', t);
        await AppPrefs.setLastSentFcmToken('');
        _fcmToken = t;

        // If user is already logged in, attempt sync immediately (otherwise no-op).
        unawaited(FcmTokenUploader.uploadIfPossible(fcmToken: t));
      } catch (_) {}
    });

    // iOS foreground presentation (harmless on Android)
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _requestNotificationPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      AppLogger.log.i(
        '🔔 Notification permission: ${settings.authorizationStatus}',
      );
    } catch (e, st) {
      AppLogger.log.w('requestPermission failed: $e\n$st');
    }
  }

  // ---- Robust token fetch with backoff (handles SERVICE_NOT_AVAILABLE) ----
  Future<String?> _getTokenWithBackoff() async {
    const delays = [1, 2, 4, 8]; // seconds
    for (final s in delays) {
      try {
        final t = await FirebaseMessaging.instance.getToken();
        if (t != null && t.isNotEmpty) return t;
      } catch (e) {
        AppLogger.log.w('getToken failed (retry in ${s}s): $e');
      }
      await Future.delayed(Duration(seconds: s));
    }

    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e, st) {
      AppLogger.log.e('getToken final failure: $e\n$st');
      return null;
    }
  }

  Future<void> fetchFCMTokenIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    _fcmToken = prefs.getString('fcmToken');

    if (_fcmToken != null && _fcmToken!.isNotEmpty) {
      AppLogger.log.i(
        'ℹ️ Existing FCM Token: ${AppLogger.redact(_fcmToken, showLast: 6)}',
      );
      return;
    }

    final token = await _getTokenWithBackoff();
    _fcmToken = token;

    if (token != null && token.isNotEmpty) {
      await prefs.setString('fcmToken', token);
      AppLogger.log.i('✅ FCM Token: ${AppLogger.redact(token, showLast: 6)}');

      // If user is already logged in, attempt sync immediately (otherwise no-op).
      unawaited(FcmTokenUploader.uploadIfPossible(fcmToken: token));
    } else {
      AppLogger.log.w('⚠️ No FCM token (device/config/network). Will retry later.');
    }
  }

  /// Call this when you receive an FCM message in foreground
  Future<void> showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'flutter_notification',
      'flutter_notification_title',
      channelDescription: 'Default notifications channel',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const details = NotificationDetails(android: androidDetails);

    final nid = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await flutterLocalNotificationsPlugin.show(
      id: nid,
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      notificationDetails: details,
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
    );
  }

  void listenToMessages({
    required void Function(RemoteMessage) onMessage,
    required void Function(RemoteMessage) onMessageOpenedApp,
  }) {
    FirebaseMessaging.onMessage.listen(onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
  }

  /// If app was terminated and opened by tapping a notification
  Future<RemoteMessage?> getInitialMessage() {
    return FirebaseMessaging.instance.getInitialMessage();
  }
}
