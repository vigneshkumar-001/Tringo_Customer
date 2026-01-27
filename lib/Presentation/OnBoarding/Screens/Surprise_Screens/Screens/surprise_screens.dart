import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';
import 'package:video_player/video_player.dart';

import '../../../../../Core/Utility/app_color.dart';

class AppVideos {
  static const String surpriseOpenVideo = "Assets/Videos/surprise-opens.mp4";
}

class SurpriseScreens extends StatefulWidget {
  final double shopLat;
  final double shopLng;

  const SurpriseScreens({
    super.key,
    required this.shopLat,
    required this.shopLng,
  });

  @override
  State<SurpriseScreens> createState() => _SurpriseScreensState();
}

class _SurpriseScreensState extends State<SurpriseScreens> {
  double remainingMeters = 0.0;
  bool _loadingDistance = true;

  StreamSubscription<Position>? _posSub;

  VideoPlayerController? _videoCtrl;
  bool _showVideo = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _initLocationAndStartTracking();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _videoCtrl?.dispose();
    super.dispose();
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

      // ✅ First fetch immediately
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      _updateDistance(pos.latitude, pos.longitude);

      // ✅ Live updates while user moves
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
    ).toDouble();

    final newMeters = dist < 0 ? 0.0 : dist;

    if (!mounted) return;

    setState(() => remainingMeters = newMeters);

    if (remainingMeters <= 0) {
      _triggerVideoIfZero();
    }
  }

  Future<void> _triggerVideoIfZero() async {
    if (_showVideo) return;

    if (remainingMeters <= 0) {
      setState(() => _showVideo = true);

      try {
        _videoCtrl?.dispose();
        _videoCtrl = VideoPlayerController.asset(AppVideos.surpriseOpenVideo);

        await _videoCtrl!.initialize();
        _videoCtrl!.setLooping(false);
        await _videoCtrl!.play();

        setState(() {});

        _videoCtrl!.addListener(() {
          if (_videoCtrl == null) return;

          final v = _videoCtrl!;
          if (!v.value.isInitialized) return;

          final ended = v.value.position >= v.value.duration;

          if (ended && !_navigated) {
            _navigated = true;
            if (!mounted) return;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const OpenedSurpriseOfferScreen(),
              ),
            );
          }
        });
      } catch (e) {
        _showMsg("Video error: $e");
      }
    }
  }

  Future<void> _refreshDistance() async {
    setState(() => _loadingDistance = true);

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    _updateDistance(pos.latitude, pos.longitude);

    setState(() => _loadingDistance = false);
  }

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              // ✅ HEADER
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

              // ✅ MAIN CONTENT (CENTER)
              Align(
                alignment: const Alignment(0, 0.30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ CARD + GIFT OVERLAP
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // ✅ GLASS CARD (fixed height like figma)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                height: 360, // ✅ important (no full screen)
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                  top: 120, // ✅ gift overlap space
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
                                        "Move ${remainingMeters.toInt()}Mtrs",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 34,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Towards the shop to Unlock",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),

                                    SizedBox(height: 30),
                                    Container(
                                      width: double.infinity,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerRight,
                                          end: Alignment.centerLeft,
                                          colors: [
                                            AppColor.white.withOpacity(0.01),
                                            AppColor.white4.withOpacity(0.1),
                                            AppColor.white4.withOpacity(0.1),
                                            AppColor.white4.withOpacity(0.1),
                                            AppColor.white4.withOpacity(0.1),
                                            AppColor.white4.withOpacity(0.1),
                                            AppColor.white4.withOpacity(0.1),
                                            AppColor.white.withOpacity(0.01),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                    // ✅ SHOP INFO CARD (like figma)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18.0,
                                      ),
                                      child: Row(
                                        children: [
                                          // shop text
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Zam Zam Sweets",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    CommonContainer.greenStarRating(
                                                      ratingCount: '16',
                                                      ratingStar: '4.5',
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      "Opens Upto",
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white70,
                                                      ),
                                                    ),
                                                    SizedBox(width: 3),
                                                    Text(
                                                      "9pm",
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white70,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          // shop image
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.asset(
                                              AppImages
                                                  .shopContainer3, // ✅ put your image here
                                              height: 62,
                                              width: 66,
                                              fit: BoxFit.cover,
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

                          // ✅ GIFT / VIDEO ON TOP (OVER CARD)
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
                                  child: _showVideo
                                      ? (_videoCtrl != null &&
                                                _videoCtrl!.value.isInitialized)
                                            ? AspectRatio(
                                                aspectRatio: _videoCtrl!
                                                    .value
                                                    .aspectRatio,
                                                child: VideoPlayer(_videoCtrl!),
                                              )
                                            : const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                    ),
                                              )
                                      : Image.asset(
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

                      // ✅ BUTTONS (below card like figma)
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
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                              onTap: _refreshDistance,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}

// ✅ dummy next page
class OpenedSurpriseOfferScreen extends StatelessWidget {
  const OpenedSurpriseOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Offer Opened 🎁")));
  }
}

///old///
// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:tringo_app/Core/Utility/app_Images.dart';
// import 'package:tringo_app/Core/Utility/app_color.dart';
// import 'package:tringo_app/Core/Utility/google_font.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Surprise_Screens/Screens/Opened_surprise_offer_screen.dart';
//
// import '../../../../../Core/Widgets/common_container.dart';
//
// class SurpriseScreens extends StatefulWidget {
//   const SurpriseScreens({super.key});
//
//   @override
//   State<SurpriseScreens> createState() => _SurpriseScreensState();
// }
//
// class _SurpriseScreensState extends State<SurpriseScreens> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [AppColor.emeraldGreen, AppColor.green],
//           ),
//           image: DecorationImage(
//             image: AssetImage(AppImages.paymentBCImage),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: SafeArea(
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               /// ✅ MAIN CONTENT
//               Padding(
//                 padding: const EdgeInsets.only(top: 220),
//                 child: Column(
//                   children: [
//                     Container(
//                       margin: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 30,
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: BackdropFilter(
//                           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 20,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.15),
//                               borderRadius: BorderRadius.circular(20),
//                               border: Border.all(
//                                 color: Colors.white.withOpacity(0.3),
//                                 width: 1.5,
//                               ),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.only(
//                                 top: 85,
//                                 right: 15,
//                                 left: 15,
//                                 bottom: 25,
//                               ),
//                               child: Column(
//                                 children: [
//                                   Text(
//                                     'Move 500Mtrs',
//                                     textAlign: TextAlign.center,
//                                     style: GoogleFont.Mulish(
//                                       fontSize: 34,
//                                       fontWeight: FontWeight.w900,
//                                       color: AppColor.white,
//                                     ),
//                                   ),
//                                   Text(
//                                     'Towards the shop to Unlock',
//                                     textAlign: TextAlign.center,
//                                     style: GoogleFont.Mulish(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w700,
//                                       color: AppColor.white,
//                                     ),
//                                   ),
//
//                                   const SizedBox(height: 20),
//
//                                   Container(
//                                     height: 0.5,
//                                     width: double.infinity,
//                                     decoration: BoxDecoration(
//                                       gradient: LinearGradient(
//                                         begin: Alignment.centerLeft,
//                                         end: Alignment.centerRight,
//                                         colors: [
//                                           const Color(
//                                             0xFFFFFFFF,
//                                           ).withOpacity(0.2),
//                                           const Color(
//                                             0xFFF1F1F1,
//                                           ).withOpacity(0.3),
//                                           const Color(
//                                             0xFFF1F1F1,
//                                           ).withOpacity(0.3),
//                                           const Color(
//                                             0xFFFFFFFF,
//                                           ).withOpacity(0.2),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//
//                                   const SizedBox(height: 20),
//
//                                   Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Expanded(
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(
//                                             right: 12,
//                                           ),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 'Zam Zam Sweets',
//                                                 maxLines: 1,
//                                                 overflow: TextOverflow.ellipsis,
//                                                 style: GoogleFont.Mulish(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 16,
//                                                   color: AppColor.white,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 13),
//                                               Row(
//                                                 children: [
//                                                   CommonContainer.greenStarRating(
//                                                     ratingStar: '4.5',
//                                                     ratingCount: '16',
//                                                   ),
//                                                   const SizedBox(width: 10),
//                                                   Text(
//                                                     'Opens Upto ',
//                                                     style: GoogleFont.Mulish(
//                                                       fontSize: 9,
//                                                       color:
//                                                           AppColor.borderGray,
//                                                     ),
//                                                   ),
//                                                   Text(
//                                                     '9Pm',
//                                                     style: GoogleFont.Mulish(
//                                                       fontSize: 9,
//                                                       color:
//                                                           AppColor.borderGray,
//                                                       fontWeight:
//                                                           FontWeight.w800,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//
//                                       ClipRRect(
//                                         borderRadius: BorderRadius.circular(15),
//                                         child: Image.asset(
//                                           AppImages.shopContainer3,
//                                           width: 80,
//                                           height: 80,
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 24),
//                       child: Row(
//                         children: [
//                           Container(
//                             decoration: BoxDecoration(
//                               color: AppColor.black.withOpacity(0.6),
//                               borderRadius: BorderRadius.circular(14),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 vertical: 17.5,
//                                 horizontal: 33,
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Image.asset(
//                                     AppImages.leftStickArrow,
//                                     height: 20,
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     'Skip',
//                                     style: GoogleFont.Mulish(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w700,
//                                       color: AppColor.white,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         OpenedSurpriseOfferScreen(),
//                                   ),
//                                 );
//                               },
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: AppColor.black,
//                                   borderRadius: BorderRadius.circular(14),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 17.5,
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Image.asset(
//                                         AppImages.refresh,
//                                         height: 18,
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Text(
//                                         'Refresh',
//                                         style: GoogleFont.Mulish(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w700,
//                                           color: AppColor.white,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 30),
//                   ],
//                 ),
//               ),
//
//               /// ✅ GIFT IMAGE (UNDER HEADER)
//               Positioned(
//                 top: 120,
//                 left: 0,
//                 right: 0,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 58),
//                   child: Image.asset(
//                     AppImages.surpriseOpens,
//                     height: 219,
//                     width: 264,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ),
//
//               /// ✅ TOP HEADER (ALWAYS ON TOP)
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 15,
//                     vertical: 15,
//                   ),
//                   child: SizedBox(
//                     height: 44,
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         /// LEFT BACK BUTTON
//                         Align(
//                           alignment: Alignment.centerLeft,
//                           child: CommonContainer.leftSideArrow(),
//                         ),
//
//                         /// TITLE EXACT SCREEN CENTER ✅
//                         Text(
//                           'Open Offer',
//                           style: GoogleFont.Mulish(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             color: AppColor.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [AppColor.emeraldGreen, AppColor.green],
//           ),
//           image: DecorationImage(
//             image: AssetImage(AppImages.paymentBCImage),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: SafeArea(
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 15,
//                   vertical: 15,
//                 ),
//                 child: Row(
//                   children: [
//                     CommonContainer.leftSideArrow(),
//
//                     Text('Open Offer'),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 220),
//                 child: Column(
//                   children: [
//                     Container(
//                       margin: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 30,
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: BackdropFilter(
//                           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 20,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.15),
//                               borderRadius: BorderRadius.circular(20),
//                               border: Border.all(
//                                 color: Colors.white.withOpacity(0.3),
//                                 width: 1.5,
//                               ),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.only(
//                                 top: 85,
//                                 right: 15,
//                                 left: 15,
//                                 bottom: 25,
//                               ),
//                               child: Column(
//                                 children: [
//                                   Text(
//                                     'Move 500Mtrs',
//                                     textAlign: TextAlign.center,
//                                     style: GoogleFont.Mulish(
//                                       fontSize: 34,
//                                       fontWeight: FontWeight.w900,
//                                       color: AppColor.white,
//                                     ),
//                                   ),
//                                   Text(
//                                     'Towards the shop to Unlock',
//                                     textAlign: TextAlign.center,
//                                     style: GoogleFont.Mulish(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w700,
//                                       color: AppColor.white,
//                                     ),
//                                   ),
//
//                                   const SizedBox(height: 20),
//                                   Container(
//                                     height: 0.5,
//                                     width: double.infinity,
//                                     decoration: BoxDecoration(
//                                       gradient: LinearGradient(
//                                         begin: Alignment.centerLeft,
//                                         end: Alignment.centerRight,
//                                         colors: [
//                                           Color(0xFFFFFFFF).withOpacity(0.2),
//                                           Color(0xFFF1F1F1).withOpacity(0.3),
//                                           Color(0xFFF1F1F1).withOpacity(0.3),
//                                           Color(0xFFFFFFFF).withOpacity(0.2),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 20),
//
//                                   Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Expanded(
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(
//                                             right: 12,
//                                           ),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 'Zam Zam Sweets',
//                                                 maxLines: 1,
//                                                 overflow: TextOverflow.ellipsis,
//                                                 style: GoogleFont.Mulish(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 16,
//                                                   color: AppColor.white,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 13),
//                                               Row(
//                                                 children: [
//                                                   CommonContainer.greenStarRating(
//                                                     ratingStar: '4.5',
//                                                     ratingCount: '16',
//                                                   ),
//                                                   const SizedBox(width: 10),
//                                                   Text(
//                                                     'Opens Upto ',
//                                                     style: GoogleFont.Mulish(
//                                                       fontSize: 9,
//                                                       color:
//                                                           AppColor.borderGray,
//                                                     ),
//                                                   ),
//                                                   Text(
//                                                     '9Pm',
//                                                     style: GoogleFont.Mulish(
//                                                       fontSize: 9,
//                                                       color:
//                                                           AppColor.borderGray,
//                                                       fontWeight:
//                                                           FontWeight.w800,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//
//                                       /// RIGHT SIDE IMAGE
//                                       ClipRRect(
//                                         borderRadius: BorderRadius.circular(15),
//                                         child: Image.asset(
//                                           AppImages
//                                               .shopContainer3, // replace with your image
//                                           width: 80,
//                                           height: 80,
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 24),
//                       child: Row(
//                         children: [
//                           Container(
//                             decoration: BoxDecoration(
//                               color: AppColor.black.withOpacity(0.6),
//                               borderRadius: BorderRadius.circular(14),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 vertical: 17.5,
//                                 horizontal: 33,
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Image.asset(
//                                     AppImages.leftStickArrow,
//                                     height: 20,
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     'Skip',
//                                     style: GoogleFont.Mulish(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w700,
//                                       color: AppColor.white,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () {
//                                 // Navigator.push(
//                                 //   context,
//                                 //   MaterialPageRoute(
//                                 //     builder:
//                                 //         (context) => const CommonBottomNavigation(
//                                 //       initialIndex: 0,
//                                 //     ),
//                                 //   ),
//                                 // );
//                               },
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: AppColor.black,
//                                   borderRadius: BorderRadius.circular(14),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 17.5,
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Image.asset(
//                                         AppImages.refresh,
//                                         height: 18,
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Text(
//                                         'Refresh',
//                                         style: GoogleFont.Mulish(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w700,
//                                           color: AppColor.white,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 30),
//                   ],
//                 ),
//               ),
//
//               Positioned(
//                 top: 75,
//                 left: 0,
//                 right: 0,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 58,
//                     vertical: 60,
//                   ),
//                   child: Image.asset(
//                     AppImages.surpriseOfferGift,
//                     height: 219,
//                     width: 264,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
