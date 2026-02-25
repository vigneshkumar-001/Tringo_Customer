import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Smart%20Connect/Controller/smart_connect_notifier.dart';

import '../../../../../Core/Widgets/Common Bottom Navigation bar/smart_connect_bottombar.dart';
import '../../../../../Core/Widgets/common_container.dart';
import '../Model/smart_connect_history_response.dart';

class SmartConnectHistory extends ConsumerStatefulWidget {
  const SmartConnectHistory({super.key});

  @override
  ConsumerState<SmartConnectHistory> createState() =>
      _SmartConnectHistoryState();
}

class _SmartConnectHistoryState extends ConsumerState<SmartConnectHistory> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(smartConnectNotifierProvider.notifier)
          .fetchSmartConnectHistory(
            page: 0,
            limit: 10, // ✅ better than 0
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smartConnectNotifierProvider);

    final sections = state.smartConnectHistoryResponse?.data.sections ?? [];

    // ✅ Real flat list
    final List<dynamic> realFlatList = [];
    for (final section in sections) {
      realFlatList.add(section.label);
      for (final item in section.items) {
        realFlatList.add(item);
      }
    }

    // ✅ While loading, if real list is empty -> show dummy skeleton list
    final List<dynamic> dataToShow = (state.isLoading && realFlatList.isEmpty)
        ? _skeletonFlatList()
        : realFlatList;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(smartConnectNotifierProvider.notifier)
                .fetchSmartConnectHistory(page: 0, limit: 10);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.blushPink.withOpacity(0.8),
                    AppColor.blushPink,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Skeletonizer(
                enabled: state.isLoading,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonContainer.leftSideArrow(
                        Color: Colors.transparent,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Image.asset(AppImages.aiGuideImage, height: 135),
                      ),
                      const SizedBox(height: 32),

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
                                colors: [AppColor.yellow, AppColor.pink],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ).createShader(
                                Rect.fromLTWH(
                                  0,
                                  0,
                                  bounds.width,
                                  bounds.height,
                                ),
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

                      const SizedBox(height: 30),

                      // ✅ List
                      ListView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(), // ✅ scroll only in parent
                        itemCount: dataToShow.length,
                        itemBuilder: (context, index) {
                          final element = dataToShow[index];

                          // ✅ HEADER
                          if (element is String) {
                            return _buildSectionHeader(element);
                          }

                          // ✅ ITEM
                          if (element is SmartConnectHistoryItem) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              child: CommonContainer.smartConnectHistory(
                                onTap: state.isLoading
                                    ? () {} // ✅ block navigation while loading
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                SmartConnectBottombar(
                                                  initialIndex: 3,
                                                  requestedId: element.id,
                                                ),
                                          ),
                                        );
                                      },
                                productName: element.productName,
                                shopCounting: element.shopsReachedText,
                                productCounting: element.replyCount.toString(),
                                Showrooms: element.categoryTrail,
                                productCategories: element.categoryTrail,
                                time: element.createdTimeLabel,
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Skeleton header
  Widget _buildSectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Center(
        child: Text(
          label,
          style: GoogleFont.Mulish(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColor.lightGray3,
          ),
        ),
      ),
    );
  }

  // ✅ Dummy list for skeleton UI
  List<dynamic> _skeletonFlatList() {
    return [
      "Today",
      ...List.generate(5, (_) => _fakeItem()),
      "Yesterday",
      ...List.generate(4, (_) => _fakeItem()),
    ];
  }

  // ✅ Fake item (match your model fields)
  SmartConnectHistoryItem _fakeItem() {
    return SmartConnectHistoryItem(
      id: "x",
      productName: "Loading Product",
      categoryTrail: "Loading Category",
      description: "Loading...",
      city: "Loading",
      targetShopId: "x",
      targetListingId: "x",
      targetListingType: "PRODUCT",
      status: "OPEN",
      createdAt: DateTime.now(),
      createdTimeLabel: "00:00AM",
      createdLabel: "Created on 00:00AM",
      replyCount: 0,
      shopsReachedText: "0 Shops Reached",
      lastReplyAt: null,
    );
  }
}

//
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tringo_app/Core/Utility/app_Images.dart';
// import 'package:tringo_app/Core/Utility/app_color.dart';
// import 'package:tringo_app/Core/Utility/google_font.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Smart%20Connect/Controller/smart_connect_notifier.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Smart%20Connect/Screens/smart_connect_details.dart';
//
// import '../../../../../Core/Widgets/Common Bottom Navigation bar/smart_connect_bottombar.dart';
// import '../../../../../Core/Widgets/common_container.dart';
//
// class SmartConnectHistory extends ConsumerStatefulWidget {
//   const SmartConnectHistory({super.key});
//
//   @override
//   ConsumerState<SmartConnectHistory> createState() =>
//       _SmartConnectHistoryState();
// }
//
// class _SmartConnectHistoryState extends ConsumerState<SmartConnectHistory> {
//   @override
//   void initState() {
//
// super.initState();
//
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: BouncingScrollPhysics(),
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   // AppColor.white,
//                   AppColor.blushPink.withOpacity(0.8),
//                   AppColor.blushPink,
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   CommonContainer.leftSideArrow(
//                     Color: Colors.transparent,
//                     onTap: () => Navigator.pop(context),
//                   ),
//                   SizedBox(height: 20),
//                   Center(
//                     child: Image.asset(AppImages.aiGuideImage, height: 135),
//                   ),
//                   SizedBox(height: 32),
//                   Center(
//                     child: Text(
//                       'Smart Connect',
//                       style: GoogleFont.Mulish(
//                         fontSize: 26,
//                         fontWeight: FontWeight.bold,
//                         color: AppColor.darkBlue,
//                       ),
//                     ),
//                   ),
//                   Center(
//                     child: ShaderMask(
//                       blendMode: BlendMode.srcIn,
//                       shaderCallback: (bounds) =>
//                           LinearGradient(
//                             colors: [
//                               AppColor.yellow, // Orange
//                               AppColor.pink, // Pink
//                               // Color(0xFF34A6F5), // Purple/Blue tone
//                             ],
//                             begin: Alignment.centerLeft,
//                             end: Alignment.centerRight,
//                           ).createShader(
//                             Rect.fromLTWH(0, 0, bounds.width, bounds.height),
//                           ),
//                       child: Text(
//                         'History',
//                         style: GoogleFont.Mulish(
//                           fontSize: 27,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 42),
//                   Center(
//                     child: Text(
//                       'Today',
//                       style: GoogleFont.Mulish(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w700,
//                         color: AppColor.lightGray3,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 13),
//                   CommonContainer.smartConnectHistory(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               SmartConnectBottombar(initialIndex: 3),
//                         ),
//                       );
//                     },
//                     productName: 'Iphone 17',
//                     shopCounting: '20 Shops Reached',
//                     productCounting: '2',
//                     Showrooms: 'Mobile Showrooms',
//                     productCategories: 'Phone',
//                     time: '11.15Pm',
//                   ),
//                   SizedBox(height: 25),
//                   CommonContainer.smartConnectHistory(
//                     onTap: () {},
//                     productName: 'Ceiling Fan Atomberg BLDC',
//                     shopCounting: '20 Shops Reached',
//                     productCounting: '11',
//                     Showrooms: 'Home Appliances',
//                     productCategories: 'Fan',
//                     time: '11.15Pm',
//                   ),
//                   SizedBox(height: 60),
//                   Center(
//                     child: Text(
//                       'Yesterday',
//                       style: GoogleFont.Mulish(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w700,
//                         color: AppColor.lightGray3,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 13),
//                   CommonContainer.smartConnectHistory(
//                     onTap: () {},
//                     productName: 'Water pump 1hp',
//                     shopCounting: '20 Shops Reached',
//                     productCounting: '8',
//                     Showrooms: 'Home Appliances',
//                     productCategories: 'Water pump',
//                     time: '11.15Pm',
//                   ),
//                   SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//
// }
