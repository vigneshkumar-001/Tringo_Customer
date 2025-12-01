import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Core/Utility/app_loader.dart';
import 'package:tringo_app/Core/Utility/map_urls.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Products/Controller/product_notifier.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Services%20Screen/Controller/service_data_notifier.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/Common Bottom Navigation bar/payment_successful_bottombar.dart';
import '../../../../../Core/Widgets/common_container.dart';
import '../../Home Screen/Controller/home_notifier.dart';

class SearchServiceData extends ConsumerStatefulWidget {
  final String? serviceId;
  const SearchServiceData({super.key, this.serviceId});

  @override
  ConsumerState<SearchServiceData> createState() => _SearchServiceDataState();
}

class _SearchServiceDataState extends ConsumerState<SearchServiceData> {
  int quantity = 1;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(serviceDataNotifierProvider.notifier)
          .viewDetailServices(serviceId: widget.serviceId ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceDataNotifierProvider);
    final homeState = ref.watch(homeNotifierProvider);
    if (state.isLoading) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }
    final productDetailData = state.serviceDataResponse;
    final shopsData = state.serviceDataResponse?.data.shop;
    final highlights = state.serviceDataResponse?.data.service.highlights;

    final similarProducts = state.serviceDataResponse?.data.similarServices;
    if (productDetailData == null) {
      return const Scaffold(body: Center(child: Text('No data')));
    }
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: AppColor.whiteSmoke,
                  // gradient: LinearGradient(
                  //   colors: [
                  //     AppColor.white,
                  //     AppColor.white,
                  //     AppColor.whiteSmoke,
                  //   ],
                  //   begin: Alignment.topCenter,
                  //   end: Alignment.bottomCenter,
                  // ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 16,
                      ),
                      child: CommonContainer.leftSideArrow(
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(
                      height: 215,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemCount: productDetailData.data.service.media.length,
                        itemBuilder: (context, index) {
                          final data =
                              productDetailData.data.service.media[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(20),
                              child: CachedNetworkImage(
                                imageUrl: data.url.toString() ?? '',
                                height: 250,
                                width: 310,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 250,
                                  width: 310,
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.broken_image),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 35),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        productDetailData.data.shop.isTrusted == true
                            ? CommonContainer.verifyTick()
                            : SizedBox.shrink(),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      productDetailData.data.service.englishName.toString() ??
                          '',
                      style: GoogleFont.Mulish(
                        fontSize: 18,
                        color: AppColor.darkBlue,
                      ),
                    ),
                    SizedBox(height: 9),
                    CommonContainer.greenStarRating(
                      ratingCount: productDetailData.data.service.rating
                          .toString(),
                      ratingStar: productDetailData.data.service.reviewCount
                          .toString(),
                    ),

                    SizedBox(height: 9),
                    Row(
                      children: [
                        Text(
                          '₹${productDetailData.data.service.startsAt}',
                          style: GoogleFont.Mulish(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            color: AppColor.darkBlue,
                          ),
                        ),
                        SizedBox(width: 10),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '₹${productDetailData.data.service.offerPrice}',
                              style: GoogleFont.Mulish(
                                fontSize: 14,
                                color: AppColor.lightGray3,
                              ),
                            ),
                            Transform.rotate(
                              angle: -0.1,
                              child: Container(
                                height: 1.5,
                                width: 40,
                                color: AppColor.lightGray3,
                              ),
                            ),
                          ],
                        ),
                      ],
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
                  callOnTap: () {
                    MapUrls.openDialer(
                      context,
                      productDetailData.data.shop.primaryPhone,
                    );
                  },
                  mapBox: true,
                  mapOnTap: () {
                    MapUrls.openMap(
                      context: context,
                      latitude:
                          productDetailData.data.shop.coordinates.latitude
                              .toString() ??
                          '',
                      longitude:
                          productDetailData.data.shop.coordinates.longitude
                              .toString() ??
                          '',
                    );
                  },
                  mapText: 'Map',
                  mapBoxPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  order: false,
                  callText: 'Call Now',
                  callImage: AppImages.callImage,
                  callIconSize: 21,
                  callTextSize: 16,
                  messagesIconSize: 23,
                  whatsAppIconSize: 23,
                  fireIconSize: 23,
                  callNowPadding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  iconContainerPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  whatsAppIcon: true,
                  messageLoading: homeState.isEnquiryLoading,
                  messageOnTap: () {
                    ref
                        .read(homeNotifierProvider.notifier)
                        .putEnquiry(
                          context: context,
                          serviceId: productDetailData.data.service.id,
                          productId: '',
                          message: '',
                          shopId:
                              productDetailData.data.shop.id.toString() ?? '',
                        );
                  },
                  whatsAppOnTap: () {},
                  messageContainer: true,
                  MessageIcon: true,
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.textWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 10,
                  ), // Optional padding
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            productDetailData.data.shop.isTrusted == true
                                ? CommonContainer.verifyTick()
                                : SizedBox.shrink(),
                            SizedBox(height: 6),

                            Row(
                              children: [
                                Text(
                                  shopsData?.englishName.toString() ?? '',
                                  style: GoogleFont.Mulish(
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.darkBlue,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Image.asset(
                                  AppImages.rightArrow,
                                  height: 8,
                                  color: AppColor.lightBlueCont,
                                ),
                              ],
                            ),

                            SizedBox(height: 6),

                            Row(
                              children: [
                                Image.asset(
                                  AppImages.locationImage,
                                  height: 10,
                                  color: AppColor.lightGray2,
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${shopsData?.city}, ${shopsData?.state},${shopsData?.country}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFont.Mulish(
                                      fontSize: 12,
                                      color: AppColor.lightGray2,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '5Kms',
                                  style: GoogleFont.Mulish(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: AppColor.lightGray3,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                CommonContainer.greenStarRating(
                                  ratingCount:
                                      shopsData?.rating.toString() ?? '',
                                  ratingStar:
                                      shopsData?.ratingCount.toString() ?? '',
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Opens Upto ',
                                  style: GoogleFont.Mulish(
                                    fontSize: 10,
                                    color: AppColor.lightGray2,
                                  ),
                                ),
                                Text(
                                  '9Pm',
                                  style: GoogleFont.Mulish(
                                    fontSize: 10,
                                    color: AppColor.lightGray2,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(20),
                          child: CachedNetworkImage(
                            imageUrl:
                                shopsData?.primaryImageUrl?.toString() ?? '',
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 100,
                              width: 100,
                              color: Colors.grey.withOpacity(0.2),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 60),
              CommonContainer.horizonalDivider(),
              SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Text(
                      'Similar Products',
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: AppColor.darkBlue,
                      ),
                    ),
                    Spacer(),
                    CommonContainer.rightSideArrowButton(onTap: () {}),
                  ],
                ),
              ),
              SizedBox(height: 20),
              similarProducts != null && similarProducts.items.isNotEmpty
                  ? SizedBox(
                      height: 400,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        itemCount: similarProducts.items.length,
                        itemBuilder: (context, index) {
                          final data = similarProducts.items[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: CommonContainer.similarFoods(
                              Verify: shopsData?.isTrusted ?? false,
                              image: data.primaryImageUrl ?? '',
                              foodName: data.englishName ?? '',
                              ratingStar: data.rating?.toString() ?? '',
                              ratingCount: data.ratingCount?.toString() ?? '',
                              offAmound: '₹${data.startsAt?.toString() ?? ''}',
                              oldAmound:
                                  '₹${data.offerPrice?.toString() ?? ''}',
                              km: '230Mts',
                              location: 'Lakshmi Bevan',
                            ),
                          );
                        },
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No Similar Products',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

              CommonContainer.horizonalDivider(),
              SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(AppImages.roundStar, height: 25),
                        SizedBox(width: 10),
                        Text(
                          'Highlights',
                          style: GoogleFont.Mulish(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColor.darkBlue,
                          ),
                        ),
                      ],
                    ),

                    if (productDetailData.data.service.highlights.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: highlights?.length ?? 0,
                        itemBuilder: (context, index) {
                          final data = highlights?[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColor.whiteSmoke,
                              borderRadius: BorderRadius.only(
                                topLeft: index == 0
                                    ? Radius.circular(16)
                                    : Radius.zero,
                                topRight: index == 0
                                    ? Radius.circular(16)
                                    : Radius.zero,
                                bottomLeft:
                                    index == (highlights?.length ?? 0) - 1
                                    ? Radius.circular(16)
                                    : Radius.zero,
                                bottomRight:
                                    index == (highlights?.length ?? 0) - 1
                                    ? Radius.circular(16)
                                    : Radius.zero,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  data?.label.toString() ?? '',
                                  style: GoogleFont.Mulish(
                                    color: AppColor.lightGray3,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    data?.value.toString() ?? '',
                                    textAlign: TextAlign.center,
                                    style: GoogleFont.Mulish(
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No Highlights Available',
                            style: GoogleFont.Mulish(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),

                    SizedBox(height: 52),
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
                    SizedBox(height: 20),
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
                    SizedBox(height: 35),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
