import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../Core/Utility/app_Images.dart';
import '../../../../Core/Utility/app_color.dart';
import '../../../../Core/Utility/google_font.dart';
import '../../../../Core/Widgets/Common Bottom Navigation bar/service_and_shops_details.dart';
import '../../../../Core/Widgets/common_container.dart';
import '../../../../Core/Widgets/current_location_widget.dart';
import 'Service_details.dart';

class ServiceListing extends StatefulWidget {
  final String? title;
  const ServiceListing({super.key, this.title});

  @override
  State<ServiceListing> createState() => _ServiceListingState();
}

class _ServiceListingState extends State<ServiceListing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> aHeader;
  late Animation<double> aTitle;
  late List<Animation<double>> aServices;

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

    WidgetsBinding.instance.addPostFrameCallback((_) => _ac.forward());
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
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
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
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Spacer(),
                      Expanded(
                        child: CurrentLocationWidget(
                          locationIcon: AppImages.locationImage,
                          dropDownIcon: AppImages.drapDownImage,
                          textStyle: GoogleFonts.mulish(
                            color: AppColor.darkBlue,
                            fontWeight: FontWeight.w600,
                          ),
                          onTap: () {
                            // Handle location change, e.g., open map picker or bottom sheet
                            print('Change location tapped!');
                          },
                        ),
                      ),
                      /*        CommonContainer.gradientContainer(
                        lIconColor: AppColor.blue,
                        iconImage: AppImages.drapDownImage,
                        locationImage: AppImages.locationImage,
                        text: 'Marudhupandiyar nagar main road, Madurai',
                      ),*/
                    ],
                  ),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: _fadeSlide(
                  aTitle,
                  Text(
                    'Electricians Services',
                    style: GoogleFont.Mulish(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: AppColor.black,
                    ),
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
                      _fadeSlide(
                        aServices[0],
                        CommonContainer.servicesContainer(
                          horizontalDivider: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ServiceAndShopsDetails(initialIndex: 3),
                              ),
                            );
                            // Navigator.of(context).push(
                            //   PageRouteBuilder(
                            //     transitionDuration: const Duration(
                            //       milliseconds: 650,
                            //     ),
                            //     reverseTransitionDuration: const Duration(
                            //       milliseconds: 550,
                            //     ),
                            //     pageBuilder: (_, animation, __) =>
                            //         ServiceDetails(
                            //           heroTag: 'serviceImageHero_sks',
                            //           image: AppImages.servicesContainer1,
                            //         ),
                            //     transitionsBuilder: (_, animation, __, child) {
                            //       final curve = CurvedAnimation(
                            //         parent: animation,
                            //         curve: Curves.easeOutCubic,
                            //         reverseCurve: Curves.easeInCubic,
                            //       );
                            //       return FadeTransition(
                            //         opacity: curve,
                            //         child: child,
                            //       );
                            //     },
                            //   ),
                            // );
                          },
                          Verify: true,
                          image: AppImages.servicesContainer1,
                          companyName: 'Home Triangle - Electricians',
                          location: '12, 2, Tirupparankunram Rd, kunram ',
                          fieldName: 'Company',
                          ratingStar: '4.5',
                          ratingCount: '16',
                          time: '9Pm',
                        ),
                      ),
                      const SizedBox(height: 6),
                      _fadeSlide(
                        aServices[1],
                        CommonContainer.servicesContainer(
                          horizontalDivider: true,
                          onTap: () {},
                          image: AppImages.servicesContainer2,
                          companyName: 'Home Triangle - Electricians',
                          location: '12, 2, Tirupparankunram Rd, kunram ',
                          fieldName: 'Individual',
                          ratingStar: '4.5',
                          ratingCount: '16',
                          time: '9Pm',
                        ),
                      ),
                      const SizedBox(height: 6),
                      _fadeSlide(
                        aServices[2],
                        CommonContainer.servicesContainer(
                          horizontalDivider: true,
                          onTap: () {},
                          image: AppImages.servicesContainer3,
                          companyName: 'Home Triangle - Electricians',
                          location: '12, 2, Tirupparankunram Rd, kunram ',
                          fieldName: 'Individual',
                          ratingStar: '4.5',
                          ratingCount: '16',
                          time: '9Pm',
                        ),
                      ),
                      const SizedBox(height: 6),
                      _fadeSlide(
                        aServices[3],
                        CommonContainer.servicesContainer(
                          horizontalDivider: true,
                          onTap: () {},
                          image: AppImages.servicesContainer4,
                          companyName: 'Home Triangle - Electricians',
                          location: '12, 2, Tirupparankunram Rd, kunram ',
                          fieldName: 'Individual',
                          ratingStar: '4.5',
                          ratingCount: '16',
                          time: '9Pm',
                        ),
                      ),
                      const SizedBox(height: 6),
                      _fadeSlide(
                        aServices[4],
                        CommonContainer.servicesContainer(
                          horizontalDivider: false,
                          onTap: () {},
                          image: AppImages.servicesContainer5,
                          companyName: 'Home Triangle - Electricians',
                          location: '12, 2, Tirupparankunram Rd, kunram ',
                          fieldName: 'Individual',
                          ratingStar: '4.5',
                          ratingCount: '16',
                          time: '9Pm',
                        ),
                      ),
                      const SizedBox(height: 20),
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
