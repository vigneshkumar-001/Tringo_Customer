import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/qr_scan_screen.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/common_container.dart';
import 'enter_review.dart';

class ReviewAndEarn extends ConsumerStatefulWidget {
  const ReviewAndEarn({super.key});

  @override
  ConsumerState<ReviewAndEarn> createState() => _ReviewAndEarnState();
}

class _ReviewAndEarnState extends ConsumerState<ReviewAndEarn>
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
                      'Earn by Review',
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
                    colors: [AppColor.white, AppColor.surfaceAqua],
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
                            AppImages.earnByReview,
                            height: 53,
                            width: 68,
                          ),
                          SizedBox(width: 15),
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [
                                  AppColor.tealBlue,
                                  AppColor.tealGreen,
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
                      'Total Review Reward',
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
                      padding: const EdgeInsets.symmetric(horizontal: 50),
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
                                      right: 20,
                                      top: 8,
                                      bottom: 11,
                                    ),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EnterReview(),
                                              ),
                                            );
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Scan Shop’s QR',
                                                style: GoogleFont.Mulish(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColor.darkBlue,
                                                ),
                                              ),
                                              Text(
                                                'Review the shop & Get Earnings',
                                                style: GoogleFont.Mulish(
                                                  fontSize: 12,
                                                  color: AppColor.darkGrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 30),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    QrScanScreen(
                                                      title:
                                                          'Scan QR for Review',
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Image.asset(
                                            AppImages.qRColor,
                                            height: 37,
                                            width: 34,
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
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
                  ],
                ),
              ),
              SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Text(
                      'History',
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: AppColor.darkBlue,
                      ),
                    ),
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
                      containerColor: AppColor.coolWhite,
                      mainText: 'Zam zam sweets',

                      timeText: '10.40Pm',
                      numberText: '30',
                      endText: 'Received',
                      numberTextColor: AppColor.infoTeal,
                      endTextColor: AppColor.infoTeal,
                    ),
                    SizedBox(height: 10),
                    CommonContainer.walletHistoryBox(
                      upiTexts: false,
                      containerColor: AppColor.coolWhite,
                      mainText: 'Stalin shop',
                      timeText: '10.40Pm',
                      numberText: '30',
                      endText: 'Received',
                      numberTextColor: AppColor.infoTeal,
                      endTextColor: AppColor.infoTeal,
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
