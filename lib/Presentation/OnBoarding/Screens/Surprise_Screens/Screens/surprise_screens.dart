import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Surprise_Screens/Screens/Opened_surprise_offer_screen.dart';

import '../../../../../Core/Widgets/common_container.dart';

class SurpriseScreens extends StatefulWidget {
  const SurpriseScreens({super.key});

  @override
  State<SurpriseScreens> createState() => _SurpriseScreensState();
}

class _SurpriseScreensState extends State<SurpriseScreens> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColor.emeraldGreen, AppColor.green],
          ),
          image: DecorationImage(
            image: AssetImage(AppImages.paymentBCImage),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              /// ✅ MAIN CONTENT
              Padding(
                padding: const EdgeInsets.only(top: 220),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 30,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 85,
                                right: 15,
                                left: 15,
                                bottom: 25,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Move 500Mtrs',
                                    textAlign: TextAlign.center,
                                    style: GoogleFont.Mulish(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      color: AppColor.white,
                                    ),
                                  ),
                                  Text(
                                    'Towards the shop to Unlock',
                                    textAlign: TextAlign.center,
                                    style: GoogleFont.Mulish(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.white,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Container(
                                    height: 0.5,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          const Color(
                                            0xFFFFFFFF,
                                          ).withOpacity(0.2),
                                          const Color(
                                            0xFFF1F1F1,
                                          ).withOpacity(0.3),
                                          const Color(
                                            0xFFF1F1F1,
                                          ).withOpacity(0.3),
                                          const Color(
                                            0xFFFFFFFF,
                                          ).withOpacity(0.2),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 12,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Zam Zam Sweets',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFont.Mulish(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: AppColor.white,
                                                ),
                                              ),
                                              const SizedBox(height: 13),
                                              Row(
                                                children: [
                                                  CommonContainer.greenStarRating(
                                                    ratingStar: '4.5',
                                                    ratingCount: '16',
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    'Opens Upto ',
                                                    style: GoogleFont.Mulish(
                                                      fontSize: 9,
                                                      color:
                                                          AppColor.borderGray,
                                                    ),
                                                  ),
                                                  Text(
                                                    '9Pm',
                                                    style: GoogleFont.Mulish(
                                                      fontSize: 9,
                                                      color:
                                                          AppColor.borderGray,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.asset(
                                          AppImages.shopContainer3,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColor.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 17.5,
                                horizontal: 33,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppImages.leftStickArrow,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Skip',
                                    style: GoogleFont.Mulish(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OpenedSurpriseOfferScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColor.black,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 17.5,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        AppImages.refresh,
                                        height: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Refresh',
                                        style: GoogleFont.Mulish(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColor.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),

              /// ✅ GIFT IMAGE (UNDER HEADER)
              Positioned(
                top: 120,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 58),
                  child: Image.asset(
                    AppImages.surpriseOfferGift,
                    height: 219,
                    width: 264,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              /// ✅ TOP HEADER (ALWAYS ON TOP)
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
                        /// LEFT BACK BUTTON
                        Align(
                          alignment: Alignment.centerLeft,
                          child: CommonContainer.leftSideArrow(),
                        ),

                        /// TITLE EXACT SCREEN CENTER ✅
                        Text(
                          'Open Offer',
                          style: GoogleFont.Mulish(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColor.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColor.emeraldGreen, AppColor.green],
          ),
          image: DecorationImage(
            image: AssetImage(AppImages.paymentBCImage),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    CommonContainer.leftSideArrow(),

                    Text('Open Offer'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 220),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 30,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 85,
                                right: 15,
                                left: 15,
                                bottom: 25,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Move 500Mtrs',
                                    textAlign: TextAlign.center,
                                    style: GoogleFont.Mulish(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      color: AppColor.white,
                                    ),
                                  ),
                                  Text(
                                    'Towards the shop to Unlock',
                                    textAlign: TextAlign.center,
                                    style: GoogleFont.Mulish(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.white,
                                    ),
                                  ),

                                  const SizedBox(height: 20),
                                  Container(
                                    height: 0.5,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color(0xFFFFFFFF).withOpacity(0.2),
                                          Color(0xFFF1F1F1).withOpacity(0.3),
                                          Color(0xFFF1F1F1).withOpacity(0.3),
                                          Color(0xFFFFFFFF).withOpacity(0.2),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 12,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Zam Zam Sweets',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFont.Mulish(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: AppColor.white,
                                                ),
                                              ),
                                              const SizedBox(height: 13),
                                              Row(
                                                children: [
                                                  CommonContainer.greenStarRating(
                                                    ratingStar: '4.5',
                                                    ratingCount: '16',
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    'Opens Upto ',
                                                    style: GoogleFont.Mulish(
                                                      fontSize: 9,
                                                      color:
                                                          AppColor.borderGray,
                                                    ),
                                                  ),
                                                  Text(
                                                    '9Pm',
                                                    style: GoogleFont.Mulish(
                                                      fontSize: 9,
                                                      color:
                                                          AppColor.borderGray,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      /// RIGHT SIDE IMAGE
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.asset(
                                          AppImages
                                              .shopContainer3, // replace with your image
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColor.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 17.5,
                                horizontal: 33,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppImages.leftStickArrow,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Skip',
                                    style: GoogleFont.Mulish(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder:
                                //         (context) => const CommonBottomNavigation(
                                //       initialIndex: 0,
                                //     ),
                                //   ),
                                // );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColor.black,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 17.5,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        AppImages.refresh,
                                        height: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Refresh',
                                        style: GoogleFont.Mulish(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColor.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),

              Positioned(
                top: 75,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 58,
                    vertical: 60,
                  ),
                  child: Image.asset(
                    AppImages.surpriseOfferGift,
                    height: 219,
                    width: 264,
                    fit: BoxFit.contain,
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
