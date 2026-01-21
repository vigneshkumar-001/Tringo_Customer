import 'package:flutter/material.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/qr_scan_screen.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/receive_screen.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/common_container.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

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
                      'Send',
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
                    SizedBox(height: 25),
                  ],
                ),
              ),
              SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter UID',
                      style: GoogleFont.Mulish(
                        fontSize: 14,
                        color: AppColor.mildBlack,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "",
                        filled: true,
                        fillColor: Colors.grey[200],
                        suffixIcon: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QrScanScreen(
                                  title: 'Scan QR Code',
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Image.asset(
                              AppImages.smallScanQRBlack,
                              width: 27,
                              color: AppColor.darkBlue,
                            ),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Waiting to fetch person name',
                      style: GoogleFont.Mulish(
                        fontSize: 14,
                        color: AppColor.darkGrey,
                      ),
                    ),
                    SizedBox(height: 25),
                    Text(
                      'Amount',
                      style: GoogleFont.Mulish(
                        fontSize: 14,
                        color: AppColor.mildBlack,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        hintText: "",
                        filled: true,
                        fillColor: Colors.grey[200],

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    CommonContainer.button(
                      buttonColor: AppColor.darkBlue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReceiveScreen(),
                          ),
                        );
                      },
                      text: Text('Send Now'),
                      imagePath: AppImages.rightSideArrow,
                    ),
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
