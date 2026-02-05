import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tringo_app/Core/Const/app_logger.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/app_loader.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Core/Utility/map_urls.dart';
import 'package:tringo_app/Core/Widgets/Common%20Bottom%20Navigation%20bar/shops_product.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Controller/home_notifier.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/No%20Data%20Screen/Screen/no_data_screen.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Controller/shops_notifier.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Shop%20Screen/Screens/shops_product_list.dart';

import '../../Products/Screens/product_details.dart';
import '../../Services Screen/Controller/service_notifier.dart';
import '../../Services Screen/Screens/Service_details.dart';
import '../../Services Screen/Screens/search_service_data.dart';
import '../../Surprise_Screens/Screens/surprise_screens.dart';
import '../../wallet/Screens/enter_review.dart';

class ShopsDetails extends ConsumerStatefulWidget {
  final String? heroTag; // optional; if null/empty, no hero anim
  final String? image; // optional; falls back to AppImages.imageContainer1
  final String? shopId;
  final String? page;
  const ShopsDetails({
    super.key,
    this.heroTag,
    this.image,
    this.shopId,
    this.page,
  });

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
  int? selectedIndex;
  int selectedWeight = 0; // default

  bool _enquiryDisabled = false;

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
    AppLogger.log.i(widget.shopId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(shopsNotifierProvider.notifier)
          .showSpecificShopDetails(shopId: widget.shopId ?? '');
      final notifier = ref.read(shopsNotifierProvider.notifier);

      // ✅ Reset old follow state FIRST
      notifier.resetFollowState();
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
  void didUpdateWidget(covariant ShopsDetails oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.shopId != widget.shopId) {
      ref.read(shopsNotifierProvider.notifier).resetFollowState();
    }
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  Widget _buildStars(double rating, {double size = 14}) {
    final full = rating.floor();
    final hasHalf = (rating - full) >= 0.5;
    final empty = 5 - full - (hasHalf ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ Full Stars
        for (int i = 0; i < full; i++) _star(size, AppColor.green),

        // ✅ Half Star (image + clip)
        if (hasHalf) _halfStar(size),

        // ✅ Empty Stars
        for (int i = 0; i < empty; i++) _star(size, AppColor.borderGray),
      ],
    );
  }

  Widget _star(double size, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Image.asset(
        AppImages.starImage,
        height: size,
        width: size,
        color: color,
      ),
    );
  }

  Widget _halfStar(double size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: SizedBox(
        height: size,
        width: size,
        child: Stack(
          children: [
            // ✅ Background Empty Star
            Image.asset(
              AppImages.starImage,
              height: size,
              width: size,
              color: AppColor.borderGray,
            ),

            // ✅ Half Filled Star
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: 0.5, // ✅ half fill
                child: Image.asset(
                  AppImages.starImage,
                  height: size,
                  width: size,
                  color: AppColor.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  Future<void> _onRefresh() async {
    await ref
        .read(shopsNotifierProvider.notifier)
        .showSpecificShopDetails(shopId: widget.shopId ?? '');

    // ✅ if you want refresh service provider also
    ref.invalidate(shopServicesProvider(widget.shopId ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopsNotifierProvider);
    final notifier = ref.watch(shopsNotifierProvider.notifier);
    final stateS = ref.watch(homeNotifierProvider);

    final asyncServices = ref.watch(shopServicesProvider(widget.shopId ?? ''));

    if (state.isLoading) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }
    final shopsData = state.shopDetailsResponse;
    if (shopsData == null || shopsData.data == null) {
      return const Scaffold(body: Center(child: NoDataScreen()));
    }
    final double w = MediaQuery.of(context).size.width;
    // gift size scales with screen width (max 120)
    final double giftSize = (w * 0.25).clamp(80.0, 120.0);

    // final bool useHero = (widget.heroTag != null && widget.heroTag!.isNotEmpty);
    // final String imagePath = widget.image ?? AppImages.imageContainer1;

    final services = shopsData.data?.services ?? [];
    final products = shopsData.data?.products ?? [];
    final bool isFollowing =
        state.followResponse?.data.isFollowing ??
        shopsData.data?.isFollowing ??
        false;

    final hasServices = services.isNotEmpty;
    final hasProducts = products.isNotEmpty;

    // final Widget bigImage = ClipRRect(
    //   clipBehavior: Clip.antiAlias,
    //   borderRadius: BorderRadius.circular(20),
    //   child: Image.asset(imagePath, height: 230, width: 310, fit: BoxFit.cover),
    // );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColor.darkBlue,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
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
                                        shopsData.data?.category.toString() ??
                                        '',
                                    textColor: AppColor.blue,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 10),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          shopsData.data?.englishName
                                                  .toString() ??
                                              '',
                                          style: GoogleFonts.mulish(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.darkBlue,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 9),
                                      // CommonContainer.followButton(
                                      //   isLoading: state.followButtonLoader,
                                      //   isFollowing: state.isFollowing,
                                      //   onTap: () {
                                      //     ref
                                      //         .read(
                                      //           shopsNotifierProvider.notifier,
                                      //         )
                                      //         .followButton(
                                      //           shopId:
                                      //               shopsData.data?.id
                                      //                   .toString() ??
                                      //               '',
                                      //           follow: !state.isFollowing,
                                      //         );
                                      //   },
                                      // ),

                                      // CommonContainer.followButton(
                                      //   isLoading: state.followButtonLoader,
                                      //   isFollowing: state.isFollowing,
                                      //   onTap: () {
                                      //     ref
                                      //         .read(
                                      //           shopsNotifierProvider.notifier,
                                      //         )
                                      //         .followButton(
                                      //           shopId:
                                      //               shopsData.data?.id
                                      //                   .toString() ??
                                      //               '',
                                      //           follow: !state.isFollowing,
                                      //         );
                                      //   },
                                      // ),
                                    ],
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.symmetric(
                                //     horizontal: 16,
                                //   ),
                                //   child: Row(
                                //     children: [
                                //       Text(
                                //         shopsData.data?.englishName.toString() ??
                                //             '',
                                //         style: GoogleFont.Mulish(
                                //           fontSize: 25,
                                //           fontWeight: FontWeight.bold,
                                //           color: AppColor.darkBlue,
                                //         ),
                                //       ),
                                //
                                //     ],
                                //   ),
                                // ),
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
                                        shopsData.data?.distanceLabel
                                                .toString() ??
                                            '',

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
                              // CommonContainer.followButton(
                              //   isLoading: state.followButtonLoader,
                              //   isFollowing: state.isFollowing,
                              //   onTap: () {
                              //     ref
                              //         .read(
                              //           shopsNotifierProvider.notifier,
                              //         )
                              //         .followButton(
                              //           shopId:
                              //               shopsData.data?.id
                              //                   .toString() ??
                              //               '',
                              //           follow: !state.isFollowing,
                              //         );
                              //   },
                              // ),
                              // Actions row
                              _staggerFromTop(
                                aActions,
                                SingleChildScrollView(
                                  physics: BouncingScrollPhysics(),
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  scrollDirection: Axis.horizontal,
                                  child: CommonContainer.callNowButton(
                                    isFollowing: state.isFollowing,
                                    followButtonLoading:
                                        state.followButtonLoader,
                                    followButtonOnTap: () {
                                      ref
                                          .read(shopsNotifierProvider.notifier)
                                          .followButton(
                                            shopId:
                                                shopsData.data?.id.toString() ??
                                                '',
                                            follow: !state.isFollowing,
                                          );
                                    },
                                    canFollow: true,
                                    callOnTap: () async {
                                      await MapUrls.openDialer(
                                        context,
                                        shopsData.data?.primaryPhone,
                                      );
                                      await ref
                                          .read(homeNotifierProvider.notifier)
                                          .markCallOrLocation(
                                            type: 'CALL',
                                            shopId:
                                                shopsData.data?.id.toString() ??
                                                '',
                                          );
                                    },
                                    callImage: AppImages.callImage,
                                    callText: 'Call Now',

                                    mapOnTap: () async {
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
                                      await ref
                                          .read(homeNotifierProvider.notifier)
                                          .markCallOrLocation(
                                            type: 'MAP',
                                            shopId:
                                                shopsData.data?.id.toString() ??
                                                '',
                                          );
                                    },
                                    messageOnTap: () {
                                      if (_enquiryDisabled ||
                                          stateS.isEnquiryLoading)
                                        return;

                                      setState(() {
                                        _enquiryDisabled = true;
                                      });

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
                                    messageDisabled: _enquiryDisabled,
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                  ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: CachedNetworkImage(
                                                  imageUrl: data?.url ?? '',
                                                  height: 250,
                                                  width: 310,
                                                  fit: BoxFit.cover,
                                                  placeholder: (_, __) =>
                                                      Container(
                                                        height: 250,
                                                        width: 310,
                                                        color: Colors.grey
                                                            .withOpacity(0.2),
                                                      ),
                                                  errorWidget: (_, __, ___) =>
                                                      Container(
                                                        height: 250,
                                                        width: 310,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                          color: Colors
                                                              .grey
                                                              .shade300,
                                                        ),
                                                        child: Icon(
                                                          Icons.broken_image,
                                                        ),
                                                      ),
                                                ),
                                              ),

                                              // ClipRRect(
                                              //   borderRadius:
                                              //       BorderRadiusGeometry.circular(
                                              //         20,
                                              //       ),
                                              //   child: CachedNetworkImage(
                                              //     imageUrl:
                                              //         data?.url?.toString() ?? '',
                                              //     height: 250,
                                              //     width: 310,
                                              //     fit: BoxFit.cover,
                                              //     placeholder: (context, url) =>
                                              //         Container(
                                              //           height: 250,
                                              //           width: 310,
                                              //           color: Colors.grey
                                              //               .withOpacity(0.2),
                                              //         ),
                                              //     errorWidget:
                                              //         (
                                              //           context,
                                              //           url,
                                              //           error,
                                              //         ) => ClipRRect(
                                              //           borderRadius:
                                              //               BorderRadius.circular(
                                              //                 16,
                                              //               ),
                                              //           child: Container(
                                              //             height: 100,
                                              //             width: 100,
                                              //             color: Colors
                                              //                 .grey
                                              //                 .shade300, // background if you want
                                              //             child: const Icon(
                                              //               Icons.broken_image,
                                              //             ),
                                              //           ),
                                              //         ),
                                              //   ),
                                              // ),
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
                                                        BorderRadius.circular(
                                                          30,
                                                        ),
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
                                                        style:
                                                            GoogleFont.Mulish(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14,
                                                              color: AppColor
                                                                  .darkBlue,
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
                                                          color: AppColor
                                                              .darkBlue
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
                                                        style:
                                                            GoogleFont.Mulish(
                                                              fontSize: 12,
                                                              color: AppColor
                                                                  .darkBlue,
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
                              if (shopsData.data?.surprise?.hasOffer ==
                                  true) ...[
                                _staggerFromTop(
                                  aOffer,
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Stack(
                                      clipBehavior: Clip
                                          .none, // allow gift to overflow above
                                      children: [
                                        // Base pill: NOT positioned → Stack takes this size (auto height)
                                        GestureDetector(
                                          onTap:
                                              shopsData
                                                      .data
                                                      ?.surprise
                                                      ?.isClaimed ==
                                                  true
                                              ? null
                                              : () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => SurpriseScreens(
                                                        shopId:
                                                            shopsData.data?.id
                                                                .toString() ??
                                                            '',
                                                        shopLat: double.parse(
                                                          shopsData
                                                                  .data
                                                                  ?.gpsLatitude ??
                                                              "0",
                                                        ),
                                                        shopLng: double.parse(
                                                          shopsData
                                                                  .data
                                                                  ?.gpsLongitude ??
                                                              "0",
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                          child: Container(
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
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              gradient: LinearGradient(
                                                begin: Alignment.center,
                                                end: Alignment.centerRight,
                                                colors: [
                                                  AppColor.lightMintGreen,
                                                  AppColor.lightMintGreen
                                                      .withOpacity(0.5),
                                                  // AppColor.lightMintGreen,
                                                  AppColor.whiteSmoke
                                                      .withOpacity(0.99),
                                                  AppColor.whiteSmoke
                                                      .withOpacity(0.99),
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
                                                  shopsData
                                                              .data
                                                              ?.surprise
                                                              ?.isClaimed ==
                                                          true
                                                      ? 'Surprise Claimed 🎉'
                                                      : 'Surprise Offer',
                                                  style: GoogleFont.Mulish(
                                                    fontSize:
                                                        shopsData
                                                                .data
                                                                ?.surprise
                                                                ?.isClaimed ==
                                                            true
                                                        ? 16
                                                        : 22,
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
                                                  shopsData
                                                              .data
                                                              ?.surprise
                                                              ?.isClaimed ==
                                                          true
                                                      ? 'You’ve already unlocked this offer'
                                                      : 'Visit the shop nearby to unlock',
                                                  style: GoogleFont.Mulish(
                                                    fontSize:
                                                        shopsData
                                                                .data
                                                                ?.surprise
                                                                ?.isClaimed ==
                                                            true
                                                        ? 14
                                                        : 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Gift image overlapping on top-right
                                        Positioned(
                                          right: 0,
                                          top:
                                              -giftSize *
                                              0.23, // slight lift above pill
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
                              const SizedBox(width: 10),
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

                      // -----------------------------
                      // TAG FILTER CHIPS
                      // -----------------------------
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
                            children: [
                              ...List.generate(
                                shopsData.data?.serviceCategories.length ?? 0,

                                // shopsData.data?.serviceTags?.length ?? 0,
                                (index) {
                                  final tag =
                                      shopsData.data!.serviceCategories[index];
                                  final isSelected = selectedIndex == index;

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: CommonContainer.categoryChip(
                                      tag.label ?? '',
                                      rightSideArrow: true,
                                      ContainerColor: isSelected
                                          ? AppColor.white
                                          : Colors.transparent,
                                      BorderColor: AppColor.brightGray,
                                      TextColor: AppColor.lightGray2,
                                      isSelected: isSelected,
                                      onTap: () {
                                        setState(() => selectedIndex = index);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // -----------------------------
                      // FILTERED SERVICES LIST
                      // -----------------------------
                      _staggerFromTop(
                        aSnacksBox,
                        Builder(
                          builder: (context) {
                            final allServices = shopsData.data?.services ?? [];
                            final tags =
                                shopsData.data?.serviceCategories ??
                                []; // ✅ correct list

                            // ✅ selected slug
                            String? selectedSlug;
                            if (selectedIndex != null &&
                                selectedIndex! >= 0 &&
                                selectedIndex! < tags.length) {
                              selectedSlug = tags[selectedIndex!].slug;
                            }

                            // ✅ filter
                            final filteredServices =
                                (selectedSlug == null ||
                                    selectedSlug.isEmpty ||
                                    selectedSlug == "all")
                                ? allServices
                                : allServices.where((service) {
                                    final cat = service.category;
                                    final subCat = service.subCategory;
                                    return cat == selectedSlug ||
                                        subCat == selectedSlug;
                                  }).toList();

                            return Stack(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredServices.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == filteredServices.length) {
                                      return const SizedBox(height: 100);
                                    }

                                    final data = filteredServices[index];

                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                      ),
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
                                          CommonContainer.serviceDetails(
                                            filedName: data.englishName,
                                            imageWidth: 130,
                                            image: data.imageUrl, // ✅ FIX
                                            ratingStar: data.rating.toString(),
                                            ratingCount: data.ratingCount
                                                .toString(), // ✅ FIX
                                            offAmound: '₹${data.offerPrice}',
                                            horizontalDivider: true,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SearchServiceData(
                                                        serviceId: data.id,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 35),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                // ✅ View All Button (same)
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
                                          ),
                                          blurRadius: 80,
                                          spreadRadius: 40,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                    ShopsProduct(
                                                      page: widget.page,
                                                      category: shopsData
                                                          .data
                                                          ?.category,
                                                      englishName: shopsData
                                                          .data
                                                          ?.englishName,
                                                      isTrusted: shopsData
                                                          .data
                                                          ?.isTrusted,
                                                      shopImageUrl:
                                                          shopsData
                                                                  .data
                                                                  ?.media
                                                                  .isNotEmpty ==
                                                              true
                                                          ? shopsData
                                                                .data!
                                                                .media
                                                                .first
                                                                .url
                                                          : "",
                                                      initialIndex: 3,
                                                      shopId: widget.shopId,
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 40),
                      _staggerFromTop(
                        aHorizonalDivider,
                        CommonContainer.horizonalDivider(),
                      ),
                    ]
                    // if (hasServices) ...[
                    //   _staggerFromTop(
                    //     aOfferProducts,
                    //     Padding(
                    //       padding: const EdgeInsets.symmetric(
                    //         horizontal: 15,
                    //         vertical: 5,
                    //       ),
                    //       child: Row(
                    //         children: [
                    //           Image.asset(
                    //             AppImages.fireImage,
                    //             height: 35,
                    //             color: AppColor.darkBlue,
                    //           ),
                    //           SizedBox(width: 10),
                    //           Text(
                    //             'Offer Services',
                    //             style: GoogleFont.Mulish(
                    //               fontWeight: FontWeight.bold,
                    //               fontSize: 22,
                    //               color: AppColor.darkBlue,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    //
                    //   _staggerFromTop(
                    //     aSnacksFliter,
                    //     SingleChildScrollView(
                    //       scrollDirection: Axis.horizontal,
                    //       physics: const BouncingScrollPhysics(),
                    //       padding: const EdgeInsets.symmetric(
                    //         horizontal: 15,
                    //         vertical: 20,
                    //       ),
                    //       child: Row(
                    //         children: List.generate(
                    //           shopsData.data?.serviceTags?.length ?? 0,
                    //           (index) {
                    //             final isSelected = selectedIndex == index;
                    //             return Padding(
                    //               padding: const EdgeInsets.only(right: 8),
                    //
                    //               child: CommonContainer.categoryChip(
                    //                 rightSideArrow: true,
                    //                 ContainerColor: isSelected
                    //                     ? AppColor.white
                    //                     : Colors.transparent,
                    //                 BorderColor: isSelected
                    //                     ? AppColor.brightGray
                    //                     : AppColor.brightGray,
                    //                 TextColor: isSelected
                    //                     ? AppColor.lightGray2
                    //                     : AppColor.lightGray2,
                    //                 shopsData.data?.serviceTags?[index].label ??
                    //                     '',
                    //                 isSelected: isSelected,
                    //                 onTap: () {
                    //                   setState(() => selectedIndex = index);
                    //                 },
                    //               ),
                    //             );
                    //           },
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    //   _staggerFromTop(
                    //     aSnacksBox,
                    //     Stack(
                    //       children: [
                    //         ListView.builder(
                    //           shrinkWrap: true,
                    //           physics: NeverScrollableScrollPhysics(),
                    //           itemCount: shopsData.data?.services?.length,
                    //           itemBuilder: (context, index) {
                    //             final data = shopsData.data?.services?[index];
                    //             return Container(
                    //               padding: EdgeInsets.symmetric(horizontal: 15),
                    //               decoration: BoxDecoration(
                    //                 gradient: LinearGradient(
                    //                   colors: [
                    //                     AppColor.white.withOpacity(0.5),
                    //                     AppColor.white.withOpacity(0.3),
                    //                     AppColor.white,
                    //                   ],
                    //                   begin: Alignment.topCenter,
                    //                   end: Alignment.bottomCenter,
                    //                 ),
                    //               ),
                    //               child: Column(
                    //                 children: [
                    //                   CommonContainer.serviceDetails(
                    //                     filedName:
                    //                         data?.englishName.toString() ?? '',
                    //                     imageWidth: 130,
                    //                     image:
                    //                         data?.primaryImageUrl.toString() ??
                    //                         '',
                    //                     ratingStar: data?.rating.toString() ?? '',
                    //                     onTap: () {
                    //                       Navigator.push(
                    //                         context,
                    //                         MaterialPageRoute(
                    //                           builder: (context) =>
                    //                               SearchServiceData(
                    //                                 serviceId: data?.id,
                    //                               ),
                    //                         ),
                    //                       );
                    //                     },
                    //                     ratingCount:
                    //                         data?.reviewCount.toString() ?? '',
                    //                     offAmound:
                    //                         '₹${data?.offerPrice.toString() ?? ''}',
                    //                     horizontalDivider: true,
                    //                   ),
                    //
                    //                   // CommonContainer.foodList(
                    //                   //   onTap: () {
                    //                   //     Navigator.push(
                    //                   //       context,
                    //                   //       MaterialPageRoute(
                    //                   //         builder: (context) =>
                    //                   //             SearchServiceData(
                    //                   //               serviceId: data?.id,
                    //                   //             ),
                    //                   //       ),
                    //                   //     );
                    //                   //     // Navigator.push(
                    //                   //     //   context,
                    //                   //     //   MaterialPageRoute(
                    //                   //     //     builder: (context) =>
                    //                   //     //         SearchServiceData(
                    //                   //     //           serviceId: data?.id,
                    //                   //     //         ),
                    //                   //     //   ),
                    //                   //     // );
                    //                   //   },
                    //                   //   imageWidth: 130,
                    //                   //   image:
                    //                   //       data?.primaryImageUrl.toString() ??
                    //                   //       '',
                    //                   //   foodName:
                    //                   //       data?.englishName.toString() ?? '',
                    //                   //   ratingStar: data?.rating.toString() ?? '',
                    //                   //   ratingCount:
                    //                   //       data?.reviewCount.toString() ?? '',
                    //                   //   offAmound:
                    //                   //       '₹${data?.offerPrice.toString() ?? ''}',
                    //                   //   oldAmound:
                    //                   //       '₹${data?.startsAt.toString() ?? ''}',
                    //                   //   km: '',
                    //                   //   location: '',
                    //                   //   Verify: false,
                    //                   //   locations: false,
                    //                   //   weight: true,
                    //                   //   horizontalDivider: true,
                    //                   //   // weightOptions: const ['300Gm', '500Gm'],
                    //                   //   selectedWeightIndex: selectedWeight,
                    //                   //   onWeightChanged: (i) =>
                    //                   //       setState(() => selectedWeight = i),
                    //                   // ),
                    //                   SizedBox(height: 35),
                    //                 ],
                    //               ),
                    //             );
                    //           },
                    //         ),
                    //
                    //         Positioned(
                    //           bottom: 0,
                    //           left: 0,
                    //           right: 0,
                    //           child: Container(
                    //             padding: const EdgeInsets.symmetric(
                    //               vertical: 20,
                    //               horizontal: 20,
                    //             ),
                    //             decoration: BoxDecoration(
                    //               boxShadow: [
                    //                 BoxShadow(
                    //                   color: AppColor.white.withOpacity(
                    //                     0.9,
                    //                   ), // white shadow
                    //                   blurRadius: 80,
                    //                   spreadRadius: 40,
                    //                   offset: const Offset(
                    //                     0,
                    //                     0,
                    //                   ), // shadow on all sides
                    //                 ),
                    //               ],
                    //             ),
                    //             child: Row(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 Text(
                    //                   'View All',
                    //                   style: GoogleFont.Mulish(
                    //                     fontWeight: FontWeight.bold,
                    //                     fontSize: 16,
                    //                     color: AppColor.darkBlue,
                    //                   ),
                    //                 ),
                    //                 const SizedBox(width: 10),
                    //                 CommonContainer.rightSideArrowButton(
                    //                   onTap: () {
                    //                     Navigator.push(
                    //                       context,
                    //                       MaterialPageRoute(
                    //                         builder: (context) => ShopsProduct(
                    //                           page: widget.page,
                    //                           category: shopsData.data?.category
                    //                               .toString(),
                    //                           englishName: shopsData
                    //                               .data
                    //                               ?.englishName
                    //                               .toString(),
                    //                           isTrusted:
                    //                               shopsData.data?.isTrusted,
                    //                           shopImageUrl:
                    //                               shopsData.data?.media?[0].url,
                    //                           initialIndex: 3,
                    //                           shopId: widget.shopId,
                    //                         ),
                    //                         // ShopsProductList(),
                    //                       ),
                    //                     );
                    //                   },
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    //
                    //   SizedBox(height: 40),
                    //   _staggerFromTop(
                    //     aHorizonalDivider,
                    //     CommonContainer.horizonalDivider(),
                    //   ),
                    // ]
                    else if (hasProducts) ...[
                      // -----------------------------
                      // OFFER PRODUCTS TITLE
                      // -----------------------------
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
                              const SizedBox(width: 10),
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

                      // -----------------------------
                      // PRODUCT FILTER CHIPS
                      // -----------------------------
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
                                final tag =
                                    shopsData.data!.productCategories![index];

                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: CommonContainer.categoryChip(
                                    tag.label ??
                                        '', // label as positional (same as services section)
                                    rightSideArrow: true,
                                    ContainerColor: isSelected
                                        ? AppColor.white
                                        : Colors.transparent,
                                    BorderColor: AppColor.brightGray,
                                    TextColor: AppColor.lightGray2,
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

                      // -----------------------------
                      // FILTERED PRODUCTS LIST
                      // -----------------------------
                      _staggerFromTop(
                        aSnacksBox,
                        Builder(
                          builder: (context) {
                            final allProducts = shopsData.data?.products ?? [];
                            final tags =
                                shopsData.data?.productCategories ?? [];

                            // 1) Get selected slug from chip
                            String? selectedSlug;
                            if (selectedIndex != null &&
                                selectedIndex! >= 0 &&
                                selectedIndex! < tags.length) {
                              selectedSlug = tags[selectedIndex!].slug;
                            }

                            // 2) Filter products by category / subCategory
                            final filteredProducts =
                                (selectedSlug == null || selectedSlug.isEmpty)
                                ? allProducts
                                : allProducts.where((product) {
                                    //  adjust these fields if your model uses different names
                                    final cat = product.category;
                                    final subCat = product.subCategory;
                                    return cat == selectedSlug ||
                                        subCat == selectedSlug;
                                  }).toList();

                            return Stack(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredProducts.length,
                                  itemBuilder: (context, index) {
                                    final data = filteredProducts[index];

                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                      ),
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
                                                        productId: data.id,
                                                      ),
                                                ),
                                              );
                                            },
                                            imageWidth: 130,
                                            image:
                                                data.imageUrl?.toString() ?? '',
                                            foodName:
                                                data.englishName?.toString() ??
                                                '',
                                            ratingStar:
                                                data.rating?.toString() ?? '',
                                            ratingCount:
                                                data.ratingCount?.toString() ??
                                                '',
                                            offAmound:
                                                '₹${data.offerPrice?.toString() ?? ''}',
                                            oldAmound:
                                                '₹${data.price?.toString() ?? ''}',
                                            km: '',
                                            location: '',
                                            Verify: false,
                                            locations: false,
                                            weight: true,
                                            horizontalDivider: true,
                                            selectedWeightIndex: selectedWeight,
                                            onWeightChanged: (i) => setState(
                                              () => selectedWeight = i,
                                            ),
                                          ),
                                          const SizedBox(height: 35),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                // View All button (unchanged)
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
                                          ),
                                          blurRadius: 80,
                                          spreadRadius: 40,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'View All',
                                          style: GoogleFont.Mulish(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColor.darkBlue,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        CommonContainer.rightSideArrowButton(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ShopsProduct(
                                                      category: shopsData
                                                          .data
                                                          ?.category
                                                          ?.toString(),
                                                      englishName: shopsData
                                                          .data
                                                          ?.englishName
                                                          ?.toString(),
                                                      isTrusted: shopsData
                                                          .data
                                                          ?.isTrusted,
                                                      shopImageUrl: shopsData
                                                          .data
                                                          ?.media?[0]
                                                          .url,
                                                      initialIndex: 2,
                                                      shopId: widget.shopId,
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 40),
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
                      child: Builder(
                        builder: (context) {
                          final reviewUi = shopsData.data?.reviewUi;
                          final reviews = shopsData.data?.reviews ?? [];

                          final hasReviews = reviews.isNotEmpty;

                          // ✅ show average rating from API
                          final avgRating = hasReviews
                              ? (double.tryParse(
                                      shopsData.data?.averageRating ?? "0",
                                    ) ??
                                    0)
                              : (reviewUi?.averageRating.toDouble() ?? 0);

                          // ✅ count label
                          final countLabel = hasReviews
                              ? "${reviews.length} Reviews"
                              : (reviewUi?.countLabel ?? "No Reviews");

                          // ✅ button text from API
                          final buttonText =
                              reviewUi?.buttonText ?? "Write a Review";

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ✅ Reviews title
                              _staggerFromTop(
                                aReviewText,
                                Row(
                                  children: [
                                    Image.asset(
                                      AppImages.reviewImage,
                                      height: 27.08,
                                      width: 26,
                                    ),
                                    const SizedBox(width: 10),
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

                              const SizedBox(height: 18),

                              // ✅ Rating row + Stars
                              _staggerFromTop(
                                aRating,
                                Row(
                                  children: [
                                    Text(
                                      avgRating.toStringAsFixed(1),
                                      style: GoogleFont.Mulish(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 33,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // ✅ Only ONE STAR
                                    Image.asset(
                                      AppImages.starImage,
                                      height: 22,
                                      color: AppColor.green,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 6),

                              _staggerFromTop(
                                aTotalReviewText,
                                Text(
                                  countLabel,
                                  style: GoogleFont.Mulish(
                                    color: AppColor.lightGray3,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              // ✅ Review UI button (ALWAYS SHOW)
                              CommonContainer.button(
                                imagePath: AppImages.rightSideArrow,
                                buttonColor: AppColor.darkBlue,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EnterReview(
                                        shopId: shopsData
                                            .data
                                            ?.id, // ✅ pass shop id
                                      ),
                                    ),
                                  );
                                },
                                text: Text(buttonText),
                              ),

                              const SizedBox(height: 20),

                              // ✅ IF NO REVIEWS → show empty UI
                              if (!hasReviews) ...[
                                _staggerFromTop(
                                  aReviewBox,
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColor.brightGray,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "No reviews yet",
                                          style: GoogleFont.Mulish(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColor.darkBlue,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Be the first one to review and earn reward 🎁",
                                          style: GoogleFont.Mulish(
                                            color: AppColor.lightGray3,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]
                              // ✅ IF REVIEWS EXIST → list show
                              else ...[
                                _staggerFromTop(
                                  aReviewBox,
                                  Column(
                                    children: List.generate(reviews.length, (
                                      index,
                                    ) {
                                      final r = reviews[index];
                                      final rRating = r.rating.toDouble();

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColor.white,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border(
                                              bottom: BorderSide(
                                                color: AppColor.brightGray,
                                                width: 8,
                                              ),
                                              left: BorderSide(
                                                color: AppColor.brightGray,
                                                width: 2,
                                              ),
                                              right: BorderSide(
                                                color: AppColor.brightGray,
                                                width: 2,
                                              ),
                                              top: BorderSide(
                                                color: AppColor.brightGray,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 18,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Title + stars
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        r.heading,
                                                        style:
                                                            GoogleFont.Mulish(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              color: AppColor
                                                                  .darkBlue,
                                                            ),
                                                      ),
                                                    ),
                                                    _buildStars(
                                                      rRating,
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      r.rating.toString(),
                                                      style: GoogleFont.Mulish(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: AppColor.green,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 10),

                                                Text(
                                                  r.comment,
                                                  style: GoogleFont.Mulish(
                                                    color: AppColor.lightGray3,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),

                                                const SizedBox(height: 12),
                                                CommonContainer.horizonalDivider(),
                                                const SizedBox(height: 12),

                                                Text(
                                                  r.createdAtRelative,
                                                  style: GoogleFont.Mulish(
                                                    color: AppColor.lightGray2,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 78),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
