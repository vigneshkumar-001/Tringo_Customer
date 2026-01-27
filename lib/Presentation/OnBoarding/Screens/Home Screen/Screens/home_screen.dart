import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
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
import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Model/shop_details_response.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../Core/Utility/map_urls.dart';
import '../../../../../Core/Widgets/Common Bottom Navigation bar/buttom_navigatebar.dart';
import '../../../../../Core/Widgets/Common Bottom Navigation bar/food_details_bottombar.dart';
import '../../../../../Core/Widgets/Common Bottom Navigation bar/search_screen_bottombar.dart';
import '../../../../../Core/Widgets/Common Bottom Navigation bar/service_and_shops_details.dart';
import '../../../../../Core/Widgets/caller_id_role_helper.dart';
import '../../No Data Screen/Screen/no_data_screen.dart';
import '../../Profile Screen/profile_screen.dart';
import '../../Smart Connect/smart_connect_guide.dart';
import '../../wallet/Screens/wallet_screens.dart';

final callerIdAskedProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

const _avatarHeroTag = 'profileAvatarHero';

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  int selectedIndex = 0;
  int selectedServiceIndex = 0;
  late final TextEditingController textController;
  final _homeScrollCtrl = ScrollController();
  String? currentAddress;
  bool _locBusy = false;
  final id = 'shop1'; // your real unique id
  final section = 'shops'; // or 'services'
  bool _shopsPressed = false;
  bool _servicesPressed = false;
  StreamSubscription<ServiceStatus>? _serviceSub;
  final Set<String> _enquiredServiceIds = {};
  final Set<String> _enquiredShopIds = {};

  final Set<String> _disabledMessageShopIds = {};
  final Set<String> _disabledMessageIds = {};

  StreamSubscription<Position>? _posSub;

  String shopHeroTag(int index, String name, {String section = 'shops'}) {
    final safe = name.replaceAll(RegExp(r'\s+'), '_').toLowerCase();
    return 'hero-$section-$index-$safe';
  }

  //  native channel
  static const MethodChannel _native = MethodChannel('sim_info');

  bool _openingSystemRole = false; // prevent double open
  bool _askedOnce = false; // show only once per app run

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final overlayOk = await CallerIdRoleHelper.isOverlayGranted();
      if (!overlayOk) {
        await CallerIdRoleHelper.requestOverlayPermission();
      }
      await CallerIdRoleHelper.maybeAskOnce(ref: ref);
    });

    textController = TextEditingController();

    Future.microtask(() async {
      final loc = await _initLocationFlow();
      ref
          .read(homeNotifierProvider.notifier)
          .fetchHomeDetails(lat: loc.lat, lng: loc.lng);
    });

    _listenServiceChanges();
  }

  // @override
  // void initState() {
  //   super.initState();
  //
  //   WidgetsBinding.instance.addObserver(this);
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     final overlayOk = await CallerIdRoleHelper.isOverlayGranted();
  //     if (!overlayOk) {
  //       await CallerIdRoleHelper.requestOverlayPermission();
  //     }
  //     await CallerIdRoleHelper.maybeAskOnce(ref: ref);
  //   });
  //
  //   textController = TextEditingController();
  //   Future.microtask(() async {
  //     final loc = await _initLocationFlow();
  //
  //     ref
  //         .read(homeNotifierProvider.notifier)
  //         .fetchHomeDetails(lat: loc.lat, lng: loc.lng);
  //   });
  //   _initLocationFlow();
  //   _listenServiceChanges();
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // user system screen-ல இருந்து back வந்த பிறகு check
      await Future.delayed(const Duration(milliseconds: 400));
      await CallerIdRoleHelper.maybeAskOnce(ref: ref, force: true);
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
      debugPrint("✅ [HOME] isDefaultCallerIdApp => $ok");
      return ok ?? false;
    } catch (e) {
      debugPrint('❌ [HOME] isDefaultCallerIdApp error: $e');
      return false;
    }
  }

  Future<bool> _requestDefaultCallerIdApp() async {
    try {
      if (!Platform.isAndroid) return true;
      debugPrint("🔥 [HOME] calling requestDefaultCallerIdApp...");
      final ok = await _native.invokeMethod<bool>('requestDefaultCallerIdApp');
      debugPrint("✅ [HOME] requestDefaultCallerIdApp result => $ok");
      return ok ?? false;
    } catch (e) {
      debugPrint('❌ [HOME] requestDefaultCallerIdApp error: $e');
      return false;
    }
  }

  /// ✅ Home screen open ஆகும்போது system popup மட்டும் once
  Future<void> _maybeShowSystemCallerIdPopupOnce() async {
    if (!mounted) return;
    if (!Platform.isAndroid) return;

    if (_openingSystemRole) return;
    if (_askedOnce) return;

    final ok = await _isDefaultCallerIdApp();
    if (ok) return;

    _askedOnce = true;
    _openingSystemRole = true;

    final granted = await _requestDefaultCallerIdApp();

    await Future.delayed(const Duration(milliseconds: 400));
    _openingSystemRole = false;

    debugPrint(" [HOME] system role granted=$granted");
  }

  Future<({double lat, double lng})> _initLocationFlow() async {
    if (!mounted) return (lat: 0.0, lng: 0.0);

    setState(() {
      _locBusy = true;
      if (currentAddress == null || currentAddress!.isEmpty) {
        currentAddress = "Fetching location...";
      }
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
          setState(() => currentAddress = "Location services disabled");
          return (lat: 0.0, lng: 0.0);
        }
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.denied) {
        setState(() => currentAddress = "Location permission denied");
        return (lat: 0.0, lng: 0.0);
      }

      if (perm == LocationPermission.deniedForever) {
        final open = await _askToOpenAppSettings();
        if (open == true) {
          await Geolocator.openAppSettings();
        }
        setState(() => currentAddress = "Permission permanently denied");
        return (lat: 0.0, lng: 0.0);
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 12),
      );

      final address = await _reverseToNiceAddress(pos);

      setState(() {
        currentAddress =
            address ??
            "${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}";
      });

      return (lat: pos.latitude, lng: pos.longitude);
    } catch (e) {
      setState(() => currentAddress = "Unable to fetch location");
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

      // Build a short line (street/locality/area with null-safe commas)
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
        _initLocationFlow(); // GPS turned on → try again
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

  // final List<String> imageList = [
  //   AppImages.homeScreenScroll2,
  //   AppImages.homeScreenScroll1,
  //   AppImages.homeScreenScroll3,
  //   // Add more images here
  // ];

  void onChangeLocation() {
    // open map picker, show bottom sheet, etc.
    print('Change location tapped!');
  }

  Route<T> slideUpRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondary, child) {
        final tween = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        final fade = Tween<double>(
          begin: 0,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOut));
        return FadeTransition(
          opacity: animation.drive(fade),
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeNotifierProvider);
    final home = state.homeResponse;

    if (state.isLoading && home == null) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }

    if (!state.isLoading && state.error != null) {
      return Scaffold(
        body: Center(
          child: NoDataScreen(
            onRefresh: () async {
              final loc = await _initLocationFlow();
              await ref
                  .read(homeNotifierProvider.notifier)
                  .fetchHomeDetails(lat: loc.lat, lng: loc.lng);
            },
            showBottomButton: false,
            showTopBackArrow: false,
          ),
        ),
      );
    }

    final banners = home!.data.banners;
    final categories = home!.data.shopCategories;
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
            onRefresh: () async {
              final loc = await _initLocationFlow();
              await ref
                  .read(homeNotifierProvider.notifier)
                  .fetchHomeDetails(lat: loc.lat, lng: loc.lng);
            },
            showBottomButton: false,
            showTopBackArrow: false,
          ),
        ),
      );
    }
    // ---- SAFE INDEXING ----
    final bool hasShopCategories = categories.isNotEmpty;
    final bool hasServiceCategories = serviceCategories.isNotEmpty;

    // Only compute safe indexes if list is not empty
    final int? safeIndex = hasShopCategories
        ? selectedIndex.clamp(0, categories.length - 1)
        : null;

    final int? safeServiceIndex = hasServiceCategories
        ? selectedServiceIndex.clamp(0, serviceCategories.length - 1)
        : null;

    // ---- SELECTED ITEMS ----
    final selectedCategory = safeIndex != null ? categories[safeIndex] : null;

    final selectedServiceCategory = safeServiceIndex != null
        ? serviceCategories[safeServiceIndex]
        : null;

    // ---- SLUGS (SAFE) ----
    final selectedSlug = selectedCategory?.slug ?? 'all';
    final selectedServiceSlug = selectedServiceCategory?.slug ?? 'all';

    // ---- FILTERED LISTS ----
    final filteredShops = selectedSlug == 'all'
        ? trendingShops
        : trendingShops.where((s) => s.category == selectedSlug).toList();

    final filteredServiceShops = selectedServiceSlug == 'all'
        ? servicesList
        : servicesList.where((s) => s.category == selectedServiceSlug).toList();

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              final loc = await _initLocationFlow();
              AppLogger.log.i(loc.lat);
              AppLogger.log.i(loc.lng);
              await ref
                  .read(homeNotifierProvider.notifier)
                  .fetchHomeDetails(lat: loc.lat, lng: loc.lng);
            },
            child: SingleChildScrollView(
              controller: _homeScrollCtrl,
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    decoration: BoxDecoration(color: AppColor.darkBlue),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _initLocationFlow, // tap to refresh
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
                                      SizedBox(width: 6),
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
                                      //SizedBox(width: 6),
                                      // if (_locBusy)
                                      //   SizedBox(
                                      //     height: 14,
                                      //     width: 14,
                                      //     child: CircularProgressIndicator(
                                      //       strokeWidth: 2,
                                      //       color: AppColor.white,
                                      //     ),
                                      //   )
                                      // else
                                      // Image.asset(
                                      //   AppImages.drapDownImage,
                                      //   height: 11,
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            /* Row(
                              children: [
                                Image.asset(AppImages.locationImage, height: 24),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Marudhupandiyar nagar main road, Madurai',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: GoogleFont.Mulish(color: AppColor.white),
                                  ),
                                ),
                                SizedBox(width: 6),
                                Image.asset(AppImages.drapDownImage, height: 11),
                              ],
                            ),*/
                            // Spacer(),
                            SizedBox(width: 20),
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
                                child: DottedBorder(
                                  color: AppColor.lightBlueBorder,
                                  dashPattern: [4.0, 2.0],
                                  borderType: dotted.BorderType.RRect,
                                  padding: EdgeInsets.all(10),
                                  radius: Radius.circular(18),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        AppImages.coinImage,
                                        height: 16,
                                        width: 17.33,
                                      ),
                                      SizedBox(width: 6),
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

                            SizedBox(width: 10),

                            ///  Proper spacing and avatar
                            /*InkWell(
                              onTap: () {
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                radius: 16,
                                child: Image.asset(AppImages.avatarImage),
                              ),
                            ),*/
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileScreen(
                                      balance: state
                                          .homeResponse
                                          ?.data
                                          .tcoin
                                          ?.balance
                                          .toString(),
                                      gender: state
                                          .homeResponse
                                          ?.data
                                          .user
                                          .gender
                                          .toString(),
                                      dob: state.homeResponse?.data.user.dob
                                          .toString(),
                                      email: state.homeResponse?.data.user.email
                                          .toString(),

                                      url:
                                          state
                                              .homeResponse
                                              ?.data
                                              .user
                                              .avatarUrl
                                              .toString() ??
                                          '',
                                      name:
                                          state.homeResponse?.data.user.name
                                              .toString() ??
                                          '',
                                      phnNumber:
                                          state
                                              .homeResponse
                                              ?.data
                                              .user
                                              .phoneNumber
                                              .toString() ??
                                          '',
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
                        SizedBox(height: 28),
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
                                  SizedBox(width: 10),
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
                        SizedBox(height: 11),
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
                                  SizedBox(width: 10),
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
                                  // --- SERVICES BUTTON ---
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
                                          SizedBox(width: 10),
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

                            SizedBox(width: 12),
                            InkWell(
                              onTap: () async {
                                // 1) Scroll HomeScreen to top (nice quick animation)
                                if (_homeScrollCtrl.hasClients) {
                                  await _homeScrollCtrl.animateTo(
                                    0,
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeOut,
                                  );
                                }

                                // 2) Slide the next page up from bottom
                                if (!mounted) return;
                                await Navigator.of(
                                  context,
                                ).push(slideUpRoute(const SmartConnectGuide()));
                              },
                              child: Image.asset(
                                AppImages.aiGuideImage,
                                height: 45,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 27),
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
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColor.white2.withOpacity(0.5),
                                AppColor.white2.withOpacity(0.5),
                                // AppColor.white2.withOpacity(0.5),
                                AppColor.white2.withOpacity(0.9),
                                AppColor.lowLightWhite,
                                AppColor.lowLightWhite,
                                AppColor.lowLightWhite,
                                AppColor.lowLightWhite,
                                AppColor.white2.withOpacity(0.5),
                                // AppColor.white.withOpacity(0.9),
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
                                                //  Banner background image
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

                                                //  Gradient overlay at bottom
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

                                                // Title + subtitle + CTA
                                                Positioned(
                                                  left: 12,
                                                  right: 12,
                                                  bottom: 10,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        banner.title,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            GoogleFont.Mulish(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                      ),
                                                      if ((banner.subtitle ??
                                                              '')
                                                          .isNotEmpty)
                                                        Text(
                                                          banner.subtitle!,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              GoogleFont.Mulish(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                      0.9,
                                                                    ),
                                                              ),
                                                        ),
                                                      if ((banner.ctaLabel ??
                                                              '')
                                                          .isNotEmpty)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                top: 6,
                                                              ),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 4,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                    0.9,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    20,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              banner.ctaLabel!,
                                                              style: GoogleFont.Mulish(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: AppColor
                                                                    .darkBlue,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),

                                                // Tap full banner
                                                Positioned.fill(
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: () {
                                                        // TODO: handle deep link from banner.ctaLink if needed
                                                        // e.g. open "tringo://..." with your navigation
                                                        print(banner.ctaLink);
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
                                SizedBox.shrink(),
                            ],
                          ),

                          // Column(
                          //   children: [
                          //     if (imageList.isNotEmpty)
                          //       CarouselSlider(
                          //         options: CarouselOptions(
                          //           height: 131,
                          //           enlargeCenterPage: false,
                          //           enableInfiniteScroll: true,
                          //           autoPlay: true,
                          //           autoPlayInterval: Duration(seconds: 4),
                          //           viewportFraction: 0.9,
                          //           padEnds: true,
                          //         ),
                          //         items: imageList.map((imagePath) {
                          //           return Builder(
                          //             builder: (BuildContext context) {
                          //               return Padding(
                          //                 padding: const EdgeInsets.symmetric(
                          //                   horizontal: 6,
                          //                 ),
                          //                 child: ClipRRect(
                          //                   borderRadius: BorderRadius.circular(
                          //                     16,
                          //                   ),
                          //                   child: Image.asset(
                          //                     imagePath,
                          //                     width: double.infinity,
                          //                     fit: BoxFit.fill,
                          //                   ),
                          //                 ),
                          //               );
                          //             },
                          //           );
                          //         }).toList(),
                          //       ),
                          //   ],
                          // ),
                        ),
                        SizedBox(height: 57),
                        /* filteredServiceShops.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                child: Center(
                                  child: Text(
                                    "No Services Available",
                                    style: GoogleFont.Mulish(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.deepTeaBlue,
                                    ),
                                  ),
                                ),
                              )
                            : */
                        /* filteredServiceShops.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                child: Center(
                                  child: Text(
                                    "No Services Available",
                                    style: GoogleFont.Mulish(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.deepTeaBlue,
                                    ),
                                  ),
                                ),
                              )
                            : */
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
                              // HEADER (title + arrow + floating right icon box)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 14,
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // row with title + arrow; give right padding so it doesn't hide under the floating box
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
                                                  // ServiceListing(),
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
                                            // subtle lift for depth
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

                              SizedBox(height: 8),
                              if (serviceCategories.isEmpty)
                                Padding(
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
                                    physics: BouncingScrollPhysics(),
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
                                              onTap: () {
                                                setState(
                                                  () => selectedServiceIndex =
                                                      index,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              // Wrap the whole section with the gradient, not each item
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColor.iceBlue,
                                      AppColor.iceBlue,
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
                                              offset: Offset(0, 2),
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
                                                _disabledMessageIds.contains(
                                                  services.id,
                                                );
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 20,
                                              ),
                                              child: Column(
                                                children: [
                                                  CommonContainer.servicesContainer(
                                                    callTap: () async {
                                                      await MapUrls.openDialer(
                                                        context,
                                                        services.primaryPhone,
                                                      );
                                                    },
                                                    horizontalDivider: true,
                                                    fireOnTap: () {},
                                                    isMessageLoading:
                                                        isThisCardLoading,
                                                    messageDisabled:
                                                        hasMessaged,
                                                    messageOnTap: () {
                                                      if (hasMessaged ||
                                                          isThisCardLoading)
                                                        return;

                                                      // lock this service message button
                                                      setState(() {
                                                        _disabledMessageIds.add(
                                                          services.id,
                                                        );
                                                      });

                                                      ref
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
                                                    },

                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ServiceAndShopsDetails(
                                                                type:
                                                                    'services',
                                                                shopId:
                                                                    services.id,
                                                                initialIndex: 3,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                    whatsAppOnTap: () {
                                                      MapUrls.openWhatsapp(
                                                        message: 'hi',
                                                        context: context,
                                                        phone: services
                                                            .primaryPhone,
                                                      );
                                                    },
                                                    Verify: services.isTrusted,
                                                    image: services
                                                        .primaryImageUrl
                                                        .toString(),
                                                    companyName:
                                                        '${services.englishName.toUpperCase()} - ${services.category.toUpperCase()}',
                                                    location:
                                                        '${services.addressEn},'
                                                        '${services.city},${services.state} ',
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
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      SizedBox(height: 20),

                                      filteredServiceShops.isEmpty
                                          ? SizedBox.shrink()
                                          : Row(
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
                                                SizedBox(width: 12),
                                                CommonContainer.rightSideArrowButton(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ButtomNavigatebar(
                                                              initialIndex: 4,
                                                            ),
                                                        // ServiceListing(),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                      SizedBox(height: 30),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        /* filteredShops.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                child: Center(
                                  child: Text(
                                    "No Products Available",
                                    style: GoogleFont.Mulish(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.deepTeaBlue,
                                    ),
                                  ),
                                ),
                              )
                            :*/
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColor.white3,
                                AppColor.white3,
                                AppColor.white3,
                                AppColor.white.withOpacity(0.2),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                child: Image.asset(AppImages.addImage),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 57),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // HEADER (title + arrow + floating right icon box)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 14,
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // row with title + arrow; give right padding so it doesn't hide under the floating box
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
                                        Spacer(),
                                        CommonContainer.rightSideArrowButton(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ButtomNavigatebar(
                                                      initialIndex: 3,
                                                    ),
                                                // ShopsListing(),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  // floating right icon box
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
                                          // subtle lift for depth
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
                                            // color: AppColor.deepTeaBlue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 8),

                            // CATEGORY CHIPS
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
                                    children: List.generate(
                                      home.data.shopCategories.length,
                                      (index) {
                                        final isSelected =
                                            selectedIndex == index;
                                        final category =
                                            home.data.shopCategories[index];
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
                                            onTap: () {
                                              setState(
                                                () => selectedIndex = index,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),

                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColor.lowLightGreen,
                                    AppColor.lowLightGreen,
                                    AppColor.lowLightGreen,
                                    AppColor.lowLightGreen,
                                    AppColor.lowLightGreen,
                                    AppColor.lowLightGreen,
                                    AppColor.lowLightGreen,
                                    AppColor.lowLightGreen.withOpacity(0.99),
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
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
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
                                            child: Column(
                                              children: [
                                                CommonContainer.servicesContainer(
                                                  whatsAppOnTap: () {
                                                    MapUrls.openWhatsapp(
                                                      message: 'hi',
                                                      context: context,
                                                      phone: shops.primaryPhone,
                                                    );
                                                  },
                                                  fireTooltip: 'App Offer 5%',

                                                  isMessageLoading:
                                                      isThisCardLoading,
                                                  messageDisabled: hasMessaged,
                                                  messageOnTap: () {
                                                    if (hasMessaged ||
                                                        isThisCardLoading)
                                                      return;

                                                    //  lock this shop’s message button (one-time click)
                                                    setState(() {
                                                      _disabledMessageShopIds
                                                          .add(shops.id);
                                                    });
                                                    ref
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
                                                  },

                                                  callTap: () async {
                                                    await MapUrls.openDialer(
                                                      context,
                                                      shops.primaryPhone,
                                                    );
                                                  },

                                                  horizontalDivider: true,
                                                  heroTag: shopHeroTag(
                                                    0,
                                                    'Sri Krishna Sweets Private Limited',
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
                                                  companyName:
                                                      shops.englishName,
                                                  location:
                                                      '${shops.addressEn}, ${shops.city}, ${shops.state}',
                                                  fieldName: shops.distanceLabel
                                                      .toString(),
                                                  ratingStar: shops.rating
                                                      .toString(),
                                                  ratingCount: shops.ratingCount
                                                      .toString(),
                                                  time:
                                                      shops.closeTime
                                                          .toString() ??
                                                      '',
                                                ),
                                                SizedBox(height: 6),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    SizedBox(height: 25),
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
                                                // ShopsListing(),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 60),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Copyrights 2025@ All Rights Reserved',
                          style: GoogleFont.Mulish(
                            fontSize: 10,
                            color: AppColor.darkBlue,
                          ),
                        ),

                        SizedBox(height: 25),
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
