import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/app_snackbar.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Screens/home_screen.dart';

import '../Model/surprise_offer_response.dart';

class OpenedSurpriseOfferScreen extends StatelessWidget {
  final SurpriseStatusResponse response;
  const OpenedSurpriseOfferScreen({super.key, required this.response});

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$d-$m-$y';
  }

  Widget brokenBanner({double height = 215}) {
    return Container(
      width: double.infinity,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColor.lowGery1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 42,
            color: AppColor.lightGray3,
          ),
          const SizedBox(height: 6),
          Text(
            'Image not available',
            style: GoogleFont.Mulish(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.lightGray3,
            ),
          ),
        ],
      ),
    );
  }

  Widget brokenShopThumb({double h = 130, double w = 115, double radius = 14}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        height: h,
        width: w,
        color: AppColor.lowGery1,
        alignment: Alignment.center,
        child: Icon(
          Icons.broken_image_outlined,
          color: AppColor.lightGray3,
          size: 34,
        ),
      ),
    );
  }

  Widget shopImage({
    required String? imageUrl,
    double height = 130,
    double width = 115,
    double radius = 14,
  }) {
    final url = (imageUrl ?? '').toString().trim();
    final showNetwork = url.isNotEmpty;

    if (!showNetwork) {
      return brokenShopThumb(
        h: height,
        w: width,
        radius: radius,
      ); // ✅ null/empty
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        height: height,
        width: width,
        fit: BoxFit.cover,
        // ✅ invalid/404/network error
        errorBuilder: (_, __, ___) =>
            brokenShopThumb(h: height, w: width, radius: radius),
        // ✅ while loading
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return brokenShopThumb(h: height, w: width, radius: radius);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = response.data;
    final ui = data.ui;

    final shop = data.shop; // nullable
    final offer = data.offer; // nullable

    final screenTitle = ui.screenTitle.isNotEmpty
        ? ui.screenTitle
        : 'Open Offer';
    final codeLabel = ui.codeLabel.isNotEmpty ? ui.codeLabel : 'Offer Code';

    final offerTitle = (offer?.title ?? '').trim();
    final offerShort = (offer?.shortText ?? '').trim();
    final offerDesc = (offer?.description ?? '').trim();
    final validUpto = _formatDate(offer?.validUpto);

    final bannerUrl = (offer?.bannerUrl ?? '').toString().trim();
    final showNetworkBanner = bannerUrl.isNotEmpty;

    final code = (data.code ?? '').toString().trim();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      CommonContainer.leftSideArrow(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      Text(
                        screenTitle,
                        style: GoogleFont.Mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColor.black,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // SHOP CARD
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImages.walletBCImage),
                    ),
                    gradient: LinearGradient(
                      colors: [AppColor.white, AppColor.aquaTint],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15.0,
                                ),
                                child: Row(
                                  children: [
                                    shopImage(
                                      imageUrl: shop?.imageUrl,
                                      height: 130,
                                      width: 115,
                                    ),

                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 30.0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              (shop?.name ?? '-').toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFont.Mulish(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                                color: AppColor.darkBlue,
                                              ),
                                            ),
                                            const SizedBox(height: 6),

                                            Row(
                                              children: [
                                                Image.asset(
                                                  AppImages.locationImage,
                                                  height: 10,
                                                  color: AppColor.lightGray2,
                                                ),
                                                const SizedBox(width: 3),
                                                Flexible(
                                                  child: Text(
                                                    (shop?.city ?? '')
                                                        .toString(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFont.Mulish(
                                                      fontSize: 12,
                                                      color:
                                                          AppColor.lightGray2,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  (shop?.distanceLabel ?? '')
                                                      .toString(),
                                                  style: GoogleFont.Mulish(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: AppColor.lightGray3,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                CommonContainer.greenStarRating(
                                                  ratingStar:
                                                      (shop?.rating ?? 0)
                                                          .toString(),
                                                  ratingCount:
                                                      (shop?.reviewCount ?? 0)
                                                          .toString(),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  (shop?.closeTime ?? '')
                                                          .toString()
                                                          .isEmpty
                                                      ? ''
                                                      : 'Opens Upto ',
                                                  style: GoogleFont.Mulish(
                                                    fontSize: 9,
                                                    color: AppColor.lightGray2,
                                                  ),
                                                ),
                                                Text(
                                                  (shop?.closeTime ?? '')
                                                      .toString(),
                                                  style: GoogleFont.Mulish(
                                                    fontSize: 9,
                                                    color: AppColor.lightGray2,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // OFFER DETAILS TITLE (use ui.primaryText/secondaryText if you want)
                Center(
                  child: Text(
                    ui.primaryText?.toString().trim().isNotEmpty == true
                        ? ui.primaryText!.toString()
                        : 'Offer Details',
                    style: GoogleFont.Mulish(
                      fontSize: 16,
                      color: AppColor.darkBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // OFFER BANNER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: showNetworkBanner
                        ? Image.network(
                            bannerUrl,
                            width: double.infinity,
                            height: 215,
                            fit: BoxFit.cover,
                            // ✅ while loading (optional)
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return brokenBanner(height: 215); // or loader UI
                            },
                            // ✅ if url invalid / 404 / network error
                            errorBuilder: (context, error, stackTrace) {
                              return brokenBanner(height: 215);
                            },
                          )
                        : brokenBanner(height: 215), // ✅ null/empty bannerUrl
                  ),
                ),

                const SizedBox(height: 20),

                // OFFER TEXT BOX
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.lowGery1,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offerTitle.isNotEmpty ? offerTitle : '-',
                          style: GoogleFont.Mulish(
                            fontSize: 20,
                            color: AppColor.darkBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),

                        Text(
                          offerDesc.isNotEmpty ? offerDesc : '-',
                          style: GoogleFont.Mulish(
                            fontSize: 12,
                            color: AppColor.lightGray3,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        if (validUpto.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                'Valid Upto',
                                style: GoogleFont.Mulish(
                                  fontSize: 12,
                                  color: AppColor.lightGray3,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                validUpto,
                                style: GoogleFont.Mulish(
                                  fontSize: 12,
                                  color: AppColor.darkBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // OFFER CODE TITLE (from ui)
                Center(
                  child: Text(
                    codeLabel,
                    style: GoogleFont.Mulish(
                      fontSize: 16,
                      color: AppColor.darkBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // COPY CODE (LONG PRESS)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: GestureDetector(
                      onLongPress: () async {
                        if (code.isEmpty) return;

                        await Clipboard.setData(ClipboardData(text: code));

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          AppSnackBar.success(context, 'Offer code copied');
                          // ScaffoldMessenger.of(context).showSnackBar(
                          // ,
                          // );
                        }
                      },
                      child: DottedBorder(
                        color: AppColor.darkGrey.withOpacity(0.7),
                        strokeWidth: 2,
                        dashPattern: const [4, 2],
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(15),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColor.darkGrey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            code.isNotEmpty ? code : '-',
                            style: GoogleFont.Mulish(
                              fontSize: 20,
                              color: AppColor.darkBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // (Optional) show terms
                if ((offer?.terms ?? '').toString().trim().isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        offer!.terms!.toString(),
                        style: GoogleFont.Mulish(
                          fontSize: 12,
                          color: AppColor.lightGray3,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:tringo_app/Core/Utility/app_Images.dart';
// import 'package:tringo_app/Core/Utility/app_color.dart';
// import 'package:tringo_app/Core/Utility/app_snackbar.dart';
// import 'package:tringo_app/Core/Utility/google_font.dart';
// import 'package:tringo_app/Core/Widgets/common_container.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Screens/home_screen.dart';
//
// import '../Model/surprise_offer_response.dart';
//
// class OpenedSurpriseOfferScreen extends StatelessWidget {
//   final SurpriseStatusResponse response;
//   const OpenedSurpriseOfferScreen({super.key, required this.response});
//
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 15),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 15),
//                   child: Row(
//                     children: [
//                       CommonContainer.leftSideArrow(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => HomeScreen(),
//                             ),
//                           );
//                         },
//                       ),
//                       Spacer(),
//                       Text(
//                         'Unlocked Surprise Offer',
//                         style: GoogleFont.Mulish(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                           color: AppColor.black,
//                         ),
//                       ),
//                       Spacer(),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                       image: AssetImage(AppImages.walletBCImage),
//                     ),
//                     gradient: LinearGradient(
//                       colors: [AppColor.white, AppColor.aquaTint],
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                     ),
//                     borderRadius: BorderRadius.only(
//                       bottomLeft: Radius.circular(25),
//                       bottomRight: Radius.circular(25),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       InkWell(
//                         borderRadius: BorderRadius.circular(24),
//                         onTap: () {},
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 15,
//                           ),
//                           child: Column(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 15.0,
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Image.asset(
//                                       AppImages.shopContainer3,
//                                       height: 130,
//                                       width: 115,
//                                     ),
//
//                                     SizedBox(width: 14),
//                                     Expanded(
//                                       child: Padding(
//                                         padding: const EdgeInsets.only(
//                                           right: 30.0,
//                                         ),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               response.data.shop!.name,
//                                               maxLines: 1,
//                                               overflow: TextOverflow.ellipsis,
//                                               style: GoogleFont.Mulish(
//                                                 fontWeight: FontWeight.w800,
//                                                 fontSize: 16,
//                                                 color: AppColor.darkBlue,
//                                               ),
//                                             ),
//                                             SizedBox(height: 6),
//
//                                             Row(
//                                               children: [
//                                                 Image.asset(
//                                                   AppImages.locationImage,
//                                                   height: 10,
//                                                   color: AppColor.lightGray2,
//                                                 ),
//                                                 SizedBox(width: 3),
//                                                 Flexible(
//                                                   child: Text(
//                                                     response.data.shop!.city,
//                                                     maxLines: 1,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                     style: GoogleFont.Mulish(
//                                                       fontSize: 12,
//                                                       color:
//                                                           AppColor.lightGray2,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 SizedBox(width: 5),
//                                                 Text(
//                                                   response
//                                                           .data
//                                                           .shop
//                                                           ?.distanceLabel
//                                                           .toString() ??
//                                                       '',
//                                                   style: GoogleFont.Mulish(
//                                                     fontWeight: FontWeight.bold,
//                                                     fontSize: 12,
//                                                     color: AppColor.lightGray3,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             SizedBox(height: 10),
//
//                                             Row(
//                                               children: [
//                                                 CommonContainer.greenStarRating(
//                                                   ratingStar:
//                                                       response.data.shop?.rating
//                                                           .toString() ??
//                                                       '',
//                                                   ratingCount:
//                                                       response
//                                                           .data
//                                                           .shop
//                                                           ?.reviewCount
//                                                           .toString() ??
//                                                       '',
//                                                 ),
//                                                 SizedBox(width: 10),
//                                                 Text(
//                                                   'Opens Upto ',
//                                                   style: GoogleFont.Mulish(
//                                                     fontSize: 9,
//                                                     color: AppColor.lightGray2,
//                                                   ),
//                                                 ),
//                                                 Text(
//                                                   response.data.shop?.closeTime
//                                                           .toString() ??
//                                                       '',
//                                                   style: GoogleFont.Mulish(
//                                                     fontSize: 9,
//                                                     color: AppColor.lightGray2,
//                                                     fontWeight: FontWeight.w800,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Center(
//                   child: Text(
//                     'Offer Details',
//                     style: GoogleFont.Mulish(
//                       fontSize: 16,
//                       color: AppColor.darkBlue,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Image.asset(AppImages.image, width: 360, height: 215),
//                 SizedBox(height: 20),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//                     decoration: BoxDecoration(
//                       color: AppColor.lowGery1,
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Buy for Rs.1000 get Rs. 3000',
//                           style: GoogleFont.Mulish(
//                             fontSize: 20,
//                             color: AppColor.darkBlue,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                         SizedBox(height: 5),
//                         Text(
//                           'Nam elementum tempor turpis, vitae pharetra ligula. Mauris id ullamcorper ligula. Morbi efficitur, quam lobortis pharetra consectetur, nisi mi pulvinar eros,',
//                           style: GoogleFont.Mulish(
//                             fontSize: 12,
//                             color: AppColor.lightGray3,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                         SizedBox(height: 5),
//                         Row(
//                           children: [
//                             Text(
//                               'Valid Upto',
//                               style: GoogleFont.Mulish(
//                                 fontSize: 12,
//                                 color: AppColor.lightGray3,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                             SizedBox(width: 10),
//                             Text(
//                               '18-jun-2026',
//                               style: GoogleFont.Mulish(
//                                 fontSize: 12,
//                                 color: AppColor.darkBlue,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 15),
//                 Center(
//                   child: Text(
//                     'Offer Code',
//                     style: GoogleFont.Mulish(
//                       fontSize: 16,
//                       color: AppColor.darkBlue,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 15),
//
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Center(
//                     child: GestureDetector(
//                       onLongPress: () async {
//                         final code = (response.data.code ?? '')
//                             .toString()
//                             .trim();
//                         if (code.isEmpty) return;
//
//                         await Clipboard.setData(ClipboardData(text: code));
//
//                         if (context.mounted) {
//                           ScaffoldMessenger.of(context).hideCurrentSnackBar();
//                           AppSnackBar.success(context, 'Offer code copied');
//                         }
//                       },
//                       child: DottedBorder(
//                         color: AppColor.darkGrey.withOpacity(0.7),
//                         strokeWidth: 2,
//                         dashPattern: const [4, 2],
//                         borderType: BorderType.RRect,
//                         radius: const Radius.circular(15),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             color: AppColor.darkGrey.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           alignment: Alignment.center,
//                           child: Text(
//                             (response.data.code ?? '').toString(),
//                             style: GoogleFont.Mulish(
//                               fontSize: 20,
//                               color: AppColor.darkBlue,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 //
//                 // SizedBox(height: 10),
//                 // Padding(
//                 //   padding: const EdgeInsets.symmetric(
//                 //     horizontal: 10,
//                 //     vertical: 15,
//                 //   ),
//                 //   child: CommonContainer.button(
//                 //     borderRadius: 12,
//                 //     buttonColor: AppColor.darkBlue,
//                 //     imagePath: AppImages.rightSideArrow,
//                 //     onTap: () {},
//                 //     text: Text('View All Unlocked Offers'),
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
