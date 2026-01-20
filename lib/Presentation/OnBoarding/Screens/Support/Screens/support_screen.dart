import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';

import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/app_loader.dart';
import '../../../../../Core/Utility/date_time_converter.dart';
import '../../../../../Core/Widgets/common_container.dart';
import '../../No Data Screen/Screen/no_data_screen.dart';
import '../Model/support_list_response.dart';
import '../controller/support_notifier.dart';
import 'create_support.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    Future.microtask(() async {
      ref.read(supportNotifier.notifier).supportList(context: context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supportNotifier);
    final supportListResponse = state.supportListResponse;
    if (state.isLoading && supportListResponse == null) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }

    if (!state.isLoading && state.error != null) {
      return Scaffold(
        body: Center(
          child: NoDataScreen(
            onRefresh: () async {
              // await ref
              //     .read(homeNotifierProvider.notifier)
              //     .fetchHomeDetails(lat: loc.lat, lng: loc.lng);
            },
            showBottomButton: false,
            showTopBackArrow: false,
          ),
        ),
      );
    }
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
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: supportListResponse?.data.length ?? 0,
                  itemBuilder: (context, index) {
                    final ticket = supportListResponse!.data[index];

                    // Map status to color and image
                    Color containerColor;
                    Color imageTextColor;
                    String imageAsset;
                    String statusText;

                    switch (ticket.status) {
                      case SupportStatus.pending:
                        containerColor = AppColor.yellow.withOpacity(0.2);
                        imageTextColor = AppColor.yellow;
                        imageAsset = AppImages.orangeClock;
                        statusText = 'Pending';
                        break;
                      case SupportStatus.resolved:
                        containerColor = AppColor.green.withOpacity(0.2);
                        imageTextColor = AppColor.green;
                        imageAsset = AppImages.greenTick;
                        statusText = 'Solved';
                        break;
                      case SupportStatus.closed:
                        containerColor = AppColor.gray84.withOpacity(0.2);
                        imageTextColor = AppColor.gray84;
                        imageAsset =
                            AppImages.closeImage; // add your closed icon
                        statusText = 'Closed';
                        break;
                      case SupportStatus.OPEN:
                        containerColor = AppColor.blue.withOpacity(0.2);
                        imageTextColor = AppColor.blue;
                        imageAsset = AppImages.timing; // add your closed icon
                        statusText = 'Opened';
                        break;
                      default:
                        containerColor = AppColor.blue.withOpacity(0.2);
                        imageTextColor = AppColor.blue;
                        imageAsset = AppImages.timing;
                        statusText = 'Unknown';
                    }

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CommonContainer.supportBox(
                        imageTextColor: imageTextColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateSupport(),
                            ),
                          );
                        },
                        containerColor: containerColor,
                        image: imageAsset,
                        imageText: statusText,
                        mainText: ticket.subject,
                        timingText:
                            'Created on ${DateAndTimeConvert.formatDateTime(ticket.lastMessageAt.toIso8601String(), showTime: false)}',
                      ),
                    );
                  },
                ),

                /*  SizedBox(height: 35),
                CommonContainer.horizonalDivider(),
                SizedBox(height: 35),
                CommonContainer.supportBox(
                  imageTextColor: AppColor.green,
                  onTap: () {},
                  containerColor: AppColor.green.withOpacity(0.2),
                  image: AppImages.greenTick,
                  imageText: 'Solved',
                  mainText:
                      'Transaction Failed due to some reason, i don’t ...',
                  timingText: 'Created on 15.02.25',
                ),

                SizedBox(height: 35),
                CommonContainer.horizonalDivider(),
                SizedBox(height: 35),
                CommonContainer.supportBox(
                  imageTextColor: AppColor.yellow,
                  onTap: () {},
                  containerColor: AppColor.yellow.withOpacity(0.2),
                  image: AppImages.orangeClock,
                  imageText: 'Pending',
                  mainText:
                      'Transaction Failed due to some reason, i don’t ...',
                  timingText: 'Created on 15.02.25',
                ),*/
                SizedBox(height: 50),
                CommonContainer.button(
                  buttonColor: AppColor.darkBlue,
                  imagePath: AppImages.rightSideArrow,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateSupport()),
                    );
                  },
                  text: Text('Create Ticket'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
