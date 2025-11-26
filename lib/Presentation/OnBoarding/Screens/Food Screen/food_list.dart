import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../Core/Utility/app_Images.dart';
import '../../../../Core/Utility/app_color.dart';
import '../../../../Core/Utility/google_font.dart';
import '../../../../Core/Widgets/Common Bottom Navigation bar/food_details_bottombar.dart';
import '../../../../Core/Widgets/common_container.dart';
import '../../../../Core/Widgets/current_location_widget.dart';
import 'food_details.dart';

class FoodList extends StatefulWidget {
  const FoodList({super.key});

  @override
  State<FoodList> createState() => _FoodListState();
}

class _FoodListState extends State<FoodList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
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
                      'Food',
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: AppColor.black,
                      ),
                    ),
                    SizedBox(width: 80),
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
                    // CommonContainer.gradientContainer(
                    //   lIconColor: AppColor.blue,
                    //   iconImage: AppImages.drapDownImage,
                    //   locationImage: AppImages.locationImage,
                    //   text: 'Marudhupandiyar nagar main road, Madurai',
                    // ),
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
                  Ad: true,
                  horizontalDivider: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FoodDetailsBottombar(initialIndex: 3),
                      ),
                    );
                  },
                  Verify: true,
                  image: AppImages.foodList1,
                  foodName: 'Ulti Breakfast Combo',
                  ratingStar: '4.5',
                  ratingCount: '16',
                  offAmound: '₹175',
                  oldAmound: '₹223',
                  km: '1Kms',
                  location: 'Veaan Hotels & Restauant',
                ),
                SizedBox(height: 10),
                CommonContainer.foodList(
                  Ad: true,
                  horizontalDivider: true,
                  onTap: () {},
                  Verify: true,
                  image: AppImages.foodList2,
                  foodName: 'Maharaj Idli',
                  ratingStar: '4.5',
                  ratingCount: '16',
                  offAmound: '₹8',
                  oldAmound: '₹12',
                  km: '1.5Kms',
                  location: 'Dhurn Hotels & Restauant',
                ),
                SizedBox(height: 10),
                CommonContainer.foodList(
                  horizontalDivider: true,
                  onTap: () {},
                  image: AppImages.foodList3,
                  foodName: 'Veg Meals',
                  ratingStar: '4.5',
                  ratingCount: '16',
                  offAmound: '₹75',
                  oldAmound: '₹125',
                  km: '113Kms',
                  location: 'Kumar Mess',
                ),
                SizedBox(height: 10),
                CommonContainer.foodList(
                  horizontalDivider: true,
                  onTap: () {},
                  image: AppImages.foodList4,
                  foodName: 'Kadai Vada',
                  ratingStar: '4.5',
                  ratingCount: '16',
                  offAmound: '₹42',
                  oldAmound: '₹65',
                  km: '120Kms',
                  location: 'Bhuvana Mess',
                ),
                SizedBox(height: 10),
                CommonContainer.foodList(
                  horizontalDivider: false,
                  onTap: () {},
                  image: AppImages.foodList5,
                  foodName: 'Puliyothara Rocking Combo',
                  ratingStar: '4.5',
                  ratingCount: '16',
                  offAmound: '₹50',
                  oldAmound: '₹65',
                  km: '210Kms',
                  location: 'Veaan Hotels & Restauant',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
