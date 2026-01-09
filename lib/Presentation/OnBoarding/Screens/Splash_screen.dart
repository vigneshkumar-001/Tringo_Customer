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

    PermissionService.requestOverlayAndContacts();
    checkNavigation();
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
    await ref.read(appVersionNotifierProvider.notifier).getAppVersion(
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

  // Future<void> _batteryOptimizationFlow() async {
  //   if (!Platform.isAndroid) return;
  //   if (_batteryFlowRunning) return;
  //   if (_navigated) return;
  //
  //   _batteryFlowRunning = true;
  //
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //
  //     // If user chose "Don't ask again"
  //     final dontAskAgain = prefs.getBool(_batteryDontAskKey) ?? false;
  //     if (dontAskAgain) return;
  //
  //     // ✅ THIS IS THE ONLY CHECK
  //     final isUnrestricted =
  //     await CallerIdRoleHelper.isIgnoringBatteryOptimizations();
  //
  //     debugPrint(
  //       "BatteryFlow => isIgnoringBatteryOptimizations=$isUnrestricted",
  //     );
  //
  //     // ✅ If battery optimization is DISABLED → DO NOT show
  //     if (isUnrestricted == true) return;
  //
  //     // ❌ Battery optimization ENABLED → SHOW bottom sheet
  //     if (!mounted) return;
  //
  //     final res = await _showBatteryBottomSheetWithDontAsk();
  //     if (res == null) return;
  //
  //     // Save preference FIRST
  //     if (res.dontAskAgain) {
  //       await prefs.setBool(_batteryDontAskKey, true);
  //     }
  //
  //     // Then open settings if user wants
  //     if (res.openSettings) {
  //       await CallerIdRoleHelper.openBatteryUnrestrictedSettings();
  //     }
  //   } finally {
  //     _batteryFlowRunning = false;
  //   }
  // }



  // Future<_BatterySheetResult?> _showBatteryBottomSheetWithDontAsk() async {
  //   bool dontAskAgain = true;
  //
  //   return showModalBottomSheet<_BatterySheetResult>(
  //     backgroundColor: AppColor.white,
  //     context: context,
  //     isDismissible: false,
  //     enableDrag: false,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (_) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return Padding(
  //             padding: const EdgeInsets.all(24.0),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text(
  //                   "Battery Permission Required",
  //                   style: GoogleFonts.ibmPlexSans(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 12),
  //                 Text(
  //                   "To show Caller ID popup reliably, please enable background usage / set Battery to Unrestricted.\n\n"
  //                       "Steps:\n"
  //                       "Settings → Apps → Tringo → Battery → Unrestricted\n"
  //                       "OR enable: Allow background usage",
  //                   textAlign: TextAlign.center,
  //                   style: GoogleFonts.ibmPlexSans(fontSize: 14),
  //                 ),
  //                 const SizedBox(height: 16),
  //
  //                 Row(
  //                   children: [
  //                     Checkbox(
  //                       value: dontAskAgain,
  //                       onChanged: (v) {
  //                         setState(() => dontAskAgain = v ?? false);
  //                       },
  //                     ),
  //                     const Expanded(child: Text("Don't show this again")),
  //                   ],
  //                 ),
  //
  //                 const SizedBox(height: 10),
  //
  //                 SizedBox(
  //                   width: double.infinity,
  //                   child: ElevatedButton(
  //                     onPressed: () {
  //                       Navigator.pop(
  //                         context,
  //                         _BatterySheetResult(
  //                           dontAskAgain: dontAskAgain,
  //                           openSettings: true,
  //                         ),
  //                       );
  //                     },
  //                     style: ElevatedButton.styleFrom(
  //                       padding: const EdgeInsets.symmetric(vertical: 14),
  //                       backgroundColor: AppColor.blue,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(14),
  //                       ),
  //                     ),
  //                     child: Text(
  //                       "Open Settings",
  //                       style: GoogleFonts.ibmPlexSans(
  //                         color: Colors.white,
  //                         fontSize: 15,
  //                         fontWeight: FontWeight.w700,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //
  //                 const SizedBox(height: 10),
  //
  //                 SizedBox(
  //                   width: double.infinity,
  //                   child: OutlinedButton(
  //                     onPressed: () {
  //                       Navigator.pop(
  //                         context,
  //                         _BatterySheetResult(
  //                           dontAskAgain: dontAskAgain,
  //                           openSettings: false,
  //                         ),
  //                       );
  //                     },
  //                     child: const Text("Continue"),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  // ---------------- Version Update Bottom Sheet ----------------

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

//
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tringo_app/Core/Utility/app_Images.dart';
// import 'package:tringo_app/Core/Utility/app_color.dart';
// import 'package:tringo_app/Core/Utility/google_font.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../../Core/Widgets/caller_id_role_helper.dart';
// import '../../../Core/Widgets/common_container.dart';
// import '../../../Core/app_go_routes.dart';
// import '../../../Core/permissions/permission_service.dart';
// import 'Home Screen/Screens/home_screen.dart';
// import 'Login Screen/Controller/app_version_notifier.dart';
// import 'Login Screen/login_mobile_number.dart';
// import 'fill_profile/Screens/fill_profile.dart';
//
// class SplashScreen extends ConsumerStatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   ConsumerState<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends ConsumerState<SplashScreen>
//     with WidgetsBindingObserver {
//   String appVersion = '1.0.0';
//
//   bool _batteryFlowRunning = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//
//     // Request base permissions (contacts + overlay + notification)
//     PermissionService.requestOverlayAndContacts();
//
//     checkNavigation();
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   checkNavigation();
//   //   PermissionService.requestOverlayAndContacts();
//   // }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _batteryOptimizationFlow(); // re-check after settings
//     }
//   }
//
//   Future<void> checkNavigation() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     final token = prefs.getString('token');
//     final bool isProfileCompleted =
//         prefs.getBool("isProfileCompleted") ?? false;
//
//     // 1) Check app version
//     await ref
//         .read(appVersionNotifierProvider.notifier)
//         .getAppVersion(
//           appPlatForm: 'android',
//           appVersion: appVersion,
//           appName: 'customer',
//         );
//
//     final versionState = ref.read(appVersionNotifierProvider);
//
//     if (versionState.appVersionResponse?.data?.forceUpdate == true) {
//       _showUpdateBottomSheet();
//       return;
//     }
//
//     // 2) Battery + role + overlay flow (Android only)
//     await _batteryOptimizationFlow();
//
//     // 3) Hold splash for 3 seconds
//     await Future.delayed(const Duration(seconds: 3));
//     if (!mounted) return;
//
//     // 4) Navigate
//     if (token == null) {
//       context.go(AppRoutes.loginPath);
//     } else if (!isProfileCompleted) {
//       context.go(AppRoutes.fillProfilePath);
//     } else {
//       context.go(AppRoutes.homePath);
//     }
//   }
//
//   Future<void> _batteryOptimizationFlow() async {
//     if (!Platform.isAndroid) return;
//     if (_batteryFlowRunning) return;
//     _batteryFlowRunning = true;
//
//     try {
//       // Choose ONE check:
//       // final ok = await CallerIdRoleHelper.isIgnoringBatteryOptimizations();
//       final restricted = await CallerIdRoleHelper.isBackgroundRestricted();
//
//       // If using backgroundRestricted:
//       if (restricted == false) return;
//
//       if (!mounted) return;
//
//       await _showBatteryMandatoryBottomSheet();
//       await CallerIdRoleHelper.openBatteryUnrestrictedSettings();
//     } finally {
//       _batteryFlowRunning = false;
//     }
//   }
//
//
//   Future<void> _showBatteryMandatoryBottomSheet() async {
//     return showModalBottomSheet(
//       backgroundColor: AppColor.white,
//       context: context,
//       isDismissible: false,
//       enableDrag: false,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) {
//         return Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 "Battery Optimization Required",
//                 style: GoogleFonts.ibmPlexSans(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 "To show Caller ID popup reliably on Android 12–15, you must set Tringo battery usage to "
//                 "\"Unrestricted\" (or disable battery optimization).\n\n"
//                 "Please do this now:\n"
//                 "Settings → Apps → Tringo → Battery → Unrestricted",
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.ibmPlexSans(fontSize: 14),
//               ),
//               const SizedBox(height: 24),
//
//               // ✅ Only button (No Later)
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     backgroundColor: AppColor.blue,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                   child: Text(
//                     "Open Settings",
//                     style: GoogleFonts.ibmPlexSans(
//                       color: Colors.white,
//                       fontSize: 15,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void _showUpdateBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isDismissible: false,
//       enableDrag: false,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) {
//         return Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 "Update Available",
//                 style: GoogleFonts.ibmPlexSans(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 12),
//
//               Text(
//                 "A new version of the app is available. Please update to continue.",
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.ibmPlexSans(fontSize: 14),
//               ),
//               const SizedBox(height: 24),
//               CommonContainer.button(
//                 text: Text('Update Now'),
//                 onTap: () {
//                   openPlayStore();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void openPlayStore() async {
//     final versionState = ref.read(appVersionNotifierProvider);
//     final storeUrl =
//         versionState.appVersionResponse?.data?.store.android.toString() ?? '';
//
//     if (storeUrl.isEmpty) {
//       print('No URL available.');
//       return;
//     }
//
//     final uri = Uri.parse(storeUrl);
//     print('Trying to launch: $uri');
//
//     // Try in-app or platform default mode
//     final success = await launchUrl(
//       uri,
//       mode: LaunchMode.platformDefault, // or LaunchMode.inAppWebView
//     );
//
//     if (!success) {
//       print('Could not open the link. Maybe no browser is installed.');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final h = MediaQuery.of(context).size.height;
//     final w = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Image.asset(
//               AppImages.splashScreen,
//               width: w,
//               height: h,
//               fit: BoxFit.cover,
//             ),
//             Positioned(
//               top: h * 0.53,
//               left: w * 0.43,
//               child: Text(
//                 'V $appVersion',
//                 style: GoogleFont.Mulish(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w900,
//                   color: AppColor.black,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
