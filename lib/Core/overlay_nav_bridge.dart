import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'app_go_routes.dart';

class OverlayNavBridge {
  static const MethodChannel _channel = MethodChannel('tringo_overlay_nav');
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;
    _channel.setMethodCallHandler(_handleCall);
  }

  static Future<void> _handleCall(MethodCall call) async {
    if (call.method != 'openShopDetails') return;

    final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? const {};
    final shopId = (args['shopId'] as String?)?.trim() ?? '';
    final tab = (args['tab'] is int)
        ? args['tab'] as int
        : int.tryParse('${args['tab']}') ?? 4;

    if (shopId.isEmpty) return;

    final route = Uri(
      path: '/shop/details',
      queryParameters: {
        'shopId': shopId,
        'tab': '$tab',
      },
    ).toString();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      goRouter.go(route);
    });
  }
}