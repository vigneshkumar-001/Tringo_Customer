import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_border/dotted_border.dart' as dotted;
import 'package:flutter/material.dart';

import '../../../../Core/Utility/app_Images.dart';
import '../../../../Core/Utility/app_color.dart';
import '../../../../Core/Utility/google_font.dart';
import '../../../../Core/Widgets/common_container.dart';
import '../Login Screen/login_mobile_number.dart';

class ProfileScreen extends StatefulWidget {
  final String? url;
  final String? name;
  final String? phnNumber;
  const ProfileScreen({super.key, this.url, this.name, this.phnNumber});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Logout",
            style: GoogleFont.Mulish(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppColor.darkBlue,
            ),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: GoogleFont.Mulish(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColor.lightGray2,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: GoogleFont.Mulish(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkBlue,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginMobileNumber()),
                  (route) => false,
                );
              },
              child: Text(
                "Logout",
                style: GoogleFont.Mulish(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColor.lightRed,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    CommonContainer.leftSideArrow(
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    Spacer(),
                    DottedBorder(
                      color: AppColor.mistGray,
                      dashPattern: [4.0, 2.0],
                      borderType: dotted.BorderType.RRect,
                      padding: EdgeInsets.all(10),
                      radius: Radius.circular(18),
                      child: Row(
                        children: [
                          Image.asset(
                            AppImages.coinImage,
                            height: 16,
                            width: 17.33,
                            color: AppColor.darkBlue,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '10',
                            style: GoogleFont.Mulish(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: AppColor.darkBlue,
                            ),
                          ),
                          Text(
                            ' Tcoins',
                            style: GoogleFont.Mulish(
                              fontSize: 12,
                              color: AppColor.darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 0, left: 25),
                  decoration: BoxDecoration(
                    color: AppColor.darkBlue,
                    image: DecorationImage(
                      image: AssetImage(AppImages.profileContainer),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // left texts...
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name.toString()?? '',
                              style: GoogleFont.Mulish(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: AppColor.white,
                              ),
                            ),
                            Text(
                              widget.phnNumber.toString()?? '',
                              style: GoogleFont.Mulish(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColor.lightGray,
                              ),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () {},
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Edit Details',
                                    style: GoogleFont.Mulish(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppColor.yellow,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Image.asset(
                                    AppImages.rightArrow,
                                    height: 12,
                                    color: AppColor.yellow,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: widget.url == null
                              ? Image.asset(
                            AppImages.avatarImage1,
                            height: 170,
                            width: 170,
                            fit: BoxFit.cover,
                          )
                              : Image.network(
                            widget.url.toString(),
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                      ,


                      // CommonContainer.glowAvatarUniversal(
                      //   image: AssetImage(AppImages.avatarImage1),
                      //   size: 103,
                      //   radius: 24,
                      //   borderWidth: 2,
                      //   borderColor: AppColor.yellow,
                      // ),
                    ],
                  ),
                ),
                SizedBox(height: 27),
                CommonContainer.profileList(
                  onTap: () {},
                  label: 'Food Orders',
                  iconPath: AppImages.foodOrders,
                  iconHeight: 25,
                  iconWidth: 19,
                ),
                SizedBox(height: 15),
                CommonContainer.profileList(
                  onTap: () {},
                  label: 'Earnings',
                  iconPath: AppImages.earnings,
                  iconHeight: 25,
                  iconWidth: 19,
                ),
                SizedBox(height: 15),
                CommonContainer.profileList(
                  onTap: () {},
                  label: 'My Referrals',
                  iconPath: AppImages.myReferrals,
                  iconHeight: 25,
                  iconWidth: 19,
                ),
                SizedBox(height: 15),
                CommonContainer.profileList(
                  onTap: () {},
                  label: 'Saved Locations',
                  iconPath: AppImages.savedLocations,
                  iconHeight: 25,
                  iconWidth: 19,
                ),
                SizedBox(height: 15),
                CommonContainer.profileList(
                  onTap: () {},
                  label: 'Support',
                  iconPath: AppImages.support,
                  iconHeight: 25,
                  iconWidth: 19,
                ),
                SizedBox(height: 20),
                CommonContainer.horizonalDivider(),
                SizedBox(height: 20),
                CommonContainer.profileList(
                  onTap: () {},
                  label: 'Account Related',
                  iconPath: AppImages.accountRelated,
                  iconHeight: 25,
                  iconWidth: 19,
                ),
                SizedBox(height: 15),
                CommonContainer.profileList(
                  onTap: () {},
                  label: 'Search History',
                  iconPath: AppImages.searchHistory,
                  iconHeight: 25,
                  iconWidth: 19,
                ),
                SizedBox(height: 15),
                CommonContainer.profileList(
                  onTap: () {},
                  label: 'Privacy Policy',
                  iconPath: AppImages.privacyPolicy,
                  iconHeight: 25,
                  iconWidth: 19,
                ),
                SizedBox(height: 20),
                CommonContainer.horizonalDivider(),

                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _showLogoutDialog();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(
                        color: AppColor.lightRed,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // optional – rounded corners
                      ),
                    ),
                    child: Text(
                      'Logout',
                      style: GoogleFont.Mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.lightRed, // text color
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
