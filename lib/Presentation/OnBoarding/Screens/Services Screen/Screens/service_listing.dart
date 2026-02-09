import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tringo_app/Core/Utility/app_loader.dart';
import 'package:tringo_app/Core/Utility/map_urls.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Services%20Screen/Controller/service_notifier.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/Common Bottom Navigation bar/service_and_shops_details.dart';
import '../../../../../Core/Widgets/advetisements_screens.dart';
import '../../../../../Core/Widgets/common_container.dart';
import '../../../../../Core/Widgets/current_location_widget.dart';
import '../../Home Screen/Controller/home_notifier.dart';
import '../../No Data Screen/Screen/no_data_screen.dart';

class ServiceListing extends ConsumerStatefulWidget {
  final String? title;
  final String? highlightId;
  const ServiceListing({super.key, this.title, this.highlightId});

  @override
  ConsumerState<ServiceListing> createState() => _ServiceListingState();
}

class _ServiceListingState extends ConsumerState<ServiceListing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> aHeader;
  late Animation<double> aTitle;
  late List<Animation<double>> aServices;

  // ✅ disable only after SUCCESS (per service/shop id)
  final Set<String> _disabledMessageServiceIds = {};

  @override
  void initState() {
    super.initState();

    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    final curve = CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic);

    aHeader = CurvedAnimation(parent: curve, curve: const Interval(0.0, 0.2));
    aTitle = CurvedAnimation(parent: curve, curve: const Interval(0.15, 0.3));

    aServices = List.generate(5, (i) {
      final start = 0.3 + i * 0.1;
      final end = (start + 0.15).clamp(0.0, 1.0);
      return CurvedAnimation(parent: curve, curve: Interval(start, end));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref
          .read(serviceNotifierProvider.notifier)
          .fetchServiceDetails(
            force: true,
            highlightId: widget.highlightId ?? '',
          );

      ref
          .read(homeNotifierProvider.notifier)
          .advertisements(placement: 'SHOP_LIST', lat: 0.0, lang: 0.0);

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

  // ✅ Message handler (disable only after success)
  Future<void> _handleServiceEnquiry({
    required BuildContext context,
    required String? serviceOrShopId,
    required bool isThisCardLoading,
  }) async {
    if (serviceOrShopId == null || serviceOrShopId.isEmpty) return;

    final hasMessaged = _disabledMessageServiceIds.contains(serviceOrShopId);
    if (hasMessaged || isThisCardLoading) return;

    final ok = await ref
        .read(homeNotifierProvider.notifier)
        .putEnquiry(
          context: context,
          serviceId: '',
          productId: '',
          message: '',
          shopId: serviceOrShopId,
        );

    if (!mounted) return;

    if (ok) {
      setState(() {
        _disabledMessageServiceIds.add(serviceOrShopId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceNotifierProvider);
    final homeState = ref.watch(homeNotifierProvider);

    final ads = homeState.advertisementResponse;
    final addsBanner = (ads != null && ads.data.isNotEmpty)
        ? ads.data.first
        : null;

    if (state.isLoading) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }

    final serviceRawData = state.serviceResponse;
    if (serviceRawData == null) {
      return const Scaffold(body: Center(child: NoDataScreen()));
    }

    final servicesData = serviceRawData.data;

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                      const SizedBox(width: 15),
                      Text(
                        'Services',
                        style: GoogleFont.Mulish(
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                          color: AppColor.black,
                        ),
                      ),
                      const SizedBox(width: 50),
                      Expanded(
                        child: CurrentLocationWidget(
                          locationIcon: AppImages.locationImage,
                          dropDownIcon: AppImages.drapDownImage,
                          textStyle: GoogleFonts.mulish(
                            color: AppColor.darkBlue,
                            fontWeight: FontWeight.w600,
                          ),
                          onTap: () {
                            debugPrint('Change location tapped!');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Service Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: servicesData.length,
                        itemBuilder: (context, index) {
                          final data = servicesData[index];

                          // If your API uses shop/service id here, keep consistent
                          final String? id = data.id;

                          final isThisCardLoading =
                              homeState.isEnquiryLoading &&
                              homeState.activeEnquiryId == id;

                          final hasMessaged =
                              (id != null &&
                              _disabledMessageServiceIds.contains(id));

                          final anim = aServices[index % aServices.length];

                          final card = CommonContainer.servicesContainer(
                            callTap: () async {
                              await MapUrls.openDialer(
                                context,
                                data.primaryPhone,
                              );
                              await ref
                                  .read(homeNotifierProvider.notifier)
                                  .markCallOrLocation(
                                    type: 'CALL',
                                    shopId: id ?? '',
                                  );
                            },

                            isMessageLoading: isThisCardLoading,
                            messageDisabled: hasMessaged,

                            // ✅ UPDATED
                            messageOnTap: () async {
                              await _handleServiceEnquiry(
                                context: context,
                                serviceOrShopId: id,
                                isThisCardLoading: isThisCardLoading,
                              );
                            },

                            horizontalDivider: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServiceAndShopsDetails(
                                    initialIndex: 3,
                                    shopId: id ?? '',
                                  ),
                                ),
                              );
                            },

                            Verify: data.isTrusted,
                            image: data.primaryImageUrl?.toString() ?? '',
                            companyName: data.englishName?.toString() ?? '',
                            location:
                                '${data.addressEn ?? ''},${data.city ?? ''}${data.state ?? ''} ',
                            fieldName: data.distanceLabel?.toString() ?? '',
                            ratingStar: (data.rating ?? 0).toString(),
                            ratingCount: (data.ratingCount ?? 0).toString(),
                            time: data.closeTime ?? '',
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: _fadeSlide(anim, card),
                          );
                        },
                      ),

                      const SizedBox(height: 6),

                      addsBanner == null
                          ? const SizedBox.shrink()
                          : DismissibleAdBanner(
                              imageUrl: addsBanner.imageUrl?.toString() ?? '',
                              onTap: () {},
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:tringo_app/Core/Const/app_logger.dart';
// import 'package:tringo_app/Core/Utility/app_loader.dart';
// import 'package:tringo_app/Core/Utility/map_urls.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Services%20Screen/Controller/service_notifier.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../../../../Core/Utility/app_Images.dart';
// import '../../../../../Core/Utility/app_color.dart';
// import '../../../../../Core/Utility/google_font.dart';
// import '../../../../../Core/Widgets/Common Bottom Navigation bar/service_and_shops_details.dart';
// import '../../../../../Core/Widgets/advetisements_screens.dart';
// import '../../../../../Core/Widgets/common_container.dart';
// import '../../../../../Core/Widgets/current_location_widget.dart';
// import '../../Home Screen/Controller/home_notifier.dart';
// import '../../No Data Screen/Screen/no_data_screen.dart';
// import 'Service_details.dart';
//
// class ServiceListing extends ConsumerStatefulWidget {
//   final String? title;
//   final String? highlightId;
//   const ServiceListing({super.key, this.title, this.highlightId});
//
//   @override
//   ConsumerState<ServiceListing> createState() => _ServiceListingState();
// }
//
// class _ServiceListingState extends ConsumerState<ServiceListing>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ac;
//   late Animation<double> aHeader;
//   late Animation<double> aTitle;
//   late List<Animation<double>> aServices;
//
//   final Set<String> _disabledMessageServiceIds = {};
//
//   @override
//   void initState() {
//     super.initState();
//
//     _ac = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2500),
//     );
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref
//           .read(serviceNotifierProvider.notifier)
//           .fetchServiceDetails(
//             force: true,
//             highlightId: widget.highlightId ?? '',
//           );
//       ref
//           .read(homeNotifierProvider.notifier)
//           .advertisements( placement: 'SHOP_LIST',lat: 0.0,lang: 0.0);
//       _ac.forward();
//     });
//     final curve = CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic);
//
//     aHeader = CurvedAnimation(parent: curve, curve: const Interval(0.0, 0.2));
//     aTitle = CurvedAnimation(parent: curve, curve: const Interval(0.15, 0.3));
//
//     aServices = List.generate(5, (i) {
//       final start = 0.3 + i * 0.1;
//       final end = (start + 0.15).clamp(0.0, 1.0);
//       return CurvedAnimation(parent: curve, curve: Interval(start, end));
//     });
//
//     WidgetsBinding.instance.addPostFrameCallback((_) => _ac.forward());
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
//     final state = ref.watch(serviceNotifierProvider);
//     final states = ref.watch(homeNotifierProvider);
//     final ads = states.advertisementResponse;
//
//     final addsBanner = (ads != null && ads.data.isNotEmpty)
//         ? ads.data.first
//         : null;
//     if (state.isLoading) {
//       return Scaffold(
//         body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
//       );
//     }
//
//     final serviceRawData = state.serviceResponse;
//     if (serviceRawData == null) {
//       return const Scaffold(body: Center(child: NoDataScreen()));
//     }
//
//     final servicesData = serviceRawData.data;
//     return Scaffold(
//       backgroundColor: AppColor.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: BouncingScrollPhysics(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 15,
//                   vertical: 16,
//                 ),
//                 child: _fadeSlide(
//                   aHeader,
//                   Row(
//                     children: [
//                       CommonContainer.leftSideArrow(
//                         onTap: () {
//                           Navigator.pop(context);
//                         },
//                       ),
//                       SizedBox(width: 15),
//                       Text(
//                         'Services',
//                         style: GoogleFont.Mulish(
//                           fontWeight: FontWeight.w800,
//                           fontSize: 24,
//                           color: AppColor.black,
//                         ),
//                       ),
//                       SizedBox(width: 50),
//                       Expanded(
//                         child: CurrentLocationWidget(
//                           locationIcon: AppImages.locationImage,
//                           dropDownIcon: AppImages.drapDownImage,
//                           textStyle: GoogleFonts.mulish(
//                             color: AppColor.darkBlue,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           onTap: () {
//                             // Handle location change, e.g., open map picker or bottom sheet
//                             print('Change location tapped!');
//                           },
//                         ),
//                       ),
//                       /*        CommonContainer.gradientContainer(
//                         lIconColor: AppColor.blue,
//                         iconImage: AppImages.drapDownImage,
//                         locationImage: AppImages.locationImage,
//                         text: 'Marudhupandiyar nagar main road, Madurai',
//                       ),*/
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 12),
//
//               // Service Cards
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 5),
//                   child: Column(
//                     children: [
//                       ListView.builder(
//                         shrinkWrap: true,
//                         primary: false,
//                         physics: NeverScrollableScrollPhysics(),
//                         itemCount: servicesData.length,
//                         itemBuilder: (context, index) {
//                           final data = servicesData[index];
//                           final isThisCardLoading =
//                               states.isEnquiryLoading &&
//                               states.activeEnquiryId == data.id;
//
//                           final hasMessaged = _disabledMessageServiceIds
//                               .contains(data.id);
//                           return CommonContainer.servicesContainer(
//                             callTap: () async {
//                               await MapUrls.openDialer(
//                                 context,
//                                 data.primaryPhone,
//                               );
//                               await ref
//                                   .read(homeNotifierProvider.notifier)
//                                   .markCallOrLocation(
//                                 type: 'CALL',
//                                 shopId:
//                                 data.id.toString() ??
//                                     '',
//                               );
//                             },
//                             isMessageLoading: isThisCardLoading,
//                             messageDisabled: hasMessaged,
//                             messageOnTap: () {
//                               if (hasMessaged || isThisCardLoading) return;
//
//                               // lock this card's message button
//                               setState(() {
//                                 _disabledMessageServiceIds.add(data.id);
//                               });
//                               ref
//                                   .read(homeNotifierProvider.notifier)
//                                   .putEnquiry(
//                                     context: context,
//                                     serviceId: '',
//                                     productId: '',
//                                     message: '',
//                                     shopId: data.id,
//                                   );
//                             },
//                             horizontalDivider: true,
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => ServiceAndShopsDetails(
//                                     initialIndex: 3,
//                                     shopId: data.id,
//                                   ),
//                                 ),
//                               );
//                             },
//                             Verify: data.isTrusted,
//                             image: data.primaryImageUrl.toString(),
//                             companyName: data.englishName.toString(),
//                             location:
//                                 '${data.addressEn},${data.city}${data.state} ',
//                             fieldName: data.distanceLabel.toString(),
//                             ratingStar: data.rating.toString(),
//                             ratingCount: data.ratingCount.toString(),
//                             time: data.closeTime,
//                           );
//                         },
//                       ),
//
//                       SizedBox(height: 6),    addsBanner == null
//                           ? const SizedBox.shrink()
//                           : DismissibleAdBanner(
//                         imageUrl: addsBanner?.imageUrl.toString()?? '',
//                         onTap: () {
//                           // open banner.ctaUrl if needed
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
