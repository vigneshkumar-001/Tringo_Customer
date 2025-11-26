import 'package:flutter/material.dart';

import '../../../../Core/Utility/app_Images.dart';
import '../../../../Core/Utility/app_color.dart';
import '../../../../Core/Utility/google_font.dart';
import '../../../../Core/Widgets/common_container.dart';

class ShopsProductList extends StatefulWidget {
  const ShopsProductList({super.key});

  @override
  State<ShopsProductList> createState() => _ShopsProductListState();
}

class _ShopsProductListState extends State<ShopsProductList>
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
                                const Spacer(),
                                CommonContainer.gradientContainer(
                                  text: 'Sweets & Bakery',
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
                                      Row(
                                        children: [
                                          CommonContainer.verifyTick(),
                                          const SizedBox(width: 10),
                                          CommonContainer.doorDelivery(),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Title
                                    _staggerFromTop(
                                      aTitle,
                                      Text(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        'Sri Krishna Sweets Private Limited',
                                        style: GoogleFont.Mulish(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.darkBlue,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 25),

                                    // // Location
                                    // _staggerFromTop(
                                    //   aLocation,
                                    //
                                    // ),
                                  ],
                                ),
                              ),
                              // // Location
                              // _staggerFromTop(
                              //   aLocation,
                              //
                              // ),
                              _staggerFromTop(
                                aSecondImg,
                                Image.asset(
                                  AppImages.imageContainer1,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        children: List.generate(categoryTabs.length, (index) {
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
                              categoryTabs[index]["label"],
                              isSelected: isSelected,
                              onTap: () {
                                setState(() => selectedIndex = index);
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  _staggerFromTop(
                    aSnacksBox,
                    Stack(
                      children: [
                        Container(
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
                                image: AppImages.snacks1,
                                foodName: 'Badam Mysurpa',
                                ratingStar: '4.5',
                                ratingCount: '16',
                                offAmound: '₹79',
                                oldAmound: '₹110',
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
                              CommonContainer.foodList(
                                imageWidth: 130,
                                image: AppImages.snacks2,
                                foodName: 'Madras Mixture',
                                ratingStar: '4.5',
                                ratingCount: '16',
                                offAmound: '₹210',
                                oldAmound: '₹240',
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
                              CommonContainer.foodList(
                                imageWidth: 130,
                                image: AppImages.snacks3,
                                foodName: 'Badam Halwa',
                                ratingStar: '4.5',
                                ratingCount: '16',
                                offAmound: '₹467',
                                oldAmound: '₹521',
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
                              CommonContainer.foodList(
                                imageWidth: 130,
                                image: AppImages.snacks4,
                                foodName:
                                    'Mysurpa Special (Tin Pack) - Sri Krishna',
                                ratingStar: '4.5',
                                ratingCount: '16',
                                offAmound: '₹850.00',
                                oldAmound: '₹930.00',
                                km: '',
                                location: '',
                                Verify: false,
                                locations: false,
                                weight: true,
                                horizontalDivider: false,
                                weightOptions: const ['300Gm', '500Gm'],
                                selectedWeightIndex: selectedWeight,
                                onWeightChanged: (i) =>
                                    setState(() => selectedWeight = i),
                              ),
                            ],
                          ),
                        ),
                        // Positioned(
                        //   bottom: 0,
                        //   left: 0,
                        //   right: 0,
                        //   child: Container(
                        //     padding: const EdgeInsets.symmetric(
                        //       vertical: 20,
                        //       horizontal: 20,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       boxShadow: [
                        //         BoxShadow(
                        //           color: AppColor.white.withOpacity(
                        //             0.9,
                        //           ), // white shadow
                        //           blurRadius: 80,
                        //           spreadRadius: 40,
                        //           offset: const Offset(
                        //             0,
                        //             0,
                        //           ), // shadow on all sides
                        //         ),
                        //       ],
                        //     ),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         Text(
                        //           'View All',
                        //           style: GoogleFont.Mulish(
                        //             fontWeight: FontWeight.bold,
                        //             fontSize: 16,
                        //             color: AppColor.darkBlue,
                        //           ),
                        //         ),
                        //         const SizedBox(width: 10),
                        //         CommonContainer.rightSideArrowButton(
                        //           onTap: () {
                        //             // Handle navigation or logic
                        //           },
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  _staggerFromTop(
                    aHorizonalDivider,
                    CommonContainer.horizonalDivider(),
                  ),
                  SizedBox(height: 40),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
