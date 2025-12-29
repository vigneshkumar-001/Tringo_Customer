import 'package:flutter/material.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';

import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/common_container.dart';

class DetailMobileNoUser extends StatefulWidget {
  const DetailMobileNoUser({super.key});

  @override
  State<DetailMobileNoUser> createState() => _DetailMobileNoUserState();
}

class _DetailMobileNoUserState extends State<DetailMobileNoUser> {
  bool showUserDetails = true;
  Widget userDetails(double w) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16, top: 20),
              child: Row(
                children: [
                  CommonContainer.leftSideArrow(
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'Mobile Number Info',
                    style: GoogleFont.Mulish(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColor.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  AppImages.mobileNoInfoBCImage,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: w * 0.55,
                      height: 212,
                      child: Image.asset(
                        AppImages.servicesContainer1,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 85),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text(
                    'Shivani',
                    style: GoogleFont.Mulish(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.black,
                    ),
                  ),
                  SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: GoogleFont.Mulish(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                      children: [
                        TextSpan(
                          text: "Mobile No ",
                          style: GoogleFont.Mulish(color: AppColor.darkBlue),
                        ),
                        TextSpan(
                          text: '9876543210',
                          style: GoogleFont.Mulish(
                            color: AppColor.blue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 110),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => HomeScreen(),
                        //   ),
                        // );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.blue,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(AppImages.callImage, height: 16),
                              SizedBox(width: 10),
                              Text(
                                'Call Now',
                                style: GoogleFont.Mulish(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  CommonContainer.horizonalDivider(),
                  SizedBox(height: 30),
                  Text(
                    'Advertisements',
                    style: GoogleFont.Mulish(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  SizedBox(height: 30),
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                          width: 288,
                          decoration: BoxDecoration(
                            color: AppColor.veryLightGray,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    AppImages.foodImage2,
                                    height: 140,
                                    width: 259,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 10),
                                CommonContainer.verifyTick(),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      'Sri Krishna',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFont.Mulish(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Image.asset(
                                      AppImages.rightArrow,
                                      width: 8,
                                      height: 12,
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
                                    SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        '12, 2, Tirupparankunram Rd, kunram ',
                                        style: GoogleFont.Mulish(
                                          fontSize: 12,
                                          color: AppColor.lightGray2,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      '5Kms',
                                      style: GoogleFont.Mulish(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColor.lightGray3,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 9),
                                Row(
                                  children: [
                                    // Container(
                                    //   padding: const EdgeInsets.symmetric(
                                    //     horizontal: 10,
                                    //     vertical: 3,
                                    //   ),
                                    //   decoration: BoxDecoration(
                                    //     color: AppColor.green,
                                    //     borderRadius: BorderRadius.circular(30),
                                    //   ),
                                    //   child: Row(
                                    //     mainAxisSize: MainAxisSize.min,
                                    //     children: [
                                    //       Text(
                                    //         ratingStar,
                                    //         style: GoogleFont.Mulish(
                                    //           fontWeight: FontWeight.bold,
                                    //           fontSize: 14,
                                    //           color: AppColor.white,
                                    //         ),
                                    //       ),
                                    //       const SizedBox(width: 5),
                                    //       Image.asset(AppImages.starImage, height: 9),
                                    //       const SizedBox(width: 5),
                                    //       Container(
                                    //         width: 1.5,
                                    //         height: 11,
                                    //         decoration: BoxDecoration(
                                    //           color: AppColor.white.withOpacity(0.4),
                                    //           borderRadius: BorderRadius.circular(1),
                                    //         ),
                                    //       ),
                                    //       const SizedBox(width: 5),
                                    //       Text(
                                    //         ratingCound,
                                    //         style: GoogleFont.Mulish(
                                    //           fontSize: 12,
                                    //           color: AppColor.white,
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    CommonContainer.greenStarRating(
                                      ratingCount: '4.5',
                                      ratingStar: '16',
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          text: 'Opens Upto ',
                                          style: GoogleFont.Mulish(
                                            fontSize: 10,
                                            color: AppColor.lightGray2,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '9Pm',
                                              style: GoogleFont.Mulish(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: AppColor.lightGray2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Container(
                          width: 288,
                          decoration: BoxDecoration(
                            color: AppColor.veryLightGray,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    AppImages.foodImage2,
                                    height: 140,
                                    width: 259,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 10),
                                CommonContainer.verifyTick(),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      'Sri Krishna',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFont.Mulish(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Image.asset(
                                      AppImages.rightArrow,
                                      width: 8,
                                      height: 12,
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
                                    SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        '12, 2, Tirupparankunram Rd, kunram ',
                                        style: GoogleFont.Mulish(
                                          fontSize: 12,
                                          color: AppColor.lightGray2,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      '5Kms',
                                      style: GoogleFont.Mulish(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColor.lightGray3,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 9),
                                Row(
                                  children: [
                                    // Container(
                                    //   padding: const EdgeInsets.symmetric(
                                    //     horizontal: 10,
                                    //     vertical: 3,
                                    //   ),
                                    //   decoration: BoxDecoration(
                                    //     color: AppColor.green,
                                    //     borderRadius: BorderRadius.circular(30),
                                    //   ),
                                    //   child: Row(
                                    //     mainAxisSize: MainAxisSize.min,
                                    //     children: [
                                    //       Text(
                                    //         ratingStar,
                                    //         style: GoogleFont.Mulish(
                                    //           fontWeight: FontWeight.bold,
                                    //           fontSize: 14,
                                    //           color: AppColor.white,
                                    //         ),
                                    //       ),
                                    //       const SizedBox(width: 5),
                                    //       Image.asset(AppImages.starImage, height: 9),
                                    //       const SizedBox(width: 5),
                                    //       Container(
                                    //         width: 1.5,
                                    //         height: 11,
                                    //         decoration: BoxDecoration(
                                    //           color: AppColor.white.withOpacity(0.4),
                                    //           borderRadius: BorderRadius.circular(1),
                                    //         ),
                                    //       ),
                                    //       const SizedBox(width: 5),
                                    //       Text(
                                    //         ratingCound,
                                    //         style: GoogleFont.Mulish(
                                    //           fontSize: 12,
                                    //           color: AppColor.white,
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    CommonContainer.greenStarRating(
                                      ratingCount: '4.5',
                                      ratingStar: '16',
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          text: 'Opens Upto ',
                                          style: GoogleFont.Mulish(
                                            fontSize: 10,
                                            color: AppColor.lightGray2,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '9Pm',
                                              style: GoogleFont.Mulish(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: AppColor.lightGray2,
                                              ),
                                            ),
                                          ],
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget shopDetails(double w) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16, top: 20),
              child: Row(
                children: [
                  CommonContainer.leftSideArrow(
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'Mobile Number Info',
                    style: GoogleFont.Mulish(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColor.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  AppImages.mobileNoInfoBCImage,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 90,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: w * 0.90,
                      height: 204,
                      child: Image.asset(
                        AppImages.foodImage1,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 85),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Center(
                    child: CommonContainer.gradientContainer(
                      text: "Sweets & Bakery",
                      textColor: AppColor.skyBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Sri Krishna Sweets Private Limited',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFont.Mulish(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColor.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  RichText(
                    text: TextSpan(
                      style: GoogleFont.Mulish(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                      children: [
                        TextSpan(
                          text: "Mobile No ",
                          style: GoogleFont.Mulish(color: AppColor.darkBlue),
                        ),
                        TextSpan(
                          text: '9876543210',
                          style: GoogleFont.Mulish(
                            color: AppColor.blue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ✅ UPDATED BUTTON ROW (NO OVERFLOW)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              // TODO: call action
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColor.blue,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(AppImages.callImage, height: 16),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Call Now',
                                    style: GoogleFont.Mulish(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColor.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              // TODO: details action
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColor.darkBlue,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Details',
                                    style: GoogleFont.Mulish(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColor.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Image.asset(
                                    AppImages.rightSideArrow,
                                    height: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  CommonContainer.horizonalDivider(),
                  const SizedBox(height: 30),

                  Text(
                    'Advertisements',
                    style: GoogleFont.Mulish(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.darkBlue,
                    ),
                  ),

                  const SizedBox(height: 30),

                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: 288,
                      decoration: BoxDecoration(
                        color: AppColor.veryLightGray,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                AppImages.foodImage2,
                                height: 140,
                                width: 259,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            CommonContainer.verifyTick(),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Sri Krishna',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFont.Mulish(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Image.asset(
                                  AppImages.rightArrow,
                                  width: 8,
                                  height: 12,
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
                                const SizedBox(width: 3),
                                const Expanded(
                                  child: Text(
                                    '12, 2, Tirupparankunram Rd, kunram',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '5Kms',
                                  style: GoogleFont.Mulish(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.lightGray3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 9),
                            Row(
                              children: [
                                CommonContainer.greenStarRating(
                                  ratingCount: '4.5',
                                  ratingStar: '16',
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'Opens Upto ',
                                      style: GoogleFont.Mulish(
                                        fontSize: 10,
                                        color: AppColor.lightGray2,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '9Pm',
                                          style: GoogleFont.Mulish(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppColor.lightGray2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(body: showUserDetails ? userDetails(w) : shopDetails(w));
  }
}
