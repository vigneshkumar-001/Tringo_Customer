
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../Core/Utility/app_Images.dart';
import '../../../../Core/Utility/app_color.dart';
import '../../../../Core/Utility/google_font.dart';
import '../../../../Core/Widgets/common_container.dart';

class FoodBookingFailed extends StatefulWidget {
  const FoodBookingFailed({super.key});

  @override
  State<FoodBookingFailed> createState() => _FoodBookingFailedState();
}

class _FoodBookingFailedState extends State<FoodBookingFailed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColor.darkRed,
                      image: DecorationImage(
                        image: AssetImage(AppImages.successfulBCImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 42.0),
                      child: Column(
                        children: [
                          Image.asset(AppImages.failedImage, height: 128),
                          Text(
                            'Payment Failed',
                            style: GoogleFont.Mulish(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: AppColor.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Transaction Id 8U994KL',
                            style: GoogleFont.Mulish(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColor.white,
                            ),
                          ),
                          const SizedBox(height: 55),
                        ],
                      ),
                    ),
                  ),

                  // Spacer to make room for the floating card
                  const SizedBox(height: 110),

                  // Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CommonContainer.callNowButton(
                      callOnTap: () {},
                      callIconSize: 25,
                      callImage: AppImages.support,
                      callImageColor: AppColor.white,
                      callText: 'Raise Ticket',
                      callTextSize: 16,
                      callNowPadding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 13,
                      ),
                      mapBox: true,
                      mapOnTap: () {},
                      mapTextSize: 16,
                      mapImage: AppImages.callImage,
                      mapIconSize: 19,
                      mapText: 'Call Support',
                      mapBoxPadding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 13,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Similar foods header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Text(
                          'Similar Foods',
                          style: GoogleFont.Mulish(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        const Spacer(),
                        CommonContainer.rightSideArrowButton(onTap: () {}),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Similar foods list
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        CommonContainer.similarFoods(
                          Verify: true,
                          image: AppImages.similarFoods1,
                          foodName: 'Ghee Roast',
                          ratingStar: '4.5',
                          ratingCount: '16',
                          offAmound: '₹60',
                          oldAmound: '₹80',
                          km: '230Mts',
                          location: 'Lakshmi Bevan',
                        ),
                        const SizedBox(width: 10),
                        CommonContainer.similarFoods(
                          Verify: false,
                          image: AppImages.similarFoods2,
                          foodName: 'Parotta',
                          ratingStar: '4.5',
                          ratingCount: '16',
                          offAmound: '₹120',
                          oldAmound: '₹128',
                          km: '5Kms',
                          location: 'Hotel Dave',
                        ),
                        const SizedBox(width: 10),
                        CommonContainer.similarFoods(
                          Verify: true,
                          image: AppImages.similarFoods3,
                          foodName: 'Pulav',
                          ratingStar: '4.5',
                          ratingCount: '16',
                          offAmound: '₹110',
                          oldAmound: '₹160',
                          km: '5Kms',
                          location: 'Veaan Hotel',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 46),
                ],
              ),

              // Floating info card
              Positioned(
                top: 270,
                left: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Incase your money collected from our end, it will be refunded shortly.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.mulish(
                            fontSize: 14,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 27),
                        Text(
                          'Do you have any doubt, please raise ticket in support',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.mulish(
                            fontSize: 14,
                            color: AppColor.lightRed,
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
  }
}
