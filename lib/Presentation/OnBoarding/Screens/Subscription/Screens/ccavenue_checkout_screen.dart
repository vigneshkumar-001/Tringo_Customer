import 'dart:convert';

import 'package:flutter/material.dart';
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
  late final WebViewController _controller;
  bool _handledCallback = false;

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
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
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
