import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/qr_scan_screen.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/receive_screen.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/referral_screen.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/review_and_earn.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/send_screen.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/withdraw_screen.dart';

import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/common_container.dart';

class WalletScreens extends StatefulWidget {
  const WalletScreens({super.key});

  @override
  State<WalletScreens> createState() => _WalletScreensState();
}

class _WalletScreensState extends State<WalletScreens>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  DateTime selectedDate = DateTime.now();
  String selectedDay = 'Today';
  String _fmt(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  int selectedIndex = 0;

  final List<String> segments = [
    '50 All',
    '6 Rewards',
    '10 Sent',
    '10 Received',
  ];

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

  Future<void> _openDateFilterSheet() async {
    final res = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColor.lightGray,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              SizedBox(height: 12),

              _sheetItem('Today', () => Navigator.pop(context, 'Today')),
              _sheetItem(
                'Yesterday',
                () => Navigator.pop(context, 'Yesterday'),
              ),
              _sheetItem(
                'Custom Date',
                () => Navigator.pop(context, 'Custom Date'),
              ),

              SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (res == null) return;

    if (res == 'Today') {
      setState(() {
        selectedDay = 'Today';
        selectedDate = DateTime.now();
      });
    } else if (res == 'Yesterday') {
      setState(() {
        selectedDay = 'Yesterday';
        selectedDate = DateTime.now().subtract(const Duration(days: 1));
      });
    } else if (res == 'Custom Date') {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              dialogBackgroundColor: AppColor.white,
              colorScheme: ColorScheme.light(
                primary: AppColor.strongBlue,
                onPrimary: AppColor.iceBlue,
                onSurface: AppColor.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppColor.strongBlue,
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        setState(() {
          selectedDate = picked;
          selectedDay = _fmt(picked);
        });
      }
    }
  }

  Widget _sheetItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFont.Mulish(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColor.black,
              ),
            ),
            Spacer(),
            Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
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
                      'Wallet',
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
                    colors: [AppColor.white, AppColor.veryLightMintGreen],
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
                          Image.asset(AppImages.wallet, height: 55, width: 62),
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
                              '150',
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
                      'TCoin Wallet Balance',
                      style: GoogleFont.Mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColor.darkBlue,
                      ),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 149),
                      child: Row(
                        children: [
                          Text(
                            'UID886UI38',
                            style: GoogleFont.Mulish(
                              fontSize: 13,
                              color: AppColor.darkBlue,
                            ),
                          ),
                          SizedBox(width: 6),
                          Image.asset(AppImages.uID, height: 14),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
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
                    SizedBox(height: 0),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 58,
                        vertical: 25,
                      ),
                      child: Row(
                        children: [
                          CommonContainer.walletSendBox(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SendScreen(),
                                ),
                              );
                            },
                            text: 'Send',
                            image: AppImages.sendArrow,
                          ),
                          SizedBox(width: 20),
                          CommonContainer.walletSendBox(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReceiveScreen(),
                                ),
                              );
                            },
                            text: 'Receive',
                            image: AppImages.receiveArrow,
                          ),
                          SizedBox(width: 20),
                          CommonContainer.walletSendBox(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      QrScanScreen(title: 'Scan QR Code'),
                                ),
                              );
                            },
                            text: 'Scan QR',
                            image: AppImages.smallScanQR,
                          ),
                          SizedBox(width: 20),
                          CommonContainer.walletSendBox(
                            imageHeight: 30,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WithdrawScreen(),
                                ),
                              );
                            },
                            text: 'Withdraw',
                            image: AppImages.withdraw,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 31),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReferralScreen(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.surfaceBlue,
                          borderRadius: BorderRadius.circular(15),
                          border: Border(
                            left: BorderSide(color: AppColor.blue, width: 2),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 40,
                            bottom: 25,
                            top: 25,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                AppImages.referFriends,
                                height: 64,
                                width: 75,
                              ),
                              SizedBox(height: 15),
                              Text(
                                'Refer Friends',
                                style: GoogleFont.Mulish(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    'Let’s Start',
                                    style: GoogleFont.Mulish(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.linkBlue,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Image.asset(
                                    AppImages.rightSideArrow,
                                    height: 13,
                                    color: AppColor.linkBlue,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewAndEarn(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.lightMint,
                          borderRadius: BorderRadius.circular(15),
                          border: Border(
                            right: BorderSide(
                              color: AppColor.positiveGreen,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 25,
                            bottom: 25,
                            top: 25,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                AppImages.earnByReview,
                                height: 64,
                                width: 83,
                              ),
                              SizedBox(height: 15),
                              Text(
                                'Earn by Review',
                                style: GoogleFont.Mulish(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    'Know More',
                                    style: GoogleFont.Mulish(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.positiveGreen,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Image.asset(
                                    AppImages.rightSideArrow,
                                    height: 13,
                                    color: AppColor.positiveGreen,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 26),
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
                    Spacer(),
                    GestureDetector(
                      onTap: _openDateFilterSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.textWhite,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Text(
                            //   selectedDay,
                            //   style: GoogleFont.Mulish(
                            //     fontSize: 12,
                            //     fontWeight: FontWeight.w600,
                            //     color: AppColor.black,
                            //   ),
                            // ),
                            // SizedBox(width: 5),
                            Image.asset(AppImages.filter, height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 26),
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 15),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(segments.length, (index) {
                    bool isSelected = selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 7),
                        padding: EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          segments[index],
                          style: GoogleFont.Mulish(
                            color: isSelected ? AppColor.darkBlue : Colors.grey,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }),
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
                      containerColor: AppColor.lightGreenBg,
                      mainText: 'Abdul kalam',

                      timeText: '10.40Pm',
                      numberText: '30',
                      endText: 'Received',
                      numberTextColor: AppColor.green,
                      endTextColor: AppColor.green,
                    ),
                    SizedBox(height: 10),
                    CommonContainer.walletHistoryBox(
                      upiTexts: false,
                      containerColor: AppColor.pinkSurface,
                      mainText: 'Stalin',
                      timeText: '10.40Pm',
                      numberText: '15',
                      endText: 'Send',
                      numberTextColor: AppColor.lightRed,
                      endTextColor: AppColor.lightRed,
                    ),
                    SizedBox(height: 20),
                    Text(
                      '1 Nov 2025',
                      style: GoogleFont.Mulish(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColor.darkGrey,
                      ),
                    ),
                    SizedBox(height: 20),
                    CommonContainer.walletHistoryBox(
                      upiTexts: true,
                      containerColor: AppColor.lightBlueGray,
                      mainText: 'Withdraw Requested',
                      upiText: '4587458788@Upi',
                      timeText: '10.40Pm',
                      numberText: '₹12',
                      endText: 'Waiting',
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
