import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/app_loader.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Core/Widgets/Common%20Bottom%20Navigation%20bar/service_and_shops_details.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';
import 'package:tringo_app/Core/Widgets/current_location_widget.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Controller/home_notifier.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/No%20Data%20Screen/Screen/no_data_screen.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Controller/shops_notifier.dart';

import '../../../../../Core/Utility/map_urls.dart';

class ShopsListing extends ConsumerStatefulWidget {
  final String? highlightId;
  const ShopsListing({super.key,this.highlightId});

  @override
  ConsumerState<ShopsListing> createState() => _ShopsListingState();
}

class _ShopsListingState extends ConsumerState<ShopsListing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> aHeader;
  late Animation<double> aLocationChip;
  late List<Animation<double>> aShops; // For each shop card

  final Set<String> _disabledMessageShopIds = {};

  @override
  void initState() {
    super.initState();

    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    final curve = CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic);

    aHeader = CurvedAnimation(parent: curve, curve: const Interval(0.0, 0.2));

    aLocationChip = CurvedAnimation(
      parent: curve,
      curve: const Interval(0.1, 0.3),
    );

    // 6 stagger slots; we re-use with modulo
    aShops = List.generate(6, (i) {
      final start = 0.2 + i * 0.1;
      final end = start + 0.20;
      return CurvedAnimation(parent: curve, curve: Interval(start, end));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shopsNotifierProvider.notifier).fetchShopsDetails(force: true,highlightId: widget.highlightId??'');
      _ac.forward();
    });
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  Widget _fadeSlide(
    Animation<double> animation,
    Widget child, {
    double dy = 20,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - animation.value) * dy),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopsNotifierProvider);
    final homeState = ref.watch(homeNotifierProvider);

    if (state.isLoading) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }

    final shopsData = state.shopsResponse;
    if (shopsData == null) {
      return const Scaffold(body: Center(child: NoDataScreen()));
    }

    final shops = shopsData.data;

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(shopsNotifierProvider.notifier)
                .fetchShopsDetails(force: true,highlightId: widget.highlightId?? '');
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 16,
                  ),
                  child: _fadeSlide(
                    aHeader,
                    Row(
                      children: [
                        CommonContainer.leftSideArrow(
                          onTap: () => Navigator.pop(context),
                        ),
                        SizedBox(width: 15),
                        Text(
                          'Products',
                          style: GoogleFont.Mulish(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            color: AppColor.black,
                          ),
                        ),
                        SizedBox(width: 50),
                        Expanded(
                          child: CurrentLocationWidget(
                            locationIcon: AppImages.locationImage,
                            dropDownIcon: AppImages.drapDownImage,
                            textStyle: GoogleFonts.mulish(
                              color: AppColor.darkBlue,
                              fontWeight: FontWeight.w600,
                            ),
                            onTap: () {
                              // TODO: location change
                              debugPrint('Change location tapped!');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // LIST
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: shops.length,
                        itemBuilder: (context, index) {
                          final data = shops[index];
                          final isThisCardLoading =
                              homeState.isEnquiryLoading &&
                              homeState.activeEnquiryId == data.id;

                          final hasMessaged =
                              data.id != null &&
                              _disabledMessageShopIds.contains(data.id);
                          // Staggered animation slot
                          final anim = aShops[index % aShops.length];

                          // ✅ Safe unique hero tag only when id is non-null
                          final String? heroTag =
                              (data.id != null && data.id!.isNotEmpty)
                              ? 'shop-hero-${data.id}'
                              : null;

                          Widget card = CommonContainer.servicesContainer(
                            whatsAppOnTap: () {
                              MapUrls.openWhatsapp(
                                message: 'hi',
                                context: context,
                                phone: data.primaryPhone,
                              );
                            },
                            isMessageLoading: isThisCardLoading,
                            messageDisabled: hasMessaged,

                            messageOnTap: () {
                              // safety – no double tap / double API hit
                              if (hasMessaged || isThisCardLoading) return;

                              // lock this shop's message button
                              if (data.id != null) {
                                setState(() {
                                  _disabledMessageShopIds.add(data.id!);
                                });
                              }

                              ref
                                  .read(homeNotifierProvider.notifier)
                                  .putEnquiry(
                                    context: context,
                                    serviceId: '',
                                    productId: '',
                                    message: '',
                                    shopId: data.id,
                                  );
                            },

                            // IMPORTANT: disable internal Hero if any
                            heroTag: null,
                            callTap: () async {
                              await MapUrls.openDialer(
                                context,
                                data.primaryPhone,
                              );
                            },
                            horizontalDivider: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServiceAndShopsDetails(
                                    shopId: data.id ?? '',
                                    initialIndex: 4,
                                    // If your details screen supports heroTag, pass it:
                                    // heroTag: heroTag,
                                  ),
                                ),
                              );
                            },
                            Verify: data.isTrusted == true,
                            image: (data.primaryImageUrl?.isNotEmpty ?? false)
                                ? data.primaryImageUrl!
                                : AppImages.imageContainer1,
                            companyName: data.englishName,
                            location:
                                '${data.city}, ${data.state}, ${data.country}',
                            fieldName: data.distanceLabel ?? 'Nearby',
                            ratingStar: (data.rating ?? 0).toString(),
                            ratingCount: (data.ratingCount ?? 0).toString(),
                            time: data.closeTime ?? 'Timing info',
                          );

                          // Wrap with Hero only if we have a valid tag
                          if (heroTag != null) {
                            card = Hero(tag: heroTag, child: card);
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: _fadeSlide(anim, card),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
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

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import 'package:tringo_app/Core/Utility/app_Images.dart';
// import 'package:tringo_app/Core/Utility/app_color.dart';
// import 'package:tringo_app/Core/Utility/app_loader.dart';
// import 'package:tringo_app/Core/Utility/google_font.dart';
// import 'package:tringo_app/Core/Widgets/Common%20Bottom%20Navigation%20bar/service_and_shops_details.dart';
// import 'package:tringo_app/Core/Widgets/common_container.dart';
// import 'package:tringo_app/Core/Widgets/current_location_widget.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Controller/shops_notifier.dart';
//
// class ShopsListing extends ConsumerStatefulWidget {
//   const ShopsListing({super.key});
//
//   @override
//   ConsumerState<ShopsListing> createState() => _ShopsListingState();
// }
//
// class _ShopsListingState extends ConsumerState<ShopsListing>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ac;
//   late Animation<double> aHeader;
//   late Animation<double> aLocationChip;
//   late List<Animation<double>> aShops; // For each shop card
//
//   @override
//   void initState() {
//     super.initState();
//
//     _ac = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2500),
//     );
//
//     final curve = CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic);
//
//     aHeader = CurvedAnimation(parent: curve, curve: const Interval(0.0, 0.2));
//
//     aLocationChip = CurvedAnimation(
//       parent: curve,
//       curve: const Interval(0.1, 0.3),
//     );
//
//     // 6 stagger slots; we re-use with modulo
//     aShops = List.generate(6, (i) {
//       final start = 0.2 + i * 0.1;
//       final end = start + 0.20;
//       return CurvedAnimation(parent: curve, curve: Interval(start, end));
//     });
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(shopsNotifierProvider.notifier).fetchShopsDetails(force: true);
//       _ac.forward();
//     });
//   }
//
//   @override
//   void dispose() {
//     _ac.dispose();
//     super.dispose();
//   }
//
//   Widget _fadeSlide(
//     Animation<double> animation,
//     Widget child, {
//     double dy = 20,
//   }) {
//     return AnimatedBuilder(
//       animation: animation,
//       builder: (context, _) {
//         return Opacity(
//           opacity: animation.value,
//           child: Transform.translate(
//             offset: Offset(0, (1 - animation.value) * dy),
//             child: child,
//           ),
//         );
//       },
//       child: child,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(shopsNotifierProvider);
//
//     if (state.isLoading) {
//       return Scaffold(
//         body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
//       );
//     }
//
//     final shopsData = state.shopsResponse;
//     if (shopsData == null) {
//       return const Scaffold(body: Center(child: Text('No data')));
//     }
//
//     final shops = shopsData.data;
//
//     return Scaffold(
//       backgroundColor: AppColor.white,
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: () async {
//             await ref
//                 .read(shopsNotifierProvider.notifier)
//                 .fetchShopsDetails(force: true);
//           },
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             child: Column(
//               children: [
//                 // HEADER
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 15,
//                     vertical: 16,
//                   ),
//                   child: _fadeSlide(
//                     aHeader,
//                     Row(
//                       children: [
//                         CommonContainer.leftSideArrow(
//                           onTap: () => Navigator.pop(context),
//                         ),
//                         const SizedBox(width: 15),
//                         Text(
//                           'Shops',
//                           style: GoogleFont.Mulish(
//                             fontWeight: FontWeight.w800,
//                             fontSize: 22,
//                             color: AppColor.black,
//                           ),
//                         ),
//                         const SizedBox(width: 80),
//                         Expanded(
//                           child: CurrentLocationWidget(
//                             locationIcon: AppImages.locationImage,
//                             dropDownIcon: AppImages.drapDownImage,
//                             textStyle: GoogleFonts.mulish(
//                               color: AppColor.darkBlue,
//                               fontWeight: FontWeight.w600,
//                             ),
//                             onTap: () {
//                               // TODO: location change
//                               debugPrint('Change location tapped!');
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 15),
//
//                 // LIST
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 15),
//                   child: Column(
//                     children: [
//                       ListView.builder(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: shops.length,
//                         itemBuilder: (context, index) {
//                           final data = shops[index];
//
//                           // staggered animation slot
//                           final anim = aShops[index % aShops.length];
//
//                           // ✅ unique hero tag per shop
//                           final heroTag = 'hero-shop-${data.id}';
//
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 5),
//                             child: _fadeSlide(
//                               anim,
//                               CommonContainer.servicesContainer(
//                                 heroTag: heroTag,
//                                 horizontalDivider: true,
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           ServiceAndShopsDetails(
//                                             shopId: data.id?? '',
//                                             initialIndex: 4,
//                                           ),
//                                     ),
//                                   );
//                                 },
//                                 Verify: data.isTrusted == true,
//                                 image:
//                                     (data.primaryImageUrl?.isNotEmpty ?? false)
//                                     ? data.primaryImageUrl!
//                                     : AppImages.imageContainer1,
//                                 companyName: data.englishName,
//                                 location:
//                                     '${data.city}, ${data.state}, ${data.country}',
//                                 fieldName: data.distanceLabel ?? 'Nearby',
//                                 ratingStar: (data.rating ?? 0).toString(),
//                                 ratingCount: (data.ratingCount ?? 0).toString(),
//                                 time: data.openLabel ?? 'Timing info',
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 40),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
