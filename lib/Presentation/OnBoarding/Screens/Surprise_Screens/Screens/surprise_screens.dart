import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Core/Utility/app_loader.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Surprise_Screens/Screens/Opened_surprise_offer_screen.dart';
import 'package:video_player/video_player.dart';

import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Surprise_Screens/Controller/surprise_notifier.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Login Screen/Controller/login_notifier.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Surprise_Screens/Model/surprise_offer_response.dart';

class AppVideos {
  static const String surpriseOpenVideo = "Assets/Videos/surprise-opens.mp4";
}

class SurpriseScreens extends ConsumerStatefulWidget {
  final double shopLat;
  final double shopLng;
  final String shopId;
  final String? subOfferId;

  const SurpriseScreens({
    super.key,
    required this.shopLat,
    required this.shopLng,
    required this.shopId,
    this.subOfferId,
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
  bool _fetchApiInFlight = false;

  // location used for API
  double? _lat;
  double? _lng;
  bool _statusCheckInFlight = false;
  DateTime? _lastStatusCheckAt;
  late final String _shopId;
  late final String _offerId;

  // video
  VideoPlayerController? _videoCtrl;
  bool _skipSurpriseOpenVideo = false;
  static const String _kSkipSurpriseOpenVideoPref = 'skip_surprise_open_video';

  // navigation guard
  bool _navigated = false;
  bool _videoStarted = false;
  int _unlockStartAttempts = 0;
  static const int _maxUnlockStartAttempts = 6;

  // premium transition state
  final GlobalKey _giftKey = GlobalKey();
  Rect? _giftRect;

  bool _giftHidden = false;
  bool _showTransitionVideo = false;
  bool _claimRedirectInFlight = false;

  late final AnimationController _rectCtrl;
  late final AnimationController _bounceCtrl;

  // Riverpod listen cancel
  late final ProviderSubscription<SurpriseState> _surpriseSub;

  @override
  void initState() {
    super.initState();

    _shopId = widget.shopId.trim();
    _offerId = (widget.subOfferId ?? '').trim();

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
      final resp = next.surpriseStatusResponse;
      if (resp != null && _isRespForThisOffer(resp)) {
        _maybeRedirectIfClaimed(resp);
      }

      final nextUnlock =
          next.surpriseStatusResponse?.data.geo?.canUnlock ?? false;

      // start when: loading finished AND canUnlock==true (guarded by _videoStarted)
      if (!next.isLoading &&
          nextUnlock &&
          !_videoStarted &&
          !_navigated &&
          resp != null &&
          _isRespForThisOffer(resp)) {
        _triggerUnlockStart();
      }

      // if becomes false, stop everything (optional)
      if (!nextUnlock) {
        _stopAndResetVideoUI();
        // allow again when near again
        _videoStarted = false;
        _unlockStartAttempts = 0;
      }
    });

    _initLocationAndStartTracking();
    _loadSkipVideoPref();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Delay provider modification until after first frame to satisfy Riverpod's
      // "do not modify providers during build/lifecycle" assertion (especially with go_router).
      ref.read(surpriseNotifierProvider.notifier).reset();
      _fetchLocationAndCallApi();
    });
  }

  Future<void> _loadSkipVideoPref() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final v = sp.getBool(_kSkipSurpriseOpenVideoPref) ?? false;
      if (!mounted) return;
      setState(() => _skipSurpriseOpenVideo = v);
    } catch (_) {
      // ignore
    }
  }

  Future<void> _persistSkipVideoPref(bool value) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setBool(_kSkipSurpriseOpenVideoPref, value);
    } catch (_) {
      // ignore
    }
  }

  bool _isRespForThisOffer(SurpriseStatusResponse resp) {
    final respShopId = (resp.data.shopId).toString().trim();
    if (respShopId.isNotEmpty && respShopId != _shopId) return false;

    if (_offerId.isEmpty) return true;

    final respOfferId =
        (resp.data.offer?.id ?? resp.data.legacy?.offerId ?? '').toString().trim();
    if (respOfferId.isEmpty) return true;
    return respOfferId == _offerId;
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
    if (_fetchApiInFlight) return;
    _fetchApiInFlight = true;
    try {
      setState(() => _loadingDistance = true);

      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }

      if (pos == null) {
        throw Exception("Unable to fetch location");
      }

      _lat = pos.latitude;
      _lng = pos.longitude;

      _updateDistance(_lat!, _lng!);

      _statusCheckInFlight = true;
      _lastStatusCheckAt = DateTime.now();
      await ref
          .read(surpriseNotifierProvider.notifier)
          .surpriseStatusCheck(
            lat: _lat!,
            lng: _lng!, // ✅ real lng
            shopId: widget.shopId,
            offerId: widget.subOfferId,
          );

    } catch (e) {
      _showMsg("Error: $e");
    } finally {
      _statusCheckInFlight = false;
      _fetchApiInFlight = false;
      if (mounted) setState(() => _loadingDistance = false);
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

      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }
      if (pos != null) {
        _updateDistance(pos.latitude, pos.longitude);
      }

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
    // keep latest position for claim/status checks
    _lat = userLat;
    _lng = userLng;

    final dist = Geolocator.distanceBetween(
      userLat,
      userLng,
      widget.shopLat,
      widget.shopLng,
    );
    final newMeters = dist < 0 ? 0.0 : dist;
    if (!mounted) return;
    setState(() => remainingMeters = newMeters);

    // Auto-check unlock state when user is very near, so "0 meter" can open without manual refresh.
    _maybeAutoStatusCheck(newMeters);
  }

  Future<void> _maybeAutoStatusCheck(double meters) async {
    if (!mounted) return;
    if (_statusCheckInFlight) return;
    if (_lat == null || _lng == null) return;

    final canUnlock =
        ref.read(surpriseNotifierProvider).surpriseStatusResponse?.data?.geo?.canUnlock ?? false;
    if (canUnlock) return;

    // Only when near the shop, and not too frequently.
    if (meters > 30) return;

    final now = DateTime.now();
    final last = _lastStatusCheckAt;
    if (last != null && now.difference(last) < const Duration(seconds: 5)) return;
    _lastStatusCheckAt = now;

    _statusCheckInFlight = true;
    try {
      await ref.read(surpriseNotifierProvider.notifier).surpriseStatusCheck(
            lat: _lat!,
            lng: _lng!,
            shopId: widget.shopId,
            offerId: widget.subOfferId,
          );
    } catch (_) {
      // ignore auto-check errors
    } finally {
      _statusCheckInFlight = false;
    }
  }

  Future<void> _maybeRedirectIfClaimed(SurpriseStatusResponse resp) async {
    if (_navigated || _claimRedirectInFlight) return;

    final stage = resp.data.stage.toString().toUpperCase();
    final isClaimed = resp.data.state?.isClaimed == true || stage == 'CLAIMED';
    if (!isClaimed) return;

    _claimRedirectInFlight = true;
    try {
      final code = (resp.data.code ?? '').toString().trim();
      final offerId = (widget.subOfferId ?? '').trim();
      final shopId = widget.shopId.trim();

      // If code is missing, fetch full claimed details from new GET API.
      if (code.isEmpty && offerId.isNotEmpty && shopId.isNotEmpty) {
        final api = ref.read(apiDataSourceProvider);
        final result =
            await api.surpriseOfferDetails(shopId: shopId, offerId: offerId);

        result.fold(
          (_) {},
          (fresh) {
            if (!mounted || _navigated) return;
            _navigated = true;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => OpenedSurpriseOfferScreen(response: fresh),
              ),
            );
          },
        );
        return;
      }

      if (!mounted) return;
      _navigated = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OpenedSurpriseOfferScreen(response: resp),
        ),
      );
    } finally {
      _claimRedirectInFlight = false;
    }
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
        final ok = await _ensureLatLngForUnlock();
        if (!ok) {
          _showMsg("Getting location… try again");
          _videoStarted = false;
          return;
        }
      }

      final rect = _getGiftRect();
      if (rect == null) {
        _videoStarted = false;
        return;
      }

      _giftRect = rect;

      // 1) bounce
      if (mounted) setState(() {});
      await _bounceCtrl.forward(from: 0);

      // 2) prepare video (fallback to "no video" for devices that can't decode)
      var playedVideo = false;
      if (!_skipSurpriseOpenVideo) {
        try {
          _videoCtrl?.dispose();
          _videoCtrl = VideoPlayerController.asset(AppVideos.surpriseOpenVideo);

          await _videoCtrl!.initialize();
          await _videoCtrl!.setVolume(0.0);
          await _videoCtrl!.play();
          playedVideo = true;
        } on PlatformException catch (_) {
          _skipSurpriseOpenVideo = true;
          await _persistSkipVideoPref(true);
          _videoCtrl?.dispose();
          _videoCtrl = null;
        } catch (_) {
          _skipSurpriseOpenVideo = true;
          await _persistSkipVideoPref(true);
          _videoCtrl?.dispose();
          _videoCtrl = null;
        }
      }

      // 3) show transition (with or without video)
      if (!mounted) return;
      setState(() {
        _giftHidden = true;
        _showTransitionVideo = playedVideo;
      });

      if (playedVideo) {
        await _rectCtrl.forward(from: 0);
        await _waitVideoEnd(_videoCtrl!);
      } else {
        // No video: keep a tiny delay so UI doesn't feel abrupt.
        await Future.delayed(const Duration(milliseconds: 220));
      }

      // 5) call CLAIM API
      final status = ref.read(surpriseNotifierProvider).surpriseStatusResponse;
      final offerIdToClaim = _offerId.isNotEmpty
          ? _offerId
          : (status?.data.offer?.id ?? status?.data.legacy?.offerId ?? '')
              .toString()
              .trim();
      final claimRes = await ref
          .read(surpriseNotifierProvider.notifier)
          .surpriseClaimed(
            lat: _lat!,
            lng: _lng!,
            shopId: widget.shopId,
            offerId: offerIdToClaim,
          );

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
      _showMsg("Something went wrong. Try again");
      _stopAndResetVideoUI();
      _videoStarted = false;
    }
  }

  Future<bool> _ensureLatLngForUnlock() async {
    try {
      // Fast path
      if (_lat != null && _lng != null) return true;

      // Try last known first (no GPS wait)
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        _lat = last.latitude;
        _lng = last.longitude;
        return true;
      }

      // Try current with a short timeout
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      ).timeout(const Duration(seconds: 3));

      _lat = pos.latitude;
      _lng = pos.longitude;
      return true;
    } catch (_) {
      return false;
    }
  }

  void _triggerUnlockStart() {
    if (_navigated) return;
    if (_videoStarted) return;

    if (_unlockStartAttempts >= _maxUnlockStartAttempts) return;
    _unlockStartAttempts++;
    _videoStarted = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _startPremiumGiftToVideoAndClaim();

      // If start failed due to missing rect/location, retry a few times.
      if (!_navigated && !_showTransitionVideo && !_videoStarted) {
        await Future.delayed(const Duration(milliseconds: 120));
        if (!mounted) return;
        final canUnlockNow = ref
                .read(surpriseNotifierProvider)
                .surpriseStatusResponse
                ?.data
                ?.geo
                ?.canUnlock ??
            false;
        if (canUnlockNow) _triggerUnlockStart();
      }
    });
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

  Widget _claimLoaderOverlay() {
    // When video is skipped (unsupported devices), show a lightweight loader
    // while claim API runs, instead of showing a technical error.
    if (_showTransitionVideo) return const SizedBox.shrink();
    if (!_giftHidden) return const SizedBox.shrink();
    if (_navigated) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.25),
        child: Center(
          child: ThreeDotsLoader(dotColor: Colors.white),
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
    final resp = state.surpriseStatusResponse;
    final data = (resp != null && _isRespForThisOffer(resp)) ? resp.data : null;
    final canUnlock = data?.geo?.canUnlock ?? false;

    // If canUnlock is already true on first response, ensure we auto-start at least once.
    if (!state.isLoading && canUnlock && !_navigated && !_videoStarted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final stillCanUnlock = ref
                .read(surpriseNotifierProvider)
                .surpriseStatusResponse
                ?.data
                ?.geo
                ?.canUnlock ??
            false;
        if (stillCanUnlock && !_videoStarted && !_navigated) _triggerUnlockStart();
      });
    }

    final apiMeters = data?.geo?.remainingMeters;
    final localMeters = remainingMeters.toInt();
    final shownMeters =
        apiMeters == null ? localMeters : (apiMeters < localMeters ? apiMeters : localMeters);
    final metersText = "$shownMeters Mtrs";

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
                                          AppLoader.circularLoader(
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
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.55),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 38.0,
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
                                  onTap: () async {
                                    if (canUnlock && !_videoStarted) {
                                      _videoStarted = true;
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        _startPremiumGiftToVideoAndClaim();
                                      });
                                      return;
                                    }
                                    await _fetchLocationAndCallApi();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          canUnlock ? Icons.lock_open : Icons.refresh,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          canUnlock ? "Unlock" : "Refresh",
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

        // overlay loader (fallback when video can't play)
        _claimLoaderOverlay(),
      ],
    );
  }
}
