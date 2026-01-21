import 'package:flutter/material.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';

import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/common_container.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen>
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
      backgroundColor: AppColor.whiteSmoke,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            child: Column(
              children: [
                Stack(
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
                      'Receive TCoin',
                      style: GoogleFont.Mulish(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColor.mildBlack,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 43),
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 57,vertical: 66),
                    child: Column(
                      children: [
                        Image.asset(AppImages.qRCode, height: 200),
                        SizedBox(height: 31),
                        Text(
                          'Scan QR',
                          style: GoogleFont.Mulish(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        SizedBox(height: 11),
                        Text(
                          '( or )',
                          style: GoogleFont.Mulish(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColor.borderGray,
                          ),
                        ),
                        SizedBox(height: 11),
                        Text(
                          'Use this UID',
                          style: GoogleFont.Mulish(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColor.blue,
                          ),
                        ),
                        SizedBox(height: 11),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'UID886UI38',
                              style: GoogleFont.Mulish(
                                fontSize: 13,
                                color: AppColor.darkBlue,
                              ),
                            ),
                            SizedBox(width: 6),
                            Image.asset(AppImages.uIDBlue, height: 14),
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
      ),
    );
  }
}
