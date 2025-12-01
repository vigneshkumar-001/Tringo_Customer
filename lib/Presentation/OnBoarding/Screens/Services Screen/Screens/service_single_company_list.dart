import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Core/Utility/app_loader.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Services%20Screen/Controller/service_notifier.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Services%20Screen/Screens/search_service_data.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/common_container.dart';

class ServiceSingleCompanyList extends ConsumerStatefulWidget {
  final String? shopId;
  final String? shopImgUrl;
  final String? category;
  final String? englishName;
  final bool? isTrusted;
  const ServiceSingleCompanyList({
    super.key,
    this.shopId,
    this.shopImgUrl,
    this.category,
    this.englishName,
    this.isTrusted,
  });

  @override
  ConsumerState<ServiceSingleCompanyList> createState() =>
      _ServiceSingleCompanyListState();
}

class _ServiceSingleCompanyListState
    extends ConsumerState<ServiceSingleCompanyList>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;

  late final AnimationController _ac;

  late final Animation<double> aHeader;
  late final Animation<double> aChips;
  late final Animation<double> aTitle;
  late final Animation<double> aLocation;
  late final Animation<double> aActions;
  late final Animation<double> aSecondImg;
  late final Animation<double> aOffer;
  late final Animation<double> aOfferProducts;
  late final Animation<double> aSnacksFliter;
  late final Animation<double> aSnacksBox;
  late final Animation<double> aHorizonalDivider;
  late final Animation<double> aPeopleViewText;
  late final Animation<double> aPeopleViewScroller;
  late final Animation<double> aReviewText;
  late final Animation<double> aRating;
  late final Animation<double> aTotalReviewText;
  late final Animation<double> aReviewBox;

  @override
  void initState() {
    super.initState();

    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      reverseDuration: const Duration(milliseconds: 1000),
    );

    final curve = CurvedAnimation(
      parent: _ac,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    aHeader = CurvedAnimation(parent: curve, curve: const Interval(0.00, 0.22));
    aChips = CurvedAnimation(parent: curve, curve: const Interval(0.08, 0.30));
    aTitle = CurvedAnimation(parent: curve, curve: const Interval(0.16, 0.34));
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ac.forward();
    });
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
            offset: Offset(0, (1 - a.value) * dy * 100),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Watch the per-shop services future
    final asyncServices = ref.watch(shopServicesProvider(widget.shopId ?? ''));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
                                  text: widget.category?.toUpperCase() ?? '',
                                  textColor: AppColor.blue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.isTrusted == true) ...[
                                      _staggerFromTop(
                                        aChips,
                                        CommonContainer.verifyTick(),
                                      ),
                                    ],

                                    const SizedBox(height: 12),
                                    _staggerFromTop(
                                      aTitle,
                                      Text(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        widget.englishName ?? '',
                                        style: GoogleFont.Mulish(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                  ],
                                ),
                              ),
                              _staggerFromTop(
                                aSecondImg,
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.shopImgUrl ?? '',
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              size: 40, // reduce icon size
                                              color: Colors.grey,
                                            ),
                                          ),
                                    ),
                                  ),
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

              const SizedBox(height: 15),

              // =========== BODY: LOADER + CATEGORIES + SERVICES ===========
              asyncServices.when(
                // 1️⃣ INITIAL / REFETCH LOADING
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: ThreeDotsLoader(dotColor: AppColor.black),
                  ),
                ),

                // 2️⃣ ERROR
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Failed to load services',
                    style: GoogleFont.Mulish(
                      fontSize: 14,
                      color: AppColor.lightGray2,
                    ),
                  ),
                ),

                // 3️⃣ SUCCESS
                data: (response) {
                  final categories = response.data.categories ?? [];
                  final allServices = response.data.items ?? [];

                  // ---- decide which category is selected ----
                  String? selectedSlug;
                  if (categories.isNotEmpty) {
                    final safeIndex = selectedIndex.clamp(
                      0,
                      categories.length - 1,
                    );
                    selectedSlug = categories[safeIndex].slug;
                  }

                  // ---- filter services by slug (category field) ----
                  final List<dynamic> filteredServices;
                  if (selectedSlug == null ||
                      selectedSlug.isEmpty ||
                      selectedSlug == 'all') {
                    filteredServices = allServices;
                  } else {
                    filteredServices = allServices
                        .where((s) => s.category == selectedSlug)
                        .toList();
                  }

                  if (filteredServices.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No services available',
                        style: GoogleFont.Mulish(
                          fontSize: 14,
                          color: AppColor.lightGray2,
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (categories.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 20,
                          ),
                          child: Row(
                            children: List.generate(categories.length, (index) {
                              final isSelected = selectedIndex == index;
                              final c = categories[index];

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: CommonContainer.categoryChip(
                                  c.label ?? '',
                                  rightSideArrow: true,
                                  ContainerColor: isSelected
                                      ? AppColor.white
                                      : Colors.transparent,
                                  BorderColor: AppColor.brightGray,
                                  TextColor: AppColor.lightGray2,
                                  isSelected: isSelected,
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index;
                                    });
                                  },
                                ),
                              );
                            }),
                          ),
                        ),

                      // FILTERED SERVICES LIST
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredServices.length,
                        itemBuilder: (context, index) {
                          final service = filteredServices[index];

                          final title = service.englishName ?? 'Service';
                          final image =
                              service.primaryImageUrl?.toString() ?? '';
                          final startsAt = service.startsAt;

                          return CommonContainer.serviceDetails(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SearchServiceData(serviceId: service?.id),
                                ),
                              );
                            },
                            filedName: title,
                            imageWidth: 130,
                            image: image,
                            ratingStar: '4.5',
                            ratingCount: '16',
                            offAmound: startsAt != null ? '₹$startsAt' : '',
                            horizontalDivider:
                                index != filteredServices.length - 1,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*Widget build(BuildContext context) {
    final state = ref.watch(serviceNotifierProvider);
    final services = state.servicesListResponse?.data;
    final double w = MediaQuery.of(context).size.width;

    final double giftSize = (w * 0.25).clamp(80.0, 120.0);
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
                                SizedBox(width: 220),
                                CommonContainer.gradientContainer(
                                  text: 'Electrical',
                                  textColor: AppColor.blue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Chips
                                    _staggerFromTop(
                                      aChips,
                                      CommonContainer.verifyTick(),
                                    ),

                                    const SizedBox(height: 12),

                                    // Title
                                    _staggerFromTop(
                                      aTitle,
                                      Text(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        'Home triangle-Electricians',
                                        style: GoogleFont.Mulish(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 25),
                                  ],
                                ),
                              ),

                              _staggerFromTop(
                                aSecondImg,
                                Image.asset(
                                  AppImages.servicesContainer1,
                                  width: 122,
                                  height: 98,
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
              SizedBox(height: 15),
              Column(
                children: [
                  if (state.isLoading && services == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: ThreeDotsLoader()),
                    ),

                  // 🔹 AFTER LOAD: NO DATA
                  if (!state.isLoading && services == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No services available',
                        style: GoogleFont.Mulish(
                          fontSize: 14,
                          color: AppColor.lightGray2,
                        ),
                      ),
                    ),

                  // 🔹 AFTER LOAD: SHOW LIST
                  if (services != null)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: state.servicesListResponse?.data.items.length,
                      itemBuilder: (context, index) {
                        final services =
                            state.servicesListResponse?.data.items[index];

                        final title = services?.englishName ?? 'Service';
                        final image = services?.primaryImageUrl
                            .toString(); // plug real image if you have

                        return CommonContainer.serviceDetails(
                          filedName: title,
                          imageWidth: 130,
                          image: image ?? '',
                          ratingStar: '4.5',
                          ratingCount: '16',
                          offAmound: '₹${services?.startsAt}',
                          horizontalDivider:
                              index !=
                              state.servicesListResponse!.data.items.length - 1,
                        );
                      },
                    ),
                ],
              ),

              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     _staggerFromTop(
              //       aSnacksFliter,
              //       SingleChildScrollView(
              //         scrollDirection: Axis.horizontal,
              //         physics: const BouncingScrollPhysics(),
              //         padding: const EdgeInsets.symmetric(
              //           horizontal: 15,
              //           vertical: 20,
              //         ),
              //         child: Row(
              //           children: List.generate(categoryTabs.length, (index) {
              //             final isSelected = selectedIndex == index;
              //             return Padding(
              //               padding: const EdgeInsets.only(right: 8),
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
              //                 categoryTabs[index]["label"],
              //                 isSelected: isSelected,
              //                 onTap: () {
              //                   setState(() => selectedIndex = index);
              //                 },
              //               ),
              //             );
              //           }),
              //         ),
              //       ),
              //     ),
              //     _staggerFromTop(
              //       aSnacksBox,
              //       Stack(
              //         children: [
              //           Container(
              //             padding: EdgeInsets.symmetric(horizontal: 15),
              //             decoration: BoxDecoration(
              //               gradient: LinearGradient(
              //                 colors: [
              //                   AppColor.white.withOpacity(0.5),
              //                   AppColor.white.withOpacity(0.3),
              //                   AppColor.white,
              //                 ],
              //                 begin: Alignment.topCenter,
              //                 end: Alignment.bottomCenter,
              //               ),
              //             ),
              //             child: Column(
              //               children: [
              //                 CommonContainer.serviceDetails(
              //                   filedName: 'Electrical Consulting',
              //                   imageWidth: 130,
              //                   image: AppImages.servicesFiled1,
              //                   ratingStar: '4.5',
              //                   ratingCount: '16',
              //                   offAmound: '₹79',
              //                   horizontalDivider: true,
              //                 ),
              //                 CommonContainer.serviceDetails(
              //                   filedName: 'Fan Repair Service',
              //                   imageWidth: 130,
              //                   image: AppImages.servicesFiled2,
              //                   ratingStar: '4.5',
              //                   ratingCount: '16',
              //                   offAmound: '₹150',
              //                   horizontalDivider: true,
              //                 ),
              //                 CommonContainer.serviceDetails(
              //                   filedName: 'AC Installation',
              //                   imageWidth: 130,
              //                   image: AppImages.servicesFiled3,
              //                   ratingStar: '4.5',
              //                   ratingCount: '16',
              //                   offAmound: '₹1200',
              //                   horizontalDivider: true,
              //                 ),
              //                 CommonContainer.serviceDetails(
              //                   filedName: 'Building Construction',
              //                   imageWidth: 130,
              //                   image: AppImages.servicesFiled4,
              //                   ratingStar: '4.5',
              //                   ratingCount: '16',
              //                   offAmound: '₹15000',
              //                   horizontalDivider: true,
              //                 ),
              //                 CommonContainer.serviceDetails(
              //                   filedName: 'Welding Service',
              //                   imageWidth: 130,
              //                   image: AppImages.servicesFiled5,
              //                   ratingStar: '4.5',
              //                   ratingCount: '16',
              //                   offAmound: '₹150',
              //                   horizontalDivider: true,
              //                 ),
              //                 CommonContainer.serviceDetails(
              //                   filedName: 'Building Construction',
              //                   imageWidth: 130,
              //                   image: AppImages.servicesFiled6,
              //                   ratingStar: '4.5',
              //                   ratingCount: '16',
              //                   offAmound: '₹15000',
              //                   horizontalDivider: false,
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //     SizedBox(height: 30),
              //     _staggerFromTop(
              //       aHorizonalDivider,
              //       CommonContainer.horizonalDivider(),
              //     ),
              //     SizedBox(height: 40),
              //     _staggerFromTop(
              //       aPeopleViewText,
              //       Padding(
              //         padding: const EdgeInsets.symmetric(horizontal: 15),
              //         child: Text(
              //           'People also viewed',
              //           style: GoogleFont.Mulish(
              //             fontWeight: FontWeight.bold,
              //             fontSize: 22,
              //             color: AppColor.darkBlue,
              //           ),
              //         ),
              //       ),
              //     ),
              //     SizedBox(height: 20),
              //     _staggerFromTop(
              //       aPeopleViewScroller,
              //       SingleChildScrollView(
              //         physics: BouncingScrollPhysics(),
              //         padding: EdgeInsets.symmetric(horizontal: 6),
              //         scrollDirection: Axis.horizontal,
              //         child: Row(
              //           children: [
              //             CommonContainer.shopPeopleView(
              //               onTap: () {},
              //               Images: AppImages.shopContainer3,
              //               shopName: 'Zam Zam Sweets',
              //               locationName: '12, 2, Tirupparankunram Rd, kunram ',
              //               km: '5Kms',
              //               ratingStar: '4.5',
              //               ratingCound: '16',
              //               time: '9Pm',
              //             ),
              //             CommonContainer.shopPeopleView(
              //               onTap: () {},
              //               Images: AppImages.shopContainer5,
              //               shopName: 'JMS Bhagavathi Amman Sweets',
              //               locationName: '12, 2, Tirupparankunram Rd, kunram ',
              //               km: '5Kms',
              //               ratingStar: '4.5',
              //               ratingCound: '16',
              //               time: '9Pm',
              //             ),
              //             CommonContainer.shopPeopleView(
              //               onTap: () {},
              //               Images: AppImages.shopContainer3,
              //               shopName: 'Zam Zam Sweets',
              //               locationName: '12, 2, Tirupparankunram Rd, kunram ',
              //               km: '5Kms',
              //               ratingStar: '4.5',
              //               ratingCound: '16',
              //               time: '9Pm',
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //     SizedBox(height: 45),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }*/
