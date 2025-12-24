import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Core/Widgets/common_container.dart';
import '../../../Core/app_go_routes.dart';
import 'Home Screen/Screens/home_screen.dart';
import 'Login Screen/Controller/app_version_notifier.dart';
import 'Login Screen/login_mobile_number.dart';
import 'fill_profile/Screens/fill_profile.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String appVersion = '1.0.0';
  @override
  void initState() {
    super.initState();
    checkNavigation();
  }

  Future<void> checkNavigation() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');
    final bool isProfileCompleted =
        prefs.getBool("isProfileCompleted") ?? false;
    await ref
        .read(appVersionNotifierProvider.notifier)
        .getAppVersion(
          appPlatForm: 'android',
          appVersion: appVersion,
          appName: 'vendor',
        );

    // 2) Read version state and decide
    final versionState = ref.read(appVersionNotifierProvider);

    if (versionState.appVersionResponse?.data?.forceUpdate == true) {
      _showUpdateBottomSheet();

      return;
    }
    // Hold splash for 5 seconds
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    if (token == null) {
      context.go(AppRoutes.loginPath);
    } else if (!isProfileCompleted) {
      context.go(AppRoutes.fillProfilePath);
    } else {
      context.go(AppRoutes.homePath);
    }
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
