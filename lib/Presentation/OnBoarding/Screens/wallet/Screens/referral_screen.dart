import 'package:flutter/material.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/common_container.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 16,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CommonContainer.leftSideArrow(
                        Color: AppColor.whiteSmoke,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    Text(
                      'Refer Friend',
                      style: GoogleFont.Mulish(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColor.mildBlack,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 41),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.walletBCImage),
                  ),
                  gradient: LinearGradient(
                    colors: [AppColor.white, AppColor.surfaceBlue],
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 115),
                      child: Row(
                        children: [
                          Image.asset(
                            AppImages.referFriends,
                            height: 55,
                            width: 62,
                          ),
                          SizedBox(width: 15),
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [
                                  AppColor.brandBlue,
                                  AppColor.accentCyan,
                                  AppColor.successGreen,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds);
                            },
                            child: Text(
                              '63',
                              style: GoogleFont.Mulish(
                                fontSize: 42,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Total Referral Reward',
                      style: GoogleFont.Mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColor.darkBlue,
                      ),
                    ),

                    SizedBox(height: 25),
                    Container(
                      width: double.infinity,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            AppColor.white.withOpacity(0.5),
                            AppColor.white4.withOpacity(0.4),
                            AppColor.white4.withOpacity(0.4),
                            AppColor.white4.withOpacity(0.4),
                            AppColor.white4.withOpacity(0.4),
                            AppColor.white4.withOpacity(0.4),
                            AppColor.white4.withOpacity(0.4),
                            AppColor.white.withOpacity(0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    SizedBox(height: 25),
                    Padding(
                      padding: EdgeInsets.only(left: 40, right: 25),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColor.blue,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Image.asset(
                                      AppImages.playStore,
                                      height: 36,
                                    ),
                                  ),

                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 10,
                                        bottom: 7,
                                        top: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Share Android App Link',
                                            style: GoogleFont.Mulish(
                                              color: AppColor.darkGrey,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '/refy/refu098kjfindfu38...',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFont.Mulish(
                                                    color: AppColor.blue,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {},
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    0,
                                                  ),
                                                  child: Image.asset(
                                                    AppImages.share,
                                                    width: 25,
                                                    color: AppColor.blue,
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
                          ),

                          SizedBox(width: 20),
                          InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.yellow,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Image.asset(
                                AppImages.iPhoneLogo,
                                height: 35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: AppColor.white,
                                  width: 1.5,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                      right: 113,
                                      top: 8,
                                      bottom: 11,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Share Referral Code',
                                          style: GoogleFont.Mulish(
                                            fontSize: 12,
                                            color: AppColor.darkGrey,
                                          ),
                                        ),
                                        Text(
                                          '525866',
                                          style: GoogleFont.Mulish(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColor.darkBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.black.withOpacity(0.02),
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.01),
                                          ],
                                          stops: [0, 1, 1],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.black,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Image.asset(AppImages.share, height: 35),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Today',
                style: GoogleFont.Mulish(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColor.darkGrey,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    CommonContainer.walletHistoryBox(
                      upiTexts: false,
                      containerColor: AppColor.surfaceBlue,
                      mainText: 'Abdul kalam',

                      timeText: '10.40Pm',
                      numberText: '30',
                      endText: 'Received',
                      numberTextColor: AppColor.blue,
                      endTextColor: AppColor.blue,
                    ),
                    SizedBox(height: 10),
                    CommonContainer.walletHistoryBox(
                      upiTexts: false,
                      containerColor: AppColor.surfaceBlue,
                      mainText: 'Stalin',
                      timeText: '10.40Pm',
                      numberText: '30',
                      endText: 'Received',
                      numberTextColor: AppColor.blue,
                      endTextColor: AppColor.blue,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
