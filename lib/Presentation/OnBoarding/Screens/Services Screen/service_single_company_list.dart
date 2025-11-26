import 'package:flutter/material.dart';

import '../../../../Core/Utility/app_Images.dart';
import '../../../../Core/Utility/app_color.dart';
import '../../../../Core/Utility/google_font.dart';
import '../../../../Core/Widgets/common_container.dart';

class ServiceSingleCompanyList extends StatefulWidget {
  const ServiceSingleCompanyList({super.key});

  @override
  State<ServiceSingleCompanyList> createState() =>
      _ServiceSingleCompanyListState();
}

class _ServiceSingleCompanyListState extends State<ServiceSingleCompanyList>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> categoryTabs = [
    {"label": "Electrical"},
    {"label": "Plumbing"},
    {"label": "Building"},
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
                              CommonContainer.serviceDetails(
                                filedName: 'Electrical Consulting',
                                imageWidth: 130,
                                image: AppImages.servicesFiled1,
                                ratingStar: '4.5',
                                ratingCount: '16',
                                offAmound: '₹79',
                                horizontalDivider: true,
                              ),
                              CommonContainer.serviceDetails(
                                filedName: 'Fan Repair Service',
                                imageWidth: 130,
                                image: AppImages.servicesFiled2,
                                ratingStar: '4.5',
                                ratingCount: '16',
                                offAmound: '₹150',
                                horizontalDivider: true,
                              ),
                              CommonContainer.serviceDetails(
                                filedName: 'AC Installation',
                                imageWidth: 130,
                                image: AppImages.servicesFiled3,
                                ratingStar: '4.5',
                                ratingCount: '16',
                                offAmound: '₹1200',
                                horizontalDivider: true,
                              ),
                              CommonContainer.serviceDetails(
                                filedName: 'Building Construction',
                                imageWidth: 130,
                                image: AppImages.servicesFiled4,
                                ratingStar: '4.5',
                                ratingCount: '16',
                                offAmound: '₹15000',
                                horizontalDivider: true,
                              ),
                              CommonContainer.serviceDetails(
                                filedName: 'Welding Service',
                                imageWidth: 130,
                                image: AppImages.servicesFiled5,
                                ratingStar: '4.5',
                                ratingCount: '16',
                                offAmound: '₹150',
                                horizontalDivider: true,
                              ),
                              CommonContainer.serviceDetails(
                                filedName: 'Building Construction',
                                imageWidth: 130,
                                image: AppImages.servicesFiled6,
                                ratingStar: '4.5',
                                ratingCount: '16',
                                offAmound: '₹15000',
                                horizontalDivider: false,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
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
