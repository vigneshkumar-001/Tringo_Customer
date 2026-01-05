import 'package:flutter/material.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';

import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Utility/map_urls.dart';
import '../../../../../Core/Widgets/Common Bottom Navigation bar/service_and_shops_details.dart';
import '../../../../../Core/Widgets/common_container.dart';
import '../../Search Screen/Model/search_suggestion_response.dart';

class DetailMobileNoUser extends StatefulWidget {
  final SearchItem item;
  const DetailMobileNoUser({super.key, required this.item});

  @override
  State<DetailMobileNoUser> createState() => _DetailMobileNoUserState();
}

class _DetailMobileNoUserState extends State<DetailMobileNoUser> {
  bool showUserDetails = true;

  @override
  void initState() {
    super.initState();

    switch (widget.item.type) {
      case 'OWNER_SHOP':
        showUserDetails = false;
        break;
      case 'CUSTOMER':
      case 'VENDOR':
      case 'EMPLOYEE':
      default:
        showUserDetails = true;
    }
  }

  // String get name => widget.item.label;
  String get name => (widget.item.meta?.name ?? '').trim().isNotEmpty
      ? widget.item.meta!.name!.trim()
      : widget.item.label;

  String get phone =>
      widget.item.meta?.phone ??
      widget.item.target.phone ??
      widget.item.target.q;

  String get subtitle =>
      widget.item.meta?.subtitle ?? widget.item.meta?.categoryLabel ?? '';

  // String? get imageUrl => widget.item.meta?.imageUrl;

  String? get imageUrl => (widget.item.meta?.imageUrl);

  int get detailsInitialIndex {
    switch (widget.item.target.kind) {
      case 'SERVICE_DETAIL':
        return 3;
      case 'SHOP_DETAIL':
      default:
        return 4;
    }
  }

  String? get shopId => widget.item.target.shopId;
  String? get pageType => widget.item.target.kind;

  Widget userDetails(double w) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16, top: 20),
              child: Row(
                children: [
                  CommonContainer.leftSideArrow(
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'Mobile Number Info',
                    style: GoogleFont.Mulish(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColor.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  AppImages.mobileNoInfoBCImage,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: w * 0.55,
                      height: 212,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: imageUrl != null && imageUrl!.isNotEmpty
                            ? Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.broken_image_outlined,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Image not available',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Image not available',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 85),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text(
                    name,
                    style: GoogleFont.Mulish(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.black,
                    ),
                  ),
                  SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: GoogleFont.Mulish(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                      children: [
                        TextSpan(
                          text: "Mobile No ",
                          style: GoogleFont.Mulish(color: AppColor.darkBlue),
                        ),
                        TextSpan(
                          text: phone,
                          style: GoogleFont.Mulish(
                            color: AppColor.blue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 110),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () async {
                        await MapUrls.openDialer(context, phone);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.blue,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(AppImages.callImage, height: 16),
                              SizedBox(width: 10),
                              Text(
                                'Call Now',
                                style: GoogleFont.Mulish(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  _adsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget shopDetails(double w) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 16,
                      left: 16,
                      top: 20,
                    ),
                    child: Row(
                      children: [
                        CommonContainer.leftSideArrow(
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'Mobile Number Info',
                          style: GoogleFont.Mulish(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColor.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 300, // ✅ adjust (280-340) based on your design
                    width: double.infinity,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Image.asset(
                          AppImages.mobileNoInfoBCImage,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 80,
                          left: 0,
                          right: 0,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              width: w * 0.85,
                              height: 212,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: imageUrl != null && imageUrl!.isNotEmpty
                                    ? Image.network(
                                        imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              // ❌ Broken image UI
                                              return Container(
                                                color: Colors.grey.shade200,
                                                alignment: Alignment.center,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Icon(
                                                      Icons
                                                          .broken_image_outlined,
                                                      size: 48,
                                                      color: Colors.grey,
                                                    ),
                                                    SizedBox(height: 6),
                                                    Text(
                                                      'Image not available',
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                      )
                                    : Container(
                                        color: Colors.grey.shade200,
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.broken_image_outlined,
                                              size: 48,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              'Image not available',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                              // networkImageWithRadius(
                              //   url: imageUrl,
                              //   radius: 18,
                              //   fit: BoxFit.cover,
                              // ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // NOW THIS WILL "SHOW FULL" PROPERLY
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        // Center(
                        //   child: CommonContainer.gradientContainer(
                        //     text: subtitle,
                        //     textColor: AppColor.skyBlue,
                        //     fontWeight: FontWeight.w700,
                        //   ),
                        // ),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: CommonContainer.gradientContainer(
                              text: subtitle,
                              textColor: AppColor.skyBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFont.Mulish(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColor.black,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        RichText(
                          text: TextSpan(
                            style: GoogleFont.Mulish(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                            children: [
                              TextSpan(
                                text: "Mobile No ",
                                style: GoogleFont.Mulish(
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              TextSpan(
                                text: phone,
                                style: GoogleFont.Mulish(
                                  color: AppColor.blue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () async {
                                    await MapUrls.openDialer(context, phone);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.blue,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          AppImages.callImage,
                                          height: 16,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Call Now',
                                          style: GoogleFont.Mulish(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColor.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () {
                                    if (shopId == null || shopId!.isEmpty)
                                      return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ServiceAndShopsDetails(
                                          initialIndex: detailsInitialIndex,
                                          shopId: shopId,
                                          type: pageType,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.darkBlue,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Details',
                                          style: GoogleFont.Mulish(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColor.white,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Image.asset(
                                          AppImages.rightSideArrow,
                                          height: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        _adsSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _adsSection() {
    return Column(
      children: [
        const SizedBox(height: 30),
        CommonContainer.horizonalDivider(),
        const SizedBox(height: 30),

        Text(
          'Advertisements',
          style: GoogleFont.Mulish(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColor.darkBlue,
          ),
        ),

        const SizedBox(height: 30),

        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [_adCard(), const SizedBox(width: 15), _adCard()],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _adCard() {
    return Container(
      width: 288,
      decoration: BoxDecoration(
        color: AppColor.veryLightGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                AppImages.foodImage2,
                height: 140,
                width: 259,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            CommonContainer.verifyTick(),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Sri Krishna',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFont.Mulish(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColor.darkBlue,
                  ),
                ),
                const SizedBox(width: 4),
                Image.asset(
                  AppImages.rightArrow,
                  width: 8,
                  height: 12,
                  color: AppColor.lightBlueCont,
                ),
              ],
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
                Expanded(
                  child: Text(
                    '12, 2, Tirupparankunram Rd, kunram ',
                    style: GoogleFont.Mulish(
                      fontSize: 12,
                      color: AppColor.lightGray2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '5Kms',
                  style: GoogleFont.Mulish(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColor.lightGray3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                CommonContainer.greenStarRating(
                  ratingCount: '4.5',
                  ratingStar: '16',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'Opens Upto ',
                      style: GoogleFont.Mulish(
                        fontSize: 10,
                        color: AppColor.lightGray2,
                      ),
                      children: [
                        TextSpan(
                          text: '9Pm',
                          style: GoogleFont.Mulish(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColor.lightGray2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(body: showUserDetails ? userDetails(w) : shopDetails(w));
  }
}
