import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';

/// Opens a shop's own website inside the app (no external browser hand-off).
/// Only http/https navigation is allowed - any other scheme (tel:, intent:,
/// mailto:, javascript:, etc.) a page tries to open is silently blocked,
/// since the target site is third-party content set by the shop owner and
/// this screen exposes no JavaScript bridge into the app.
class ShopWebsiteWebView extends StatefulWidget {
  const ShopWebsiteWebView({super.key, required this.url, this.title});

  final String url;
  final String? title;

  @override
  State<ShopWebsiteWebView> createState() => _ShopWebsiteWebViewState();
}

class _ShopWebsiteWebViewState extends State<ShopWebsiteWebView> {
  late final WebViewController _controller;
  double _progress = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColor.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            if (!mounted) return;
            setState(() => _progress = value / 100);
          },
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() => _hasError = false);
          },
          onWebResourceError: (_) {
            if (!mounted) return;
            setState(() => _hasError = true);
          },
          onNavigationRequest: (request) {
            final scheme = Uri.tryParse(request.url)?.scheme.toLowerCase();
            if (scheme == 'http' || scheme == 'https') {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle = (widget.title ?? '').trim().isNotEmpty
        ? widget.title!.trim()
        : (Uri.tryParse(widget.url)?.host ?? 'Website');

    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          displayTitle,
          overflow: TextOverflow.ellipsis,
          style: GoogleFont.Mulish(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        bottom: _progress < 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: _progress == 0 ? null : _progress,
                  minHeight: 2,
                  backgroundColor: AppColor.white2,
                  color: AppColor.blue,
                ),
              )
            : null,
      ),
      body: _hasError
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 40, color: AppColor.lightGray3),
                    const SizedBox(height: 12),
                    Text(
                      'Could not load this website. Please check your connection and try again.',
                      textAlign: TextAlign.center,
                      style: GoogleFont.Mulish(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.lightGray3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() => _hasError = false);
                        _controller.reload();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : WebViewWidget(controller: _controller),
    );
  }
}
