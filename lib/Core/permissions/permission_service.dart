import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tringo_app/Core/Utility/app_prefs.dart';
import 'package:tringo_app/Core/Widgets/caller_id_role_helper.dart';

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

  static Future<bool> syncCallerIdOverlayStateAtStartup() async {
    if (!Platform.isAndroid) return false;

    try {
      var openedOverlaySettings = false;
      final enabled = await AppPrefs.getCallerIdOverlayEnabled();
      final autoDisabled = await AppPrefs.getCallerIdOverlayAutoDisabled();

      // If user has explicitly turned it off (and it wasn't auto-disabled), don't ask anything.
      if (!enabled && !autoDisabled) return false;

      // Optional: Notifications (Android 13+) can improve reliability on restrictive OEMs.
      // Ask only when user currently wants the feature ON.
      if (enabled) {
        try {
          final notifStatus = await Permission.notification.status;
          if (!notifStatus.isGranted) {
            await Permission.notification.request();
          }
        } catch (_) {}
      }

      // Phone permission is required for Caller ID overlay feature.
      // Request only when user currently wants the feature ON.
      var phoneGranted = await Permission.phone.status.isGranted;
      if (enabled && !phoneGranted) {
        final req = await Permission.phone.request();
        phoneGranted = req.isGranted;
      }

      // Ask to become the default Caller ID app (role / default dialer-like prompt),
      // only once and only when user wants the feature ON.
      if (enabled) {
        try {
          final askedOnce = await AppPrefs.getDefaultCallerIdRoleAskedOnce();
          if (!askedOnce) {
            final isDefault = await CallerIdRoleHelper.isDefaultCallerIdApp();
            if (!isDefault) {
              await AppPrefs.setDefaultCallerIdRoleAskedOnce(true);
              await CallerIdRoleHelper.requestDefaultCallerIdApp();
              return true; // prompt shown; wait for resume
            }
            await AppPrefs.setDefaultCallerIdRoleAskedOnce(true);
          }
        } catch (_) {}
      }

      // Overlay special setting (SYSTEM_ALERT_WINDOW).
      final overlayGranted = await CallerIdRoleHelper.isOverlayGranted();
      final ready = phoneGranted && overlayGranted;

      // If missing overlay setting and the user wanted the feature, open settings once.
      if (enabled && !overlayGranted) {
        final openedOnce = await AppPrefs.getOverlaySettingsAutoOpenedOnce();
        if (!openedOnce) {
          await AppPrefs.setOverlaySettingsAutoOpenedOnce(true);
          await CallerIdRoleHelper.requestOverlayPermission();
          openedOverlaySettings = true;
        }
      }

      if (enabled) {
        // User wanted it ON, but it's not ready => keep toggle OFF and prevent service attempts.
        if (!ready) {
          await AppPrefs.setCallerIdOverlayEnabled(false);
          await AppPrefs.setCallerIdOverlayAutoDisabled(true);
        } else {
          await AppPrefs.setCallerIdOverlayAutoDisabled(false);

          // NOTE (Caller-ID foreground notification):
          // We intentionally DO NOT start the persistent keep-alive foreground
          // service here. On Android 8+ a running foreground service must show a
          // notification ("Tringo Caller ID – Running…"), which cannot be fully
          // hidden by the OS. Keeping it alive at all times made that notification
          // sit permanently in the shade right after install.
          //
          // Caller-ID still works during calls: TringoCallReceiver /
          // TringoCallEndReceiver are statically registered for PHONE_STATE in the
          // manifest and start the overlay service transiently for the duration of
          // a call, then stop it — so the notification (if shown at all) appears
          // only briefly during an active call, never permanently while idle.
          //
          // Trade-off: on very aggressive OEMs (MIUI/Realme/Oppo/OnePlus) where the
          // app is force-stopped or autostart is disabled, the transient start from
          // the receiver can be slightly less reliable than a kept-alive service.
          // To restore the previous always-on behaviour, re-enable the line below.
          // await CallerIdRoleHelper.startOverlayServiceKeepAlive();
        }
        return openedOverlaySettings;
      }

      // Auto-recover: if we auto-disabled earlier and now it's ready, turn it ON again.
      if (autoDisabled && ready) {
        await AppPrefs.setCallerIdOverlayEnabled(true);
        await AppPrefs.setCallerIdOverlayAutoDisabled(false);
      }

      return openedOverlaySettings;
    } catch (_) {
      // Never crash app startup on permission reconciliation.
      return false;
    }
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
