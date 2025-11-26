import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/shops_details.dart';

import '../../../../Core/Utility/google_font.dart';
import '../../../../Core/Widgets/Common Bottom Navigation bar/service_and_shops_details.dart';
import '../../../../Core/Widgets/current_location_widget.dart';

class ShopsListing extends StatefulWidget {
  const ShopsListing({super.key});

  @override
  State<ShopsListing> createState() => _ShopsListingState();
}

class _ShopsListingState extends State<ShopsListing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> aHeader;
  late Animation<double> aLocationChip;
  late List<Animation<double>> aShops; // For each shop card

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    final curve = CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic);

    aHeader = CurvedAnimation(parent: curve, curve: const Interval(0.0, 0.2));
    aLocationChip = CurvedAnimation(
      parent: curve,
      curve: const Interval(0.1, 0.3),
    );

    // ✅ Generate 6 animations to match 6 shop cards
    aShops = List.generate(6, (i) {
      final start = 0.2 + i * 0.1;
      final end = start + 0.20;
      return CurvedAnimation(parent: curve, curve: Interval(start, end));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _ac.forward());
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  Widget _fadeSlide(
    Animation<double> animation,
    Widget child, {
    double dy = 20,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - animation.value) * dy),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 16,
                ),
                child: _fadeSlide(
                  aHeader,
                  Row(
                    children: [
                      CommonContainer.leftSideArrow(
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: 15),
                      Text(
                        'Shops',
                        style: GoogleFont.Mulish(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: AppColor.black,
                        ),
                      ),
                      SizedBox(width: 80),
                      Expanded(
                        child: CurrentLocationWidget(
                          locationIcon: AppImages.locationImage,
                          dropDownIcon: AppImages.drapDownImage,
                          textStyle: GoogleFonts.mulish(
                            color: AppColor.darkBlue,
                            fontWeight: FontWeight.w600,
                          ),
                          onTap: () {
                            // Handle location change, e.g., open map picker or bottom sheet
                            print('Change location tapped!');
                          },
                        ),
                      ),

                      // Expanded(
                      //   child: CommonContainer.gradientContainer(
                      //     textColor: AppColor.darkBlue,
                      //     dIconColor: AppColor.darkBlue,
                      //     lIconColor: AppColor.blue,
                      //     iconImage: AppImages.drapDownImage,
                      //     locationImage: AppImages.locationImage,
                      //     text: 'Marudhupandiyar nagar main road, Madurai',
                      //   ),
                      // ),
                    ],
                  ),
                ),

                /*Row(
                  children: [
                    CommonContainer.leftSideArrow(
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 15),
                    Text(
                      'Shops',
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: AppColor.black,
                      ),
                    ),
                    SizedBox(width: 60),
                    CommonContainer.gradientContainer(
                      iconImage: AppImages.drapDownImage,
                      locationImage: AppImages.locationImage,
                      text: 'Marudhupandiyar nagar main road, Madurai',
                    ),
                  ],
                ),*/
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        children: [
                          _fadeSlide(
                            aShops[0],
                            CommonContainer.servicesContainer(
                              heroTag: 'shopImageHero_sks',
                              horizontalDivider: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ServiceAndShopsDetails(initialIndex: 4),
                                  ),
                                );
                                // Navigator.of(context).push(
                                //   PageRouteBuilder(
                                //     transitionDuration: const Duration(
                                //       milliseconds: 650,
                                //     ),
                                //     reverseTransitionDuration: const Duration(
                                //       milliseconds: 550,
                                //     ),
                                //     pageBuilder: (_, animation, __) =>
                                //         ShopsDetails(
                                //           heroTag: 'shopImageHero_sks',
                                //           image: AppImages.imageContainer1,
                                //         ),
                                //     transitionsBuilder:
                                //         (_, animation, __, child) {
                                //           final curve = CurvedAnimation(
                                //             parent: animation,
                                //             curve: Curves.easeOutCubic,
                                //             reverseCurve: Curves.easeInCubic,
                                //           );
                                //           return FadeTransition(
                                //             opacity: curve,
                                //             child: child,
                                //           );
                                //         },
                                //   ),
                                // );
                              },
                              Verify: true,
                              image: AppImages.imageContainer1,
                              companyName: 'Sri Krishna Sweets Private Limited',
                              location: '12, 2, Tirupparankunram Rd, kunram ',
                              fieldName: '5Kms',
                              ratingStar: '4.5',
                              ratingCount: '16',
                              time: '9Pm',
                            ),
                          ),

                          /* CommonContainer.servicesContainer(
                            heroTag:
                                'shopImageHero_sks', // unique tag for THIS card only
                            horizontalDivider: true,
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration: const Duration(
                                    milliseconds: 650,
                                  ),
                                  reverseTransitionDuration: const Duration(
                                    milliseconds: 550,
                                  ),
                                  pageBuilder: (_, animation, __) =>
                                      ShopsDetails(
                                        heroTag: 'shopImageHero_sks',
                                        image: AppImages.imageContainer1,
                                      ),
                                  transitionsBuilder:
                                      (_, animation, __, child) {
                                        final curve = CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                          reverseCurve: Curves.easeInCubic,
                                        );
                                        return FadeTransition(
                                          opacity: curve,
                                          child: child,
                                        );
                                      },
                                ),
                              );
                            },
                            Verify: true,
                            image: AppImages.imageContainer1,
                            companyName: 'Sri Krishna Sweets Private Limited',
                            location: '12, 2, Tirupparankunram Rd, kunram ',
                            fieldName: '5Kms',
                            ratingStar: '4.5',
                            ratingCount: '16',
                            time: '9Pm',
                          ),*/
                          SizedBox(height: 6),
                          _fadeSlide(
                            aShops[1],
                            CommonContainer.servicesContainer(
                              horizontalDivider: true,
                              onTap: () {},
                              image: AppImages.shopContainer2,
                              companyName: 'Nach Textiles',
                              location: '12, 2, Tirupparankunram Rd, kunram ',
                              fieldName: '5Kms',
                              ratingStar: '4.5',
                              ratingCount: '16',
                              time: '9Pm',
                            ),
                          ),
                          SizedBox(height: 6),
                          _fadeSlide(
                            aShops[2],
                            CommonContainer.servicesContainer(
                              horizontalDivider: true,
                              onTap: () {},
                              image: AppImages.shopContainer2,
                              companyName: 'Nach Textiles',
                              location: '12, 2, Tirupparankunram Rd, kunram ',
                              fieldName: '5Kms',
                              ratingStar: '4.5',
                              ratingCount: '16',
                              time: '9Pm',
                            ),
                          ),
                          SizedBox(height: 6),
                          _fadeSlide(
                            aShops[3],
                            CommonContainer.servicesContainer(
                              horizontalDivider: true,
                              onTap: () {},
                              image: AppImages.shopContainer3,
                              companyName: 'Zam Zam Sweets',
                              location: '12, 2, Tirupparankunram Rd, kunram ',
                              fieldName: '5Kms',
                              ratingStar: '4.5',
                              ratingCount: '16',
                              time: '9Pm',
                            ),
                          ),
                          SizedBox(height: 6),
                          _fadeSlide(
                            aShops[4],
                            CommonContainer.servicesContainer(
                              horizontalDivider: true,
                              onTap: () {},
                              image: AppImages.shopContainer4,
                              companyName: 'Ambika Textiles',
                              location: '12, 2, Tirupparankunram Rd, kunram ',
                              fieldName: '5Kms',
                              ratingStar: '4.5',
                              ratingCount: '16',
                              time: '9Pm',
                            ),
                          ),
                          SizedBox(height: 6),
                          _fadeSlide(
                            aShops[5],
                            CommonContainer.servicesContainer(
                              horizontalDivider: false,
                              onTap: () {},

                              image: AppImages.shopContainer5,
                              companyName: 'JMS Bhagavathi Amman Sweets',
                              location: '12, 2, Tirupparankunram Rd, kunram ',
                              fieldName: '5Kms',
                              ratingStar: '4.5',
                              ratingCount: '16',
                              time: '9Pm',
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),
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

/*
import 'package:flutter/material.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/shops_details.dart';
import '../../../../Core/Utility/google_font.dart';

class ShopsListing extends StatefulWidget {
  const ShopsListing({super.key});

  @override
  State<ShopsListing> createState() => _ShopsListingState();
}

class _ShopsListingState extends State<ShopsListing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> aHeader;
  late Animation<double> aLocationChip;
  late List<Animation<double>> aShops;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final curve = CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic);

    aHeader = CurvedAnimation(parent: curve, curve: const Interval(0.0, 0.2));
    aLocationChip = CurvedAnimation(parent: curve, curve: const Interval(0.1, 0.3));

    /// ✅ Make sure we create 6 animations to avoid RangeError
    aShops = List.generate(6, (i) {
      final start = 0.2 + i * 0.1;
      final end = (start + 0.15).clamp(0.0, 1.0);
      return CurvedAnimation(parent: curve, curve: Interval(start, end));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _ac.forward());
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  Widget _fadeSlide(
      Animation<double> animation,
      Widget child, {
        double dy = 20,
      }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - animation.value) * dy),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                child: _fadeSlide(
                  aHeader,
                  Row(
                    children: [
                      CommonContainer.leftSideArrow(
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        'Shops',
                        style: GoogleFont.Mulish(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: AppColor.black,
                        ),
                      ),
                      const SizedBox(width: 80),
                      Expanded(
                        child: CommonContainer.gradientContainer(
                          textColor: AppColor.darkBlue,
                          dIconColor: AppColor.darkBlue,
                          lIconColor: AppColor.blue,
                          iconImage: AppImages.drapDownImage,
                          locationImage: AppImages.locationImage,
                          text: 'Marudhupandiyar nagar main road, Madurai',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        children: List.generate(6, (index) {
                          final shopData = _getShopData(index);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _fadeSlide(
                              aShops[index],
                              CommonContainer.servicesContainer(
                                heroTag: shopData['heroTag'] ?? '',
                                horizontalDivider: index != 5,
                                onTap: shopData['onTap'],
                                image: shopData['image'],
                                companyName: shopData['companyName'],
                                location: shopData['location'],
                                fieldName: shopData['fieldName'],
                                ratingStar: shopData['ratingStar'],
                                ratingCount: shopData['ratingCount'],
                                time: shopData['time'],
                                Verify: shopData['Verify'] ?? false,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method to return each shop's mock data
  Map<String, dynamic> _getShopData(int index) {
    switch (index) {
      case 0:
        return {
          'heroTag': 'shopImageHero_sks',
          'onTap': () {
            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 650),
                reverseTransitionDuration: const Duration(milliseconds: 550),
                pageBuilder: (_, animation, __) => ShopsDetails(
                  heroTag: 'shopImageHero_sks',
                  image: AppImages.imageContainer1,
                ),
                transitionsBuilder: (_, animation, __, child) {
                  final curve = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  );
                  return FadeTransition(
                    opacity: curve,
                    child: child,
                  );
                },
              ),
            );
          },
          'image': AppImages.imageContainer1,
          'companyName': 'Sri Krishna Sweets Private Limited',
          'location': '12, 2, Tirupparankunram Rd, kunram ',
          'fieldName': '5Kms',
          'ratingStar': '4.5',
          'ratingCount': '16',
          'time': '9Pm',
          'Verify': true,
        };
      case 1:
      case 2:
        return {
          'image': AppImages.shopContainer2,
          'companyName': 'Nach Textiles',
          'location': '12, 2, Tirupparankunram Rd, kunram ',
          'fieldName': '5Kms',
          'ratingStar': '4.5',
          'ratingCount': '16',
          'time': '9Pm',
        };
      case 3:
        return {
          'image': AppImages.shopContainer3,
          'companyName': 'Zam Zam Sweets',
          'location': '12, 2, Tirupparankunram Rd, kunram ',
          'fieldName': '5Kms',
          'ratingStar': '4.5',
          'ratingCount': '16',
          'time': '9Pm',
        };
      case 4:
        return {
          'image': AppImages.shopContainer4,
          'companyName': 'Ambika Textiles',
          'location': '12, 2, Tirupparankunram Rd, kunram ',
          'fieldName': '5Kms',
          'ratingStar': '4.5',
          'ratingCount': '16',
          'time': '9Pm',
        };
      case 5:
        return {
          'image': AppImages.shopContainer5,
          'companyName': 'JMS Bhagavathi Amman Sweets',
          'location': '12, 2, Tirupparankunram Rd, kunram ',
          'fieldName': '5Kms',
          'ratingStar': '4.5',
          'ratingCount': '16',
          'time': '9Pm',
        };
      default:
        return {};
    }
  }
}
*/
