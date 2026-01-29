import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';

import '../Model/surprise_offer_response.dart';

class OpenedSurpriseOfferScreen extends StatelessWidget {
  final SurpriseStatusResponse response;
  const OpenedSurpriseOfferScreen({super.key, required this.response});

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      CommonContainer.leftSideArrow(),
                      Spacer(),
                      Text(
                        'Unlocked Surprise Offer',
                        style: GoogleFont.Mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColor.black,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImages.walletBCImage),
                    ),
                    gradient: LinearGradient(
                      colors: [AppColor.white, AppColor.aquaTint],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15.0,
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      AppImages.shopContainer3,
                                      height: 130,
                                      width: 115,
                                    ),

                                    SizedBox(width: 14),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 50.0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              response.data.shop.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFont.Mulish(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                                color: AppColor.darkBlue,
                                              ),
                                            ),
                                            SizedBox(height: 6),

                                            Row(
                                              children: [
                                                Image.asset(
                                                  AppImages.locationImage,
                                                  height: 10,
                                                  color: AppColor.lightGray2,
                                                ),
                                                SizedBox(width: 3),
                                                Flexible(
                                                  child: Text(
                                                    response.data.shop.city,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFont.Mulish(
                                                      fontSize: 12,
                                                      color:
                                                          AppColor.lightGray2,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  response
                                                          .data
                                                          .shop
                                                          .distanceLabel
                                                          .toString() ??
                                                      '',
                                                  style: GoogleFont.Mulish(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: AppColor.lightGray3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),

                                            Row(
                                              children: [
                                                CommonContainer.greenStarRating(
                                                  ratingStar:
                                                      response.data.shop.rating
                                                          .toString() ??
                                                      '',
                                                  ratingCount:
                                                      response
                                                          .data
                                                          .shop
                                                          .reviewCount
                                                          .toString() ??
                                                      '',
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  'Opens Upto ',
                                                  style: GoogleFont.Mulish(
                                                    fontSize: 9,
                                                    color: AppColor.lightGray2,
                                                  ),
                                                ),
                                                Text(
                                                  '9Pm',
                                                  style: GoogleFont.Mulish(
                                                    fontSize: 9,
                                                    color: AppColor.lightGray2,
                                                    fontWeight: FontWeight.w800,
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    'Offer Details',
                    style: GoogleFont.Mulish(
                      fontSize: 16,
                      color: AppColor.darkBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Image.asset(AppImages.image, width: 360, height: 215),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    decoration: BoxDecoration(
                      color: AppColor.lowGery1,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buy for Rs.1000 get Rs. 3000',
                          style: GoogleFont.Mulish(
                            fontSize: 20,
                            color: AppColor.darkBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Nam elementum tempor turpis, vitae pharetra ligula. Mauris id ullamcorper ligula. Morbi efficitur, quam lobortis pharetra consectetur, nisi mi pulvinar eros,',
                          style: GoogleFont.Mulish(
                            fontSize: 12,
                            color: AppColor.lightGray3,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              'Valid Upto',
                              style: GoogleFont.Mulish(
                                fontSize: 12,
                                color: AppColor.lightGray3,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '18-jun-2026',
                              style: GoogleFont.Mulish(
                                fontSize: 12,
                                color: AppColor.darkBlue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Center(
                  child: Text(
                    'Offer Code',
                    style: GoogleFont.Mulish(
                      fontSize: 16,
                      color: AppColor.darkBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: DottedBorder(
                      color: AppColor.darkGrey.withOpacity(0.7),
                      strokeWidth: 2,

                      dashPattern: const [4, 2],
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(15),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColor.darkGrey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),

                        alignment: Alignment.center,
                        child: Text(
                          response.data.code.toString() ?? '',
                          style: GoogleFont.Mulish(
                            fontSize: 20,
                            color: AppColor.darkBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 15,
                  ),
                  child: CommonContainer.button(
                    borderRadius: 12,
                    buttonColor: AppColor.darkBlue,
                    imagePath: AppImages.rightSideArrow,
                    onTap: () {},
                    text: Text('View All Unlocked Offers'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
