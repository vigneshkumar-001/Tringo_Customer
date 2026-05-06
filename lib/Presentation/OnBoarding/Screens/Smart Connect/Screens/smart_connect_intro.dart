import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import 'Smart_connect_search.dart';

class SmartConnectIntro extends StatefulWidget {
  const SmartConnectIntro({
    super.key,
    this.urlFallback = 'https://bknd.tringobiz.com/smart-connect.html',
    this.showSkipAfter = const Duration(seconds: 5),
    this.fallbackAutoNavigateAfter = const Duration(seconds: 20),
  });

  /// Fallback web page (used only when MP4 is not configured).
  final String urlFallback;

  /// Configure an MP4 intro without changing code:
  /// - `--dart-define=SMART_CONNECT_INTRO_MP4_URL=https://.../intro.mp4` (preferred)
  /// - or `--dart-define=SMART_CONNECT_INTRO_MP4_ASSET=Assets/Videos/intro.mp4`
  static const String mp4Url =
      String.fromEnvironment('SMART_CONNECT_INTRO_MP4_URL', defaultValue: '');
  static const String mp4Asset =
      String.fromEnvironment('SMART_CONNECT_INTRO_MP4_ASSET', defaultValue: '');
  static const String _defaultHtmlAsset =
      'Assets/SmartConnect/smart_connect_intro.html';

  final Duration showSkipAfter;
  final Duration fallbackAutoNavigateAfter;

  @override
  State<SmartConnectIntro> createState() => _SmartConnectIntroState();
}

class _SmartConnectIntroState extends State<SmartConnectIntro> {
  WebViewController? _webController;
  VideoPlayerController? _videoCtrl;

  Timer? _skipTimer;
  Timer? _fallbackTimer;
  Timer? _hintTimer;

  bool _skipVisible = false;
  bool _navigated = false;
  bool _pageReady = false;
  bool _hintVisible = false;

  @override
  void initState() {
    super.initState();

    _skipTimer = Timer(widget.showSkipAfter, () {
      if (!mounted) return;
      setState(() => _skipVisible = true);
    });

    _initPlayerOrFallback();
  }

  Future<void> _initPlayerOrFallback() async {
    // Prefer MP4 when configured, because the current web page does not contain a video element.
    final url = SmartConnectIntro.mp4Url.trim();
    final asset = SmartConnectIntro.mp4Asset.trim();

    // IMPORTANT: do NOT attempt a default MP4 asset path, because missing assets
    // cause noisy ExoPlayer errors. Only play MP4 when explicitly configured.
    if (url.isNotEmpty || asset.isNotEmpty) {
      try {
        final VideoPlayerController ctrl = url.isNotEmpty
            ? VideoPlayerController.networkUrl(Uri.parse(url))
            : VideoPlayerController.asset(asset);

        _videoCtrl = ctrl;
        await ctrl.initialize();
        if (!mounted) return;

        await ctrl.setLooping(false);
        await ctrl.setVolume(1.0);
        await ctrl.play();

        ctrl.addListener(() {
          final c = _videoCtrl;
          if (c == null) return;
          if (!c.value.isInitialized) return;
          final v = c.value;
          if (v.hasError) return;
          if (v.position >= v.duration && !_navigated) {
            _goNext();
          }
        });

        setState(() => _pageReady = true);
        _showHintOnce();
        return;
      } catch (e) {
        // fall through to web fallback (still lets user continue with Skip)
      }
    }

    // Next best: load the provided HTML animation as a local asset (plays like a video).
    try {
      final html = await rootBundle.loadString(SmartConnectIntro._defaultHtmlAsset);
      if (!mounted) return;

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(AppColor.white)
        ..addJavaScriptChannel(
          'SmartConnect',
          onMessageReceived: (JavaScriptMessage message) {
            if (message.message == 'ended') {
              _goNext();
            }
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              _pageReady = true;
              if (!mounted) return;
              setState(() {});
              _showHintOnce();
            },
          ),
        )
        ..loadHtmlString(html, baseUrl: widget.urlFallback);

      _webController = controller;
      _fallbackTimer = Timer(widget.fallbackAutoNavigateAfter, _goNext);
      return;
    } catch (_) {
      // Ignore and fall back to remote URL.
    }

    final allowedHost = Uri.tryParse(widget.urlFallback)?.host;
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColor.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final host = Uri.tryParse(request.url)?.host;
            if (allowedHost != null &&
                host != null &&
                host.isNotEmpty &&
                host != allowedHost) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (_) {
            _pageReady = true;
            if (!mounted) return;
            setState(() {});
            _showHintOnce();
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.urlFallback));

    _webController = controller;
    _fallbackTimer = Timer(widget.fallbackAutoNavigateAfter, _goNext);
  }

  @override
  void dispose() {
    _skipTimer?.cancel();
    _fallbackTimer?.cancel();
    _hintTimer?.cancel();
    _videoCtrl?.dispose();
    super.dispose();
  }

  void _showHintOnce() {
    if (_hintVisible) return;
    if (!mounted) return;
    setState(() => _hintVisible = true);
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _hintVisible = false);
    });
  }

  void _goNext() {
    if (_navigated) return;
    _navigated = true;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => SmartConnectSearch()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final video = _videoCtrl;
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Stack(
        children: [
          if (video != null && video.value.isInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: video.value.size.width,
                  height: video.value.size.height,
                  child: VideoPlayer(video),
                ),
              ),
            )
          else if (_webController != null)
            Positioned.fill(
              child: ColoredBox(
                color: AppColor.white,
                child: WebViewWidget(controller: _webController!),
              ),
            )
          else
            const Positioned.fill(
              child: ColoredBox(color: AppColor.white),
            ),

          if (!_pageReady)
            const Positioned.fill(
              child: ColoredBox(
                color: AppColor.white,
                child: Center(child: _ThreeDotLoader()),
              ),
            ),

          Positioned(
            top: pad.top + 12,
            right: pad.right + 12,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _skipVisible ? 1 : 0,
              child: IgnorePointer(
                ignoring: !_skipVisible,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.55),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onPressed: _goNext,
                  child: Text(
                    'Skip',
                    style: GoogleFont.Mulish(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: pad.top + 12,
            left: 12,
            right: 12,
            child: IgnorePointer(
              ignoring: true,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: _hintVisible ? 1 : 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.50),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      'What is Smart Connect? Let’s see…',
                      textAlign: TextAlign.center,
                      style: GoogleFont.Mulish(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreeDotLoader extends StatefulWidget {
  const _ThreeDotLoader();

  @override
  State<_ThreeDotLoader> createState() => _ThreeDotLoaderState();
}

class _ThreeDotLoaderState extends State<_ThreeDotLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value;
        final a1 = (1 - (t - 0.0).abs() * 3).clamp(0.25, 1.0);
        final a2 = (1 - (t - 0.33).abs() * 3).clamp(0.25, 1.0);
        final a3 = (1 - (t - 0.66).abs() * 3).clamp(0.25, 1.0);

        Widget dot(double opacity) => Opacity(
          opacity: opacity,
          child: Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: AppColor.darkBlue,
              shape: BoxShape.circle,
            ),
          ),
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            dot(a1),
            const SizedBox(width: 7),
            dot(a2),
            const SizedBox(width: 7),
            dot(a3),
          ],
        );
      },
    );
  }
}
