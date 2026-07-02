import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Subscription/Model/ccavenue_init_response.dart';

class CcavenueCheckoutResult {
  final bool cancelled;
  final String callbackUrl;
  final String? encResp;

  const CcavenueCheckoutResult({
    required this.cancelled,
    required this.callbackUrl,
    required this.encResp,
  });
}

class CcavenueCheckoutScreen extends StatefulWidget {
  final CcavenueInitData data;
  const CcavenueCheckoutScreen({super.key, required this.data});

  @override
  State<CcavenueCheckoutScreen> createState() => _CcavenueCheckoutScreenState();
}

class _CcavenueCheckoutScreenState extends State<CcavenueCheckoutScreen> {
  static const MethodChannel _paymentLauncherChannel = MethodChannel(
    'tringo_customer/payment_launcher',
  );

  late final WebViewController _controller;
  bool _handledCallback = false;
  String? _lastExternalLaunchUrl;
  DateTime? _lastExternalLaunchAt;

  bool _isCallbackUrl(String url) {
    final u = url.trim();
    if (u.isEmpty) return false;
    final redirect = (widget.data.redirectUrl ?? '').trim();
    final cancel = (widget.data.cancelUrl ?? '').trim();
    if (redirect.isNotEmpty && u.startsWith(redirect)) return true;
    if (cancel.isNotEmpty && u.startsWith(cancel)) return true;

    // Fallback match.
    return u.contains('/api/v1/subscriptions/ccavenue/callback');
  }

  Future<String?> _tryReadEncResp() async {
    try {
      final dynamic res = await _controller.runJavaScriptReturningResult(
        '''
(() => {
  try {
    const el = document.querySelector('input[name="encResp"]');
    if (el && el.value) return el.value;
    const params = new URLSearchParams(window.location.search || '');
    const v = params.get('encResp') || params.get('encresp');
    if (v) return v;
    return '';
  } catch (e) {
    return '';
  }
})()
''',
      );

      // Some platforms wrap strings in quotes.
      final s = (res ?? '').toString();
      final unquoted = s.startsWith('"') && s.endsWith('"')
          ? jsonDecode(s).toString()
          : s;
      final v = unquoted.trim();
      return v.isEmpty ? null : v;
    } catch (_) {
      return null;
    }
  }

  Future<bool> _tryLaunchExternal(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;

    if (Platform.isAndroid) {
      try {
        final launched = await _paymentLauncherChannel.invokeMethod<bool>(
          'launchExternalPaymentUrl',
          {'url': trimmed},
        );
        if (launched == true) return true;
      } catch (_) {
        // Fall through to url_launcher below.
      }
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return false;

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  bool _isExternalScheme(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    if (scheme.isEmpty) return false;
    return !const {
      'http',
      'https',
      'about',
      'data',
      'javascript',
      'blob',
      'file',
    }.contains(scheme);
  }

  bool _isDuplicateExternalLaunch(String url) {
    final now = DateTime.now();
    final lastAt = _lastExternalLaunchAt;
    if (_lastExternalLaunchUrl == url &&
        lastAt != null &&
        now.difference(lastAt).inMilliseconds < 1500) {
      return true;
    }
    _lastExternalLaunchUrl = url;
    _lastExternalLaunchAt = now;
    return false;
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _recoverFromUnknownSchemePage() async {
    try {
      if (await _controller.canGoBack()) {
        await _controller.goBack();
      }
    } catch (_) {
      // Ignore recovery errors; the user can retry manually.
    }
  }

  Future<void> _handleExternalPaymentLaunch(
    String url, {
    bool recoverWebView = false,
  }) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty || _isDuplicateExternalLaunch(trimmed)) return;

    final ok = await _tryLaunchExternal(trimmed);

    if (recoverWebView) {
      unawaited(_recoverFromUnknownSchemePage());
    }

    if (!ok && mounted) {
      _showInfo(
        'Unable to open payment app. Please install a supported UPI app and try again.',
      );
    }
  }

  Future<void> _injectExternalSchemeBridge() async {
    try {
      await _controller.runJavaScript('''
(() => {
  if (window.__tringoPaymentBridgeInstalled) return;
  window.__tringoPaymentBridgeInstalled = true;

  const safeSchemes = /^(https?:|about:|data:|javascript:|blob:|file:)/i;

  function forwardIfExternal(rawUrl) {
    if (typeof rawUrl !== 'string') return false;
    const url = rawUrl.trim();
    if (!url || safeSchemes.test(url)) return false;

    try {
      if (window.TringoPaymentBridge && window.TringoPaymentBridge.postMessage) {
        window.TringoPaymentBridge.postMessage(url);
        return true;
      }
    } catch (_) {}

    return false;
  }

  document.addEventListener('click', (event) => {
    let node = event.target;
    while (node && node.tagName !== 'A') node = node.parentElement;
    if (!node) return;

    const href = node.getAttribute('href') || node.href || '';
    if (forwardIfExternal(href)) {
      event.preventDefault();
      event.stopPropagation();
    }
  }, true);

  document.addEventListener('submit', (event) => {
    const form = event.target;
    if (!form) return;
    const action = form.getAttribute('action') || form.action || '';
    if (forwardIfExternal(action)) {
      event.preventDefault();
      event.stopPropagation();
    }
  }, true);

  if (window.HTMLAnchorElement && HTMLAnchorElement.prototype) {
    const originalAnchorClick = HTMLAnchorElement.prototype.click;
    HTMLAnchorElement.prototype.click = function() {
      const href = this.getAttribute('href') || this.href || '';
      if (forwardIfExternal(href)) return;
      return originalAnchorClick.call(this);
    };
  }

  if (window.HTMLFormElement && HTMLFormElement.prototype) {
    const originalFormSubmit = HTMLFormElement.prototype.submit;
    HTMLFormElement.prototype.submit = function() {
      const action = this.getAttribute('action') || this.action || '';
      if (forwardIfExternal(action)) return;
      return originalFormSubmit.call(this);
    };
  }

  const originalOpen = window.open ? window.open.bind(window) : null;
  window.open = function(url, ...rest) {
    if (typeof url === 'string' && forwardIfExternal(url)) return null;
    return originalOpen ? originalOpen(url, ...rest) : null;
  };

  const originalAssign = window.location.assign.bind(window.location);
  window.location.assign = function(url) {
    if (typeof url === 'string' && forwardIfExternal(url)) return;
    return originalAssign(url);
  };

  const originalReplace = window.location.replace.bind(window.location);
  window.location.replace = function(url) {
    if (typeof url === 'string' && forwardIfExternal(url)) return;
    return originalReplace(url);
  };
})();
''');
    } catch (_) {
      // Ignore injection failures; navigation delegate still handles many cases.
    }
  }

  @override
  void initState() {
    super.initState();

    final form = widget.data.form;
    final action = (form?.action ?? '').trim();
    final encRequest = (form?.encRequest ?? '').trim();
    final accessCode = (form?.accessCode ?? '').trim();

    final html = '''
<!doctype html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tringo Checkout</title>
  </head>
  <body>
    <form id="cc_form" action="${htmlEscape.convert(action)}" method="POST">
      <input type="hidden" name="encRequest" value="${htmlEscape.convert(encRequest)}" />
      <input type="hidden" name="access_code" value="${htmlEscape.convert(accessCode)}" />
    </form>
    <script>
      document.getElementById('cc_form').submit();
    </script>
  </body>
</html>
''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'TringoPaymentBridge',
        onMessageReceived: (message) {
          unawaited(
            _handleExternalPaymentLaunch(
              message.message,
              recoverWebView: true,
            ),
          );
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            _handledCallback = false;
          },
          onPageFinished: (url) async {
            unawaited(_injectExternalSchemeBridge());
            if (_handledCallback) return;
            if (!_isCallbackUrl(url)) return;
            _handledCallback = true;
            final encResp = await _tryReadEncResp();
            if (!mounted) return;
            Navigator.of(context).pop(
              CcavenueCheckoutResult(
                cancelled: false,
                callbackUrl: url,
                encResp: encResp,
              ),
            );
          },
          onWebResourceError: (error) {
            // A UPI / intent redirect (upi:, phonepe:, tez:, intent:, ...) that
            // slipped past onNavigationRequest fails here as
            // ERR_UNKNOWN_URL_SCHEME. Launch the offending URL in the external
            // app instead of just recovering, so UPI payments actually proceed.
            if (error.description.contains('ERR_UNKNOWN_URL_SCHEME')) {
              final failedUrl = error.url?.trim() ?? '';
              if (failedUrl.isNotEmpty) {
                unawaited(
                  _handleExternalPaymentLaunch(
                    failedUrl,
                    recoverWebView: true,
                  ),
                );
              } else {
                unawaited(_recoverFromUnknownSchemePage());
              }
            }
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null && _isExternalScheme(uri)) {
              unawaited(
                _handleExternalPaymentLaunch(
                  request.url,
                  recoverWebView: true,
                ),
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(html);
  }

  Future<void> _close() async {
    if (!mounted) return;
    Navigator.of(context).pop(
      const CcavenueCheckoutResult(
        cancelled: true,
        callbackUrl: '',
        encResp: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        surfaceTintColor: AppColor.white,
        elevation: 0,
        leading: IconButton(
          onPressed: _close,
          icon: const Icon(Icons.close, color: AppColor.darkBlue),
        ),
        title: Text(
          'Subscription Payment',
          style: GoogleFont.Mulish(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColor.darkBlue,
          ),
        ),
      ),
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
