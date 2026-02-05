import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_border/dotted_border.dart' as dotted;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Home%20Screen/Screens/home_screen.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Surprise_Screens/Screens/surprise_screens.dart';

import '../../../../Core/Utility/app_Images.dart';
import '../../../../Core/Utility/app_color.dart';
import '../../../../Core/Utility/app_snackbar.dart';
import '../../../../Core/Utility/google_font.dart';
import '../../../../Core/Widgets/common_container.dart';
import '../../../../Core/app_go_routes.dart';
import '../Edit Profile/Screens/edit_profile.dart';
import '../Login Screen/Screens/login_mobile_number.dart';
import '../Login Screen/Screens/referral_screens.dart';
import '../Privacy Policy/screens/privacy_policy.dart';
import '../Support/Screens/support_screen.dart';
import '../wallet/Screens/referral_screen.dart';
import '../wallet/Screens/wallet_screens.dart';
import 'Controller/profile_notifier.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? url;
  final String? name;
  final String? balance;
  final String? phnNumber;
  final String? email;
  final String? dob;
  final String? gender;
  const ProfileScreen({
    super.key,
    this.url,
    this.name,
    this.phnNumber,
    this.balance,
    this.email,
    this.dob,
    this.gender,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColor.white,
          surfaceTintColor: Colors.white,
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
              onPressed: () async {
                // Navigator.pop(context);
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute(builder: (_) => LoginMobileNumber()),
                //   (route) => false,
                // );
                final prefs = await SharedPreferences.getInstance();
                prefs.remove('token');
                // prefs.remove('isProfileCompleted');
                // prefs.remove('isNewOwner');
                await prefs.clear();

                // Then navigate
                context.goNamed(AppRoutes.login);
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

  Future<bool> _confirmDeleteAccount(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: Colors.red.shade600,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Delete Account?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(
                              dialogContext,
                            ).pop(false); // <-- return false
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            foregroundColor: Colors.grey.shade700,
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(
                              dialogContext,
                            ).pop(true); // <-- return true
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return result ?? false; // if dialog is dismissed unexpectedly
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await _confirmDeleteAccount(context);
    if (!confirmed) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref.read(profileNotifier.notifier).deleteAccount();
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // always close loader
      }
    }

    final st = ref.read(profileNotifier);

    final success =
        st.deleteResponse?.status == true &&
        st.deleteResponse?.data.deleted == true;

    if (!mounted) return;

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      AppSnackBar.success(context, "Account deleted successfully");
      context.goNamed(AppRoutes.login);
    } else {
      AppSnackBar.error(context, st.error ?? "Delete failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = ((widget.name ?? '').trim().toLowerCase() == 'null')
        ? ''
        : (widget.name ?? '').trim();

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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                        // Navigator.pop(context);
                      },
                    ),
                    // Spacer(),
                    // InkWell(
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => WalletScreens(),
                    //       ),
                    //     );
                    //   },
                    //   child: DottedBorder(
                    //     color: AppColor.mistGray,
                    //     dashPattern: [4.0, 2.0],
                    //     borderType: dotted.BorderType.RRect,
                    //     padding: EdgeInsets.all(10),
                    //     radius: Radius.circular(18),
                    //     child: Row(
                    //       children: [
                    //         Image.asset(
                    //           AppImages.coinImage,
                    //           height: 16,
                    //           width: 17.33,
                    //           color: AppColor.darkBlue,
                    //         ),
                    //         SizedBox(width: 6),
                    //         Text(
                    //           widget.balance.toString() ?? '',
                    //           style: GoogleFont.Mulish(
                    //             fontWeight: FontWeight.w900,
                    //             fontSize: 12,
                    //             color: AppColor.darkBlue,
                    //           ),
                    //         ),
                    //         Text(
                    //           ' Tcoins',
                    //           style: GoogleFont.Mulish(
                    //             fontSize: 12,
                    //             color: AppColor.darkBlue,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
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
                              displayName,
                              style: GoogleFont.Mulish(
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                                color: AppColor.white,
                              ),
                            ),
                            Text(
                              widget.phnNumber.toString() ?? '',
                              style: GoogleFont.Mulish(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColor.lightGray,
                              ),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () {
                                // context.pushNamed(AppRoutes.editProfilePath);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfile(
                                      url: widget.url,
                                      name: widget.name,
                                      phone: widget.phnNumber,
                                      email: widget.email,
                                      dob: widget.dob,
                                      gender: widget.gender,
                                    ),
                                  ),
                                );
                              },
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
                                  SizedBox(width: 6),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: widget.url ?? '',
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,

                            placeholder: (context, url) => Container(
                              height: 120,
                              width: 120,
                              color: Colors.grey.withOpacity(0.2),
                            ),

                            errorWidget: (context, url, error) => Container(
                              height: 120,
                              width: 120,
                              color: Colors.grey.withOpacity(0.2),
                              child: const Icon(Icons.broken_image, size: 28),
                            ),
                          ),
                        ),
                      ),

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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WalletScreens()),
                    );
                  },
                  label: 'Earnings',
                  iconPath: AppImages.earnings,
                  iconHeight: 25,
                  iconWidth: 19,
                ),
                SizedBox(height: 15),
                CommonContainer.profileList(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReferralScreen()),
                    );
                  },
                  label: 'My Referrals',
                  iconPath: AppImages.myReferrals,
                  iconHeight: 25,
                  iconWidth: 19,
                ),

                SizedBox(height: 15),
                CommonContainer.profileList(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SupportScreen()),
                    );
                  },
                  label: 'Support',
                  iconPath: AppImages.support,
                  iconHeight: 25,
                  iconWidth: 19,
                ),
                SizedBox(height: 20),
                CommonContainer.horizonalDivider(),
                SizedBox(height: 20),
                CommonContainer.profileList(
                  onTap: _handleDeleteAccount,
                  label: 'Delete Account',
                  iconPath: AppImages.accountRelated,
                  iconHeight: 25,
                  iconWidth: 19,
                ),
                // SizedBox(height: 15),
                // CommonContainer.profileList(
                //   onTap: () {},
                //   label: 'Search History',
                //   iconPath: AppImages.searchHistory,
                //   iconHeight: 25,
                //   iconWidth: 19,
                // ),
                SizedBox(height: 15),
                CommonContainer.profileList(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PrivacyPolicy(showAcceptReject: false),
                      ),
                    );
                  },
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
