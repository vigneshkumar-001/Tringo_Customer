import 'package:flutter/material.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';

import '../../../../Core/Utility/app_color.dart';
import '../../../../Core/Utility/google_font.dart';
import '../../../../Core/Widgets/common_container.dart';

class SmartConnectDetails extends StatefulWidget {
  const SmartConnectDetails({super.key});

  @override
  State<SmartConnectDetails> createState() => _SmartConnectDetailsState();
}

class _SmartConnectDetailsState extends State<SmartConnectDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                child: Row(
                  children: [
                    CommonContainer.leftSideArrow(
                      Color: Colors.transparent,
                      onTap: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 20),
                    Text(
                      '3 Shops Replied',
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColor.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      // AppColor.white,
                      AppColor.blushPink,
                      AppColor.blushPink.withOpacity(0.9),
                      AppColor.white,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Iphone 17',
                                    style: GoogleFont.Mulish(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 19,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    'Quisque facilisis hendrerit justo sed egestas. Phasellus feugiat ac nulla non cursus. Pellentesque a fringilla libero. Ut non est non quam luctus sodales. Quisque vitae fermentum felis, sit amet pretium sem. ',
                                    style: GoogleFont.Mulish(
                                      fontSize: 10,
                                      color: AppColor.lightGray3,
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Row(
                                    children: [
                                      Text(
                                        'Replied on ',
                                        style: GoogleFont.Mulish(
                                          fontSize: 10,
                                          color: AppColor.lightGray2,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          '11.15Pm',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFont.Mulish(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10,
                                            color: AppColor.lightGray2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 35),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColor.yellow,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 8,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Price',
                                      style: GoogleFont.Mulish(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    Text(
                                      '₹ 76,050',
                                      style: GoogleFont.Mulish(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: AppColor.white,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(0, 5),
                                            blurRadius: 10,
                                            color: Colors.black.withOpacity(
                                              0.3,
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
                      SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              Image.asset(AppImages.iPhoneImage1, width: 221),
                              SizedBox(width: 10),
                              Image.asset(AppImages.iPhoneImage2, width: 221),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CommonContainer.verifyTick(),
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        'Supreme Mobiles',
                                        style: GoogleFont.Mulish(
                                          fontSize: 16,
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
                                      SizedBox(width: 3),
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
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColor.green,
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
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
                                              color: AppColor.white.withOpacity(
                                                0.4,
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
                            SizedBox(width: 40),
                            Image.asset(
                              AppImages.supremeMobile,
                              height: 111,
                              width: 99,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: CommonContainer.callNowButton(
                          callOnTap: () {},
                          callImage: AppImages.callImage,
                          callText: 'Call Now',
                          callIconSize: 16,
                          callTextSize: 16,
                          callNowPadding: EdgeInsets.symmetric(
                            horizontal: 65,
                            vertical: 10,
                          ),
                          messageContainer: true,
                          MessageIcon: true,
                          whatsAppIcon: true,
                          messageOnTap: () {},
                          messagesIconSize: 25,
                          whatsAppIconSize: 25,
                          whatsAppOnTap: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      // AppColor.white,
                      AppColor.oliveGreen,
                      // AppColor.oliveGreen.withOpacity(0.9),
                      AppColor.white,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Iphone 17 Pro',
                                    style: GoogleFont.Mulish(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 19,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    'Quisque facilisis hendrerit justo sed egestas. Phasellus feugiat ac nulla non cursus. Pellentesque a fringilla libero. Ut non est non quam luctus sodales. Quisque vitae fermentum felis, sit amet pretium sem. ',
                                    style: GoogleFont.Mulish(
                                      fontSize: 10,
                                      color: AppColor.lightGray3,
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Row(
                                    children: [
                                      Text(
                                        'Replied on ',
                                        style: GoogleFont.Mulish(
                                          fontSize: 10,
                                          color: AppColor.lightGray2,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          '11.15Pm',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFont.Mulish(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10,
                                            color: AppColor.lightGray2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 35),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColor.springGreen,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 8,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Price',
                                      style: GoogleFont.Mulish(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    Text(
                                      '₹ 75,011',
                                      style: GoogleFont.Mulish(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: AppColor.white,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(0, 5),
                                            blurRadius: 10,
                                            color: Colors.black.withOpacity(
                                              0.3,
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
                      SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              Image.asset(AppImages.iPhoneImage3, height: 237),
                              SizedBox(width: 10),
                              Image.asset(AppImages.iPhoneImage4, width: 221),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Row(
                                      children: [
                                        Text(
                                          'I Store',
                                          style: GoogleFont.Mulish(
                                            fontSize: 16,
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
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Image.asset(
                                        AppImages.locationImage,
                                        height: 10,
                                        color: AppColor.lightGray2,
                                      ),
                                      SizedBox(width: 3),
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
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColor.green,
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
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
                                              color: AppColor.white.withOpacity(
                                                0.4,
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
                            SizedBox(width: 40),
                            Image.asset(
                              AppImages.iStore,
                              height: 111,
                              width: 99,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: CommonContainer.callNowButton(
                          callOnTap: () {},
                          callImage: AppImages.callImage,
                          callText: 'Call Now',
                          callIconSize: 16,
                          callTextSize: 16,
                          callNowPadding: EdgeInsets.symmetric(
                            horizontal: 65,
                            vertical: 10,
                          ),
                          messageContainer: true,
                          MessageIcon: true,
                          whatsAppIcon: true,
                          messageOnTap: () {},
                          messagesIconSize: 25,
                          whatsAppIconSize: 25,
                          whatsAppOnTap: () {},
                        ),
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
