import 'package:flutter/material.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';

import '../../../../Core/Utility/app_color.dart';
import '../../../../Core/Widgets/Common Bottom Navigation bar/payment_successful_bottombar.dart';
import '../../../../Core/Widgets/common_container.dart';
import 'food_booking_success.dart';

class FoodDetails extends StatefulWidget {
  const FoodDetails({super.key});

  @override
  State<FoodDetails> createState() => _FoodDetailsState();
}

class _FoodDetailsState extends State<FoodDetails> {
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
                  gradient: LinearGradient(
                    colors: [
                      AppColor.white,
                      AppColor.white,
                      AppColor.whiteSmoke,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
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
                            AppImages.foodImage1,
                            height: 219,
                            width: 285,
                          ),
                          SizedBox(width: 10),
                          Image.asset(
                            AppImages.sabharishHotel,
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
                      'Ulti Breakfast Combo',
                      style: GoogleFont.Mulish(
                        fontSize: 18,
                        color: AppColor.darkBlue,
                      ),
                    ),
                    SizedBox(height: 9),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.green,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '4.1',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFont.Mulish(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColor.white,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Image.asset(AppImages.starImage, height: 9),
                              const SizedBox(width: 5),
                              Container(
                                width: 1.5,
                                height: 11,
                                decoration: BoxDecoration(
                                  color: AppColor.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '56',
                                style: GoogleFont.Mulish(
                                  fontSize: 12,
                                  color: AppColor.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Text(
                          'Quantity',
                          style: GoogleFont.Mulish(color: AppColor.darkBlue),
                        ),
                        SizedBox(width: 15),
                        InkWell(
                          onTap: () {
                            if (quantity > 1) {
                              setState(() {
                                quantity--;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(11),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColor.textWhite,
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: AppColor.black.withOpacity(0.1),
                                width: 1.5,
                              ),
                            ),
                            child: Image.asset(
                              AppImages.minus,
                              width: 30,
                              height: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: AppColor.black.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            '$quantity',
                            style: GoogleFont.Mulish(
                              fontSize: 16,
                              color: AppColor.darkBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            setState(() {
                              quantity++;
                            });
                          },
                          borderRadius: BorderRadius.circular(11),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColor.textWhite,
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: AppColor.black.withOpacity(0.1),
                                width: 1.5,
                              ),
                            ),
                            child: Image.asset(
                              AppImages.plus,
                              width: 30,
                              height: 28,
                            ),
                          ),
                        ),
 /*                       InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(11),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColor.textWhite,
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: AppColor.black.withOpacity(0.1),
                                width: 1.5,
                              ),
                            ),
                            child: Image.asset(
                              AppImages.minus,
                              width: 30,
                              height: 28,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(11),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: AppColor.black.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              '1',
                              style: GoogleFont.Mulish(
                                fontSize: 16,
                                color: AppColor.darkBlue,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(11),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColor.textWhite,
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: AppColor.black.withOpacity(0.1),
                                width: 1.5,
                              ),
                            ),
                            child: Image.asset(
                              AppImages.plus,
                              width: 30,
                              height: 28,
                            ),
                          ),
                        ),*/
                        SizedBox(width: 15),
                        Text(
                          '2 Left',
                          style: GoogleFont.Mulish(color: AppColor.lightRed),
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
                  orderOnTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentSuccessfulBottombar(initialIndex: 3,),
                      ),
                    );
                  },
                  order: true,
                  orderImage: AppImages.orderImage,
                  orderText: 'Order Your’s',
                  callText: 'Call',
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
                            const SizedBox(height: 6),

                            Row(
                              children: [
                                Text(
                                  'Sri Krishna',
                                  style: GoogleFont.Mulish(
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Image.asset(
                                  AppImages.rightArrow,
                                  height: 8,
                                  color: AppColor.lightBlueCont,
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            Row(
                              children: [
                                Image.asset(
                                  AppImages.locationImage,
                                  height: 10,
                                  color: AppColor.lightGray2,
                                ),
                                const SizedBox(width: 4),
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
                                const SizedBox(width: 10),
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.green,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '4.5',
                                        style: GoogleFont.Mulish(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColor.white,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Image.asset(
                                        AppImages.starImage,
                                        height: 9,
                                      ),
                                      const SizedBox(width: 5),
                                      Container(
                                        width: 1.5,
                                        height: 11,
                                        decoration: BoxDecoration(
                                          color: AppColor.white.withOpacity(
                                            0.4,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '16',
                                        style: GoogleFont.Mulish(
                                          fontSize: 12,
                                          color: AppColor.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
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
                      Image.asset(AppImages.sabharishHotel, height: 98),
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
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColor.whiteSmoke,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16),
                          topLeft: Radius.circular(16),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                          vertical: 12,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'No Of Quantity',
                                  style: GoogleFont.Mulish(
                                    color: AppColor.lightGray3,
                                  ),
                                ),
                                SizedBox(width: 22),
                                Text(
                                  '2',
                                  style: GoogleFont.Mulish(
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                          vertical: 12,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Door Delivery',
                                  style: GoogleFont.Mulish(
                                    color: AppColor.lightGray3,
                                  ),
                                ),
                                SizedBox(width: 22),
                                Text(
                                  'Available',
                                  style: GoogleFont.Mulish(
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                    SizedBox(height: 35,),
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
