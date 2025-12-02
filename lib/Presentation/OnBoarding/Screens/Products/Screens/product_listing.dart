import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tringo_app/Core/Utility/app_loader.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Products/Controller/product_notifier.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Products/Screens/product_details.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/common_container.dart';
import '../../../../../Core/Widgets/current_location_widget.dart';
import '../../No Data Screen/Screen/no_data_screen.dart';

class ProductListing extends ConsumerStatefulWidget {
  final String? title;
  const ProductListing({super.key, this.title});

  @override
  ConsumerState<ProductListing> createState() => _ProductListingState();
}

class _ProductListingState extends ConsumerState<ProductListing> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productNotifierProvider.notifier).productList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productNotifierProvider);

    if (state.isLoading) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }

    final productListData = state.productListResponse;
    if (productListData == null) {
      return const Scaffold(body: Center(child: NoDataScreen()));
    }

    // ✅ Make a safe non-null list
    final items = productListData.data?.items ?? [];

    if (items.isEmpty) {
      return const Scaffold(body: Center(child: NoDataScreen()));
    }

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    CommonContainer.leftSideArrow(
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 15),
                    Text(
                      widget.title ?? '',
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: AppColor.black,
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: CurrentLocationWidget(
                        locationIcon: AppImages.locationImage,
                        dropDownIcon: AppImages.drapDownImage,
                        textStyle: GoogleFonts.mulish(
                          color: AppColor.darkBlue,
                          fontWeight: FontWeight.w600,
                        ),
                        onTap: () {
                          // Handle location change
                          debugPrint('Change location tapped!');
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 17),

                Text(
                  '${items.length}+ Results',
                  style: GoogleFont.Mulish(
                    fontSize: 14,
                    color: AppColor.lightGray2,
                  ),
                ),

                // ✅ Products list
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final data = items[index];
                    final shop = data.shop; // may be null

                    return CommonContainer.foodList(
                      titleWeight: FontWeight.w400,
                      locations: true,
                      fontSize: 12,
                      imageWidth: 130,
                      imageHeight: 150,
                      Ad: false,
                      horizontalDivider: true,

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetails(productId: data.id),
                          ),
                        );
                      },

                      // 🔹 All below are now null-safe
                      Verify: shop?.isTrusted ?? false, // bool not bool?
                      image: data.imageUrl ?? '',
                      foodName: data.englishName ?? '',

                      ratingStar: (shop?.rating ?? 0).toString(),
                      ratingCount: (shop?.ratingCount ?? 0).toString(),

                      offAmound: '₹${data.price ?? ''}',
                      oldAmound: '₹${data.offerPrice ?? ''}',

                      km: (shop?.distanceKm ?? '').toString(),
                      location:
                          '${shop?.englishName ?? ''} & ${shop?.category ?? ''}',
                    );
                  },
                ),

                const SizedBox(height: 10),
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
// import 'package:tringo_app/Core/Utility/app_loader.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Products/Controller/product_notifier.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Products/Screens/product_details.dart';
//
// import '../../../../../Core/Utility/app_Images.dart';
// import '../../../../../Core/Utility/app_color.dart';
// import '../../../../../Core/Utility/google_font.dart';
// import '../../../../../Core/Widgets/common_container.dart';
// import '../../../../../Core/Widgets/current_location_widget.dart';
// import '../../Food Screen/food_details.dart';
// import '../../No Data Screen/Screen/no_data_screen.dart';
//
// class ProductListing extends ConsumerStatefulWidget {
//   final String? title;
//   const ProductListing({super.key, this.title});
//
//   @override
//   ConsumerState<ProductListing> createState() => _ProductListingState();
// }
//
// class _ProductListingState extends ConsumerState<ProductListing> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(productNotifierProvider.notifier).productList();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(productNotifierProvider);
//
//     if (state.isLoading) {
//       return Scaffold(
//         body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
//       );
//     }
//
//     final productListData = state.productListResponse;
//
//     if (productListData == null) {
//       return const Scaffold(body: Center(child: NoDataScreen()));
//     }
//
//     final items = productListData.data?.items ?? [];
//
//     if (items.isEmpty) {
//       return const Scaffold(body: Center(child: NoDataScreen()));
//     }
//     return Scaffold(
//       backgroundColor: AppColor.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     CommonContainer.leftSideArrow(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                     ),
//                     SizedBox(width: 15),
//                     Text(
//                       widget.title ?? '',
//                       style: GoogleFont.Mulish(
//                         fontWeight: FontWeight.w800,
//                         fontSize: 22,
//                         color: AppColor.black,
//                       ),
//                     ),
//                     SizedBox(width: 40),
//                     Expanded(
//                       child: CurrentLocationWidget(
//                         locationIcon: AppImages.locationImage,
//                         dropDownIcon: AppImages.drapDownImage,
//                         textStyle: GoogleFonts.mulish(
//                           color: AppColor.darkBlue,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         onTap: () {
//                           // Handle location change, e.g., open map picker or bottom sheet
//                           print('Change location tapped!');
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 17),
//                 Text(
//                   '${productListData.data?.items.length}+ Results',
//                   style: GoogleFont.Mulish(
//                     fontSize: 14,
//                     color: AppColor.lightGray2,
//                   ),
//                 ),
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   itemCount: productListData.data?. items.length,
//                   itemBuilder: (context, index) {
//                     final data = productListData.data?.items[index];
//                     return CommonContainer.foodList(
//                       titleWeight: FontWeight.w400,
//                       locations: true,
//                       fontSize: 12,
//                       imageWidth: 130,
//                       imageHeight: 150,
//                       Ad: false,
//                       horizontalDivider: true,
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 ProductDetails(productId: data?.id),
//                           ),
//                         );
//                       },
//                       Verify: data?.shop.isTrusted,
//                       image: data.imageUrl.toString(),
//                       foodName: data.englishName.toString(),
//                       ratingStar: data.shop.rating.toString(),
//                       ratingCount: data.shop.ratingCount.toString(),
//                       offAmound: '₹${data.price}',
//                       oldAmound: '₹3,999',
//                       km: data.shop.distanceKm.toString(),
//                       location:
//                           '${data.shop.englishName} & ${data.shop.category}',
//                     );
//                   },
//                 ),
//
//                 SizedBox(height: 10),
//                 /*      CommonContainer.foodList(
//                   titleWeight: FontWeight.w400,
//                   locations: true,
//                   fontSize: 12,
//                   imageWidth: 130,
//                   imageHeight: 150,
//                   Ad: false,
//                   horizontalDivider: true,
//                   onTap: () {},
//                   Verify: false,
//                   image: AppImages.fanImage2,
//                   foodName: 'Super P400 BLDC Pedestal Fan by Super fan',
//                   ratingStar: '4.5',
//                   ratingCount: '16',
//                   offAmound: '₹2,999',
//                   oldAmound: '₹3,999',
//                   km: '100Mtrs',
//                   location: 'Lkh Electricals & Applicances',
//                 ),
//                 SizedBox(height: 10),
//                 CommonContainer.foodList(
//                   titleWeight: FontWeight.w400,
//                   locations: true,
//                   fontSize: 12,
//                   imageWidth: 130,
//                   imageHeight: 150,
//                   Ad: false,
//                   horizontalDivider: true,
//                   onTap: () {},
//                   Verify: false,
//                   image: AppImages.fanImage3,
//                   foodName: 'Super P400 BLDC Pedestal Fan by Super fan',
//                   ratingStar: '4.5',
//                   ratingCount: '16',
//                   offAmound: '₹2,999',
//                   oldAmound: '₹3,999',
//                   km: '100Mtrs',
//                   location: 'Lkh Electricals & Applicances',
//                 ),
//                 SizedBox(height: 10),
//                 CommonContainer.foodList(
//                   titleWeight: FontWeight.w400,
//                   locations: true,
//                   fontSize: 12,
//                   imageWidth: 130,
//                   imageHeight: 150,
//                   Ad: false,
//                   horizontalDivider: false,
//                   onTap: () {},
//                   Verify: false,
//                   image: AppImages.fanImage4,
//                   foodName: 'Super P400 BLDC Pedestal Fan by Super fan',
//                   ratingStar: '4.5',
//                   ratingCount: '16',
//                   offAmound: '₹2,999',
//                   oldAmound: '₹3,999',
//                   km: '100Mtrs',
//                   location: 'Lkh Electricals & Applicances',
//                 ),*/
//                 /*      CommonContainer.foodList(
//                   titleWeight: FontWeight.w400,
//                   locations: true,
//                   fontSize: 12,
//                   imageWidth: 130,
//                   imageHeight: 150,
//                   Ad: false,
//                   horizontalDivider: true,
//                   onTap: () {},
//                   Verify: false,
//                   image: AppImages.fanImage2,
//                   foodName: 'Super P400 BLDC Pedestal Fan by Super fan',
//                   ratingStar: '4.5',
//                   ratingCount: '16',
//                   offAmound: '₹2,999',
//                   oldAmound: '₹3,999',
//                   km: '100Mtrs',
//                   location: 'Lkh Electricals & Applicances',
//                 ),
//                 SizedBox(height: 10),
//                 CommonContainer.foodList(
//                   titleWeight: FontWeight.w400,
//                   locations: true,
//                   fontSize: 12,
//                   imageWidth: 130,
//                   imageHeight: 150,
//                   Ad: false,
//                   horizontalDivider: true,
//                   onTap: () {},
//                   Verify: false,
//                   image: AppImages.fanImage3,
//                   foodName: 'Super P400 BLDC Pedestal Fan by Super fan',
//                   ratingStar: '4.5',
//                   ratingCount: '16',
//                   offAmound: '₹2,999',
//                   oldAmound: '₹3,999',
//                   km: '100Mtrs',
//                   location: 'Lkh Electricals & Applicances',
//                 ),
//                 SizedBox(height: 10),
//                 CommonContainer.foodList(
//                   titleWeight: FontWeight.w400,
//                   locations: true,
//                   fontSize: 12,
//                   imageWidth: 130,
//                   imageHeight: 150,
//                   Ad: false,
//                   horizontalDivider: false,
//                   onTap: () {},
//                   Verify: false,
//                   image: AppImages.fanImage4,
//                   foodName: 'Super P400 BLDC Pedestal Fan by Super fan',
//                   ratingStar: '4.5',
//                   ratingCount: '16',
//                   offAmound: '₹2,999',
//                   oldAmound: '₹3,999',
//                   km: '100Mtrs',
//                   location: 'Lkh Electricals & Applicances',
//                 ),*/
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
