import 'package:flutter/material.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';

import '../../../../../../Core/Utility/app_color.dart';
import '../../../../../../Core/Widgets/common_container.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
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
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    Text(
                      'Support',
                      style: GoogleFont.Mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColor.mildBlack,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                CommonContainer.supportBox(
                  containerColor: AppColor.blue.withOpacity(0.2),
                  image: AppImages.timing,
                  imageText: 'Opened',
                  mainText:
                      'Transaction Failed due to some reason, i don’t ...',
                  timingText: 'Created on 15.02.25',
                ),

                SizedBox(height: 35,),
                CommonContainer.horizonalDivider(),
                SizedBox(height: 35,),
                CommonContainer.supportBox(
                  containerColor: AppColor.green.withOpacity(0.2),
                  image: AppImages.timing,
                  imageText: 'Opened',
                  mainText:
                  'Transaction Failed due to some reason, i don’t ...',
                  timingText: 'Created on 15.02.25',
                ),

                SizedBox(height: 35,),
                CommonContainer.horizonalDivider(),
                SizedBox(height: 35,),
                CommonContainer.supportBox(
                  containerColor: AppColor.blue.withOpacity(0.2),
                  image: AppImages.timing,
                  imageText: 'Opened',
                  mainText:
                  'Transaction Failed due to some reason, i don’t ...',
                  timingText: 'Created on 15.02.25',
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Row(
// children: [
// Container(
// decoration: BoxDecoration(
// color: AppColor.blue.withOpacity(0.2),
// borderRadius: BorderRadius.circular(15),
// ),
// child: Padding(
// padding: const EdgeInsets.symmetric(
// horizontal: 24,
// vertical: 20,
// ),
// child: Column(
// children: [
// Image.asset(AppImages.timing, height: 25.5),
// SizedBox(height: 5),
// Text(
// 'Opened',
// style: GoogleFont.Mulish(
// fontSize: 10,
// fontWeight: FontWeight.bold,
// color: AppColor.blue,
// ),
// ),
// ],
// ),
// ),
// ),
// SizedBox(width: 20),
// Expanded(
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Text(
// maxLines: 2,
// overflow: TextOverflow.ellipsis,
// 'Transaction Failed due to some reason, i don’t ...',
// style: GoogleFont.Mulish(color: AppColor.black),
// ),
// SizedBox(height: 9),
// Text(
// 'Created on 15.02.25',
// style: GoogleFont.Mulish(
// fontSize: 12,
// color: AppColor.black.withOpacity(0.4),
// ),
// ),
// ],
// ),
// ),
//
// ],
// ),
