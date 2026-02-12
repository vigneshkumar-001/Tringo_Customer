import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> ensureAllRequiredPermissions(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    // ✅ ONLY LOCATION permissions
    final results = await [
      Permission.locationWhenInUse, // best for maps
      // or use Permission.location (older)
    ].request();

    final locOk = results[Permission.locationWhenInUse]?.isGranted ?? false;

    if (!locOk) {
      if (!context.mounted) return false;
      await _showLocationSettingsDialog(context);
      return false;
    }

    return true;
  }

  static Future<void> _showLocationSettingsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Location Permission Required"),
        content: const Text(
          "Map use பண்ண Location permission தேவை.\n\n"
              "Settings → Permissions → Location → Allow",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }
}


// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class PermissionService {
//   static Future<bool> ensureAllRequiredPermissions(BuildContext context) async {
//     if (!Platform.isAndroid) return true;
//
//     // 1) Ask all "runtime" permissions in one flow (dialogs will still appear one-by-one, but user sees ONE flow)
//     final results = await [
//       Permission.phone,
//       Permission.contacts,
//       Permission.notification,
//     ].request();
//
//     final phoneOk = results[Permission.phone]?.isGranted ?? false;
//     final contactsOk = results[Permission.contacts]?.isGranted ?? false;
//     final notifOk = results[Permission.notification]?.isGranted ?? true; // some devices ignore
//
//     final runtimeOk = phoneOk && contactsOk; // notif optional for some use-cases
//     if (!runtimeOk) {
//       if (!context.mounted) return false;
//       await _showSettingsDialog(context);
//       return false;
//     }
//
//     // 2) Overlay permission (special; often opens settings)
//     final overlay = await Permission.systemAlertWindow.status;
//     if (!overlay.isGranted) {
//       await Permission.systemAlertWindow.request();
//     }
//
//     // Re-check overlay (because user may deny)
//     final overlayNow = await Permission.systemAlertWindow.status;
//     if (!overlayNow.isGranted) {
//       if (!context.mounted) return false;
//       await _showOverlayDialog(context);
//       return false;
//     }
//
//     return true;
//   }
//
//   static Future<void> _showSettingsDialog(BuildContext context) async {
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         title: const Text("Permissions Required"),
//         content: const Text(
//           "Caller ID popup வேலை செய்ய, இந்த permissions வேண்டும்:\n\n"
//               "• Phone\n"
//               "• Contacts\n\n"
//               "Settings → Permissions → Allow பண்ணுங்க.",
//         ),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await openAppSettings();
//             },
//             child: const Text("Open Settings"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   static Future<void> _showOverlayDialog(BuildContext context) async {
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         title: const Text("Overlay Required"),
//         content: const Text(
//           "Caller ID popup க்கு “Display over other apps / Overlay” permission தேவை.\n\n"
//               "Settings → Apps → Tringo → Display over other apps → Allow",
//         ),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await openAppSettings();
//             },
//             child: const Text("Open Settings"),
//           ),
//         ],
//       ),
//     );
//   }
// }
//