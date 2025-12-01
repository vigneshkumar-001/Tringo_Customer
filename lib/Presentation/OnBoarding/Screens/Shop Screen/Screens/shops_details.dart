import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/app_loader.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Core/Utility/map_urls.dart';
import 'package:tringo_app/Core/Widgets/Common%20Bottom%20Navigation%20bar/shops_product.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Controller/home_notifier.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Controller/shops_notifier.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Screens/shops_product_list.dart';

import '../../Products/Screens/product_details.dart';

class ShopsDetails extends ConsumerStatefulWidget {
  final String? heroTag; // optional; if null/empty, no hero anim
  final String? image; // optional; falls back to AppImages.imageContainer1
  final String? shopId;
  const ShopsDetails({super.key, this.heroTag, this.image, this.shopId});

  @override
  ConsumerState<ShopsDetails> createState() => _ShopsDetailsState();
}

class _ShopsDetailsState extends ConsumerState<ShopsDetails>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> categoryTabs = [
    {"label": "Mixture"},
    {"label": "Halwa"},
    {"label": "Badam Sweets"},
    {"label": "Milk Sweets"},
  ];
  int selectedIndex = 0;
  int selectedWeight = 0; // default

  late final AnimationController _ac;

  late final Animation<double> aHeader; // back + chip
  late final Animation<double> aChips; // verified + delivery
  late final Animation<double> aTitle; // shop name
  late final Animation<double> aLocation; // address + kms
  late final Animation<double> aActions; // call/whatsapp/map row
  late final Animation<double> aSecondImg; // the right-side image
  late final Animation<double> aOffer; // offer banner
  late final Animation<double> aOfferProducts; // aOfferProducts banner
  late final Animation<double> aSnacksFliter; // aOfferProducts banner
  late final Animation<double> aSnacksBox; // aOfferProducts banner
  late final Animation<double> aHorizonalDivider; // aOfferProducts banner
  late final Animation<double> aPeopleViewText; // aOfferProducts banner
  late final Animation<double> aPeopleViewScroller; // aOfferProducts banner
  late final Animation<double> aReviewText; // aOfferProducts banner
  late final Animation<double> aRating; // aOfferProducts banner
  late final Animation<double> aTotalReviewText; // aOfferProducts banner
  late final Animation<double> aReviewBox; // aOfferProducts banner

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      reverseDuration: const Duration(milliseconds: 1000),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(shopsNotifierProvider.notifier)
          .showSpecificShopDetails(shopId: widget.shopId ?? '');
    });

    final curve = CurvedAnimation(
      parent: _ac,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    aHeader = CurvedAnimation(parent: curve, curve: const Interval(0.00, 0.22));
    aChips = CurvedAnimation(parent: curve, curve: const Interval(0.08, 0.30));
    aTitle = CurvedAnimation(
      parent: curve,
      curve: const Interval(0.16, 0.34),
    ); // <-- FIXED
    aLocation = CurvedAnimation(
      parent: curve,
      curve: const Interval(0.24, 0.42),
    );
    aActions = CurvedAnimation(
      parent: curve,
      curve: const Interval(0.32, 0.50),
    );
    aSecondImg = CurvedAnimation(
      parent: curve,
      curve: const Interval(0.40, 0.58),
    );

    // Mid section (offer + list header + filters)
    aOffer = CurvedAnimation(parent: curve, curve: const Interval(0.50, 0.66));
    aOfferProducts = CurvedAnimation(
      parent: curve,
      curve: const Interval(0.54, 0.70),
    );
    aSnacksFliter = CurvedAnimation(
      parent: curve,
      curve: const Interval(0.58, 0.74),
    );
    aSnacksBox = CurvedAnimation(
      parent: curve,
      curve: const Interval(0.62, 0.78),
    );

    // Dividers + “People also viewed”
    aHorizonalDivider = CurvedAnimation(
      parent: curve,
      curve: const Interval(0.66, 0.80),
    );
    aPeopleViewText = CurvedAnimation(
      parent: curve,
      curve: const Interval(0.70, 0.84),
    );
    aPeopleViewScroller = CurvedAnimation(
      parent: curve,
      curve: const Interval(0.74, 0.88),
    );

    // Reviews block
    aReviewText = CurvedAnimation(
      parent: curve,
      curve: const Interval(0.78, 0.90),
    );
    aRating = CurvedAnimation(parent: curve, curve: const Interval(0.80, 0.92));
    aTotalReviewText = CurvedAnimation(
      parent: curve,
      curve: const Interval(0.82, 0.94),
    );
    aReviewBox = CurvedAnimation(
      parent: curve,
      curve: const Interval(0.84, 1.00),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _ac.forward());
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  Widget _staggerFromTop(
    Animation<double> a,
    Widget child, {
    double dy = -0.15,
  }) {
    return AnimatedBuilder(
      animation: a,
      builder: (context, _) {
        return Opacity(
          opacity: a.value,
          child: Transform.translate(
            offset: Offset(0, (1 - a.value) * dy * 100), // slides down
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
    final stateS = ref.watch(homeNotifierProvider);

    if (state.isLoading) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }
    final shopsData = state.shopDetailsResponse;
    if (shopsData == null || shopsData.data == null) {
      return const Scaffold(body: Center(child: Text('No data')));
    }
    final double w = MediaQuery.of(context).size.width;
    // gift size scales with screen width (max 120)
    final double giftSize = (w * 0.25).clamp(80.0, 120.0);

    final bool useHero = (widget.heroTag != null && widget.heroTag!.isNotEmpty);
    final String imagePath = widget.image ?? AppImages.imageContainer1;

    final services = shopsData.data?.services ?? [];
    final products = shopsData.data?.products ?? [];

    final hasServices = services.isNotEmpty;
    final hasProducts = products.isNotEmpty;

    final Widget bigImage = ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(imagePath, height: 230, width: 310, fit: BoxFit.cover),
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [AppColor.white, AppColor.whiteSmoke],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      children: [
                        _staggerFromTop(
                          aHeader,
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                CommonContainer.leftSideArrow(
                                  onTap: () => Navigator.pop(context),
                                ),
                                Spacer(),
                                CommonContainer.gradientContainer(
                                  text:
                                      shopsData.data?.category.toString() ?? '',
                                  textColor: AppColor.blue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        Column(
                          children: [
                            // Chips
                            _staggerFromTop(
                              aChips,
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    shopsData.data?.isTrusted == true
                                        ? CommonContainer.verifyTick()
                                        : SizedBox.shrink(),
                                    const SizedBox(width: 10),
                                    shopsData.data?.doorDelivery == true
                                        ? CommonContainer.doorDelivery()
                                        : SizedBox.shrink(),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 12),

                            // Title
                            _staggerFromTop(
                              aTitle,
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  shopsData.data?.englishName.toString() ?? '',
                                  style: GoogleFont.Mulish(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 14),

                            // Location
                            _staggerFromTop(
                              aLocation,
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      AppImages.locationImage,
                                      height: 15,
                                      color: AppColor.lightGray2,
                                    ),
                                    SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        '${shopsData.data?.addressEn.toString()},${shopsData.data?.state.toString()},${shopsData.data?.country.toString()} ',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '5Kms',
                                      style: GoogleFont.Mulish(
                                        fontWeight: FontWeight.w700,
                                        color: AppColor.lightGray3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 27),

                            // Actions row
                            _staggerFromTop(
                              aActions,
                              SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                scrollDirection: Axis.horizontal,
                                child: CommonContainer.callNowButton(
                                  callOnTap: () async {
                                    await MapUrls.openDialer(
                                      context,
                                      shopsData.data?.primaryPhone,
                                    );
                                  },
                                  callImage: AppImages.callImage,
                                  callText: 'Call Now',

                                  mapOnTap: () {
                                    MapUrls.openMap(
                                      context: context,
                                      latitude:
                                          shopsData.data?.gpsLatitude
                                              .toString() ??
                                          '',
                                      longitude:
                                          shopsData.data?.gpsLongitude
                                              .toString() ??
                                          '',
                                    );
                                  },
                                  messageOnTap: () {
                                    ref
                                        .read(homeNotifierProvider.notifier)
                                        .putEnquiry(
                                          context: context,
                                          serviceId: '',
                                          productId: '',
                                          message: '',
                                          shopId:
                                              shopsData.data?.id.toString() ??
                                              '',
                                        );
                                  },
                                  whatsAppIcon: true,
                                  whatsAppOnTap: () {
                                    MapUrls.openWhatsapp(
                                      message: 'hi',
                                      context: context,
                                      phone:
                                          shopsData.data?.primaryPhone
                                              .toString() ??
                                          '',
                                    );
                                  },
                                  messageLoading: stateS.isEnquiryLoading,
                                  MessageIcon: true,
                                  mapText: 'Map',
                                  mapImage: AppImages.locationImage,
                                  callIconSize: 21,
                                  callTextSize: 16,
                                  mapIconSize: 21,
                                  mapTextSize: 16,
                                  messagesIconSize: 23,
                                  whatsAppIconSize: 23,
                                  fireIconSize: 23,
                                  callNowPadding: EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 12,
                                  ),
                                  mapBoxPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  iconContainerPadding: EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 13,
                                  ),
                                  messageContainer: true,
                                  mapBox: true,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // SingleChildScrollView(
                            //   physics: BouncingScrollPhysics(),
                            //   padding: EdgeInsets.symmetric(horizontal: 16),
                            //   scrollDirection: Axis.horizontal,
                            //   child: Row(
                            //     children: [
                            //       Stack(
                            //         children: [
                            //           Image.asset(
                            //             AppImages.imageContainer2,
                            //             height: 250,
                            //             width: 310,
                            //           ),
                            //
                            //           Positioned(
                            //             top: 20,
                            //             left: 15,
                            //             child: Container(
                            //               padding: const EdgeInsets.symmetric(
                            //                 horizontal: 8,
                            //                 vertical: 4,
                            //               ),
                            //               decoration: BoxDecoration(
                            //                 color: AppColor.white,
                            //                 borderRadius: BorderRadius.circular(
                            //                   30,
                            //                 ),
                            //               ),
                            //               child: Row(
                            //                 mainAxisSize: MainAxisSize.min,
                            //                 children: [
                            //                   Text(
                            //                     '4.5',
                            //                     style: GoogleFont.Mulish(
                            //                       fontWeight: FontWeight.bold,
                            //                       fontSize: 14,
                            //                       color: AppColor.darkBlue,
                            //                     ),
                            //                   ),
                            //                   const SizedBox(width: 5),
                            //                   Image.asset(
                            //                     AppImages.starImage,
                            //                     height: 9,
                            //                     color: AppColor.green,
                            //                   ),
                            //                   const SizedBox(width: 5),
                            //                   Container(
                            //                     width: 1.5,
                            //                     height: 11,
                            //                     decoration: BoxDecoration(
                            //                       color: AppColor.darkBlue
                            //                           .withOpacity(0.2),
                            //                       borderRadius:
                            //                           BorderRadius.circular(1),
                            //                     ),
                            //                   ),
                            //                   const SizedBox(width: 5),
                            //                   Text(
                            //                     '16',
                            //                     style: GoogleFont.Mulish(
                            //                       fontSize: 12,
                            //                       color: AppColor.darkBlue,
                            //                     ),
                            //                   ),
                            //                 ],
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            SizedBox(
                              height: 260,
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                scrollDirection: Axis.horizontal,
                                itemCount: shopsData.data?.media?.length,
                                itemBuilder: (context, index) {
                                  final data = shopsData.data?.media?[index];
                                  return Row(
                                    children: [
                                      Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadiusGeometry.circular(
                                                    20,
                                                  ),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    data?.url?.toString() ?? '',
                                                height: 250,
                                                width: 310,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                      height: 250,
                                                      width: 310,
                                                      color: Colors.grey
                                                          .withOpacity(0.2),
                                                    ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(
                                                          Icons.broken_image,
                                                        ),
                                              ),
                                            ),
                                          ),
                                          if (index == 0)
                                            Positioned(
                                              top: 20,
                                              left: 15,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColor.white,
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      shopsData
                                                              .data
                                                              ?.averageRating
                                                              .toString() ??
                                                          '',
                                                      style: GoogleFont.Mulish(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color:
                                                            AppColor.darkBlue,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Image.asset(
                                                      AppImages.starImage,
                                                      height: 9,
                                                      color: AppColor.green,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Container(
                                                      width: 1.5,
                                                      height: 11,
                                                      decoration: BoxDecoration(
                                                        color: AppColor.darkBlue
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              1,
                                                            ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      shopsData
                                                              .data
                                                              ?.reviewCount
                                                              .toString() ??
                                                          '',
                                                      style: GoogleFont.Mulish(
                                                        fontSize: 12,
                                                        color:
                                                            AppColor.darkBlue,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 25),

                            _staggerFromTop(
                              aOffer,
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                ),
                                child: Stack(
                                  clipBehavior:
                                      Clip.none, // allow gift to overflow above
                                  children: [
                                    // Base pill: NOT positioned → Stack takes this size (auto height)
                                    Container(
                                      padding: EdgeInsets.fromLTRB(
                                        24,
                                        8,
                                        giftSize + 70,
                                        18,
                                      ),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            AppImages.surpriseOffer,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          begin: Alignment.center,
                                          end: Alignment.centerRight,
                                          colors: [
                                            AppColor.lightMintGreen,
                                            AppColor.lightMintGreen.withOpacity(
                                              0.5,
                                            ),
                                            // AppColor.lightMintGreen,
                                            AppColor.whiteSmoke.withOpacity(
                                              0.99,
                                            ),
                                            AppColor.whiteSmoke.withOpacity(
                                              0.99,
                                            ),
                                          ],
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize
                                            .min, // 👈 auto height from content
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Surprise Offer',
                                            style: GoogleFont.Mulish(
                                              fontSize: 22,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              shadows: const [
                                                Shadow(
                                                  offset: Offset(1, 3),
                                                  blurRadius: 10,
                                                  color: Colors.black38,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            'Unlock by near the shop',
                                            style: GoogleFont.Mulish(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Gift image overlapping on top-right
                                    Positioned(
                                      right: 0,
                                      top:
                                          -giftSize *
                                          0.22, // slight lift above pill
                                      child: SizedBox(
                                        height: 120,
                                        width: 110,
                                        child: Image.asset(
                                          AppImages.surpriseOfferGift,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 34),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasServices) ...[
                    _staggerFromTop(
                      aOfferProducts,
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              AppImages.fireImage,
                              height: 35,
                              color: AppColor.darkBlue,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Offer Services',
                              style: GoogleFont.Mulish(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: AppColor.darkBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _staggerFromTop(
                      aSnacksFliter,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 20,
                        ),
                        child: Row(
                          children: List.generate(
                            shopsData.data?.serviceTags?.length ?? 0,
                            (index) {
                              final isSelected = selectedIndex == index;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: CommonContainer.categoryChip(
                                  rightSideArrow: true,
                                  ContainerColor: isSelected
                                      ? AppColor.white
                                      : Colors.transparent,
                                  BorderColor: isSelected
                                      ? AppColor.brightGray
                                      : AppColor.brightGray,
                                  TextColor: isSelected
                                      ? AppColor.lightGray2
                                      : AppColor.lightGray2,
                                  shopsData.data?.serviceTags?[index].label ??
                                      '',
                                  isSelected: isSelected,
                                  onTap: () {
                                    setState(() => selectedIndex = index);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    _staggerFromTop(
                      aSnacksBox,
                      Stack(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: shopsData.data?.services?.length,
                            itemBuilder: (context, index) {
                              final data = shopsData.data?.services?[index];
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColor.white.withOpacity(0.5),
                                      AppColor.white.withOpacity(0.3),
                                      AppColor.white,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    CommonContainer.foodList(
                                      imageWidth: 130,
                                      image:
                                          data?.primaryImageUrl.toString() ??
                                          '',
                                      foodName:
                                          data?.englishName.toString() ?? '',
                                      ratingStar: data?.rating.toString() ?? '',
                                      ratingCount:
                                          data?.reviewCount.toString() ?? '',
                                      offAmound:
                                          '₹${data?.startsAt.toString() ?? ''}',
                                      oldAmound:
                                          '₹${data?.offerPrice.toString() ?? ''}',
                                      km: '',
                                      location: '',
                                      Verify: false,
                                      locations: false,
                                      weight: true,
                                      horizontalDivider: true,
                                      // weightOptions: const ['300Gm', '500Gm'],
                                      selectedWeightIndex: selectedWeight,
                                      onWeightChanged: (i) =>
                                          setState(() => selectedWeight = i),
                                    ),

                                    SizedBox(height: 35),
                                  ],
                                ),
                              );
                            },
                          ),

                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.white.withOpacity(
                                      0.9,
                                    ), // white shadow
                                    blurRadius: 80,
                                    spreadRadius: 40,
                                    offset: const Offset(
                                      0,
                                      0,
                                    ), // shadow on all sides
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'View All',
                                    style: GoogleFont.Mulish(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  CommonContainer.rightSideArrowButton(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ShopsProduct(
                                            initialIndex: 2,
                                            shopId: widget.shopId,
                                          ),
                                          // ShopsProductList(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),
                    _staggerFromTop(
                      aHorizonalDivider,
                      CommonContainer.horizonalDivider(),
                    ),
                  ] else if (hasProducts) ...[
                    _staggerFromTop(
                      aOfferProducts,
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              AppImages.fireImage,
                              height: 35,
                              color: AppColor.darkBlue,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Offer Products',
                              style: GoogleFont.Mulish(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: AppColor.darkBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _staggerFromTop(
                      aSnacksFliter,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 20,
                        ),
                        child: Row(
                          children: List.generate(
                            shopsData.data?.productCategories?.length ?? 0,
                            (index) {
                              final isSelected = selectedIndex == index;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: CommonContainer.categoryChip(
                                  rightSideArrow: true,
                                  ContainerColor: isSelected
                                      ? AppColor.white
                                      : Colors.transparent,
                                  BorderColor: isSelected
                                      ? AppColor.brightGray
                                      : AppColor.brightGray,
                                  TextColor: isSelected
                                      ? AppColor.lightGray2
                                      : AppColor.lightGray2,
                                  shopsData
                                          .data
                                          ?.productCategories?[index]
                                          .label
                                          .toString() ??
                                      '',
                                  isSelected: isSelected,
                                  onTap: () {
                                    setState(() => selectedIndex = index);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    _staggerFromTop(
                      aSnacksBox,
                      Stack(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: shopsData.data?.products?.length,
                            itemBuilder: (context, index) {
                              final data = shopsData.data?.products?[index];
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColor.white.withOpacity(0.5),
                                      AppColor.white.withOpacity(0.3),
                                      AppColor.white,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    CommonContainer.foodList(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProductDetails(
                                                  productId: data?.id,
                                                ),
                                          ),
                                        );
                                      },
                                      imageWidth: 130,
                                      image: data?.imageUrl.toString() ?? '',
                                      foodName:
                                          data?.englishName.toString() ?? '',
                                      ratingStar: data?.rating.toString() ?? '',
                                      ratingCount:
                                          data?.ratingCount.toString() ?? '',
                                      offAmound:
                                          '₹${data?.price.toString() ?? ''}',
                                      oldAmound:
                                          '₹${data?.offerPrice.toString() ?? ''}',
                                      km: '',
                                      location: '',
                                      Verify: false,
                                      locations: false,
                                      weight: true,
                                      horizontalDivider: true,
                                      // weightOptions: const ['300Gm', '500Gm'],
                                      selectedWeightIndex: selectedWeight,
                                      onWeightChanged: (i) =>
                                          setState(() => selectedWeight = i),
                                    ),

                                    SizedBox(height: 35),
                                  ],
                                ),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.white.withOpacity(
                                      0.9,
                                    ), // white shadow
                                    blurRadius: 80,
                                    spreadRadius: 40,
                                    offset: const Offset(
                                      0,
                                      0,
                                    ), // shadow on all sides
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'View All',
                                    style: GoogleFont.Mulish(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  CommonContainer.rightSideArrowButton(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ShopsProduct(
                                            category: shopsData.data?.category
                                                .toString(),
                                            englishName: shopsData
                                                .data
                                                ?.englishName
                                                .toString(),
                                            isTrusted:
                                                shopsData.data?.isTrusted,
                                            shopImageUrl:
                                                shopsData.data?.media?[0].url,
                                            initialIndex: 2,
                                            shopId: widget.shopId,
                                          ),
                                          // ShopsProductList(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),
                    _staggerFromTop(
                      aHorizonalDivider,
                      CommonContainer.horizonalDivider(),
                    ),
                  ],

                  SizedBox(height: 30),
                  // _staggerFromTop(
                  //   aPeopleViewText,
                  //   Padding(
                  //     padding: const EdgeInsets.symmetric(horizontal: 15),
                  //     child: Text(
                  //       'People also viewed',
                  //       style: GoogleFont.Mulish(
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 22,
                  //         color: AppColor.darkBlue,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 20),
                  // _staggerFromTop(
                  //   aPeopleViewScroller,
                  //   SingleChildScrollView(
                  //     physics: BouncingScrollPhysics(),
                  //     padding: EdgeInsets.symmetric(horizontal: 6),
                  //     scrollDirection: Axis.horizontal,
                  //     child: Row(
                  //       children: [
                  //         CommonContainer.shopPeopleView(
                  //           onTap: () {},
                  //           Images: AppImages.shopContainer3,
                  //           shopName: 'Zam Zam Sweets',
                  //           locationName: '12, 2, Tirupparankunram Rd, kunram ',
                  //           km: '5Kms',
                  //           ratingStar: '4.5',
                  //           ratingCound: '16',
                  //           time: '9Pm',
                  //         ),
                  //         CommonContainer.shopPeopleView(
                  //           onTap: () {},
                  //           Images: AppImages.shopContainer5,
                  //           shopName: 'JMS Bhagavathi Amman Sweets',
                  //           locationName: '12, 2, Tirupparankunram Rd, kunram ',
                  //           km: '5Kms',
                  //           ratingStar: '4.5',
                  //           ratingCound: '16',
                  //           time: '9Pm',
                  //         ),
                  //         CommonContainer.shopPeopleView(
                  //           onTap: () {},
                  //           Images: AppImages.shopContainer3,
                  //           shopName: 'Zam Zam Sweets',
                  //           locationName: '12, 2, Tirupparankunram Rd, kunram ',
                  //           km: '5Kms',
                  //           ratingStar: '4.5',
                  //           ratingCound: '16',
                  //           time: '9Pm',
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 45),
                  // _staggerFromTop(
                  //   aHorizonalDivider,
                  //   CommonContainer.horizonalDivider(),
                  // ),
                  // SizedBox(height: 45),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _staggerFromTop(
                          aReviewText,
                          Row(
                            children: [
                              Image.asset(
                                AppImages.reviewImage,
                                height: 27.08,
                                width: 26,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Reviews',
                                style: GoogleFont.Mulish(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 21),
                        _staggerFromTop(
                          aRating,
                          Row(
                            children: [
                              Text(
                                '4.5',
                                style: GoogleFont.Mulish(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 33,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(width: 10),
                              Image.asset(
                                AppImages.starImage,
                                height: 30,
                                color: AppColor.green,
                              ),
                            ],
                          ),
                        ),
                        _staggerFromTop(
                          aTotalReviewText,
                          Text(
                            'Based on 58 reviews',
                            style: GoogleFont.Mulish(
                              color: AppColor.lightGray3,
                            ),
                          ),
                        ),

                        SizedBox(height: 20),
                        _staggerFromTop(
                          aReviewBox,
                          CommonContainer.reviewBox(),
                        ),

                        SizedBox(height: 17),
                        _staggerFromTop(
                          aReviewBox,
                          CommonContainer.reviewBox(),
                        ),
                        SizedBox(height: 78),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Core/Const/app_logger.dart';
import 'package:tringo_app/Core/Utility/app_loader.dart';
import 'package:tringo_app/Core/Widgets/Common%20Bottom%20Navigation%20bar/shops_product.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Controller/shops_notifier.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/shops_product_list.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/common_container.dart';

class ShopsDetails extends ConsumerStatefulWidget {
  final String? heroTag; // optional; if null/empty, no hero anim
  final String? image; // optional; falls back to AppImages.imageContainer1
  final String? shopId;

  const ShopsDetails({super.key, this.heroTag, this.image, this.shopId});

  @override
  ConsumerState<ShopsDetails> createState() => _ShopsDetailsState();
}

class _ShopsDetailsState extends ConsumerState<ShopsDetails>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> categoryTabs = [
    {"label": "Mixture"},
    {"label": "Halwa"},
    {"label": "Badam Sweets"},
    {"label": "Milk Sweets"},
  ];
  int selectedIndex = 0;
  int selectedWeight = 0; // default

  @override
  void initState() {
    super.initState();

    AppLogger.log.i(widget.shopId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(shopsNotifierProvider.notifier)
          .showSpecificShopDetails(shopId: widget.shopId ?? '');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Widget _staggerFromTop(
  //   Animation<double> a,
  //   Widget child, {
  //   double dy = -0.15,
  // }) {
  //   return AnimatedBuilder(
  //     animation: a,
  //     builder: (context, _) {
  //       return Opacity(
  //         opacity: a.value,
  //         child: Transform.translate(
  //           offset: Offset(0, (1 - a.value) * dy * 100), // slides down
  //           child: child,
  //         ),
  //       );
  //     },
  //     child: child,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopsNotifierProvider);

    if (state.isLoading) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }

    final shopsData = state.shopDetailsResponse;
    if (shopsData == null || shopsData.data == null) {
      return const Scaffold(body: Center(child: Text('No data')));
    }

    final shops = shopsData.data!;
    final double w = MediaQuery.of(context).size.width;
    final double giftSize = (w * 0.25).clamp(80.0, 120.0);
    final bool useHero = widget.heroTag != null && widget.heroTag!.isNotEmpty;
    final String imagePath = widget.image ?? AppImages.imageContainer1;

    final List itemsToShow = [];
    if (shops.services != null && shops!.services!.isNotEmpty) {
      itemsToShow.addAll(shops.services!);
    } else if (shops.products != null && shops!.products!.isNotEmpty) {
      itemsToShow.addAll(shops.products!);
    }

    final Widget bigImage = ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(imagePath, height: 230, width: 310, fit: BoxFit.cover),
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [AppColor.white, AppColor.whiteSmoke],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              CommonContainer.leftSideArrow(
                                onTap: () => Navigator.pop(context),
                              ),
                              Spacer(),
                              CommonContainer.gradientContainer(
                                text: shops.category.toString(),
                                textColor: AppColor.blue,
                                fontWeight: FontWeight.w700,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 10),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Chips
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  shops?.isTrusted == true
                                      ? CommonContainer.verifyTick()
                                      : SizedBox.shrink(),
                                  const SizedBox(width: 10),
                                  shops?.doorDelivery == true
                                      ? CommonContainer.doorDelivery()
                                      : SizedBox.shrink(),
                                ],
                              ),
                            ),

                            SizedBox(height: 12),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                shops?.englishName.toString() ?? '',
                                style: GoogleFont.Mulish(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ),

                            SizedBox(height: 14),

                            // Location
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    AppImages.locationImage,
                                    height: 15,
                                    color: AppColor.lightGray2,
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      '${shops?.addressEn}, ${shops?.state} ${shops?.country}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '5Kms',
                                    style: GoogleFont.Mulish(
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.lightGray3,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 27),

                            SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              child: CommonContainer.callNowButton(
                                callImage: AppImages.callImage,
                                callText: 'Call Now',
                                whatsAppIcon: true,
                                whatsAppOnTap: () {},
                                messageOnTap: () {},
                                MessageIcon: true,
                                mapText: 'Map',
                                mapImage: AppImages.locationImage,
                                callIconSize: 21,
                                callTextSize: 16,
                                mapIconSize: 21,
                                mapTextSize: 16,
                                messagesIconSize: 23,
                                whatsAppIconSize: 23,
                                fireIconSize: 23,
                                callNowPadding: EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 12,
                                ),
                                mapBoxPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                iconContainerPadding: EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 13,
                                ),
                                messageContainer: true,
                                mapBox: true,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // SingleChildScrollView(
                            //   physics: BouncingScrollPhysics(),
                            //   padding: EdgeInsets.symmetric(horizontal: 16),
                            //   scrollDirection: Axis.horizontal,
                            //   child:
                            // ),
                            SizedBox(
                              height: 250,
                              child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: shops?.media?.length,
                                itemBuilder: (context, index) {
                                  final data = shops?.media?[index];
                                  return Row(
                                    children: [
                                      Stack(
                                        children: [
                                          useHero
                                              ? Hero(
                                                  tag: widget.heroTag!,
                                                  child: bigImage,
                                                )
                                              : bigImage,
                                          // rating pill
                                          Positioned(
                                            top: 20,
                                            left: 15,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColor.white,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '4.5',
                                                    style: GoogleFont.Mulish(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: AppColor.darkBlue,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Image.asset(
                                                    AppImages.starImage,
                                                    height: 9,
                                                    color: AppColor.green,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Container(
                                                    width: 1.5,
                                                    height: 11,
                                                    decoration: BoxDecoration(
                                                      color: AppColor.darkBlue
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            1,
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    '16',
                                                    style: GoogleFont.Mulish(
                                                      fontSize: 12,
                                                      color: AppColor.darkBlue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(width: 10),

                                      // Second image
                                      Image.network(
                                        data?.url.toString() ?? '',
                                        height: 250,
                                        width: 310,
                                      ),

                                      const SizedBox(width: 10),

                                      // Fourth image
                                      // _staggerFromTop(
                                      //   aSecondImg,
                                      //   Image.asset(
                                      //     AppImages.imageContainer4,
                                      //     height: 250,
                                      //     width: 310,
                                      //   ),
                                      // ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 25),

                            // Surprise Offer Banner (gift overlaps the pill)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                              ),
                              child: Stack(
                                clipBehavior:
                                    Clip.none, // allow gift to overflow above
                                children: [
                                  // Base pill: NOT positioned → Stack takes this size (auto height)
                                  Container(
                                    padding: EdgeInsets.fromLTRB(
                                      24,
                                      8,
                                      giftSize + 70,
                                      18,
                                    ),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          AppImages.surpriseOffer,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        begin: Alignment.center,
                                        end: Alignment.centerRight,
                                        colors: [
                                          AppColor.lightMintGreen,
                                          AppColor.lightMintGreen.withOpacity(
                                            0.5,
                                          ),
                                          // AppColor.lightMintGreen,
                                          AppColor.whiteSmoke.withOpacity(0.99),
                                          AppColor.whiteSmoke.withOpacity(0.99),
                                        ],
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize
                                          .min, // 👈 auto height from content
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Surprise Offer',
                                          style: GoogleFont.Mulish(
                                            fontSize: 22,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            shadows: const [
                                              Shadow(
                                                offset: Offset(1, 3),
                                                blurRadius: 10,
                                                color: Colors.black38,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          'Unlock by near the shop',
                                          style: GoogleFont.Mulish(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Gift image overlapping on top-right
                                  Positioned(
                                    right: 0,
                                    top:
                                        -giftSize *
                                        0.22, // slight lift above pill
                                    child: SizedBox(
                                      height: 120,
                                      width: 110,
                                      child: Image.asset(
                                        AppImages.surpriseOfferGift,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 34),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (itemsToShow != null && itemsToShow.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            AppImages.fireImage,
                            height: 35,
                            color: AppColor.darkBlue,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            (shops?.services?.isNotEmpty ?? false)
                                ? 'Offer Services'
                                : (shops?.products?.isNotEmpty ?? false)
                                ? 'Offer Products'
                                : 'No Offers',

                            style: GoogleFont.Mulish(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: AppColor.darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),


                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 20,
                      ),
                      child: Row(
                        children: List.generate(
                          shops.productCategories?.length ?? 0,
                          (index) {
                            final isSelected = selectedIndex == index;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: CommonContainer.categoryChip(
                                rightSideArrow: true,
                                ContainerColor: isSelected
                                    ? AppColor.white
                                    : Colors.transparent,
                                BorderColor: AppColor.brightGray,
                                TextColor: AppColor.lightGray2,
                                shops.productCategories?[index].label
                                        .toString() ??
                                    '',
                                isSelected: isSelected,
                                onTap: () =>
                                    setState(() => selectedIndex = index),
                              ),
                            );
                          },
                        ),
                      ),
                    ),


                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: itemsToShow.length,
                      itemBuilder: (context, index) {
                        final data = itemsToShow[index];
                        final price =
                            shops.services != null && shops.services!.isNotEmpty
                            ? data?.startsAt
                            : data?.price;

                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          child: CommonContainer.foodList(
                            imageWidth: 130,
                            image: data.imageUrl.toString() ?? '',
                            foodName: data?.englishName ?? '',
                            ratingStar: '4.5',
                            ratingCount: '16',
                            offAmound: '₹${price ?? 0}',
                            oldAmound:
                                (data?.price != null &&
                                    data!.price != data.offerPrice)
                                ? '₹${data.price}'
                                : '',
                            km: '',
                            location: '',
                            Verify: false,
                            locations: false,
                            weight: true,
                            horizontalDivider: true,
                            weightOptions: const ['300Gm', '500Gm'],
                            selectedWeightIndex: selectedWeight,
                            onWeightChanged: (i) =>
                                setState(() => selectedWeight = i),
                          ),
                        );
                      },
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.white.withOpacity(
                              0.9,
                            ), // white shadow
                            blurRadius: 80,
                            spreadRadius: 40,
                            offset: const Offset(
                              0,
                              0,
                            ), // shadow on all sides
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'View All',
                            style: GoogleFont.Mulish(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColor.darkBlue,
                            ),
                          ),
                          const SizedBox(width: 10),
                          CommonContainer.rightSideArrowButton(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ShopsProduct(initialIndex: 2),
                                  // ShopsProductList(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Stack(
                  //   children: [
                  //     Container(
                  //       padding: EdgeInsets.symmetric(horizontal: 15),
                  //       decoration: BoxDecoration(
                  //         gradient: LinearGradient(
                  //           colors: [
                  //             AppColor.white.withOpacity(0.5),
                  //             AppColor.white.withOpacity(0.3),
                  //             AppColor.white,
                  //           ],
                  //           begin: Alignment.topCenter,
                  //           end: Alignment.bottomCenter,
                  //         ),
                  //       ),
                  //       child: Column(
                  //         children: [
                  //           CommonContainer.foodList(
                  //             imageWidth: 130,
                  //             image: AppImages.snacks1,
                  //             foodName: '',
                  //             ratingStar: '4.5',
                  //             ratingCount: '16',
                  //             offAmound: '₹79',
                  //             oldAmound: '₹110',
                  //             km: '',
                  //             location: '',
                  //             Verify: false,
                  //             locations: false,
                  //             weight: true,
                  //             horizontalDivider: true,
                  //             weightOptions: const ['300Gm', '500Gm'],
                  //             selectedWeightIndex: selectedWeight,
                  //             onWeightChanged: (i) =>
                  //                 setState(() => selectedWeight = i),
                  //           ),
                  //
                  //           SizedBox(height: 35),
                  //         ],
                  //       ),
                  //     ),
                  //     Positioned(
                  //       bottom: 0,
                  //       left: 0,
                  //       right: 0,
                  //       child: Container(
                  //         padding: const EdgeInsets.symmetric(
                  //           vertical: 20,
                  //           horizontal: 20,
                  //         ),
                  //         decoration: BoxDecoration(
                  //           boxShadow: [
                  //             BoxShadow(
                  //               color: AppColor.white.withOpacity(
                  //                 0.9,
                  //               ), // white shadow
                  //               blurRadius: 80,
                  //               spreadRadius: 40,
                  //               offset: const Offset(
                  //                 0,
                  //                 0,
                  //               ), // shadow on all sides
                  //             ),
                  //           ],
                  //         ),
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             Text(
                  //               'View All',
                  //               style: GoogleFont.Mulish(
                  //                 fontWeight: FontWeight.bold,
                  //                 fontSize: 16,
                  //                 color: AppColor.darkBlue,
                  //               ),
                  //             ),
                  //             const SizedBox(width: 10),
                  //             CommonContainer.rightSideArrowButton(
                  //               onTap: () {
                  //                 Navigator.push(
                  //                   context,
                  //                   MaterialPageRoute(
                  //                     builder: (context) =>
                  //                         ShopsProduct(initialIndex: 2),
                  //                     // ShopsProductList(),
                  //                   ),
                  //                 );
                  //               },
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(height: 40),
                  //
                  //   CommonContainer.horizonalDivider(),
                  SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      'People also viewed',
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: AppColor.darkBlue,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  // _staggerFromTop(
                  //   aPeopleViewScroller,
                  //   SingleChildScrollView(
                  //     physics: BouncingScrollPhysics(),
                  //     padding: EdgeInsets.symmetric(horizontal: 6),
                  //     scrollDirection: Axis.horizontal,
                  //     child: Row(
                  //       children: [
                  //         CommonContainer.shopPeopleView(
                  //           onTap: () {},
                  //           Images: AppImages.shopContainer3,
                  //           shopName: 'Zam Zam Sweets',
                  //           locationName: '12, 2, Tirupparankunram Rd, kunram ',
                  //           km: '5Kms',
                  //           ratingStar: '4.5',
                  //           ratingCound: '16',
                  //           time: '9Pm',
                  //         ),
                  //         CommonContainer.shopPeopleView(
                  //           onTap: () {},
                  //           Images: AppImages.shopContainer5,
                  //           shopName: 'JMS Bhagavathi Amman Sweets',
                  //           locationName: '12, 2, Tirupparankunram Rd, kunram ',
                  //           km: '5Kms',
                  //           ratingStar: '4.5',
                  //           ratingCound: '16',
                  //           time: '9Pm',
                  //         ),
                  //         CommonContainer.shopPeopleView(
                  //           onTap: () {},
                  //           Images: AppImages.shopContainer3,
                  //           shopName: 'Zam Zam Sweets',
                  //           locationName: '12, 2, Tirupparankunram Rd, kunram ',
                  //           km: '5Kms',
                  //           ratingStar: '4.5',
                  //           ratingCound: '16',
                  //           time: '9Pm',
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 45),
                  // _staggerFromTop(
                  //   aHorizonalDivider,
                  //   CommonContainer.horizonalDivider(),
                  // ),
                  SizedBox(height: 45),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              AppImages.reviewImage,
                              height: 27.08,
                              width: 26,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Reviews',
                              style: GoogleFont.Mulish(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColor.darkBlue,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 21),

                        Row(
                          children: [
                            Text(
                              '4.5',
                              style: GoogleFont.Mulish(
                                fontWeight: FontWeight.bold,
                                fontSize: 33,
                                color: AppColor.darkBlue,
                              ),
                            ),
                            SizedBox(width: 10),
                            Image.asset(
                              AppImages.starImage,
                              height: 30,
                              color: AppColor.green,
                            ),
                          ],
                        ),

                        Text(
                          'Based on 58 reviews',
                          style: GoogleFont.Mulish(color: AppColor.lightGray3),
                        ),

                        SizedBox(height: 20),

                        CommonContainer.reviewBox(),

                        SizedBox(height: 17),

                        CommonContainer.reviewBox(),

                        SizedBox(height: 78),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
