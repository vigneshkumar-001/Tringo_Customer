import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Core/Widgets/caller_id_role_helper.dart';
import '../../../Core/Widgets/common_container.dart';
import '../../../Core/app_go_routes.dart';
import '../../../Core/permissions/permission_service.dart';
import 'Home Screen/Screens/home_screen.dart';
import 'Login Screen/Controller/app_version_notifier.dart';
import 'Login Screen/login_mobile_number.dart';
import 'fill_profile/Screens/fill_profile.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with WidgetsBindingObserver {
  String appVersion = '1.0.0';

  bool _batteryFlowRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Request base permissions (contacts + overlay + notification)
    PermissionService.requestOverlayAndContacts();

    checkNavigation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  // @override
  // void initState() {
  //   super.initState();
  //   checkNavigation();
  //   PermissionService.requestOverlayAndContacts();
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _batteryOptimizationFlow(); // re-check after settings
    }
  }

  Future<void> checkNavigation() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');
    final bool isProfileCompleted =
        prefs.getBool("isProfileCompleted") ?? false;

    // 1) Check app version
    await ref
        .read(appVersionNotifierProvider.notifier)
        .getAppVersion(
          appPlatForm: 'android',
          appVersion: appVersion,
          appName: 'customer',
        );

    final versionState = ref.read(appVersionNotifierProvider);

    if (versionState.appVersionResponse?.data?.forceUpdate == true) {
      _showUpdateBottomSheet();
      return;
    }

    // 2) Battery + role + overlay flow (Android only)
    await _batteryOptimizationFlow();

    // 3) Hold splash for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // 4) Navigate
    if (token == null) {
      context.go(AppRoutes.loginPath);
    } else if (!isProfileCompleted) {
      context.go(AppRoutes.fillProfilePath);
    } else {
      context.go(AppRoutes.homePath);
    }
  }

  /// ✅ Mandatory battery optimization disable (no Later option)
  Future<void> _batteryOptimizationFlow() async {
    if (!Platform.isAndroid) return;
    if (_batteryFlowRunning) return; // prevent multiple popups
    _batteryFlowRunning = true;

    try {
      // Check if battery optimization already unrestricted
      final isIgnoring =
          await CallerIdRoleHelper.isIgnoringBatteryOptimizations();

      if (isIgnoring == true) {
        _batteryFlowRunning = false;
        return;
      }

      if (!mounted) {
        _batteryFlowRunning = false;
        return;
      }

      // Show explanation + only one button (Open Settings)
      await _showBatteryMandatoryBottomSheet();

      // Open settings
      await CallerIdRoleHelper.openBatteryUnrestrictedSettings();

      // After coming back -> didChangeAppLifecycleState(resumed) will re-check
    } catch (_) {
      _batteryFlowRunning = false;
    }
  }

  Future<void> _showBatteryMandatoryBottomSheet() async {
    return showModalBottomSheet(
      backgroundColor: AppColor.white,
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Battery Optimization Required",
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "To show Caller ID popup reliably on Android 12–15, you must set Tringo battery usage to "
                "\"Unrestricted\" (or disable battery optimization).\n\n"
                "Please do this now:\n"
                "Settings → Apps → Tringo → Battery → Unrestricted",
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSans(fontSize: 14),
              ),
              const SizedBox(height: 24),

              // ✅ Only button (No Later)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColor.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "Open Settings",
                    style: GoogleFonts.ibmPlexSans(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUpdateBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Update Available",
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                "A new version of the app is available. Please update to continue.",
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSans(fontSize: 14),
              ),
              const SizedBox(height: 24),
              CommonContainer.button(
                text: Text('Update Now'),
                onTap: () {
                  openPlayStore();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void openPlayStore() async {
    final versionState = ref.read(appVersionNotifierProvider);
    final storeUrl =
        versionState.appVersionResponse?.data?.store.android.toString() ?? '';

    if (storeUrl.isEmpty) {
      print('No URL available.');
      return;
    }

    final uri = Uri.parse(storeUrl);
    print('Trying to launch: $uri');

    // Try in-app or platform default mode
    final success = await launchUrl(
      uri,
      mode: LaunchMode.platformDefault, // or LaunchMode.inAppWebView
    );

    if (!success) {
      print('Could not open the link. Maybe no browser is installed.');
    }
  }

  // Future<void> checkNavigation() async {
  //   final prefs = await SharedPreferences.getInstance();
  //
  //   bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
  //   bool isProfileCompleted = prefs.getBool("isProfileCompleted") ?? false;
  //
  //   // Hold splash for 5 seconds
  //   await Future.delayed(const Duration(seconds: 5));
  //
  //   if (!isLoggedIn) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => LoginMobileNumber()),
  //     );
  //   } else if (!isProfileCompleted) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => FillProfile()),
  //     );
  //   } else {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => HomeScreen()),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              AppImages.splashScreen,
              width: w,
              height: h,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: h * 0.53,
              left: w * 0.43,
              child: Text(
                'V $appVersion',
                style: GoogleFont.Mulish(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColor.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
