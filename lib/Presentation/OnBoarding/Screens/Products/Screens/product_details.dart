import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Core/Utility/app_loader.dart';
import 'package:tringo_app/Core/Utility/map_urls.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/No%20Data%20Screen/Screen/no_data_screen.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Products/Controller/product_notifier.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/Common Bottom Navigation bar/payment_successful_bottombar.dart';
import '../../../../../Core/Widgets/common_container.dart';
import '../../Home Screen/Controller/home_notifier.dart';

class ProductDetails extends ConsumerStatefulWidget {
  final String? productId;
  const ProductDetails({super.key, this.productId});

  @override
  ConsumerState<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends ConsumerState<ProductDetails> {
  int quantity = 1;

  bool _messageDisabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(productNotifierProvider.notifier)
          .viewAllProducts(productId: widget.productId ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productNotifierProvider);
    final homeState = ref.watch(homeNotifierProvider);
    if (state.isLoading) {
      return Scaffold(
        body: Center(child: ThreeDotsLoader(dotColor: AppColor.black)),
      );
    }
    final productDetailData = state.productDetailsResponse;
    final shopsData = state.productDetailsResponse?.data.shop;
    final highlights = state.productDetailsResponse?.data.product.highlights;

    final similarProducts = state.productDetailsResponse?.data.similarProducts;
    if (productDetailData == null) {
      return const Scaffold(body: Center(child: NoDataScreen()));
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
                        itemCount: productDetailData.data.product.media.length,
                        itemBuilder: (context, index) {
                          final data =
                              productDetailData.data.product.media[index];
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
                        SizedBox(width: 10),
                        productDetailData.data.product.doorDelivery == true
                            ? CommonContainer.doorDelivery()
                            : SizedBox.shrink(),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      productDetailData.data.product.englishName.toString() ??
                          '',
                      style: GoogleFont.Mulish(
                        fontSize: 18,
                        color: AppColor.darkBlue,
                      ),
                    ),
                    SizedBox(height: 9),
                    CommonContainer.greenStarRating(
                      ratingCount: productDetailData.data.product.rating
                          .toString(),
                      ratingStar: productDetailData.data.product.ratingCount
                          .toString(),
                    ),

                    SizedBox(height: 9),
                    Row(
                      children: [
                        Text(
                          '₹${productDetailData.data.product.price}',
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
                              '₹${productDetailData.data.product.offerPrice}',
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
                    // MapUrls.openMap(context: context, latitude: productDetailData.data.shop.l, longitude: longitude)
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
                  messageDisabled: _messageDisabled,
                  messageOnTap: () {

                    if (_messageDisabled || homeState.isEnquiryLoading) return;

                    // ✅ lock this message button
                    setState(() {
                      _messageDisabled = true;
                    });
                    ref
                        .read(homeNotifierProvider.notifier)
                        .putEnquiry(
                          context: context,
                          serviceId: '',
                          productId: productDetailData.data.product.id,
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
              SizedBox(
                height: 400,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  itemCount: similarProducts?.items.length,
                  itemBuilder: (context, index) {
                    final data = similarProducts?.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: CommonContainer.similarFoods(
                        Verify: shopsData?.isTrusted ?? false,
                        doorDelivery: data?.doorDelivery ?? false,
                        image: data?.imageUrl.toString() ?? '',
                        foodName: data?.englishName.toString() ?? '',
                        ratingStar: data?.rating.toString() ?? '',
                        ratingCount: data?.ratingCount.toString() ?? '',
                        offAmound: '₹${data?.price.toString() ?? ''}',
                        oldAmound: '₹${data?.offerPrice}',
                        km: '230Mts',
                        location: 'Lakshmi Bevan',
                      ),
                    );
                  },
                ),
              ),

              /*SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    CommonContainer.similarFoods(
                      Verify: true,
                      image: AppImages.fanImage8,
                      foodName:
                          'Atomberg Aris Starlight 48" Silent Energy Efficient BLDC Motor With Sm – Alphaeshop Limited',
                      ratingStar: '4.5',
                      ratingCount: '16',
                      offAmound: '₹60',
                      oldAmound: '₹80',
                      km: '230Mts',
                      location: 'Lakshmi Bevan',
                    ),
                    SizedBox(width: 20),
                    CommonContainer.similarFoods(
                      Verify: false,
                      image: AppImages.fanImage9,
                      foodName:
                          'Atomberg Studio+ 1200 mm BLDC Ceiling Fan with Remote Control & LED Indicators | Midnight Black',
                      ratingStar: '4.5',
                      ratingCount: '16',
                      offAmound: '₹120',
                      oldAmound: '₹128',
                      km: '5Kms',
                      location: 'Hotel Dave',
                    ),
                  ],
                ),
              ),*/
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

                    /*Container(
                      decoration: BoxDecoration(
                        color: AppColor.whiteSmoke,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Speed',
                            style: GoogleFont.Mulish(
                              color: AppColor.lightGray3,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '300CNM',
                              textAlign:
                                  TextAlign.center, // CENTER OF RIGHT HALF
                              style: GoogleFont.Mulish(
                                fontWeight: FontWeight.w700,
                                color: AppColor.darkBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),*/
                    if (productDetailData.data.product.highlights.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: highlights?.length,
                        itemBuilder: (context, index) {
                          final data = highlights?[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColor.whiteSmoke,
                              // borderRadius: BorderRadius.only(
                              //   bottomLeft: Radius.circular(16),
                              //   bottomRight: Radius.circular(16),
                              // ),
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
                                    textAlign: TextAlign
                                        .center, // CENTER OF RIGHT HALF
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
