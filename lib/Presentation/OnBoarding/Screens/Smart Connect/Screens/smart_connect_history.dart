import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Smart%20Connect/Controller/smart_connect_notifier.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Smart%20Connect/Screens/create_smart_connect.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Smart%20Connect/Screens/smart_connect_details.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Smart%20Connect/Screens/smart_connect_guide.dart';

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
          .fetchSmartConnectHistory(page: 0, limit: 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smartConnectNotifierProvider);

    final sections = state.smartConnectHistoryResponse?.data.sections ?? [];

    // Flatten sections and items into a single list
    final List<dynamic> realFlatList = [];
    for (final section in sections) {
      realFlatList.add(section.label);
      for (final item in section.items) {
        realFlatList.add(item);
      }
    }

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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 16,
                ),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemCount: dataToShow.length + 3, // 3 for top widgets
                itemBuilder: (context, index) {
                  // Top static widgets
                  if (index == 0) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// 🔹 LEFT BACK BUTTON
                        CommonContainer.leftSideArrow(
                          Color: Colors.transparent,
                          onTap: () => Navigator.pop(context),
                        ),

                        /// 🔹 RIGHT CREATE BUTTON
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact(); // 👈 subtle vibration
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SmartConnectGuide(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.darkBlue,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              "Create",
                              style: GoogleFont.Mulish(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (index == 1) {
                    return Center(
                      child: Image.asset(AppImages.aiGuideImage, height: 135),
                    );
                  } else if (index == 2) {
                    return Column(
                      children: [
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
                      ],
                    );
                  }

                  // List items
                  final element = dataToShow[index - 3];

                  if (element is String) {
                    return _buildSectionHeader(element);
                  }

                  if (element is SmartConnectHistoryItem) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 10,
                      ),
                      child: CommonContainer.smartConnectHistory(
                        onTap: state.isLoading
                            ? () {}
                            : () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (_) => SmartConnectBottombar(
                                //       initialIndex: 3,
                                //       requestedId: element.id,
                                //     ),
                                //   ),
                                // );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SmartConnectDetails(
                                      requestedId: element.id,
                                    ), // 3
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
            ),
          ),
        ),
      ),
    );
  }

  // Skeleton header
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

  // Dummy list for skeleton UI
  List<dynamic> _skeletonFlatList() {
    return [
      "Today",
      ...List.generate(5, (_) => _fakeItem()),
      "Yesterday",
      ...List.generate(4, (_) => _fakeItem()),
    ];
  }

  // Fake item (match your model fields)
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

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:skeletonizer/skeletonizer.dart';
// import 'package:tringo_app/Core/Utility/app_Images.dart';
// import 'package:tringo_app/Core/Utility/app_color.dart';
// import 'package:tringo_app/Core/Utility/google_font.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Smart%20Connect/Controller/smart_connect_notifier.dart';
//
// import '../../../../../Core/Widgets/Common Bottom Navigation bar/smart_connect_bottombar.dart';
// import '../../../../../Core/Widgets/common_container.dart';
// import '../Model/smart_connect_history_response.dart';
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
//     super.initState();
//     Future.microtask(() {
//       ref
//           .read(smartConnectNotifierProvider.notifier)
//           .fetchSmartConnectHistory(
//             page: 0,
//             limit: 10, // ✅ better than 0
//           );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(smartConnectNotifierProvider);
//
//     final sections = state.smartConnectHistoryResponse?.data.sections ?? [];
//
//     // ✅ Real flat list
//     final List<dynamic> realFlatList = [];
//     for (final section in sections) {
//       realFlatList.add(section.label);
//       for (final item in section.items) {
//         realFlatList.add(item);
//       }
//     }
//
//     // ✅ While loading, if real list is empty -> show dummy skeleton list
//     final List<dynamic> dataToShow = (state.isLoading && realFlatList.isEmpty)
//         ? _skeletonFlatList()
//         : realFlatList;
//
//     return Scaffold(
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: () async {
//             await ref
//                 .read(smartConnectNotifierProvider.notifier)
//                 .fetchSmartConnectHistory(page: 0, limit: 10);
//           },
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(
//               parent: BouncingScrollPhysics(),
//             ),
//             child: Container(
//
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     AppColor.blushPink.withOpacity(0.8),
//                     AppColor.blushPink,
//                   ],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//               child: Skeletonizer(
//                 enabled: state.isLoading,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 15,
//                     vertical: 16,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       CommonContainer.leftSideArrow(
//                         Color: Colors.transparent,
//                         onTap: () => Navigator.pop(context),
//                       ),
//                       const SizedBox(height: 20),
//                       Center(
//                         child: Image.asset(AppImages.aiGuideImage, height: 135),
//                       ),
//                       const SizedBox(height: 32),
//
//                       Center(
//                         child: Text(
//                           'Smart Connect',
//                           style: GoogleFont.Mulish(
//                             fontSize: 26,
//                             fontWeight: FontWeight.bold,
//                             color: AppColor.darkBlue,
//                           ),
//                         ),
//                       ),
//
//                       Center(
//                         child: ShaderMask(
//                           blendMode: BlendMode.srcIn,
//                           shaderCallback: (bounds) =>
//                               LinearGradient(
//                                 colors: [AppColor.yellow, AppColor.pink],
//                                 begin: Alignment.centerLeft,
//                                 end: Alignment.centerRight,
//                               ).createShader(
//                                 Rect.fromLTWH(
//                                   0,
//                                   0,
//                                   bounds.width,
//                                   bounds.height,
//                                 ),
//                               ),
//                           child: Text(
//                             'History',
//                             style: GoogleFont.Mulish(
//                               fontSize: 27,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 30),
//
//                       // ✅ List
//                       ListView.builder(
//                         shrinkWrap: true,
//                         physics:
//                             const NeverScrollableScrollPhysics(), // ✅ scroll only in parent
//                         itemCount: dataToShow.length,
//                         itemBuilder: (context, index) {
//                           final element = dataToShow[index];
//
//                           // ✅ HEADER
//                           if (element is String) {
//                             return _buildSectionHeader(element);
//                           }
//
//                           // ✅ ITEM
//                           if (element is SmartConnectHistoryItem) {
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 5,
//                                 vertical: 10,
//                               ),
//                               child: CommonContainer.smartConnectHistory(
//                                 onTap: state.isLoading
//                                     ? () {} // ✅ block navigation while loading
//                                     : () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (_) =>
//                                                 SmartConnectBottombar(
//                                                   initialIndex: 3,
//                                                   requestedId: element.id,
//                                                 ),
//                                           ),
//                                         );
//                                       },
//                                 productName: element.productName,
//                                 shopCounting: element.shopsReachedText,
//                                 productCounting: element.replyCount.toString(),
//                                 Showrooms: element.categoryTrail,
//                                 productCategories: element.categoryTrail,
//                                 time: element.createdTimeLabel,
//                               ),
//                             );
//                           }
//
//                           return const SizedBox.shrink();
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ✅ Skeleton header
//   Widget _buildSectionHeader(String label) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//       child: Center(
//         child: Text(
//           label,
//           style: GoogleFont.Mulish(
//             fontSize: 14,
//             fontWeight: FontWeight.w700,
//             color: AppColor.lightGray3,
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ✅ Dummy list for skeleton UI
//   List<dynamic> _skeletonFlatList() {
//     return [
//       "Today",
//       ...List.generate(5, (_) => _fakeItem()),
//       "Yesterday",
//       ...List.generate(4, (_) => _fakeItem()),
//     ];
//   }
//
//   // ✅ Fake item (match your model fields)
//   SmartConnectHistoryItem _fakeItem() {
//     return SmartConnectHistoryItem(
//       id: "x",
//       productName: "Loading Product",
//       categoryTrail: "Loading Category",
//       description: "Loading...",
//       city: "Loading",
//       targetShopId: "x",
//       targetListingId: "x",
//       targetListingType: "PRODUCT",
//       status: "OPEN",
//       createdAt: DateTime.now(),
//       createdTimeLabel: "00:00AM",
//       createdLabel: "Created on 00:00AM",
//       replyCount: 0,
//       shopsReachedText: "0 Shops Reached",
//       lastReplyAt: null,
//     );
//   }
// }
