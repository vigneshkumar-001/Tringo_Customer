import 'package:flutter/material.dart';

import '../../../../Core/Utility/app_Images.dart';
import '../../../../Core/Utility/app_color.dart';
import '../../../../Core/Utility/google_font.dart';
import '../../../../Core/Widgets/Common Bottom Navigation bar/payment_successful_bottombar.dart';
import '../../../../Core/Widgets/common_container.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({super.key});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int quantity = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: AppColor.whiteSmoke,
                  // gradient: LinearGradient(
                  //   colors: [
                  //     AppColor.white,
                  //     AppColor.white,
                  //     AppColor.whiteSmoke,
                  //   ],
                  //   begin: Alignment.topCenter,
                  //   end: Alignment.bottomCenter,
                  // ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 16,
                      ),
                      child: CommonContainer.leftSideArrow(
                        onTap: () => Navigator.pop(context),
                      ),
                    ),

                    SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          Image.asset(
                            AppImages.fanImage5,
                            height: 219,
                            width: 285,
                          ),
                          SizedBox(width: 10),
                          Image.asset(
                            AppImages.fanImage6,
                            height: 219,
                            width: 223,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 43),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CommonContainer.verifyTick(),
                        SizedBox(width: 10),
                        CommonContainer.doorDelivery(),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Atomberg Renesa+ BLDC Motor with Remote 900 mm Ceiling Fan (Sand Grey)',
                      style: GoogleFont.Mulish(
                        fontSize: 18,
                        color: AppColor.darkBlue,
                      ),
                    ),
                    SizedBox(height: 9),
                    CommonContainer.greenStarRating(
                      ratingCount: '16',
                      ratingStar: '4.1',
                    ),

                    SizedBox(height: 9),
                    Row(
                      children: [
                        Text(
                          '₹175',
                          style: GoogleFont.Mulish(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        SizedBox(width: 10),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '₹223',
                              style: GoogleFont.Mulish(
                                fontSize: 14,
                                color: AppColor.lightGray3,
                              ),
                            ),
                            Transform.rotate(
                              angle: -0.1,
                              child: Container(
                                height: 1.5,
                                width: 40,
                                color: AppColor.lightGray3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 27),
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                child: CommonContainer.callNowButton(
                  mapBox: true,
                  mapOnTap: () {},
                  mapText: 'Map',
                  mapBoxPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  order: false,
                  callText: 'Call Now',
                  callImage: AppImages.callImage,
                  callIconSize: 21,
                  callTextSize: 16,
                  messagesIconSize: 23,
                  whatsAppIconSize: 23,
                  fireIconSize: 23,
                  callNowPadding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  iconContainerPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  whatsAppIcon: true,
                  whatsAppOnTap: () {},
                  messageContainer: true,
                  MessageIcon: true,
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.textWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 10,
                  ), // Optional padding
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonContainer.verifyTick(),
                            SizedBox(height: 6),

                            Row(
                              children: [
                                Text(
                                  'Sri Krishna',
                                  style: GoogleFont.Mulish(
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Image.asset(
                                  AppImages.rightArrow,
                                  height: 8,
                                  color: AppColor.lightBlueCont,
                                ),
                              ],
                            ),

                            SizedBox(height: 6),

                            Row(
                              children: [
                                Image.asset(
                                  AppImages.locationImage,
                                  height: 10,
                                  color: AppColor.lightGray2,
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '12, 2, Tirupparankunram Rd, kunram',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFont.Mulish(
                                      fontSize: 12,
                                      color: AppColor.lightGray2,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '5Kms',
                                  style: GoogleFont.Mulish(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: AppColor.lightGray3,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                CommonContainer.greenStarRating(
                                  ratingCount: '16',
                                  ratingStar: '4.5',
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Opens Upto ',
                                  style: GoogleFont.Mulish(
                                    fontSize: 10,
                                    color: AppColor.lightGray2,
                                  ),
                                ),
                                Text(
                                  '9Pm',
                                  style: GoogleFont.Mulish(
                                    fontSize: 10,
                                    color: AppColor.lightGray2,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Image.asset(AppImages.fanImage7, height: 98),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 60),
              CommonContainer.horizonalDivider(),
              SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Text(
                      'Similar Products',
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
                      image: AppImages.fanImage8,
                      foodName:
                          'Atomberg Aris Starlight 48" Silent Energy Efficient BLDC Motor With Sm – Alphaeshop Limited',
                      ratingStar: '4.5',
                      ratingCount: '16',
                      offAmound: '₹60',
                      oldAmound: '₹80',
                      km: '230Mts',
                      location: 'Lakshmi Bevan',
                    ),
                    SizedBox(width: 20),
                    CommonContainer.similarFoods(
                      Verify: false,
                      image: AppImages.fanImage9,
                      foodName:
                          'Atomberg Studio+ 1200 mm BLDC Ceiling Fan with Remote Control & LED Indicators | Midnight Black',
                      ratingStar: '4.5',
                      ratingCount: '16',
                      offAmound: '₹120',
                      oldAmound: '₹128',
                      km: '5Kms',
                      location: 'Hotel Dave',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 76),
              CommonContainer.horizonalDivider(),
              SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(AppImages.roundStar, height: 25),
                        SizedBox(width: 10),
                        Text(
                          'Highlights',
                          style: GoogleFont.Mulish(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColor.darkBlue,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColor.whiteSmoke,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Speed',
                            style: GoogleFont.Mulish(
                              color: AppColor.lightGray3,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '300CNM',
                              textAlign:
                                  TextAlign.center, // CENTER OF RIGHT HALF
                              style: GoogleFont.Mulish(
                                fontWeight: FontWeight.w700,
                                color: AppColor.darkBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 1.5),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColor.whiteSmoke,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Size',
                            style: GoogleFont.Mulish(
                              color: AppColor.lightGray3,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '1200MM',
                              textAlign:
                                  TextAlign.center, // CENTER OF RIGHT HALF
                              style: GoogleFont.Mulish(
                                fontWeight: FontWeight.w700,
                                color: AppColor.darkBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 52),
                    Row(
                      children: [
                        Image.asset(
                          AppImages.reviewImage,
                          height: 27.08,
                          width: 26,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Reviews',
                          style: GoogleFont.Mulish(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColor.darkBlue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          '4.5',
                          style: GoogleFont.Mulish(
                            fontWeight: FontWeight.bold,
                            fontSize: 33,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        SizedBox(width: 10),
                        Image.asset(
                          AppImages.starImage,
                          height: 30,
                          color: AppColor.green,
                        ),
                      ],
                    ),
                    Text(
                      'Based on 58 reviews',
                      style: GoogleFont.Mulish(color: AppColor.lightGray3),
                    ),
                    SizedBox(height: 20),
                    CommonContainer.reviewBox(),
                    SizedBox(height: 35),
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
