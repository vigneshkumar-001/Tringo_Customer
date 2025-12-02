import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_border/dotted_border.dart' as dotted;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../No Data Screen/Screen/no_data_screen.dart';
import '../../Profile Screen/profile_screen.dart';
import '../../Smart Connect/smart_connect_guide.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

const _avatarHeroTag = 'profileAvatarHero';

class _HomeScreenState extends ConsumerState<HomeScreen> {
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

  StreamSubscription<Position>? _posSub;

  String shopHeroTag(int index, String name, {String section = 'shops'}) {
    final safe = name.replaceAll(RegExp(r'\s+'), '_').toLowerCase();
    return 'hero-$section-$index-$safe';
  }

  @override
  void initState() {
    super.initState();

    textController = TextEditingController();
    Future.microtask(() {
      ref.read(homeNotifierProvider.notifier).fetchHomeDetails();
    });
    _initLocationFlow();
    _listenServiceChanges();
  }

  @override
  void dispose() {
    _serviceSub?.cancel();
    _posSub?.cancel();
    textController.dispose();
    _homeScrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _initLocationFlow() async {
    setState(() => _locBusy = true);

    try {
      // 1) Ensure service on
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final enable = await _askToEnableLocationServices();
        if (enable == true) {
          await Geolocator.openLocationSettings();
          // small delay for settings page return
          await Future.delayed(const Duration(milliseconds: 600));
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
        }
        if (!serviceEnabled) {
          setState(() {
            currentAddress = "Location services disabled";
            _locBusy = false;
          });
          return;
        }
      }

      // 2) Ensure permission
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied) {
        setState(() {
          currentAddress = "Location permission denied";
          _locBusy = false;
        });
        return;
      }
      if (perm == LocationPermission.deniedForever) {
        final open = await _askToOpenAppSettings();
        if (open == true) {
          await Geolocator.openAppSettings();
        }
        setState(() {
          currentAddress = "Permission permanently denied";
          _locBusy = false;
        });
        return;
      }

      // 3) Get position (with timeout + sensible accuracy)
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // 4) Reverse-geocode with fallbacks
      final address = await _reverseToNiceAddress(pos);
      setState(() {
        currentAddress = address ?? "Unknown location";
      });
    } catch (e) {
      setState(() {
        currentAddress = "Unable to fetch location";
      });
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

  final List<String> imageList = [
    AppImages.homeScreenScroll2,
    AppImages.homeScreenScroll1,
    AppImages.homeScreenScroll3,
    // Add more images here
  ];

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

    if (state.isLoading) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }
    final home = state.homeResponse;
    if (home == null) {
      return const Scaffold(
        body: Center(
          child: NoDataScreen(showBottomButton: false, showTopBackArrow: false),
        ),
      );
    }

    final categories = home.data.shopCategories;
    final serviceCategories = home.data.categories;
    final trendingShops = home.data.trendingShops;
    final servicesList = home.data.services; // 👈 ADD THIS

    final safeIndex = (selectedIndex >= 0 && selectedIndex < categories.length)
        ? selectedIndex
        : 0;
    final safeServiceIndex =
        (selectedServiceIndex >= 0 &&
            selectedServiceIndex < serviceCategories.length)
        ? selectedServiceIndex
        : 0;
    final selectedCategory = categories[safeIndex];
    final selectedServiceCategory = serviceCategories[safeServiceIndex];
    final selectedSlug =
        selectedCategory.slug; // "all", "shop-electronics", etc.

    final selectedServiceSlug =
        selectedServiceCategory.slug; // "all", "shop-electronics", etc.

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
              await ref.read(homeNotifierProvider.notifier).fetchHomeDetails();
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
                                      SizedBox(width: 6),
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
                                      Image.asset(
                                        AppImages.drapDownImage,
                                        height: 11,
                                      ),
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
                                      home.data.user.coins.toString(),
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
                              CarouselSlider(
                                options: CarouselOptions(
                                  height: 131,
                                  enlargeCenterPage: false,
                                  enableInfiniteScroll: true,
                                  autoPlay: true,
                                  autoPlayInterval: Duration(seconds: 4),
                                  viewportFraction: 0.9,
                                  padEnds: true, // Still safe to keep off
                                ),
                                items: imageList.map((imagePath) {
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
                                          child: Image.asset(
                                            imagePath,
                                            width: double.infinity,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 57),

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

                              Container(
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
                                      home.data.categories.length,
                                      (index) {
                                        final isSelected =
                                            selectedServiceIndex == index;
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
                                            home.data.categories[index].name,
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
                                        child:
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: filteredServiceShops.length,
                                          itemBuilder: (context, index) {
                                            final services = filteredServiceShops[index];
                                            final isThisCardLoading =
                                                state.isEnquiryLoading && state.activeEnquiryId == services.id;

                                            final alreadyEnquired = _enquiredServiceIds.contains(services.id);

                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 20),
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

                                                    // 🔹 MESSAGE BUTTON – LOCK AFTER FIRST TAP
                                                    messageOnTap: () {
                                                      // if already sent enquiry for this service → do nothing
                                                      if (alreadyEnquired) {
                                                        // optional: show small info
                                                        // AppSnackBar.info(context, 'Enquiry already sent for this service');
                                                        return;
                                                      }

                                                      // mark as enquired (UI will rebuild)
                                                      setState(() {
                                                        _enquiredServiceIds.add(services.id);
                                                      });

                                                      ref
                                                          .read(homeNotifierProvider.notifier)
                                                          .putEnquiry(
                                                        context: context,
                                                        serviceId: services.id,
                                                        productId: '',
                                                        message: '',
                                                        shopId: services.id,
                                                      );
                                                    },

                                                    isMessageLoading: isThisCardLoading,

                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => ServiceAndShopsDetails(
                                                            shopId: services.id,
                                                            initialIndex: 3,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    whatsAppOnTap: () {
                                                      MapUrls.openWhatsapp(
                                                        message: 'hi',
                                                        context: context,
                                                        phone: services.primaryPhone,
                                                      );
                                                    },
                                                    Verify: services.isTrusted,
                                                    image: services.primaryImageUrl.toString(),
                                                    companyName:
                                                    '${services.englishName.toUpperCase()} - ${services.category.toUpperCase()}',
                                                    location:
                                                    '${services.city},${services.state},${services.country} ',
                                                    fieldName: services.ownershipTypeLabel,
                                                    ratingStar: services.rating.toString(),
                                                    ratingCount: services.ratingCount.toString(),
                                                    time: '9Pm',
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        )

                                        // ListView.builder(
                                        //   shrinkWrap: true,
                                        //   physics:
                                        //       const NeverScrollableScrollPhysics(),
                                        //   itemCount:
                                        //       filteredServiceShops.length,
                                        //   itemBuilder: (context, index) {
                                        //     final services =
                                        //         filteredServiceShops[index];
                                        //     final isThisCardLoading =
                                        //         state.isEnquiryLoading &&
                                        //         state.activeEnquiryId ==
                                        //             services.id;
                                        //
                                        //     return Padding(
                                        //       padding: const EdgeInsets.only(
                                        //         bottom: 20,
                                        //       ),
                                        //       child: Column(
                                        //         children: [
                                        //           CommonContainer.servicesContainer(
                                        //             callTap: () async {
                                        //               await MapUrls.openDialer(
                                        //                 context,
                                        //                 services.primaryPhone,
                                        //               );
                                        //             },
                                        //             horizontalDivider: true,
                                        //             fireOnTap: () {},
                                        //
                                        //             messageOnTap: () {
                                        //
                                        //               ref
                                        //                   .read(
                                        //                     homeNotifierProvider
                                        //                         .notifier,
                                        //                   )
                                        //                   .putEnquiry(
                                        //                     context: context,
                                        //                     serviceId:
                                        //                         services.id,
                                        //                     productId: '',
                                        //                     message: '',
                                        //                     shopId: services.id,
                                        //                   );
                                        //             },
                                        //
                                        //             isMessageLoading:
                                        //                 isThisCardLoading,
                                        //
                                        //             onTap: () {
                                        //               Navigator.push(
                                        //                 context,
                                        //                 MaterialPageRoute(
                                        //                   builder: (context) =>
                                        //                       ServiceAndShopsDetails(
                                        //                         shopId:
                                        //                             services.id,
                                        //                         initialIndex: 3,
                                        //                       ),
                                        //                 ),
                                        //               );
                                        //             },
                                        //             whatsAppOnTap: () {
                                        //               MapUrls.openWhatsapp(
                                        //                 message: 'hi',
                                        //                 context: context,
                                        //                 phone: services
                                        //                     .primaryPhone,
                                        //               );
                                        //             },
                                        //             Verify: services.isTrusted,
                                        //             image: services
                                        //                 .primaryImageUrl
                                        //                 .toString(),
                                        //             companyName:
                                        //                 '${services.englishName.toUpperCase()} - ${services.category.toUpperCase()}',
                                        //             location:
                                        //                 '${services.city},${services.state},${services.country} ',
                                        //             fieldName: services
                                        //                 .ownershipTypeLabel,
                                        //             ratingStar: services.rating
                                        //                 .toString(),
                                        //             ratingCount: services
                                        //                 .ratingCount
                                        //                 .toString(),
                                        //             time: '9Pm',
                                        //           ),
                                        //           // SizedBox(height: 6),
                                        //         ],
                                        //       ),
                                        //     );
                                        //   },
                                        // ),
                                      ),

                                      SizedBox(height: 20),

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
                            Container(
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
                                      final isSelected = selectedIndex == index;
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
                                      child:
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: filteredShops.length,
                                        itemBuilder: (context, index) {
                                          final shops = filteredShops[index];

                                          final isThisCardLoading =
                                              state.isEnquiryLoading && state.activeEnquiryId == shops.id;

                                          // 👇 check if enquiry already sent for this shop
                                          final alreadyEnquired = _enquiredShopIds.contains(shops.id);

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 5),
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

                                                  isMessageLoading: isThisCardLoading,

                                                  // 🔹 Message – only first tap will work
                                                  messageOnTap: () {
                                                    if (alreadyEnquired) {
                                                      // optional: small info
                                                      // AppSnackBar.info(context, 'Enquiry already sent for this shop');
                                                      return;
                                                    }

                                                    // mark this shop as enquired so it can't be sent again
                                                    setState(() {
                                                      _enquiredShopIds.add(shops.id);
                                                    });

                                                    ref
                                                        .read(homeNotifierProvider.notifier)
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
                                                        builder: (context) => ServiceAndShopsDetails(
                                                          shopId: shops.id,
                                                          initialIndex: 4,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  Verify: shops.isTrusted,
                                                  image: shops.primaryImageUrl.toString(),
                                                  companyName: shops.englishName,
                                                  location: '${shops.city}, ${shops.state}, ${shops.country}',
                                                  fieldName: shops.distanceKm.toString(),
                                                  ratingStar: shops.rating.toString(),
                                                  ratingCount: shops.ratingCount.toString(),
                                                  time: '9Pm',
                                                ),
                                                const SizedBox(height: 6),
                                              ],
                                            ),
                                          );
                                        },
                                      ),

                                      // ListView.builder(
                                      //   shrinkWrap: true,
                                      //   physics: NeverScrollableScrollPhysics(),
                                      //   itemCount: filteredShops.length,
                                      //   itemBuilder: (context, index) {
                                      //     final shops = filteredShops[index];
                                      //     final isThisCardLoading =
                                      //         state.isEnquiryLoading &&
                                      //         state.activeEnquiryId == shops.id;
                                      //     return Padding(
                                      //       padding: const EdgeInsets.symmetric(
                                      //         vertical: 5,
                                      //       ),
                                      //       child: Column(
                                      //         children: [
                                      //           CommonContainer.servicesContainer(
                                      //             whatsAppOnTap: () {
                                      //               MapUrls.openWhatsapp(
                                      //                 message: 'hi',
                                      //                 context: context,
                                      //                 phone: shops.primaryPhone,
                                      //               );
                                      //             },
                                      //             fireTooltip: 'App Offer 5%',
                                      //
                                      //             isMessageLoading:
                                      //                 isThisCardLoading,
                                      //             messageOnTap: () {
                                      //               ref
                                      //                   .read(
                                      //                     homeNotifierProvider
                                      //                         .notifier,
                                      //                   )
                                      //                   .putEnquiry(
                                      //                     context: context,
                                      //                     serviceId: '',
                                      //                     productId: '',
                                      //                     message: '',
                                      //                     shopId: shops.id,
                                      //                   );
                                      //             },
                                      //             callTap: () async {
                                      //               await MapUrls.openDialer(
                                      //                 context,
                                      //                 shops.primaryPhone,
                                      //               );
                                      //             },
                                      //
                                      //             horizontalDivider: true,
                                      //             heroTag: shopHeroTag(
                                      //               0,
                                      //               'Sri Krishna Sweets Private Limited',
                                      //               section: 'shops-list',
                                      //             ),
                                      //             onTap: () {
                                      //               Navigator.push(
                                      //                 context,
                                      //                 MaterialPageRoute(
                                      //                   builder: (context) =>
                                      //                       ServiceAndShopsDetails(
                                      //                         shopId: shops.id,
                                      //                         initialIndex: 4,
                                      //                       ),
                                      //                 ),
                                      //               );
                                      //             },
                                      //             Verify: shops.isTrusted,
                                      //             image: shops.primaryImageUrl
                                      //                 .toString(),
                                      //             companyName:
                                      //                 shops.englishName,
                                      //             location:
                                      //                 '${shops.city}, ${shops.state}, ${shops.country}',
                                      //             fieldName:
                                      //                 shops.distanceKm
                                      //                     .toString() ??
                                      //                 '',
                                      //             ratingStar: shops.rating
                                      //                 .toString(),
                                      //             ratingCount: shops.ratingCount
                                      //                 .toString(),
                                      //             time: '9Pm',
                                      //           ),
                                      //           SizedBox(height: 6),
                                      //         ],
                                      //       ),
                                      //     );
                                      //   },
                                      // ),
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
