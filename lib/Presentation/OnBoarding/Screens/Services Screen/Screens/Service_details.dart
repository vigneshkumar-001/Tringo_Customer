import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Core/Utility/app_loader.dart';
import 'package:tringo_app/Core/Widgets/Common%20Bottom%20Navigation%20bar/shops_product.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Services%20Screen/Controller/service_notifier.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Services%20Screen/Screens/search_service_data.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Services%20Screen/Screens/service_single_company_list.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Utility/map_urls.dart';
import '../../../../../Core/Widgets/Common Bottom Navigation bar/service_product_bottombar.dart';
import '../../../../../Core/Widgets/common_container.dart';
import '../../Home Screen/Controller/home_notifier.dart';
import '../../No Data Screen/Screen/no_data_screen.dart';

class ServiceDetails extends ConsumerStatefulWidget {
  final String? heroTag;
  final String? image;
  final String? serviceID;
  const ServiceDetails({super.key, this.heroTag, this.image, this.serviceID});

  @override
  ConsumerState<ServiceDetails> createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends ConsumerState<ServiceDetails>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> categoryTabs = [
    {"label": "Electrical"},
    {"label": "Plumbing"},
    {"label": "Building"},
    {"label": "Milk Sweets"},
  ];
  int selectedIndex = 0;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(serviceNotifierProvider.notifier)
          .showSpecificServiceDetails(
            force: true,
            shopId: widget.serviceID ?? '',
          );
      _ac.forward();
    });
    final curve = CurvedAnimation(
      parent: _ac,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // Early hero + header items
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

  // helper: slide down from top + fade
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
    final double w = MediaQuery.of(context).size.width;
    // gift size scales with screen width (max 120)
    final double giftSize = (w * 0.25).clamp(80.0, 120.0);

    final bool useHero = (widget.heroTag != null && widget.heroTag!.isNotEmpty);

    final state = ref.watch(serviceNotifierProvider);
    final homeState = ref.watch(homeNotifierProvider);
    if (state.isLoading) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }
    final serviceData = state.serviceDetailsResponse;
    if (serviceData == null || serviceData.data == null) {
      return const Scaffold(body: Center(child: NoDataScreen()));
    }

    final String imagePath = widget.image ?? AppImages.servicesContainer1;
    final serviceRawData = serviceData.data;
    final services = serviceData.data?.services ?? [];
    final products = serviceData.data?.products ?? [];

    final hasServices = services.isNotEmpty;
    final hasProducts = products.isNotEmpty;
    final Widget bigImage = ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(imagePath, height: 250, width: 257, fit: BoxFit.cover),
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
                        colors: [
                          AppColor.white,
                          AppColor.white,
                          AppColor.whiteSmoke,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header
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
                                      serviceRawData?.category
                                          ?.toUpperCase()
                                          .toString() ??
                                      '',
                                  textColor: AppColor.blue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Chips
                              serviceRawData?.isTrusted == true
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: CommonContainer.verifyTick(),
                                    )
                                  : SizedBox.shrink(),

                              const SizedBox(height: 12),

                              // Title
                              _staggerFromTop(
                                aTitle,
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    serviceRawData?.englishName.toString() ??
                                        '',
                                    style: GoogleFont.Mulish(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Location
                              _staggerFromTop(
                                aLocation,
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 30,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          maxLines: 2,
                                          serviceRawData?.descriptionEn
                                                  .toString() ??
                                              '',
                                          style: GoogleFont.Mulish(
                                            color: AppColor.lightGray2,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 27),

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
                                        serviceRawData?.primaryPhone,
                                      );
                                    },
                                    messageOnTap: () {
                                      // block if already enquired or loading
                                      if (_enquiryDisabled ||
                                          homeState.isEnquiryLoading)
                                        return;

                                      setState(() {
                                        _enquiryDisabled =
                                            true; // lock UI + text
                                      });
                                      ref
                                          .read(homeNotifierProvider.notifier)
                                          .putEnquiry(
                                            context: context,
                                            serviceId: '',
                                            productId: '',
                                            message: '',
                                            shopId:
                                                serviceRawData?.id.toString() ??
                                                '',
                                          );
                                    },
                                    mapOnTap: () {
                                      if (_enquiryDisabled ||
                                          homeState.isEnquiryLoading)
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
                                                serviceRawData?.id.toString() ??
                                                '',
                                          );
                                    },
                                    messageLoading: homeState.isEnquiryLoading,
                                    messageDisabled: _enquiryDisabled,
                                    callImage: AppImages.callImage,
                                    callText: 'Call Now',
                                    mapText: _enquiryDisabled
                                        ? 'Enquired'
                                        : 'Enquire Now',
                                    mapImage: AppImages.messageImage,
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
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    whatsAppIcon: true,

                                    whatsAppOnTap: () {
                                      MapUrls.openWhatsapp(
                                        message: 'hi',
                                        context: context,
                                        phone:
                                            serviceRawData?.primaryPhone
                                                .toString() ??
                                            '',
                                      );
                                    },
                                    fullEnquiry: true,
                                    messageContainer: true,
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
                                  itemCount: serviceRawData?.media?.length,
                                  itemBuilder: (context, index) {
                                    final data = serviceRawData?.media?[index];
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
                                                    BorderRadiusGeometry.circular(
                                                      20,
                                                    ),
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      data?.url?.toString() ??
                                                      '',
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
                                                        BorderRadius.circular(
                                                          30,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        serviceRawData
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
                                                        serviceRawData
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
                            ],
                          ),
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
                            'Services in Offer ',
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
                          serviceRawData?.productCategories?.length ?? 0,
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
                                serviceRawData?.productCategories?[index].label
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

                    Stack(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: serviceRawData?.services?.length,
                          itemBuilder: (context, index) {
                            final data = serviceRawData?.services?[index];
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
                                  CommonContainer.serviceDetails(
                                    filedName:
                                        data?.englishName.toString() ?? '',
                                    imageWidth: 130,
                                    image:
                                        data?.primaryImageUrl.toString() ?? '',
                                    ratingStar: '0.0',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SearchServiceData(
                                                serviceId: data?.id,
                                              ),
                                        ),
                                      );
                                    },
                                    ratingCount: '0',
                                    offAmound:
                                        '₹${data?.startsAt.toString() ?? ''}',
                                    horizontalDivider: true,
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
                                        builder: (context) =>
                                            ServiceProductBottombar(
                                              category: serviceRawData?.category
                                                  .toString(),
                                              englishName: serviceRawData
                                                  ?.englishName
                                                  .toString(),
                                              isTrusted:
                                                  serviceRawData?.isTrusted,
                                              shopImageUrl:
                                                  serviceRawData?.media?[0].url,
                                              shopId: serviceRawData?.id
                                                  .toString(),
                                              initialIndex: 2,
                                            ),
                                        // ServiceSingleCompanyList(),
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
                  ],

                  /*          SizedBox(height: 40),
                  _staggerFromTop(
                    aHorizonalDivider,
                    CommonContainer.horizonalDivider(),
                  ),
                  SizedBox(height: 30),
                  _staggerFromTop(
                    aPeopleViewText,
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
                  ),
                  SizedBox(height: 20),
                  _staggerFromTop(
                    aPeopleViewScroller,
                    SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          CommonContainer.shopPeopleView(
                            onTap: () {},
                            Images: AppImages.shopContainer3,
                            shopName: 'Zam Zam Sweets',
                            locationName: '12, 2, Tirupparankunram Rd, kunram ',
                            km: '5Kms',
                            ratingStar: '4.5',
                            ratingCound: '16',
                            time: '9Pm',
                          ),
                          CommonContainer.shopPeopleView(
                            onTap: () {},
                            Images: AppImages.shopContainer5,
                            shopName: 'JMS Bhagavathi Amman Sweets',
                            locationName: '12, 2, Tirupparankunram Rd, kunram ',
                            km: '5Kms',
                            ratingStar: '4.5',
                            ratingCound: '16',
                            time: '9Pm',
                          ),
                          CommonContainer.shopPeopleView(
                            onTap: () {},
                            Images: AppImages.shopContainer3,
                            shopName: 'Zam Zam Sweets',
                            locationName: '12, 2, Tirupparankunram Rd, kunram ',
                            km: '5Kms',
                            ratingStar: '4.5',
                            ratingCound: '16',
                            time: '9Pm',
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 45),
                  _staggerFromTop(
                    aHorizonalDivider,
                    CommonContainer.horizonalDivider(),
                  ),*/
                  SizedBox(height: 45),
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
