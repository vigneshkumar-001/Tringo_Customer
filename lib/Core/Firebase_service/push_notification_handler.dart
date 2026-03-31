import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:tringo_app/Core/Const/app_logger.dart';
import 'package:tringo_app/Core/app_go_routes.dart';

class PushNotificationHandler {
  PushNotificationHandler._();

  static Future<void> handleData(Map<String, dynamic> rawData) async {
    var data = rawData.map((k, v) => MapEntry(k.toString(), v));
    data = _unwrapPayload(data);

    final eventType = _pick(data, const ['eventType', 'event_type', 'event']);
    if (eventType.isEmpty) {
      _goFallback(reason: 'missing eventType', data: data);
      return;
    }

    final event = eventType.trim().toUpperCase();
    AppLogger.log.i('🔔 push eventType=$event data=$data');

    switch (event) {
      case 'SMART_CONNECT_RESPONSE': {
        final requestId = _pick(data, const ['requestId', 'requestedId']);
        if (requestId.isEmpty) {
          _goFallback(reason: 'missing requestId', data: data);
          return;
        }

        _pushUri(
          Uri(
            path: '/smart-connect/details',
            queryParameters: {'requestId': requestId},
          ),
        );
        return;
      }

      case 'PRODUCT_CREATED': {
        final productId = _pick(data, const ['productId', 'productID']);
        if (productId.isNotEmpty) {
          _pushUri(
            Uri(
              path: '/product/details',
              queryParameters: {'productId': productId},
            ),
          );
          return;
        }

        final shopId = _pick(data, const ['shopId', 'shopID']);
        if (shopId.isNotEmpty) {
          _pushUri(
            Uri(
              path: '/shop/details',
              queryParameters: {'shopId': shopId, 'tab': '3'},
            ),
          );
          return;
        }

        _goFallback(reason: 'missing productId/shopId', data: data);
        return;
      }

      case 'SERVICE_CREATED': {
        final serviceId = _pick(data, const ['serviceId', 'serviceID']);
        if (serviceId.isNotEmpty) {
          _pushUri(
            Uri(
              path: '/service/details',
              queryParameters: {'serviceId': serviceId},
            ),
          );
          return;
        }

        final shopId = _pick(data, const ['shopId', 'shopID']);
        if (shopId.isNotEmpty) {
          _pushUri(
            Uri(
              path: '/shop/details',
              queryParameters: {'shopId': shopId, 'tab': '4'},
            ),
          );
          return;
        }

        _goFallback(reason: 'missing serviceId/shopId', data: data);
        return;
      }

      case 'APP_OFFER_CREATED': {
        // Customer app currently doesn't have a dedicated "app offer details" screen.
        // Best effort: open the related shop's details page.
        final shopId = _pick(data, const ['shopId', 'shopID']);
        if (shopId.isNotEmpty) {
          _pushUri(
            Uri(
              path: '/shop/details',
              queryParameters: {'shopId': shopId, 'tab': '4'},
            ),
          );
          return;
        }
        _goFallback(reason: 'missing shopId', data: data);
        return;
      }

      case 'SURPRISE_OFFER_CREATED': {
        final shopId = _pick(data, const ['shopId', 'shopID']);
        final offerId = _pick(data, const ['offerId', 'offerID']);
        if (shopId.isEmpty || offerId.isEmpty) {
          _goFallback(reason: 'missing shopId/offerId', data: data);
          return;
        }

        _pushUri(
          Uri(
            path: '/surprise/offer',
            queryParameters: {'shopId': shopId, 'offerId': offerId},
          ),
        );
        return;
      }

      case 'TCOIN_TRANSFER_SENT': {
        _openWallet(
          type: 'SENT',
          toast: _tcoinToast(
            prefix: 'TCoins sent',
            amount: _pick(data, const ['amount']),
            counterpartyName: _pick(data, const ['counterpartyName']),
            balanceAfter: _pick(data, const ['balanceAfter']),
          ),
        );
        return;
      }

      case 'TCOIN_TRANSFER_RECEIVED': {
        _openWallet(
          type: 'RECEIVED',
          toast: _tcoinToast(
            prefix: 'TCoins received',
            amount: _pick(data, const ['amount']),
            counterpartyName: _pick(data, const ['counterpartyName']),
            balanceAfter: _pick(data, const ['balanceAfter']),
          ),
        );
        return;
      }

      case 'TCOIN_WITHDRAW_REQUESTED':
      case 'TCOIN_WITHDRAW_APPROVED':
      case 'TCOIN_WITHDRAW_REJECTED': {
        final requestId = _pick(data, const ['requestId', 'withdrawRequestId']);
        final amount = _pick(data, const ['amount']);
        final toast = [
          event.replaceAll('_', ' ').toLowerCase(),
          if (requestId.isNotEmpty) 'RequestId: $requestId',
          if (amount.isNotEmpty) 'Amount: $amount',
        ].join('\n');

        _openWallet(type: 'WITHDRAW', toast: toast);
        return;
      }

      case 'TCOIN_SIGNUP_BONUS':
      case 'TCOIN_REFERRAL_REWARD':
      case 'TCOIN_REVIEW_REWARD':
      case 'TCOIN_REFERRAL_REVIEW_REWARD':
      case 'TCOIN_ADMIN_GRANT':
      case 'TCOIN_ADMIN_DEDUCT': {
        final amount = _pick(data, const ['amount']);
        final reason = _pick(data, const ['reason']);
        final toast = [
          event.replaceAll('_', ' ').toLowerCase(),
          if (amount.isNotEmpty) 'Amount: $amount',
          if (reason.isNotEmpty) reason,
        ].join('\n');

        _openWallet(type: 'REWARDS', toast: toast);
        return;
      }

      case 'VENDOR_APPROVED': {
        // Customer app doesn't have vendor onboarding screens; open home as best effort.
        final vendorId = _pick(data, const ['vendorId', 'vendorID']);
        AppLogger.log.i('vendor approved vendorId=$vendorId');
        _go(AppRoutes.homeShellPath);
        return;
      }

      default:
        _goFallback(reason: 'unknown eventType=$event', data: data);
        return;
    }
  }

  static void _openWallet({required String type, String? toast}) {
    _push(
      '/wallet',
      extra: {
        'type': type,
        if (toast != null && toast.trim().isNotEmpty) 'toast': toast.trim(),
      },
    );
  }

  static String _tcoinToast({
    required String prefix,
    required String amount,
    required String counterpartyName,
    required String balanceAfter,
  }) {
    final parts = <String>[
      prefix,
      if (amount.trim().isNotEmpty) 'Amount: $amount',
      if (counterpartyName.trim().isNotEmpty) 'With: $counterpartyName',
      if (balanceAfter.trim().isNotEmpty) 'Balance: $balanceAfter',
    ];
    return parts.join('\n');
  }

  static String _pick(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final v = data[key];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return '';
  }

  static Map<String, dynamic> _unwrapPayload(Map<String, dynamic> data) {
    Map<String, dynamic> current = Map<String, dynamic>.from(data);

    bool hasEventType(Map<String, dynamic> m) =>
        _pick(m, const ['eventType', 'event_type', 'event']).isNotEmpty;

    for (var i = 0; i < 2; i++) {
      if (hasEventType(current)) return current;

      final dynamic inner = current['data'] ?? current['payload'];
      final innerMap = _asMap(inner);
      if (innerMap == null || innerMap.isEmpty) return current;

      // Merge inner on top so it can provide `eventType`, ids, etc.
      current = <String, dynamic>{
        ...current,
        ...innerMap,
      };
    }

    return current;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    if (value is String) {
      final s = value.trim();
      if (s.isEmpty) return null;
      try {
        final decoded = jsonDecode(s);
        if (decoded is Map) {
          return decoded.map((k, v) => MapEntry(k.toString(), v));
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static void _goFallback({required String reason, required Map<String, dynamic> data}) {
    AppLogger.log.w('push fallback: $reason data=$data');
    _go(AppRoutes.homeShellPath);
  }

  static void _pushUri(Uri uri) {
    final loc = uri.toString();
    _push(loc);
  }

  static void _go(String location) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        goRouter.go(location);
      } catch (e, st) {
        AppLogger.log.e('goRouter.go failed: $e\n$st');
      }
    });
  }

  static void _push(String location, {Object? extra}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        goRouter.push(location, extra: extra);
      } catch (e, st) {
        AppLogger.log.e('goRouter.push failed: $e\n$st');
        try {
          goRouter.go(AppRoutes.homeShellPath);
        } catch (_) {}
      }
    });
  }
}
