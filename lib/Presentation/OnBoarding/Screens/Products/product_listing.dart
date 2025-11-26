import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Products/product_details.dart';

import '../../../../Core/Utility/app_Images.dart';
import '../../../../Core/Utility/app_color.dart';
import '../../../../Core/Utility/google_font.dart';
import '../../../../Core/Widgets/common_container.dart';
import '../../../../Core/Widgets/current_location_widget.dart';
import '../Food Screen/food_details.dart';

class ProductListing extends StatefulWidget {
  final String? title;
  const ProductListing({super.key, this.title});

  @override
  State<ProductListing> createState() => _ProductListingState();
}

class _ProductListingState extends State<ProductListing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CommonContainer.leftSideArrow(
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 15),
                    Text(
                      'BLDC Fan',
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: AppColor.black,
                      ),
                    ),
                    SizedBox(width: 40),
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
                  ],
                ),
                SizedBox(height: 17),
                Text(
                  '100+ Results',
                  style: GoogleFont.Mulish(
                    fontSize: 14,
                    color: AppColor.lightGray2,
                  ),
                ),
                CommonContainer.foodList(
                  titleWeight: FontWeight.w400,
                  locations: true,
                  fontSize: 12,
                  imageWidth: 130,
                  imageHeight: 150,
                  Ad: true,
                  horizontalDivider: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProductDetails()),
                    );
                  },
                  Verify: true,
                  image: AppImages.fanImage1,
                  foodName:
                      'Orient Electric Zeno 1200mm 32W BLDC Energy Saving Ceiling Fan with Remote',
                  ratingStar: '4.5',
                  ratingCount: '16',
                  offAmound: '₹2,999',
                  oldAmound: '₹3,999',
                  km: '5Kms',
                  location: 'Veaan Electricals & Applicances',
                ),
                SizedBox(height: 10),
                CommonContainer.foodList(
                  titleWeight: FontWeight.w400,
                  locations: true,
                  fontSize: 12,
                  imageWidth: 130,
                  imageHeight: 150,
                  Ad: false,
                  horizontalDivider: true,
                  onTap: () {},
                  Verify: false,
                  image: AppImages.fanImage2,
                  foodName: 'Super P400 BLDC Pedestal Fan by Super fan',
                  ratingStar: '4.5',
                  ratingCount: '16',
                  offAmound: '₹2,999',
                  oldAmound: '₹3,999',
                  km: '100Mtrs',
                  location: 'Lkh Electricals & Applicances',
                ),
                SizedBox(height: 10),
                CommonContainer.foodList(
                  titleWeight: FontWeight.w400,
                  locations: true,
                  fontSize: 12,
                  imageWidth: 130,
                  imageHeight: 150,
                  Ad: false,
                  horizontalDivider: true,
                  onTap: () {},
                  Verify: false,
                  image: AppImages.fanImage3,
                  foodName: 'Super P400 BLDC Pedestal Fan by Super fan',
                  ratingStar: '4.5',
                  ratingCount: '16',
                  offAmound: '₹2,999',
                  oldAmound: '₹3,999',
                  km: '100Mtrs',
                  location: 'Lkh Electricals & Applicances',
                ),
                SizedBox(height: 10),
                CommonContainer.foodList(
                  titleWeight: FontWeight.w400,
                  locations: true,
                  fontSize: 12,
                  imageWidth: 130,
                  imageHeight: 150,
                  Ad: false,
                  horizontalDivider: false,
                  onTap: () {},
                  Verify: false,
                  image: AppImages.fanImage4,
                  foodName: 'Super P400 BLDC Pedestal Fan by Super fan',
                  ratingStar: '4.5',
                  ratingCount: '16',
                  offAmound: '₹2,999',
                  oldAmound: '₹3,999',
                  km: '100Mtrs',
                  location: 'Lkh Electricals & Applicances',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
