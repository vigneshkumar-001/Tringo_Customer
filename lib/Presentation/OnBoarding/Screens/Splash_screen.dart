import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Core/Const/app_logger.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Core/Widgets/caller_id_role_helper.dart';
import '../../../Core/Widgets/common_container.dart';
import '../../../Core/app_go_routes.dart';
import '../../../Core/permissions/permission_service.dart';
import 'Login Screen/Controller/app_version_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with WidgetsBindingObserver {
  String appVersion = '1.0.0';

  bool _batteryFlowRunning = false;
  bool _navigated = false;
  static const String _batteryLastOkKey = "battery_last_ok";
  bool _batterySheetOpen = false;

  static const String _batteryDontAskKey = "battery_dont_ask_again";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ✅ 1) MUST request Phone/CallLog/Contacts first
      final ok = await PermissionService.requestCorePermissionsWithDialog(
        context,
      );
      if (!ok) return;
      // final nativeOk = await CallerIdRoleHelper.debugPhonePerm();
      // debugPrint("✅ NATIVE READ_PHONE_STATE => $nativeOk");
      // ✅ 2) Overlay permission (optional here)
      final req = await CallerIdRoleHelper.requestReadPhoneState();
      final now = await CallerIdRoleHelper.debugPhonePerm();
      print("PHONE req=$req now=$now");

      await PermissionService.requestOverlayIfNeeded();

      // ✅ 3) Continue your flow
      await checkNavigation();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ✅ Only check again if still on splash (not navigated)
    if (state == AppLifecycleState.resumed && !_navigated) {
      _batteryOptimizationFlow();
    }
  }

  Future<void> checkNavigation() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');
    final bool isProfileCompleted =
        prefs.getBool("isProfileCompleted") ?? false;

    // 1) Version check
    await ref
        .read(appVersionNotifierProvider.notifier)
        .getAppVersion(
          appPlatForm: 'android',
          appVersion: appVersion,
          appName: 'customer',
        );

    final versionState = ref.read(appVersionNotifierProvider);

    if (versionState.appVersionResponse?.data?.forceUpdate == true) {
      if (!mounted) return;
      _showUpdateBottomSheet();
      return;
    }

    // 2) Battery flow (Android only)
    await _batteryOptimizationFlow();

    // 3) Splash delay
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // 4) Navigate once
    if (_navigated) return;
    _navigated = true;

    if (token == null) {
      context.go(AppRoutes.loginPath);
    } else if (!isProfileCompleted) {
      context.go(AppRoutes.fillProfilePath);
    } else {
      context.go(AppRoutes.homePath);
    }
  }

  // ---------------- ✅ Battery Flow (FIXED) ----------------
  Future<void> _batteryOptimizationFlow() async {
    if (!Platform.isAndroid) return;
    if (_batteryFlowRunning) return;
    if (_navigated) return;
    if (_batterySheetOpen) return;

    _batteryFlowRunning = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      // ✅ true = battery optimization disabled (good)
      final isUnrestricted =
          await CallerIdRoleHelper.isIgnoringBatteryOptimizations();

      final batteryOk = isUnrestricted == true;

      // last state saved in device
      final lastOk = prefs.getBool(_batteryLastOkKey); // null on first install

      // always update current state
      await prefs.setBool(_batteryLastOkKey, batteryOk);

      debugPrint("BatteryFlow => batteryOk=$batteryOk lastOk=$lastOk");

      // ✅ if currently OK => never show
      if (batteryOk) return;

      // ❌ currently BAD:
      // show only if:
      // - first time install (lastOk == null)
      // - OR user changed from OK -> BAD (lastOk == true)
      final shouldShow = (lastOk == null) || (lastOk == true);
      if (!shouldShow) return;

      if (!mounted) return;

      _batterySheetOpen = true;
      final openSettings = await _showBatteryBottomSheet();
      _batterySheetOpen = false;

      if (openSettings == true) {
        await CallerIdRoleHelper.openBatteryUnrestrictedSettings();
      }
    } finally {
      _batteryFlowRunning = false;
    }
  }

  Future<bool?> _showBatteryBottomSheet() async {
    return showModalBottomSheet<bool>(
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
                "Battery Permission Required",
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "To show Caller ID popup reliably, please set Battery to Unrestricted.\n\n"
                "Steps:\nSettings → Apps → Tringo → Battery → Unrestricted",
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSans(fontSize: 14),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
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

              // const SizedBox(height: 10),
              //
              // SizedBox(
              //   width: double.infinity,
              //   child: OutlinedButton(
              //     onPressed: () => Navigator.pop(context, false),
              //     child: const Text("Continue"),
              //   ),
              // ),
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
                text: const Text('Update Now'),
                onTap: () => openPlayStore(),
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

    if (storeUrl.isEmpty) return;

    final uri = Uri.parse(storeUrl);
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

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

// ✅ Result class
class _BatterySheetResult {
  final bool dontAskAgain;
  final bool openSettings;
  const _BatterySheetResult({
    required this.dontAskAgain,
    required this.openSettings,
  });
}
