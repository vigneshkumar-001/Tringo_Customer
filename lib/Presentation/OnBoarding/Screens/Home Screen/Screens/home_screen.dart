// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart' as dotted;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:tringo_app/Core/Const/app_logger.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/app_loader.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';

import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Controller/home_notifier.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Surprise_Screens/Screens/surprise_screens.dart';

import '../../../../../Core/Utility/app_snackbar.dart';
import '../../../../../Core/Utility/map_urls.dart';
import '../../../../../Core/Widgets/Common Bottom Navigation bar/buttom_navigatebar.dart';
import '../../../../../Core/Widgets/Common Bottom Navigation bar/search_screen_bottombar.dart';
import '../../../../../Core/Widgets/Common Bottom Navigation bar/service_and_shops_details.dart';
import '../../../../../Core/Widgets/advetisements_screens.dart';
import '../../../../../Core/Widgets/caller_id_role_helper.dart';
import '../../No Data Screen/Screen/no_data_screen.dart';
import '../../Profile Screen/profile_screen.dart';
import '../../wallet/Controller/wallet_notifier.dart';
import '../../wallet/Screens/enter_review.dart';
import '../../wallet/Screens/qr_scan_screen.dart';
import '../../wallet/Screens/send_screen.dart';
import '../../wallet/Screens/wallet_screens.dart';

final callerIdAskedProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  int selectedIndex = 0;
  int selectedServiceIndex = 0;

  late final TextEditingController textController;
  final ScrollController _homeScrollCtrl = ScrollController();

  String? currentAddress;
  bool _locBusy = false;

  bool _shopsPressed = false;
  bool _servicesPressed = false;

  StreamSubscription<ServiceStatus>? _serviceSub;
  StreamSubscription<Position>? _posSub;

  /// ✅ Disable message only after SUCCESS
  final Set<String> _disabledMessageShopIds = {};
  final Set<String> _disabledMessageServiceIds = {};

  // Native channel
  static const MethodChannel _native = MethodChannel('sim_info');
  bool _openingSystemRole = false;
  bool _askedOnce = false;

  String shopHeroTag(int index, String name, {String section = 'shops'}) {
    final safe = name.replaceAll(RegExp(r'\s+'), '_').toLowerCase();
    return 'hero-$section-$index-$safe';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    textController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final overlayOk = await CallerIdRoleHelper.isOverlayGranted();
      if (!overlayOk) {
        await CallerIdRoleHelper.requestOverlayPermission();
      }
      await CallerIdRoleHelper.maybeAskOnce(ref: ref);
      await _maybeShowSystemCallerIdPopupOnce();
    });

    Future.microtask(() async {
      final loc = await _initLocationFlow();
      await ref
          .read(homeNotifierProvider.notifier)
          .fetchHomeDetails(lat: loc.lat, lng: loc.lng);

      // ✅ Ads error should never kick user to NoData screen
      ref
          .read(homeNotifierProvider.notifier)
          .advertisements(placement: 'HOME_TOP', lang: 0.0, lat: 0.0);
    });

    _listenServiceChanges();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await Future.delayed(const Duration(milliseconds: 400));
      await CallerIdRoleHelper.maybeAskOnce(ref: ref, force: true);
      await _maybeShowSystemCallerIdPopupOnce();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceSub?.cancel();
    _posSub?.cancel();
    textController.dispose();
    _homeScrollCtrl.dispose();
    super.dispose();
  }

  Future<bool> _isDefaultCallerIdApp() async {
    try {
      if (!Platform.isAndroid) return true;
      final ok = await _native.invokeMethod<bool>('isDefaultCallerIdApp');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _requestDefaultCallerIdApp() async {
    try {
      if (!Platform.isAndroid) return true;
      final ok = await _native.invokeMethod<bool>('requestDefaultCallerIdApp');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  /// ✅ system role popup only once per app run
  Future<void> _maybeShowSystemCallerIdPopupOnce() async {
    if (!mounted) return;
    if (!Platform.isAndroid) return;
    if (_openingSystemRole) return;
    if (_askedOnce) return;

    final ok = await _isDefaultCallerIdApp();
    if (ok) return;

    _askedOnce = true;
    _openingSystemRole = true;

    await _requestDefaultCallerIdApp();
    await Future.delayed(const Duration(milliseconds: 400));
    _openingSystemRole = false;
  }

  Future<({double lat, double lng})> _initLocationFlow() async {
    if (!mounted) return (lat: 0.0, lng: 0.0);

    setState(() {
      _locBusy = true;
      currentAddress ??= "Fetching location...";
      if (currentAddress!.isEmpty) currentAddress = "Fetching location...";
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final enable = await _askToEnableLocationServices();
        if (enable == true) {
          await Geolocator.openLocationSettings();
          await Future.delayed(const Duration(milliseconds: 900));
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
        }
        if (!serviceEnabled) {
          if (mounted)
            setState(() => currentAddress = "Location services disabled");
          return (lat: 0.0, lng: 0.0);
        }
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.denied) {
        if (mounted)
          setState(() => currentAddress = "Location permission denied");
        return (lat: 0.0, lng: 0.0);
      }

      if (perm == LocationPermission.deniedForever) {
        final open = await _askToOpenAppSettings();
        if (open == true) {
          await Geolocator.openAppSettings();
        }
        if (mounted)
          setState(() => currentAddress = "Permission permanently denied");
        return (lat: 0.0, lng: 0.0);
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 12),
      );

      final address = await _reverseToNiceAddress(pos);

      if (mounted) {
        setState(() {
          currentAddress =
              address ??
              "${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}";
        });
      }

      return (lat: pos.latitude, lng: pos.longitude);
    } catch (e, st) {
      AppLogger.log.e(e);
      AppLogger.log.e(st);
      if (mounted) setState(() => currentAddress = "Unable to fetch location");
      return (lat: 0.0, lng: 0.0);
    } finally {
      if (mounted) setState(() => _locBusy = false);
    }
  }

  Future<String?> _reverseToNiceAddress(Position pos) async {
    try {
      final marks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (marks.isEmpty) return null;
      final p = marks.first;

      final parts = <String>[
        if ((p.street ?? '').trim().isNotEmpty) p.street!.trim(),
        if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
        if ((p.administrativeArea ?? '').trim().isNotEmpty)
          p.administrativeArea!.trim(),
      ];
      return parts.isNotEmpty ? parts.join(', ') : null;
    } catch (_) {
      return null;
    }
  }

  void _listenServiceChanges() {
    _serviceSub = Geolocator.getServiceStatusStream().listen((status) {
      if (status == ServiceStatus.enabled) {
        _initLocationFlow();
      }
    });
  }

  Future<bool?> _askToEnableLocationServices() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColor.white,
        title: const Text("Turn on Location"),
        content: const Text(
          "Please enable Location Services to show your current address.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Future<bool?> _askToOpenAppSettings() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Permission Needed"),
        content: const Text(
          "We need location permission. Open app settings to grant it.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Later"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> _ensureWalletReady() async {
    final st = ref.read(walletNotifier);
    if (st.walletHistoryResponse != null) return;
    await ref.read(walletNotifier.notifier).walletHistory(type: "ALL");
  }

  Future<void> _openQrAndAskAction(BuildContext context) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScanScreen(title: 'Scan QR Code'),
      ),
    );

    if (result == null || result.trim().isEmpty) return;

    final payload = QrScanPayload.fromScanValue(result);
    final toUid = (payload.toUid ?? '').trim();
    final shopId = (payload.shopId ?? '').trim();

    final hasUid = toUid.isNotEmpty;
    final hasShop = shopId.isNotEmpty;

    if (!hasUid && !hasShop) {
      AppSnackBar.error(context, "Invalid QR");
      return;
    }

    await _ensureWalletReady();

    final walletState = ref.read(walletNotifier);
    final wallet = walletState.walletHistoryResponse?.data.wallet;

    final myUid = (wallet?.uid ?? '').toString();
    final myBal = (wallet?.tcoinBalance ?? 0).toString();

    if (!context.mounted) return;

    if (hasUid && !hasShop) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              SendScreen(tCoinBalance: myBal, uid: myUid, initialToUid: toUid),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Choose Action",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              ListTile(
                enabled: hasUid,
                leading: const Icon(Icons.account_balance_wallet_rounded),
                title: const Text("Pay"),
                onTap: hasUid
                    ? () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SendScreen(
                              tCoinBalance: myBal,
                              uid: myUid,
                              initialToUid: toUid,
                            ),
                          ),
                        );
                      }
                    : null,
              ),
              ListTile(
                enabled: hasShop,
                leading: const Icon(Icons.rate_review_rounded),
                title: const Text("Review"),
                onTap: hasShop
                    ? () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EnterReview(shopId: shopId),
                          ),
                        );
                      }
                    : null,
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _refreshAll() async {
    final loc = await _initLocationFlow();
    await ref
        .read(homeNotifierProvider.notifier)
        .fetchHomeDetails(lat: loc.lat, lng: loc.lng);
    ref
        .read(homeNotifierProvider.notifier)
        .advertisements(placement: 'HOME_TOP', lang: 0.0, lat: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeNotifierProvider);
    final home = state.homeResponse;
    final ads = state.advertisementResponse;

    final addsBanner = (ads != null && ads.data.isNotEmpty)
        ? ads.data.first
        : null;

    // ✅ Initial loading only
    if (state.isLoading && home == null) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }

    // ✅ IMPORTANT FIX:
    // NoDataScreen ONLY if home==null and home fetch failed.
    // Enquiry/Ads errors MUST NOT push NoData screen.
    if (!state.isLoading && home == null && state.error != null) {
      return Scaffold(
        body: Center(
          child: NoDataScreen(
            onRefresh: _refreshAll,
            showBottomButton: false,
            showTopBackArrow: false,
          ),
        ),
      );
    }

    // If home is still null (safety)
    if (home == null) {
      return Scaffold(
        body: Center(
          child: NoDataScreen(
            onRefresh: _refreshAll,
            showBottomButton: false,
            showTopBackArrow: false,
          ),
        ),
      );
    }

    final banners = home.data.banners;
    final surpriseOffers = home.data.surpriseOffers;

    final categories = home.data.shopCategories;
    final serviceCategories = home.data.categories;

    final trendingShops = home.data.trendingShops;
    final servicesList = home.data.services;

    final bool hasAnyData =
        banners.isNotEmpty ||
        categories.isNotEmpty ||
        serviceCategories.isNotEmpty ||
        trendingShops.isNotEmpty ||
        servicesList.isNotEmpty;

    if (!hasAnyData) {
      return Scaffold(
        body: Center(
          child: NoDataScreen(
            onRefresh: _refreshAll,
            showBottomButton: false,
            showTopBackArrow: false,
          ),
        ),
      );
    }

    // Safe indexing
    final int? safeIndex = categories.isNotEmpty
        ? selectedIndex.clamp(0, categories.length - 1)
        : null;
    final int? safeServiceIndex = serviceCategories.isNotEmpty
        ? selectedServiceIndex.clamp(0, serviceCategories.length - 1)
        : null;

    final selectedCategory = safeIndex != null ? categories[safeIndex] : null;
    final selectedServiceCategory = safeServiceIndex != null
        ? serviceCategories[safeServiceIndex]
        : null;

    final selectedSlug = selectedCategory?.slug ?? 'all';
    final selectedServiceSlug = selectedServiceCategory?.slug ?? 'all';

    final filteredShops = selectedSlug == 'all'
        ? trendingShops
        : trendingShops.where((s) => s.category == selectedSlug).toList();

    final filteredServiceShops = selectedServiceSlug == 'all'
        ? servicesList
        : servicesList.where((s) => s.category == selectedServiceSlug).toList();

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshAll,
            child: SingleChildScrollView(
              controller: _homeScrollCtrl,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== TOP HEADER =====
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(color: AppColor.darkBlue),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _initLocationFlow,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 4,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        AppImages.locationImage,
                                        height: 24,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          currentAddress ??
                                              (_locBusy
                                                  ? 'Fetching location...'
                                                  : 'Tap to fetch location'),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: GoogleFont.Mulish(
                                            color: AppColor.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Wallet dotted box
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WalletScreens(),
                                    ),
                                  );
                                },
                                child: dotted.DottedBorder(
                                  color: AppColor.lightBlueBorder,
                                  dashPattern: const [4.0, 2.0],
                                  borderType: dotted.BorderType.RRect,
                                  padding: const EdgeInsets.all(10),
                                  radius: const Radius.circular(18),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        AppImages.coinImage,
                                        height: 16,
                                        width: 17.33,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        (home.data.tcoin?.balance ?? 0)
                                            .toString(),
                                        style: GoogleFont.Mulish(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12,
                                          color: AppColor.white,
                                        ),
                                      ),
                                      Text(
                                        ' Tcoins',
                                        style: GoogleFont.Mulish(
                                          fontSize: 12,
                                          color: AppColor.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Avatar
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileScreen(
                                      balance: home.data.tcoin?.balance
                                          .toString(),
                                      gender: home.data.user.gender.toString(),
                                      dob: home.data.user.dob.toString(),
                                      email: home.data.user.email.toString(),
                                      url: home.data.user.avatarUrl.toString(),
                                      name: home.data.user.name.toString(),
                                      phnNumber: home.data.user.phoneNumber
                                          .toString(),
                                    ),
                                  ),
                                );
                              },
                              child: CachedNetworkImage(
                                imageUrl: home.data.user.avatarUrl.toString(),
                                imageBuilder: (context, imageProvider) =>
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.transparent,
                                      backgroundImage: imageProvider,
                                    ),
                                placeholder: (context, url) =>
                                    const CircleAvatar(
                                      radius: 16,
                                      child: SizedBox(
                                        height: 12,
                                        width: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(
                                      radius: 16,
                                      child: Image.asset(AppImages.avatarImage),
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Search bar
                        InkWell(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                builder: (_) => const SearchScreenBottombar(
                                  initialIndex: 1,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.white,
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: AppColor.lightGray1,
                                width: 3,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    AppImages.searchImage,
                                    height: 17,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Search product, shop, service, mobile no',
                                    style: GoogleFont.Mulish(
                                      color: AppColor.lightGray,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 11),

                        // Explore Near + QR
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColor.lightBlueCont,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 15,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Explore Near',
                                    style: GoogleFont.Mulish(
                                      fontSize: 12,
                                      color: AppColor.lightGray,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTapDown: (_) =>
                                        setState(() => _shopsPressed = true),
                                    onTapUp: (_) =>
                                        setState(() => _shopsPressed = false),
                                    onTapCancel: () =>
                                        setState(() => _shopsPressed = false),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ButtomNavigatebar(
                                                initialIndex: 3,
                                              ),
                                        ),
                                      );
                                    },
                                    child: AnimatedScale(
                                      scale: _shopsPressed ? 0.90 : 1.0,
                                      duration: const Duration(milliseconds: 0),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            AppImages.shopImage,
                                            height: 23,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Shops',
                                            style: GoogleFont.Mulish(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12,
                                              color: AppColor.lightGray,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 2,
                                    height: 16,
                                    color: AppColor.lightBlueBorder,
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTapDown: (_) =>
                                        setState(() => _servicesPressed = true),
                                    onTapUp: (_) => setState(
                                      () => _servicesPressed = false,
                                    ),
                                    onTapCancel: () => setState(
                                      () => _servicesPressed = false,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ButtomNavigatebar(
                                                initialIndex: 4,
                                              ),
                                        ),
                                      );
                                    },
                                    child: AnimatedScale(
                                      scale: _servicesPressed ? 0.90 : 1.0,
                                      duration: const Duration(milliseconds: 0),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            AppImages.servicesImage,
                                            height: 23,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Services',
                                            style: GoogleFont.Mulish(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12,
                                              color: AppColor.lightGray,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            InkWell(
                              onTap: () => _openQrAndAskAction(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 13,
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.white,
                                ),
                                child: Image.asset(
                                  AppImages.qRColor,
                                  height: 23,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 27),

                  // ===== BODY =====
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColor.white.withOpacity(0.8),
                          AppColor.white,
                          AppColor.white,
                        ],
                        begin: Alignment.center,
                        end: Alignment.center,
                      ),
                    ),
                    child: Column(
                      children: [
                        // ===== BANNERS =====
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColor.white2.withOpacity(0.5),
                                AppColor.white2.withOpacity(0.5),
                                AppColor.white2.withOpacity(0.9),
                                AppColor.lowLightWhite,
                                AppColor.lowLightWhite,
                                AppColor.lowLightWhite,
                                AppColor.lowLightWhite,
                                AppColor.white2.withOpacity(0.5),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Column(
                            children: [
                              if (banners.isNotEmpty)
                                CarouselSlider(
                                  options: CarouselOptions(
                                    height: 131,
                                    enlargeCenterPage: false,
                                    enableInfiniteScroll: true,
                                    autoPlay: true,
                                    autoPlayInterval: const Duration(
                                      seconds: 4,
                                    ),
                                    viewportFraction: 0.9,
                                    padEnds: true,
                                  ),
                                  items: banners.map((banner) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                CachedNetworkImage(
                                                  imageUrl: banner.imageUrl,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                        color: Colors.grey
                                                            .withOpacity(0.2),
                                                      ),
                                                  errorWidget:
                                                      (
                                                        context,
                                                        url,
                                                        error,
                                                      ) => Container(
                                                        color: Colors
                                                            .grey
                                                            .shade300,
                                                        child: const Icon(
                                                          Icons.broken_image,
                                                        ),
                                                      ),
                                                ),
                                                Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                        gradient: LinearGradient(
                                                          begin: Alignment
                                                              .bottomCenter,
                                                          end: Alignment
                                                              .topCenter,
                                                          colors: [
                                                            Colors.black54,
                                                            Colors.transparent,
                                                          ],
                                                        ),
                                                      ),
                                                ),
                                                Positioned.fill(
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: () {
                                                        if ((banner.type)
                                                            .isEmpty)
                                                          return;

                                                        final bannerType =
                                                            banner.type
                                                                .trim()
                                                                .toUpperCase();
                                                        String? passType;

                                                        if (bannerType.contains(
                                                          'RETAIL',
                                                        )) {
                                                          passType = 'products';
                                                        } else if (bannerType
                                                            .contains(
                                                              'SERVICE',
                                                            )) {
                                                          passType = 'services';
                                                        }

                                                        if (passType == null ||
                                                            banner.shopId ==
                                                                null)
                                                          return;

                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                ServiceAndShopsDetails(
                                                                  type:
                                                                      passType,
                                                                  shopId: banner
                                                                      .shopId!,
                                                                  initialIndex:
                                                                      passType ==
                                                                          'products'
                                                                      ? 3
                                                                      : 0,
                                                                ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                )
                              else
                                const SizedBox.shrink(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // ===== SURPRISE OFFERS =====
                        if (surpriseOffers.isEmpty)
                          const SizedBox.shrink()
                        else
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 5,
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      AppImages.giftImage,
                                      height: 63,
                                      width: 79,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      children: [
                                        Text(
                                          'Surprise Offers',
                                          style: GoogleFont.Mulish(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.blackRedText,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Text(
                                              'Unlock',
                                              style: GoogleFont.Mulish(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                color: AppColor.blackRedText2,
                                              ),
                                            ),
                                            Text(
                                              ' by walk nearer below shown shops',
                                              style: GoogleFont.Mulish(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: AppColor.blackRedText2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 160,
                                child: ListView.builder(
                                  itemCount: surpriseOffers.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    final data = surpriseOffers[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: AppColor.white,
                                      ),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0,
                                          ),
                                          child: Row(
                                            children: [
                                              CommonContainer.shopImageContainer(
                                                heroTag: 'surprise-${data.id}',
                                                onTap: () {
                                                  final offerId = data.id;
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SurpriseScreens(
                                                            subOfferId: offerId,
                                                            shopLat: 0.0,
                                                            shopLng: 0.0,
                                                            shopId:
                                                                data.shop?.id
                                                                    .toString() ??
                                                                '',
                                                          ),
                                                    ),
                                                  );
                                                },
                                                verify:
                                                    data.shop?.isTrusted ??
                                                    false,
                                                shopName:
                                                    data.shop?.englishName
                                                        .toString() ??
                                                    '',
                                                location:
                                                    '${data.shop?.addressEn},${data.shop?.city},${data.shop?.state},${data.shop?.country} ',
                                                km:
                                                    data.distanceLabel
                                                        ?.toString() ??
                                                    '',
                                                ratingStar:
                                                    data.shop?.averageRating
                                                        .toString() ??
                                                    '',
                                                ratingCount:
                                                    data.shop?.reviewCount
                                                        .toString() ??
                                                    '',
                                                time:
                                                    data.closeTime
                                                        ?.toString() ??
                                                    '',
                                                Images: data.bannerUrl
                                                    .toString(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 57),
                            ],
                          ),

                        // ===== SERVICES SECTION =====
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColor.white2.withOpacity(0.5),
                                AppColor.white2.withOpacity(0.5),
                                AppColor.white2.withOpacity(0.9),
                                AppColor.white2.withOpacity(0.5),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 14,
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 120,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Services',
                                            style: GoogleFont.Mulish(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                              color: AppColor.darkBlue,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          CommonContainer.rightSideArrowButton(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ButtomNavigatebar(
                                                        initialIndex: 4,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: -38,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColor.iceBlue,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(30),
                                            topRight: Radius.circular(30),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 28,
                                            vertical: 20,
                                          ),
                                          child: Center(
                                            child: Image.asset(
                                              AppImages.servicesImage,
                                              height: 58,
                                              color: AppColor.deepTeaBlue,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Category chips
                              if (serviceCategories.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: Text('No service categories'),
                                  ),
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColor.iceBlue,
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 20,
                                    ),
                                    child: Row(
                                      children: List.generate(
                                        serviceCategories.length,
                                        (index) {
                                          final isSelected =
                                              selectedServiceIndex == index;
                                          final category =
                                              serviceCategories[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            child: CommonContainer.categoryChip(
                                              ContainerColor: isSelected
                                                  ? AppColor.iceBlue
                                                  : Colors.transparent,
                                              BorderColor: isSelected
                                                  ? AppColor.deepTeaBlue
                                                  : AppColor.frostBlue,
                                              TextColor: isSelected
                                                  ? AppColor.darkBlue
                                                  : AppColor.deepTeaBlue,
                                              category.name,
                                              isSelected: isSelected,
                                              onTap: () => setState(
                                                () => selectedServiceIndex =
                                                    index,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                              // List
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColor.iceBlue,
                                      AppColor.iceBlue,
                                      AppColor.iceBlue,
                                      AppColor.iceBlue.withOpacity(0.99),
                                      AppColor.iceBlue.withOpacity(0.50),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColor.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.04,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount:
                                              filteredServiceShops.length,
                                          itemBuilder: (context, index) {
                                            final services =
                                                filteredServiceShops[index];

                                            final isThisCardLoading =
                                                state.isEnquiryLoading &&
                                                state.activeEnquiryId ==
                                                    services.id;

                                            final hasMessaged =
                                                _disabledMessageServiceIds
                                                    .contains(services.id);

                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 20,
                                              ),
                                              child: CommonContainer.servicesContainer(
                                                callTap: () async {
                                                  await MapUrls.openDialer(
                                                    context,
                                                    services.primaryPhone,
                                                  );
                                                  await ref
                                                      .read(
                                                        homeNotifierProvider
                                                            .notifier,
                                                      )
                                                      .markCallOrLocation(
                                                        type: 'CALL',
                                                        shopId: services.id
                                                            .toString(),
                                                      );
                                                },
                                                horizontalDivider: true,
                                                fireOnTap: () {},
                                                isMessageLoading:
                                                    isThisCardLoading,
                                                messageDisabled: hasMessaged,
                                                messageOnTap: () async {
                                                  if (hasMessaged ||
                                                      isThisCardLoading)
                                                    return;

                                                  final ok = await ref
                                                      .read(
                                                        homeNotifierProvider
                                                            .notifier,
                                                      )
                                                      .putEnquiry(
                                                        context: context,
                                                        serviceId: '',
                                                        productId: '',
                                                        message: '',
                                                        shopId: services.id,
                                                      );

                                                  if (!mounted) return;

                                                  if (ok) {
                                                    setState(
                                                      () =>
                                                          _disabledMessageServiceIds
                                                              .add(services.id),
                                                    );
                                                  }
                                                },
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ServiceAndShopsDetails(
                                                            type: 'services',
                                                            shopId: services.id,
                                                            initialIndex: 3,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                whatsAppOnTap: () async {
                                                  await MapUrls.openWhatsapp(
                                                    message: 'hi',
                                                    context: context,
                                                    phone:
                                                        services.primaryPhone,
                                                  );
                                                  await ref
                                                      .read(
                                                        homeNotifierProvider
                                                            .notifier,
                                                      )
                                                      .markCallOrLocation(
                                                        type: 'WHATSAPP',
                                                        shopId: services.id
                                                            .toString(),
                                                      );
                                                },
                                                Verify: services.isTrusted,
                                                image: services.primaryImageUrl
                                                    .toString(),
                                                companyName:
                                                    '${services.englishName.toUpperCase()} - ${services.category.toUpperCase()}',
                                                location:
                                                    '${services.addressEn},${services.city},${services.state} ',
                                                fieldName:
                                                    services.distanceLabel,
                                                ratingStar: services.rating
                                                    .toString(),
                                                ratingCount: services
                                                    .ratingCount
                                                    .toString(),
                                                time: services.closeTime
                                                    .toString(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      if (filteredServiceShops.isNotEmpty)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'View All Services',
                                              style: GoogleFont.Mulish(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: AppColor.darkBlue,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            CommonContainer.rightSideArrowButton(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ButtomNavigatebar(
                                                          initialIndex: 4,
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 30),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== TOP AD BANNER (Dismissible) =====
                        addsBanner == null
                            ? const SizedBox.shrink()
                            : DismissibleAdBanner(
                                imageUrl: addsBanner.imageUrl,
                                onTap: () {},
                              ),

                        const SizedBox(height: 57),

                        // ===== PRODUCTS SECTION =====
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 14,
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 140),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Products',
                                          style: GoogleFont.Mulish(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                            color: AppColor.darkBlue,
                                          ),
                                        ),
                                        const Spacer(),
                                        CommonContainer.rightSideArrowButton(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ButtomNavigatebar(
                                                      initialIndex: 3,
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    bottom: -38,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColor.lowLightGreen,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(30),
                                          topRight: Radius.circular(30),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 28,
                                          vertical: 20,
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            AppImages.shopGreenImage,
                                            height: 58,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            if (categories.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Text('No product categories'),
                                ),
                              )
                            else
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColor.lowLightGreen,
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 20,
                                  ),
                                  child: Row(
                                    children: List.generate(categories.length, (
                                      index,
                                    ) {
                                      final isSelected = selectedIndex == index;
                                      final category = categories[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: CommonContainer.categoryChip(
                                          ContainerColor: isSelected
                                              ? AppColor.lowLightGreen
                                              : Colors.transparent,
                                          BorderColor: isSelected
                                              ? AppColor.lightGreen
                                              : AppColor.lowLightGreen2,
                                          TextColor: isSelected
                                              ? AppColor.lightGreen
                                              : AppColor.lowLightGreen3,
                                          category.name,
                                          isSelected: isSelected,
                                          onTap: () => setState(
                                            () => selectedIndex = index,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),

                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColor.lowLightGreen,
                                    AppColor.lowLightGreen,
                                    AppColor.lowLightGreen.withOpacity(0.99),
                                    AppColor.lowLightGreen.withOpacity(0.20),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColor.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.04,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: filteredShops.length,
                                        itemBuilder: (context, index) {
                                          final shops = filteredShops[index];

                                          final isThisCardLoading =
                                              state.isEnquiryLoading &&
                                              state.activeEnquiryId == shops.id;

                                          final hasMessaged =
                                              _disabledMessageShopIds.contains(
                                                shops.id,
                                              );

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 5,
                                            ),
                                            child: CommonContainer.servicesContainer(
                                              whatsAppOnTap: () async {
                                                await MapUrls.openWhatsapp(
                                                  message: 'hi',
                                                  context: context,
                                                  phone: shops.primaryPhone,
                                                );
                                                await ref
                                                    .read(
                                                      homeNotifierProvider
                                                          .notifier,
                                                    )
                                                    .markCallOrLocation(
                                                      type: 'WHATSAPP',
                                                      shopId: shops.id
                                                          .toString(),
                                                    );
                                              },
                                              fireTooltip: 'App Offer 5%',
                                              isMessageLoading:
                                                  isThisCardLoading,
                                              messageDisabled: hasMessaged,
                                              messageOnTap: () async {
                                                if (hasMessaged ||
                                                    isThisCardLoading)
                                                  return;

                                                // ✅ disable ONLY on SUCCESS
                                                final ok = await ref
                                                    .read(
                                                      homeNotifierProvider
                                                          .notifier,
                                                    )
                                                    .putEnquiry(
                                                      context: context,
                                                      serviceId: '',
                                                      productId: '',
                                                      message: '',
                                                      shopId: shops.id,
                                                    );

                                                if (!mounted) return;

                                                if (ok) {
                                                  setState(
                                                    () =>
                                                        _disabledMessageShopIds
                                                            .add(shops.id),
                                                  );
                                                }
                                              },
                                              callTap: () async {
                                                await MapUrls.openDialer(
                                                  context,
                                                  shops.primaryPhone,
                                                );
                                                await ref
                                                    .read(
                                                      homeNotifierProvider
                                                          .notifier,
                                                    )
                                                    .markCallOrLocation(
                                                      type: 'CALL',
                                                      shopId: shops.id
                                                          .toString(),
                                                    );
                                              },
                                              horizontalDivider: true,
                                              heroTag: shopHeroTag(
                                                index,
                                                shops.englishName.toString(),
                                                section: 'shops-list',
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ServiceAndShopsDetails(
                                                          shopId: shops.id,
                                                          initialIndex: 4,
                                                        ),
                                                  ),
                                                );
                                              },
                                              Verify: shops.isTrusted,
                                              image: shops.primaryImageUrl
                                                  .toString(),
                                              companyName: shops.englishName,
                                              location:
                                                  '${shops.addressEn}, ${shops.city}, ${shops.state}',
                                              fieldName: shops.distanceLabel
                                                  .toString(),
                                              ratingStar: shops.rating
                                                  .toString(),
                                              ratingCount: shops.ratingCount
                                                  .toString(),
                                              time: shops.closeTime.toString(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(height: 25),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'View All Products',
                                          style: GoogleFont.Mulish(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: AppColor.darkBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        CommonContainer.rightSideArrowButton(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ButtomNavigatebar(
                                                      initialIndex: 3,
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 60),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Text(
                          'Copyrights 2025@ All Rights Reserved',
                          style: GoogleFont.Mulish(
                            fontSize: 10,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QrScanPayload {
  final String? toUid;
  final String? shopId;
  final String? action;
  final List<String> options;

  const QrScanPayload({
    this.toUid,
    this.shopId,
    this.action,
    this.options = const [],
  });

  bool get hasUid => (toUid ?? '').trim().isNotEmpty;
  bool get hasShop => (shopId ?? '').trim().isNotEmpty;

  bool get canPay => options.contains('SEND_TCOIN') || hasUid;
  bool get canReview => options.contains('REVIEW') || hasShop;

  static QrScanPayload fromScanValue(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return const QrScanPayload();

    final uri = Uri.tryParse(v);

    final payloadParam = uri?.queryParameters['payload'];
    if (payloadParam != null && payloadParam.trim().isNotEmpty) {
      final jsonMap = _tryDecodePayloadToJson(payloadParam.trim());
      if (jsonMap != null) return _fromJsonMap(jsonMap);
    }

    if (uri != null && uri.queryParameters.isNotEmpty) {
      final qp = uri.queryParameters;
      final toUid = _pick(qp, ['toUid', 'toUID', 'uid', 'to_uid', 'to']);
      final shopId = _pick(qp, ['shopId', 'shopID', 'shop_id', 'shop']);
      if ((toUid ?? '').trim().isNotEmpty || (shopId ?? '').trim().isNotEmpty) {
        return QrScanPayload(
          toUid: toUid?.trim(),
          shopId: shopId?.trim(),
          action: _pick(qp, ['action'])?.trim(),
          options: const [],
        );
      }
    }

    final jsonMapDirect = _tryJsonDecode(v);
    if (jsonMapDirect != null) return _fromJsonMap(jsonMapDirect);

    final onlyUid = _extractUid(v);
    if (onlyUid != null) {
      return QrScanPayload(toUid: onlyUid, options: const ['SEND_TCOIN']);
    }

    return const QrScanPayload();
  }

  static QrScanPayload _fromJsonMap(Map<String, dynamic> m) {
    final toUid = _pick(m, ['toUid', 'toUID', 'uid', 'to_uid', 'to']);
    final shopId = _pick(m, ['shopId', 'shopID', 'shop_id', 'shop']);
    final action = _pick(m, ['action', 'act']);

    return QrScanPayload(
      toUid: toUid?.toString().trim(),
      shopId: shopId?.toString().trim(),
      action: action?.toString().trim(),
      options: _readOptions(m),
    );
  }

  static Map<String, dynamic>? _tryDecodePayloadToJson(String b64url) {
    try {
      var s = b64url.replaceAll('-', '+').replaceAll('_', '/');
      while (s.length % 4 != 0) {
        s += '=';
      }
      final bytes = base64Decode(s);
      final decoded = utf8.decode(bytes);
      final map = jsonDecode(decoded);
      return (map as Map).cast<String, dynamic>();
    } catch (_) {
      try {
        final bytes = base64Decode(b64url);
        final decoded = utf8.decode(bytes);
        final map = jsonDecode(decoded);
        return (map as Map).cast<String, dynamic>();
      } catch (_) {
        return null;
      }
    }
  }

  static Map<String, dynamic>? _tryJsonDecode(String v) {
    try {
      final map = jsonDecode(v);
      if (map is Map) return map.cast<String, dynamic>();
      return null;
    } catch (_) {
      return null;
    }
  }

  static String? _extractUid(String v) {
    final m = RegExp(r'(UID[A-Za-z0-9]+)', caseSensitive: false).firstMatch(v);
    return m?.group(1)?.toUpperCase();
  }

  static String? _pick(Map m, List<String> keys) {
    for (final k in keys) {
      if (m.containsKey(k) && (m[k]?.toString().trim().isNotEmpty ?? false)) {
        return m[k].toString();
      }
    }
    return null;
  }

  static List<String> _readOptions(Map<String, dynamic> jsonMap) {
    final opts = jsonMap['options'];
    if (opts is List) {
      return opts
          .map((e) {
            if (e is Map) {
              return (e['key'] ?? e['code'] ?? e['name'])?.toString();
            }
            return e?.toString();
          })
          .whereType<String>()
          .map((e) => e.trim().toUpperCase())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }
}
