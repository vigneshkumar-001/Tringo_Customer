import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_border/dotted_border.dart' as dotted;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';
import '../../../../Core/Widgets/Common Bottom Navigation bar/buttom_navigatebar.dart';
import '../../../../Core/Widgets/Common Bottom Navigation bar/food_details_bottombar.dart';
import '../../../../Core/Widgets/Common Bottom Navigation bar/search_screen_bottombar.dart';
import '../../../../Core/Widgets/Common Bottom Navigation bar/service_and_shops_details.dart';
import '../Profile Screen/profile_screen.dart';
import '../Smart Connect/smart_connect_guide.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const _avatarHeroTag = 'profileAvatarHero';

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  late final TextEditingController textController;
  final _homeScrollCtrl = ScrollController();
  String? currentAddress;
  bool _locBusy = false;
  final id = 'shop1'; // your real unique id
  final section = 'shops'; // or 'services'
  bool _shopsPressed = false;
  bool _servicesPressed = false;
  StreamSubscription<ServiceStatus>? _serviceSub;
  // optional: listen to position updates if you want auto-refresh during movement:
  StreamSubscription<Position>? _posSub;

  String shopHeroTag(int index, String name, {String section = 'shops'}) {
    final safe = name.replaceAll(RegExp(r'\s+'), '_').toLowerCase();
    return 'hero-$section-$index-$safe';
  }

  final List<Map<String, dynamic>> categoryTabs = [
    {"label": "All"},
    {"label": "Electricians"},
    {"label": "Plumbers"},
    {"label": "Builders"},
  ];

  final List<Map<String, dynamic>> shopNameTabs = [
    {"label": "All"},
    {"label": "Restaurants"},
    {"label": "Textiles"},
    {"label": "Bakery"},
  ];

  @override
  void initState() {
    super.initState();
    // 1) CREATE CONTROLLER ONCE (not inside build)
    textController = TextEditingController();
    _initLocationFlow(); // ✅ kick off on app open
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
    return Scaffold(
      body: SafeArea(
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
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                                  '10',
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
                                builder: (context) => ProfileScreen(),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.transparent,
                            backgroundImage: AssetImage(AppImages.avatarImage),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 28),
                    InkWell(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const SearchScreenBottombar(initialIndex: 1),
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
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            children: [
                              Image.asset(AppImages.searchImage, height: 17),
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
                                          ButtomNavigatebar(initialIndex: 3),
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
                                onTapUp: (_) =>
                                    setState(() => _servicesPressed = false),
                                onTapCancel: () =>
                                    setState(() => _servicesPressed = false),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ButtomNavigatebar(
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

                        // Container(
                        //   decoration: BoxDecoration(
                        //     color: AppColor.lightBlueCont,
                        //     borderRadius: BorderRadius.circular(40),
                        //   ),
                        //   child: Padding(
                        //     padding: const EdgeInsets.symmetric(
                        //       vertical: 10,
                        //       horizontal: 20,
                        //     ),
                        //     child: Row(
                        //       children: [
                        //         Text(
                        //           'Explore Near',
                        //           style: GoogleFont.Mulish(
                        //             fontSize: 12,
                        //             color: AppColor.lightGray,
                        //           ),
                        //         ),
                        //         SizedBox(width: 14),
                        //         InkWell(
                        //           onTap: () {
                        //             Navigator.push(
                        //               context,
                        //               MaterialPageRoute(
                        //                 builder: (context) =>
                        //                     ButtomNavigatebar(initialIndex: 3),
                        //               ),
                        //             );
                        //           },
                        //           child: Row(
                        //             children: [
                        //               Image.asset(
                        //                 AppImages.shopImage,
                        //                 height: 23,
                        //               ),
                        //               SizedBox(width: 10),
                        //               Text(
                        //                 'Shops',
                        //                 style: GoogleFont.Mulish(
                        //                   fontWeight: FontWeight.w900,
                        //                   fontSize: 12,
                        //                   color: AppColor.lightGray,
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //         SizedBox(width: 10),
                        //         Container(
                        //           width: 2,
                        //           height: 16, // Adjust height as needed
                        //           color: AppColor.lightBlueBorder,
                        //         ),
                        //         SizedBox(width: 10),
                        //
                        //         InkWell(
                        //           onTap: () {
                        //             Navigator.push(
                        //               context,
                        //               MaterialPageRoute(
                        //                 builder: (_) => const ButtomNavigatebar(
                        //                   initialIndex: 4,
                        //                 ),
                        //               ),
                        //             );
                        //           },
                        //
                        //           child: Row(
                        //             children: [
                        //               Image.asset(
                        //                 AppImages.servicesImage,
                        //                 height: 23,
                        //               ),
                        //               SizedBox(width: 10),
                        //               Text(
                        //                 'Services',
                        //                 style: GoogleFont.Mulish(
                        //                   fontWeight: FontWeight.w900,
                        //                   fontSize: 12,
                        //                   color: AppColor.lightGray,
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
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

                        /*   InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SmartConnectGuide(),
                              ),
                            );
                          },
                          child: Image.asset(
                            AppImages.aiGuideImage,
                            height: 45,
                          ),
                        ),*/
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
                              viewportFraction:
                                  0.9, // Controls how many items are visible
                              padEnds: true, // Still safe to keep off
                            ),
                            items: imageList.map((imagePath) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ), // ✅ Equal left and right padding
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
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
                          SizedBox(height: 27),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              children: [
                                Text(
                                  'Offers in food',
                                  style: GoogleFont.Mulish(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                    color: AppColor.lightBlueCont,
                                  ),
                                ),
                                Spacer(),
                                CommonContainer.rightSideArrowButton(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ButtomNavigatebar(initialIndex: 5),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Row(
                                children: [
                                  CommonContainer.foodOBox(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FoodDetailsBottombar(
                                                initialIndex: 3,
                                              ),
                                        ),
                                      );
                                    },
                                    offRate: '₹175',
                                    oldRate: '₹223',
                                    image: AppImages.foodImage1,
                                    foodName: 'Ulti Breakfast Combo',
                                    rating: '4.5',
                                    hotelName: 'Sree Sabarees Hotel',
                                    distance: '100Mtr',
                                    QtyList: '5',
                                  ),
                                  const SizedBox(width: 6),
                                  CommonContainer.foodOBox(
                                    offRate: '₹65',
                                    oldRate: '₹134',
                                    image: AppImages.foodImage3,
                                    foodName: 'Chicken Rice',
                                    rating: '4.5',
                                    hotelName: 'Sree Sabarees Hotel',
                                    distance: '170Mtr',
                                    QtyList: '5',
                                  ),
                                  const SizedBox(width: 6),
                                  CommonContainer.foodOBox(
                                    offRate: '₹54',
                                    oldRate: '₹140',
                                    image: AppImages.foodImage2,
                                    foodName: 'Gobi Munchurian',
                                    rating: '4.5',
                                    hotelName: 'Sree Sabarees Hotel',
                                    distance: '214Mtr',
                                    QtyList: '5',
                                  ),

                                  const SizedBox(width: 6),
                                  CommonContainer.foodOBox(
                                    offRate: '₹8',
                                    oldRate: '₹12',
                                    image: AppImages.foodImage4,
                                    foodName: 'Gobi Munchurian',
                                    rating: '4.5',
                                    hotelName: 'Sree Sabarees Hotel',
                                    distance: '314Mtr',
                                    QtyList: '5',
                                  ),
                                  const SizedBox(width: 6),
                                  CommonContainer.foodOBox(
                                    offRate: '₹65',
                                    oldRate: '₹134',
                                    image: AppImages.foodImage3,
                                    foodName: 'Chicken Rice',
                                    rating: '4.5',
                                    hotelName: 'Sree Sabarees Hotel',
                                    distance: '170Mtr',
                                    QtyList: '5',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
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
                                    SizedBox(width: 10),
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
                                        SizedBox(height: 10),
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
                              SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColor.white,
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                    ),
                                    child: Row(
                                      children: [
                                        CommonContainer.shopImageContainer(
                                          heroTag: shopHeroTag(
                                            0,
                                            'Sri Krishna Sweets Private Limited',
                                            section: 'surprise',
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ServiceAndShopsDetails(
                                                      initialIndex: 4,
                                                    ),
                                              ),
                                            );
                                            /*Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  transitionDuration: Duration(
                                                    milliseconds: 500,
                                                  ),
                                                  pageBuilder:
                                                      (
                                                        context,
                                                        animation,
                                                        secondaryAnimation,
                                                      ) => ShopsDetails(
                                                        heroTag: 'shop1',
                                                        image: AppImages
                                                            .imageContainer1,
                                                      ),
                                                  transitionsBuilder:
                                                      (
                                                        context,
                                                        animation,
                                                        secondaryAnimation,
                                                        child,
                                                      ) {
                                                        final scaleAnimation =
                                                            Tween<double>(
                                                              begin: 0.8,
                                                              end: 1.0,
                                                            ).animate(
                                                              CurvedAnimation(
                                                                parent:
                                                                    animation,
                                                                curve: Curves
                                                                    .easeOut,
                                                              ),
                                                            );
                                                        return ScaleTransition(
                                                          scale: scaleAnimation,
                                                          child: FadeTransition(
                                                            opacity: animation,
                                                            child: child,
                                                          ),
                                                        );
                                                      },
                                                ),
                                              );*/
                                          },

                                          verify: true,
                                          shopName:
                                              'Sri Krishna Sweets Private Limited',
                                          location:
                                              '12, 2, Tirupparankunram Rd, kunram ',
                                          km: '5Kms',
                                          ratingStar: '4.5',
                                          ratingCount: '16',
                                          time: ' 9Pm',
                                          Images: AppImages.imageContainer1,
                                        ),
                                        SizedBox(width: 15),
                                        CommonContainer.shopImageContainer(
                                          shopName: 'Mother Baby Shop',
                                          location:
                                              '12, 2, Tirupparankunram Rd, kunram ',
                                          km: '5Kms',
                                          ratingStar: '4.5',
                                          ratingCount: '16',
                                          time: ' 9Pm',
                                          Images: AppImages.imageContainer2,
                                        ),
                                        SizedBox(width: 15),
                                        CommonContainer.shopImageContainer(
                                          shopName: 'Kidss Talk',
                                          location:
                                              '12, 2, Tirupparankunram Rd, kunram ',
                                          km: '5Kms',
                                          ratingStar: '4.5',
                                          ratingCount: '16',
                                          time: ' 9Pm',
                                          Images: AppImages.imageContainer3,
                                        ),
                                        SizedBox(width: 15),
                                        CommonContainer.shopImageContainer(
                                          shopName: 'Pantaloons',
                                          location:
                                              '12, 2, Tirupparankunram Rd, kunram ',
                                          km: '5Kms',
                                          ratingStar: '4.5',
                                          ratingCount: '16',
                                          time: ' 9Pm',
                                          Images: AppImages.imageContainer4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 57),
                            ],
                          ),
                        ],
                      ),
                    ),

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
                                  padding: const EdgeInsets.only(right: 120),
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

                                // floating right icon box
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
                                          color: Colors.black.withOpacity(0.05),
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

                          // CATEGORY CHIPS
                          Container(
                            decoration: BoxDecoration(color: AppColor.iceBlue),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 20,
                              ),
                              child: Row(
                                children: List.generate(categoryTabs.length, (
                                  index,
                                ) {
                                  final isSelected = selectedIndex == index;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
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
                                      categoryTabs[index]["label"],
                                      isSelected: isSelected,
                                      onTap: () {
                                        setState(() => selectedIndex = index);
                                      },
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                          // CONTENT CARD
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
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      child: Column(
                                        children: [
                                          CommonContainer.servicesContainer(
                                            horizontalDivider: true,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ServiceAndShopsDetails(
                                                        initialIndex: 3,
                                                      ),
                                                  // ServiceDetails(),
                                                ),
                                              );
                                            },
                                            Verify: true,
                                            image: AppImages.servicesContainer1,
                                            companyName:
                                                'Home Triangle - Electricians',
                                            location:
                                                '12, 2, Tirupparankunram Rd, kunram ',
                                            fieldName: 'Company',
                                            ratingStar: '4.5',
                                            ratingCount: '16',
                                            time: '9Pm',
                                          ),
                                          SizedBox(height: 6),
                                          CommonContainer.servicesContainer(
                                            horizontalDivider: true,
                                            onTap: () {},
                                            image: AppImages.servicesContainer2,
                                            companyName: 'Mag Builders',
                                            location:
                                                '12, 2, Tirupparankunram Rd, kunram ',
                                            fieldName: 'Invididual',
                                            ratingStar: '4.5',
                                            ratingCount: '16',
                                            time: '9Pm',
                                          ),
                                          SizedBox(height: 6),
                                          CommonContainer.servicesContainer(
                                            horizontalDivider: true,
                                            onTap: () {},
                                            image: AppImages.servicesContainer3,
                                            companyName: 'Waman Plumbers',
                                            location:
                                                '12, 2, Tirupparankunram Rd, kunram ',
                                            fieldName: 'Invididual',
                                            ratingStar: '4.5',
                                            ratingCount: '16',
                                            time: '9Pm',
                                          ),
                                          SizedBox(height: 6),
                                          CommonContainer.servicesContainer(
                                            horizontalDivider: true,
                                            onTap: () {},
                                            image: AppImages.servicesContainer4,
                                            companyName:
                                                'Amman Engineering works',
                                            location:
                                                '12, 2, Tirupparankunram Rd, kunram ',
                                            fieldName: 'Invididual',
                                            ratingStar: '4.5',
                                            ratingCount: '16',
                                            time: '9Pm',
                                          ),
                                          SizedBox(height: 6),
                                          CommonContainer.servicesContainer(
                                            horizontalDivider: true,
                                            onTap: () {},

                                            image: AppImages.servicesContainer5,
                                            companyName:
                                                'Sukan Electrician Service',
                                            location:
                                                '12, 2, Tirupparankunram Rd, kunram ',
                                            fieldName: 'Invididual',
                                            ratingStar: '4.5',
                                            ratingCount: '16',
                                            time: '9Pm',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                            padding: const EdgeInsets.symmetric(horizontal: 14),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,

                                  children: [
                                    Text(
                                      'Shops',
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
                                        color: Colors.black.withOpacity(0.05),
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

                        const SizedBox(height: 8),

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
                              children: List.generate(shopNameTabs.length, (
                                index,
                              ) {
                                final isSelected = selectedIndex == index;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
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
                                    shopNameTabs[index]["label"],
                                    isSelected: isSelected,
                                    onTap: () {
                                      setState(() => selectedIndex = index);
                                    },
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        // CONTENT CARD
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
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    child: Column(
                                      children: [
                                        CommonContainer.servicesContainer(
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
                                                      initialIndex: 4,
                                                    ),
                                              ),
                                            );
                                            // Navigator.push(
                                            //   context,
                                            //   PageRouteBuilder(
                                            //     transitionDuration: Duration(
                                            //       milliseconds: 1000,
                                            //     ),
                                            //     pageBuilder:
                                            //         (
                                            //           context,
                                            //           animation,
                                            //           secondaryAnimation,
                                            //         ) => ShopsDetails(
                                            //           heroTag: 'shop1',
                                            //           image: AppImages
                                            //               .imageContainer1,
                                            //         ),
                                            //     transitionsBuilder:
                                            //         (
                                            //           context,
                                            //           animation,
                                            //           secondaryAnimation,
                                            //           child,
                                            //         ) {
                                            //           final scaleAnimation =
                                            //               Tween<double>(
                                            //                 begin: 0.8,
                                            //                 end: 1.0,
                                            //               ).animate(
                                            //                 CurvedAnimation(
                                            //                   parent: animation,
                                            //                   curve: Curves
                                            //                       .easeOut,
                                            //                 ),
                                            //               );
                                            //           return ScaleTransition(
                                            //             scale: scaleAnimation,
                                            //             child: FadeTransition(
                                            //               opacity: animation,
                                            //               child: child,
                                            //             ),
                                            //           );
                                            //         },
                                            //   ),
                                            // );
                                          },
                                          Verify: true,
                                          image: AppImages.imageContainer1,
                                          companyName:
                                              'Sri Krishna Sweets Private Limited',
                                          location:
                                              '12, 2, Tirupparankunram Rd, kunram ',
                                          fieldName: '5Kms',
                                          ratingStar: '4.5',
                                          ratingCount: '16',
                                          time: '9Pm',
                                        ),
                                        SizedBox(height: 6),
                                        CommonContainer.servicesContainer(
                                          horizontalDivider: true,
                                          onTap: () {},
                                          image: AppImages.shopContainer2,
                                          companyName: 'Nach Textiles',
                                          location:
                                              '12, 2, Tirupparankunram Rd, kunram ',
                                          fieldName: '5Kms',
                                          ratingStar: '4.5',
                                          ratingCount: '16',
                                          time: '9Pm',
                                        ),
                                        SizedBox(height: 6),
                                        CommonContainer.servicesContainer(
                                          horizontalDivider: true,
                                          onTap: () {},
                                          image: AppImages.shopContainer3,
                                          companyName: 'Zam Zam Sweets',
                                          location:
                                              '12, 2, Tirupparankunram Rd, kunram ',
                                          fieldName: '5Kms',
                                          ratingStar: '4.5',
                                          ratingCount: '16',
                                          time: '9Pm',
                                        ),
                                        SizedBox(height: 6),
                                        CommonContainer.servicesContainer(
                                          horizontalDivider: true,
                                          onTap: () {},
                                          image: AppImages.shopContainer4,
                                          companyName: 'Ambika Textiles',
                                          location:
                                              '12, 2, Tirupparankunram Rd, kunram ',
                                          fieldName: '5Kms',
                                          ratingStar: '4.5',
                                          ratingCount: '16',
                                          time: '9Pm',
                                        ),
                                        SizedBox(height: 6),
                                        CommonContainer.servicesContainer(
                                          horizontalDivider: true,
                                          onTap: () {},

                                          image: AppImages.shopContainer5,
                                          companyName:
                                              'JMS Bhagavathi Amman Sweets',
                                          location:
                                              '12, 2, Tirupparankunram Rd, kunram ',
                                          fieldName: '5Kms',
                                          ratingStar: '4.5',
                                          ratingCount: '16',
                                          time: '9Pm',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 25),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'View All Shops',
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
    );
  }
}
