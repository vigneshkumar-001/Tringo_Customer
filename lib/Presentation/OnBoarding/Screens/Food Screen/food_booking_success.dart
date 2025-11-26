import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_border/dotted_border.dart' as dotted;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';

import '../../../../Core/Widgets/Common Bottom Navigation bar/payment_failed_bottombar.dart';
import 'food_booking_failed.dart';

class FoodBookingSuccess extends StatefulWidget {
  const FoodBookingSuccess({super.key});

  @override
  State<FoodBookingSuccess> createState() => _FoodBookingSuccessState();
}

class _FoodBookingSuccessState extends State<FoodBookingSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColor.deepGreen,
                      image: DecorationImage(
                        image: AssetImage(AppImages.successfulBCImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 42.0),
                      child: Column(
                        children: [
                          Image.asset(AppImages.successfulImage, height: 107),
                          Text(
                            'Payment Successful',
                            style: GoogleFont.Mulish(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: AppColor.white,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Order Id 8U994KL',
                            style: GoogleFont.Mulish(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColor.white,
                            ),
                          ),
                          SizedBox(height: 130),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 140),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: CommonContainer.callNowButton(
                      callOnTap: () {},
                      callIconSize: 16,
                      callImage: AppImages.callImage,
                      callText: 'Call Shop',
                      callTextSize: 16,
                      callNowPadding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 13,
                      ),
                      mapBox: true,
                      mapOnTap: () {},
                      mapTextSize: 16,
                      mapImage: AppImages.locationImage,
                      mapIconSize: 21,
                      mapText: 'Shop Location',
                      mapBoxPadding: EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 13,
                      ),
                    ),
                  ),
                  SizedBox(height: 26),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PaymentFailedBottombar(initialIndex: 3),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: DottedBorder(
                        color: AppColor.mistGray,
                        dashPattern: [4.0, 2.0],
                        borderType: dotted.BorderType.RRect,
                        padding: EdgeInsets.all(10),
                        radius: Radius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Show',
                                        style: GoogleFont.Mulish(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                      Text(
                                        ' QR  ',
                                        style: GoogleFont.Mulish(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                      Text(
                                        '( or )',
                                        style: GoogleFont.Mulish(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: AppColor.borderGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    'Your Tringo Id',
                                    style: GoogleFont.Mulish(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                  Text(
                                    '8U994KL',
                                    style: GoogleFont.Mulish(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.blue,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFF7F8FB,
                                  ), // soft light gray background
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColor.lightGray.withOpacity(0.2),
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    // top-left highlight (light glow)
                                    /* BoxShadow(
                                    color: Colors.white,
                                    offset: Offset(-4, -1),
                                    blurRadius: 20,
                                  ),*/
                                    // bottom-right soft shadow
                                    /*   BoxShadow(
                                    color: Color(0x33000000), // subtle dark gray
                                    offset: Offset(2, 2),
                                    spreadRadius: -3,
                                    blurRadius: 7,
                                  ),*/
                                  ],
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    // color: Colors.white, // inner card surface
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      // soft inner elevation
                                      BoxShadow(
                                        color: Color(0x22000000),
                                        spreadRadius: -9,
                                        offset: Offset(0, 3),
                                        blurRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: AppColor.mistGray.withOpacity(
                                          0.1,
                                        ),
                                        spreadRadius: 1,
                                        offset: Offset(0, 0),
                                        blurRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: AppColor.white.withOpacity(0.3),
                                        offset: Offset(-3, -3),
                                        spreadRadius: 1,
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: Image.asset(
                                        AppImages.qrCodeImage,
                                        fit: BoxFit.contain,
                                        filterQuality: FilterQuality.high,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 47),
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
                        Spacer(),
                        CommonContainer.rightSideArrowButton(onTap: () {}),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 15),
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
                        SizedBox(width: 10),
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
                        SizedBox(width: 10),
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
                  SizedBox(height: 46),
                ],
              ),
              Positioned(
                top: 250,
                left: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 5), // shadow only at bottom
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 25,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Center everything vertically
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween, // Space between the items
                          children: [
                            // Left Column (Image + Text + Price)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  AppImages.idlyImage,
                                  height: 132,
                                  width: 136,
                                  fit: BoxFit
                                      .cover, // Make sure the image fits within the bounds
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Idly Set - 1',
                                  style: GoogleFonts.mulish(
                                    fontSize: 16,
                                    fontWeight: FontWeight
                                        .w600, // Adjust font weight for consistency
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '₹8',
                                      style: GoogleFonts.mulish(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 22,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '₹12',
                                      style: GoogleFonts.mulish(
                                        fontSize: 14,
                                        color: AppColor.lightGray3,
                                        decoration: TextDecoration.lineThrough,
                                        decorationThickness: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(width: 55),

                            // Right Column (Shop Image + Text)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppImages.shabaris2,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Your Food is Waiting..!',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.mulish(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 325,
                child: Align(
                  alignment:
                      Alignment.center, // This ensures it's vertically centered
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: AppColor.whiteSmoke,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          AppImages.rightArrow,
                          height: 16,
                          color: AppColor.lightBlueCont,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /*   Positioned(
                top: 240,
                left: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Image.asset(AppImages.foodList2, height: 80),
                            SizedBox(height: 10),
                            Text(
                              'Idly Set - 1',
                              style: GoogleFont.Mulish(
                                fontSize: 16,
                                color: AppColor.darkBlue,
                              ),
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  '₹8',
                                  style: GoogleFonts.mulish(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // ✅ simpler & safer: strikethrough text, no Transform
                                Text(
                                  '₹12',
                                  style: GoogleFonts.mulish(
                                    fontSize: 14,
                                    color: AppColor.lightGray3,
                                    decoration: TextDecoration.lineThrough,
                                    decorationThickness: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(width: 12),
                        CommonContainer.leftSideArrow(
                          onTap: () => Navigator.pop(context),
                        ),
                        SizedBox(width: 12),
                        Column(
                          children: [
                            Image.asset(AppImages.sabharishHotel, height: 80),
                            SizedBox(height: 13),
                            Expanded(
                              child: Text(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                'Your Food is Waiting..!',
                                style: GoogleFont.Mulish(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
