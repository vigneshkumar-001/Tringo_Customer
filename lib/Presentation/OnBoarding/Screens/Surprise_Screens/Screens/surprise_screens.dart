import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Surprise_Screens/Screens/Opened_surprise_offer_screen.dart';
import 'package:video_player/video_player.dart';

import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Surprise_Screens/Controller/surprise_notifier.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../Model/surprise_offer_response.dart';

class AppVideos {
  static const String surpriseOpenVideo = "Assets/Videos/surprise-opens.mp4";
}

class SurpriseScreens extends ConsumerStatefulWidget {
  final double shopLat;
  final double shopLng;
  final String shopId;

  const SurpriseScreens({
    super.key,
    required this.shopLat,
    required this.shopLng,
    required this.shopId,
  });

  @override
  ConsumerState<SurpriseScreens> createState() => _SurpriseScreensState();
}

class _SurpriseScreensState extends ConsumerState<SurpriseScreens>
    with TickerProviderStateMixin {
  // distance
  double remainingMeters = 0.0;
  bool _loadingDistance = true;
  StreamSubscription<Position>? _posSub;

  // location used for API
  double? _lat;
  double? _lng;

  // video
  VideoPlayerController? _videoCtrl;

  // navigation guard
  bool _navigated = false;
  bool _videoStarted = false;

  // premium transition state
  final GlobalKey _giftKey = GlobalKey();
  Rect? _giftRect;

  bool _giftHidden = false;
  bool _showTransitionVideo = false;

  late final AnimationController _rectCtrl;
  late final AnimationController _bounceCtrl;

  // Riverpod listen cancel
  late final ProviderSubscription<SurpriseState> _surpriseSub;

  @override
  void initState() {
    super.initState();

    _rectCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    // ✅ listen ONCE here (NOT in build)
    _surpriseSub = ref.listenManual<SurpriseState>(surpriseNotifierProvider, (
      prev,
      next,
    ) {
      final prevUnlock =
          prev?.surpriseStatusResponse?.data?.geo?.canUnlock ?? false;
      final nextUnlock =
          next.surpriseStatusResponse?.data.geo?.canUnlock ?? false;

      // start only when: loading finished AND false->true
      if (!next.isLoading && nextUnlock && !prevUnlock && !_videoStarted) {
        _videoStarted = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startPremiumGiftToVideoAndClaim();
        });
      }

      // if becomes false, stop everything (optional)
      if (!nextUnlock) {
        _stopAndResetVideoUI();
        // allow again when near again (optional):
        // _videoStarted = false;
      }
    });

    _initLocationAndStartTracking();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocationAndCallApi();
    });
  }

  @override
  void dispose() {
    _surpriseSub.close();
    _posSub?.cancel();
    _videoCtrl?.dispose();
    _rectCtrl.dispose();
    _bounceCtrl.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ---------------- LOCATION + API ----------------

  Future<void> _fetchLocationAndCallApi() async {
    try {
      setState(() => _loadingDistance = true);

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      _lat = pos.latitude;
      _lng = pos.longitude;

      _updateDistance(_lat!, _lng!);

      await ref
          .read(surpriseNotifierProvider.notifier)
          .surpriseStatusCheck(
            lat: _lat!,
            lng: _lng!, // ✅ real lng
            shopId: widget.shopId,
          );

      if (mounted) setState(() => _loadingDistance = false);
    } catch (e) {
      if (mounted) setState(() => _loadingDistance = false);
      _showMsg("Error: $e");
    }
  }

  Future<void> _initLocationAndStartTracking() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMsg("Location service OFF ❌");
        setState(() => _loadingDistance = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showMsg("Location permission denied ❌");
        setState(() => _loadingDistance = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      _updateDistance(pos.latitude, pos.longitude);

      _posSub?.cancel();
      _posSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
              distanceFilter: 2,
            ),
          ).listen((pos) {
            _updateDistance(pos.latitude, pos.longitude);
          });

      setState(() => _loadingDistance = false);
    } catch (e) {
      setState(() => _loadingDistance = false);
      _showMsg("Location error: $e");
    }
  }

  void _updateDistance(double userLat, double userLng) {
    final dist = Geolocator.distanceBetween(
      userLat,
      userLng,
      widget.shopLat,
      widget.shopLng,
    );
    final newMeters = dist < 0 ? 0.0 : dist;
    if (!mounted) return;
    setState(() => remainingMeters = newMeters);
  }

  // ---------------- PREMIUM GIFT -> VIDEO + CLAIM ----------------

  Rect? _getGiftRect() {
    final ctx = _giftKey.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;

    final topLeft = box.localToGlobal(Offset.zero);
    final size = box.size;
    return Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, size.height);
  }

  Future<void> _waitVideoEnd(VideoPlayerController ctrl) async {
    while (ctrl.value.isInitialized &&
        ctrl.value.position < ctrl.value.duration) {
      await Future.delayed(const Duration(milliseconds: 80));
    }
  }

  Future<void> _startPremiumGiftToVideoAndClaim() async {
    try {
      if (_navigated) return;
      if (_lat == null || _lng == null) {
        _showMsg("Location not found");
        return;
      }

      final rect = _getGiftRect();
      if (rect == null) return;

      _giftRect = rect;

      // 1) bounce
      if (mounted) setState(() {});
      await _bounceCtrl.forward(from: 0);

      // 2) prepare video
      _videoCtrl?.dispose();
      _videoCtrl = VideoPlayerController.asset(AppVideos.surpriseOpenVideo);

      await _videoCtrl!.initialize();
      await _videoCtrl!.setVolume(0.0);
      await _videoCtrl!.play();

      // 3) show overlay + expand rect
      if (!mounted) return;
      setState(() {
        _giftHidden = true;
        _showTransitionVideo = true;
      });

      await _rectCtrl.forward(from: 0);

      // 4) wait video end
      await _waitVideoEnd(_videoCtrl!);

      // 5) call CLAIM API
      final claimRes = await ref
          .read(surpriseNotifierProvider.notifier)
          .surpriseClaimed(lat: _lat!, lng: _lng!, shopId: widget.shopId);

      if (!mounted) return;

      if (claimRes == null) {
        final err = ref.read(surpriseNotifierProvider).error ?? "Claim failed";
        _showMsg(err);
        _stopAndResetVideoUI();
        _videoStarted = false; // allow retry
        return;
      }

      // 6) navigate with response
      if (_navigated) return;
      _navigated = true;

      _stopAndResetVideoUI();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OpenedSurpriseOfferScreen(response: claimRes),
        ),
      );
    } catch (e) {
      _showMsg("Video/Claim error: $e");
      _stopAndResetVideoUI();
      _videoStarted = false;
    }
  }

  void _stopAndResetVideoUI() {
    _videoCtrl?.pause();
    _videoCtrl?.dispose();
    _videoCtrl = null;

    _rectCtrl.stop();
    _rectCtrl.reset();
    _bounceCtrl.stop();
    _bounceCtrl.reset();

    if (!mounted) return;
    setState(() {
      _showTransitionVideo = false;
      _giftHidden = false;
      _giftRect = null;
    });
  }

  Rect _lerpRect(Rect a, Rect b, double t) {
    return Rect.fromLTWH(
      lerpDouble(a.left, b.left, t)!,
      lerpDouble(a.top, b.top, t)!,
      lerpDouble(a.width, b.width, t)!,
      lerpDouble(a.height, b.height, t)!,
    );
  }

  Widget _premiumTransitionVideoOverlay() {
    if (!_showTransitionVideo ||
        _giftRect == null ||
        _videoCtrl == null ||
        !_videoCtrl!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final media = MediaQuery.of(context);
    final fullRect = Rect.fromLTWH(0, 0, media.size.width, media.size.height);

    return AnimatedBuilder(
      animation: _rectCtrl,
      builder: (_, __) {
        final t = Curves.easeInOutCubic.transform(_rectCtrl.value);
        final r = _lerpRect(_giftRect!, fullRect, t);
        final radius = lerpDouble(18, 0, t)!;

        return Positioned(
          left: r.left,
          top: r.top,
          width: r.width,
          height: r.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              color: Colors.black,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoCtrl!.value.size.width,
                  height: _videoCtrl!.value.size.height,
                  child: VideoPlayer(_videoCtrl!),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(surpriseNotifierProvider);
    final data = state.surpriseStatusResponse?.data;

    final apiMeters = data?.geo?.remainingMeters;
    final metersText = "${(apiMeters ?? remainingMeters.toInt())} Mtrs";

    // final metersText = data?.geo?.remainingMeters != null
    //     ? "${data!.geo?.remainingMeters} Mtrs"
    //     : "${remainingMeters.toInt()} Mtrs";

    final bounceScale = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOutBack));

    return Stack(
      children: [
        Scaffold(
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF00A859), Color(0xFF00C853)],
              ),
              image: DecorationImage(
                image: AssetImage(AppImages.paymentBCImage),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // HEADER
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      child: SizedBox(
                        height: 44,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                child: const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const Text(
                              "Open Offer",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // MAIN CONTENT
                  Align(
                    alignment: const Alignment(0, 0.30),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(
                                      top: 120,
                                      left: 18,
                                      right: 18,
                                      bottom: 18,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        if (_loadingDistance)
                                          const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        else
                                          Text(
                                            "Move $metersText",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 34,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        Text(
                                          data?.ui.secondaryText.toString() ??
                                              ''
                                                  "Towards the shop to Unlock",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 30),

                                        Container(
                                          width: double.infinity,
                                          height: 2,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.centerRight,
                                              end: Alignment.centerLeft,
                                              colors: [
                                                AppColor.white.withOpacity(
                                                  0.01,
                                                ),
                                                AppColor.white4.withOpacity(
                                                  0.1,
                                                ),
                                                AppColor.white4.withOpacity(
                                                  0.1,
                                                ),
                                                AppColor.white4.withOpacity(
                                                  0.1,
                                                ),
                                                AppColor.white4.withOpacity(
                                                  0.1,
                                                ),
                                                AppColor.white4.withOpacity(
                                                  0.1,
                                                ),
                                                AppColor.white4.withOpacity(
                                                  0.1,
                                                ),
                                                AppColor.white.withOpacity(
                                                  0.01,
                                                ),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              1,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 30),

                                        // SHOP INFO
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      data?.shop?.name ?? '',

                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        CommonContainer.greenStarRating(
                                                          ratingCount:
                                                              data
                                                                  ?.shop
                                                                  ?.reviewCount
                                                                  .toString() ??
                                                              '0',
                                                          ratingStar:
                                                              data?.shop?.rating
                                                                  .toString() ??
                                                              '0',
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          "Opens Upto",
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                Colors.white70,
                                                          ),
                                                        ),
                                                        SizedBox(width: 3),
                                                        Text(
                                                          data?.shop?.closeTime
                                                                  .toString() ??
                                                              '',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                Colors.white70,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      data?.shop?.imageUrl ??
                                                      '',

                                                  height: 62,
                                                  width: 66,
                                                  fit: BoxFit.cover,
                                                  placeholder: (_, __) =>
                                                      Container(
                                                        height: 62,
                                                        width: 66,
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        child: const Icon(
                                                          Icons.store,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                  errorWidget: (_, __, ___) =>
                                                      Container(
                                                        height: 62,
                                                        width: 66,
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        child: const Icon(
                                                          Icons.broken_image,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // GIFT (bounces then hides when video starts)
                              Positioned(
                                top: -130,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: AnimatedBuilder(
                                    animation: _bounceCtrl,
                                    builder: (_, child) => Transform.scale(
                                      scale: bounceScale.value,
                                      child: child,
                                    ),
                                    child: IgnorePointer(
                                      ignoring: true,
                                      child: AnimatedOpacity(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        opacity: _giftHidden ? 0 : 1,
                                        child: SizedBox(
                                          key: _giftKey,
                                          height: 220,
                                          width: 270,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: Image.asset(
                                              AppImages.surpriseOfferGift,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.55),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.arrow_back,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Skip",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _fetchLocationAndCallApi,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.refresh,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Refresh",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // overlay video transition
        _premiumTransitionVideoOverlay(),
      ],
    );
  }
}

// class OpenedSurpriseOfferScreen extends StatelessWidget {
//   final SurpriseStatusResponse response;
//
//   const OpenedSurpriseOfferScreen({super.key, required this.response});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Text(
//           "Offer Opened 🎁\n\nResponse: ${response.data.geo.canUnlock.toString()}",
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }

/*import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:video_player/video_player.dart';

import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Surprise_Screens/Controller/surprise_notifier.dart';
import '../../../../../Core/Utility/app_color.dart';

class AppVideos {
  static const String surpriseOpenVideo = "Assets/Videos/surprise-opens.mp4";
}

class SurpriseScreens extends ConsumerStatefulWidget {
  final double shopLat;
  final double shopLng;
  final String shopId;

  const SurpriseScreens({
    super.key,
    required this.shopLat,
    required this.shopLng,
    required this.shopId,
  });

  @override
  ConsumerState<SurpriseScreens> createState() => _SurpriseScreensState();
}

class _SurpriseScreensState extends ConsumerState<SurpriseScreens> {
  // distance
  double remainingMeters = 0.0;
  bool _loadingDistance = true;
  StreamSubscription<Position>? _posSub;

  // location used for API
  double? _lat;
  double? _lng;

  // video overlay
  VideoPlayerController? _videoCtrl;
  bool _showFullScreenVideo = false;
  bool _videoStarted = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _initLocationAndStartTracking();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocationAndCallApi(); // first call
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _videoCtrl?.dispose();
    // restore UI overlays if you hide them
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // ---------------- LOCATION + API ----------------

  Future<void> _fetchLocationAndCallApi() async {
    try {
      setState(() => _loadingDistance = true);

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      _lat = pos.latitude;
      _lng = pos.longitude;

      // update local distance also
      _updateDistance(_lat!, _lng!);

      // call API
      await ref.read(surpriseNotifierProvider.notifier).surpriseStatusCheck(
        lat: _lat!,
        // lng: _lng!,
        lng: 78.097104,
        shopId: widget.shopId,
      );

      if (mounted) setState(() => _loadingDistance = false);
    } catch (e) {
      if (mounted) setState(() => _loadingDistance = false);
      _showMsg("Error: $e");
    }
  }

  Future<void> _initLocationAndStartTracking() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMsg("Location service OFF ❌");
        setState(() => _loadingDistance = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showMsg("Location permission denied ❌");
        setState(() => _loadingDistance = false);
        return;
      }

      // first fetch
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      _updateDistance(pos.latitude, pos.longitude);

      // live updates
      _posSub?.cancel();
      _posSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 2,
        ),
      ).listen((pos) {
        _updateDistance(pos.latitude, pos.longitude);
      });

      setState(() => _loadingDistance = false);
    } catch (e) {
      setState(() => _loadingDistance = false);
      _showMsg("Location error: $e");
    }
  }

  void _updateDistance(double userLat, double userLng) {
    final dist = Geolocator.distanceBetween(
      userLat,
      userLng,
      widget.shopLat,
      widget.shopLng,
    );

    final newMeters = dist < 0 ? 0.0 : dist;

    if (!mounted) return;
    setState(() => remainingMeters = newMeters);
  }

  // ---------------- VIDEO (FULL SCREEN) ----------------

  Future<void> _initAndPlayVideoFullScreen() async {
    try {
      if (_navigated) return;



      setState(() => _showFullScreenVideo = true);

      _videoCtrl?.dispose();
      _videoCtrl = VideoPlayerController.asset(AppVideos.surpriseOpenVideo);

      await _videoCtrl!.initialize();
      await _videoCtrl!.play();

      if (mounted) setState(() {});

      _videoCtrl!.addListener(() {
        final v = _videoCtrl;
        if (v == null || !v.value.isInitialized) return;

        final ended = v.value.position >= v.value.duration;
        if (ended && !_navigated) {
          _navigated = true;

          // restore overlays before navigating
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OpenedSurpriseOfferScreen()),
          );
        }
      });
    } catch (e) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      _showMsg("Video error: $e");
      if (mounted) setState(() => _showFullScreenVideo = false);
    }
  }

  Widget _fullScreenVideoOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black,
        child: Center(
          child: (_videoCtrl != null && _videoCtrl!.value.isInitialized)
              ? FittedBox(
            fit: BoxFit.cover, // ✅ fills full screen like animation
            child: SizedBox(
              width: _videoCtrl!.value.size.width,
              height: _videoCtrl!.value.size.height,
              child: VideoPlayer(_videoCtrl!),
            ),
          )
              : const CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(surpriseNotifierProvider);
    final data = state.surpriseStatusResponse?.data;

    final bool canUnlock = data?.geo.canUnlock ?? false;


    if (canUnlock && !_videoStarted) {
      _videoStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initAndPlayVideoFullScreen();
      });
    }

    // show meters: prefer API meters, else local meters
    final metersText = data?.geo.remainingMeters != null
        ? "${data!.geo.remainingMeters} Mtrs"
        : "${remainingMeters.toInt()} Mtrs";

    return Stack(
      children: [
        Scaffold(
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF00A859), Color(0xFF00C853)],
              ),
              image: DecorationImage(
                image: AssetImage(AppImages.paymentBCImage),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // HEADER
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      child: SizedBox(
                        height: 44,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                child: const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const Text(
                              "Open Offer",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // MAIN CONTENT
                  Align(
                    alignment: const Alignment(0, 0.30),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(

                                    width: double.infinity,
                                    padding: const EdgeInsets.only(
                                      top: 120,
                                      left: 18,
                                      right: 18,
                                      bottom: 18,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        if (_loadingDistance)
                                          const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        else
                                          Text(
                                            "Move $metersText",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 34,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        Text(
                                          data?.ui.secondaryText.toString() ??
                                              "Towards the shop to Unlock",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                        Container(
                                          width: double.infinity,
                                          height: 2,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.centerRight,
                                              end: Alignment.centerLeft,
                                              colors: [
                                                AppColor.white
                                                    .withOpacity(0.01),
                                                AppColor.white4
                                                    .withOpacity(0.1),
                                                AppColor.white4
                                                    .withOpacity(0.1),
                                                AppColor.white4
                                                    .withOpacity(0.1),
                                                AppColor.white4
                                                    .withOpacity(0.1),
                                                AppColor.white4
                                                    .withOpacity(0.1),
                                                AppColor.white4
                                                    .withOpacity(0.1),
                                                AppColor.white
                                                    .withOpacity(0.01),
                                              ],
                                            ),
                                            borderRadius:
                                            BorderRadius.circular(1),
                                          ),
                                        ),
                                        const SizedBox(height: 30),

                                        // SHOP INFO
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    Text(
                                                      data?.shop.name
                                                          .toString() ??
                                                          '',
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                        FontWeight.w800,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        CommonContainer
                                                            .greenStarRating(
                                                          ratingCount: data
                                                              ?.shop
                                                              .reviewCount
                                                              .toString() ??
                                                              '',
                                                          ratingStar: data
                                                              ?.shop
                                                              .rating
                                                              .toString() ??
                                                              '',
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        const Text(
                                                          "Opens Upto",
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                            FontWeight
                                                                .w600,
                                                            color: Colors
                                                                .white70,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 3),
                                                        const Text(
                                                          "9pm",
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                            FontWeight
                                                                .w600,
                                                            color: Colors
                                                                .white70,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              ClipRRect(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    12),
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                  data?.shop.imageUrl ??
                                                      '',
                                                  height: 62,
                                                  width: 66,
                                                  fit: BoxFit.cover,
                                                  placeholder:
                                                      (context, url) =>
                                                      Container(
                                                        height: 62,
                                                        width: 66,
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        child: const Icon(
                                                          Icons.store,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                  errorWidget: (context, url,
                                                      error) =>
                                                      Container(
                                                        height: 62,
                                                        width: 66,
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        child: const Icon(
                                                          Icons.broken_image,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // GIFT ON TOP (always show gift here; video plays fullscreen)
                              Positioned(
                                top: -130,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: SizedBox(
                                    height: 220,
                                    width: 270,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.asset(
                                        AppImages.surpriseOfferGift,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.55),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.arrow_back,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Skip",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _fetchLocationAndCallApi,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.refresh,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Refresh",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ✅ FULL SCREEN VIDEO OVERLAY (plays when canUnlock == true)
        if (_showFullScreenVideo) _fullScreenVideoOverlay(),
      ],
    );
  }
}

// dummy next page
class OpenedSurpriseOfferScreen extends StatelessWidget {
  const OpenedSurpriseOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Offer Opened 🎁")));
  }
}*/
