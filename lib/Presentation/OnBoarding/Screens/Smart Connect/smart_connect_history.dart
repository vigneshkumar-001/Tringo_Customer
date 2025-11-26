import 'package:flutter/material.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Smart%20Connect/smart_connect_details.dart';

import '../../../../Core/Widgets/Common Bottom Navigation bar/smart_connect_bottombar.dart';
import '../../../../Core/Widgets/common_container.dart';

class SmartConnectHistory extends StatefulWidget {
  const SmartConnectHistory({super.key});

  @override
  State<SmartConnectHistory> createState() => _SmartConnectHistoryState();
}

class _SmartConnectHistoryState extends State<SmartConnectHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  // AppColor.white,
                  AppColor.blushPink.withOpacity(0.8),
                  AppColor.blushPink,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonContainer.leftSideArrow(
                    Color: Colors.transparent,
                    onTap: () => Navigator.pop(context),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Image.asset(AppImages.aiGuideImage, height: 135),
                  ),
                  SizedBox(height: 32),
                  Center(
                    child: Text(
                      'Smart Connect',
                      style: GoogleFont.Mulish(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkBlue,
                      ),
                    ),
                  ),
                  Center(
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) =>
                          LinearGradient(
                            colors: [
                              AppColor.yellow, // Orange
                              AppColor.pink, // Pink
                              // Color(0xFF34A6F5), // Purple/Blue tone
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                      child: Text(
                        'History',
                        style: GoogleFont.Mulish(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 42),
                  Center(
                    child: Text(
                      'Today',
                      style: GoogleFont.Mulish(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColor.lightGray3,
                      ),
                    ),
                  ),
                  SizedBox(height: 13),
                  CommonContainer.smartConnectHistory(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SmartConnectBottombar(initialIndex: 3),
                        ),
                      );
                    },
                    productName: 'Iphone 17',
                    shopCounting: '20 Shops Reached',
                    productCounting: '2',
                    Showrooms: 'Mobile Showrooms',
                    productCategories: 'Phone',
                    time: '11.15Pm',
                  ),
                  SizedBox(height: 25),
                  CommonContainer.smartConnectHistory(
                    onTap: () {},
                    productName: 'Ceiling Fan Atomberg BLDC',
                    shopCounting: '20 Shops Reached',
                    productCounting: '11',
                    Showrooms: 'Home Appliances',
                    productCategories: 'Fan',
                    time: '11.15Pm',
                  ),
                  SizedBox(height: 60),
                  Center(
                    child: Text(
                      'Yesterday',
                      style: GoogleFont.Mulish(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColor.lightGray3,
                      ),
                    ),
                  ),
                  SizedBox(height: 13),
                  CommonContainer.smartConnectHistory(
                    onTap: () {},
                    productName: 'Water pump 1hp',
                    shopCounting: '20 Shops Reached',
                    productCounting: '8',
                    Showrooms: 'Home Appliances',
                    productCategories: 'Water pump',
                    time: '11.15Pm',
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
