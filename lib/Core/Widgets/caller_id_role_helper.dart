import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:permission_handler/permission_handler.dart';

final callerIdAskedProvider = StateProvider<bool>((ref) => false);

const MethodChannel _native = MethodChannel('sim_info');

class CallerIdRoleHelper {
  static Future<bool> requestReadPhoneState() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await _native.invokeMethod<bool>('requestReadPhoneState');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> debugPhonePerm() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await _native.invokeMethod<bool>('debugPhonePerm');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isDefaultCallerIdApp() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await _native.invokeMethod<bool>('isDefaultCallerIdApp');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestDefaultCallerIdApp() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await _native.invokeMethod<bool>('requestDefaultCallerIdApp');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> maybeAskOnce({
    required WidgetRef ref,
    bool force = false,
  }) async {
    if (!Platform.isAndroid) return;

    final alreadyAsked = ref.read(callerIdAskedProvider);
    if (!force && alreadyAsked) return;

    final ok = await isDefaultCallerIdApp();
    if (ok) {
      ref.read(callerIdAskedProvider.notifier).state = true;
      return;
    }

    ref.read(callerIdAskedProvider.notifier).state = true;
    await requestDefaultCallerIdApp();
  }

  // Overlay methods
  static Future<bool> isOverlayGranted() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await _native.invokeMethod<bool>('isOverlayGranted');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestOverlayPermission() async {
    if (!Platform.isAndroid) return;
    try {
      await _native.invokeMethod('requestOverlayPermission');
    } catch (_) {}
  }

  // Battery / settings
  static Future<bool> openBatteryUnrestrictedSettings() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await _native.invokeMethod<bool>('openBatteryUnrestrictedSettings');
      return ok ?? true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await _native.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestIgnoreBatteryOptimization() async {
    if (!Platform.isAndroid) return;
    try {
      await _native.invokeMethod('requestIgnoreBatteryOptimization');
    } catch (_) {}
  }

  static Future<bool> openAppDetailsSettings() async {
    try {
      return await openAppSettings();
    } catch (_) {
      return false;
    }
  }
}


/*class CallerIdRoleHelper {
  static Future<bool> requestReadPhoneState() async {
    if (!Platform.isAndroid) return true;
    final ok = await _native.invokeMethod<bool>('requestReadPhoneState');
    return ok ?? false;
  }

  static Future<bool> debugReadPhoneState() async {
    if (!Platform.isAndroid) return true;
    final ok = await _native.invokeMethod<bool>('debugPhonePerm');
    return ok ?? false;
  }
  static Future<bool> debugPhonePerm() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await _native.invokeMethod<bool>('debugPhonePerm');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }
  static Future<bool> openIgnoreBatteryOptimizationsSettings() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await _native.invokeMethod<bool>(
        'openIgnoreBatteryOptimizationsSettings',
      );
      return ok ?? true;
    } catch (e) {
      // ignore: avoid_print
      print('❌ openIgnoreBatteryOptimizationsSettings failed: $e');
      return false;
    }
  }

  static Future<bool> openBatteryUnrestrictedSettings() async {
    if (!Platform.isAndroid) return true;

    try {
      final ok = await _native.invokeMethod<bool>(
        'openBatteryUnrestrictedSettings',
      );

      // some native impl returns nothing -> treat as "attempted"
      return ok ?? true;
    } catch (e) {
      // log and return false so caller can fallback
      // ignore: avoid_print
      print('❌ openBatteryUnrestrictedSettings failed: $e');
      return false;
    }
  }

  static Future<bool> openAppDetailsSettings() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await openAppSettings(); // permission_handler
      return ok;
    } catch (e) {
      // ignore: avoid_print
      print('❌ openAppDetailsSettings failed: $e');
      return false;
    }
  }
  // ---------------- Role methods ----------------

  static Future<bool> isDefaultCallerIdApp() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await _native.invokeMethod<bool>('isDefaultCallerIdApp');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestDefaultCallerIdApp() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await _native.invokeMethod<bool>('requestDefaultCallerIdApp');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> maybeAskOnce({
    required WidgetRef ref,
    bool force = false,
  }) async {
    if (!Platform.isAndroid) return;

    final alreadyAsked = ref.read(callerIdAskedProvider);
    if (!force && alreadyAsked) return;

    final ok = await isDefaultCallerIdApp();
    if (ok) {
      ref.read(callerIdAskedProvider.notifier).state = true;
      return;
    }

    ref.read(callerIdAskedProvider.notifier).state = true;
    await requestDefaultCallerIdApp();
  }

  // ---------------- Overlay methods ----------------

  static Future<bool> isOverlayGranted() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok = await _native.invokeMethod<bool>('isOverlayGranted');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestOverlayPermission() async {
    if (!Platform.isAndroid) return;
    try {
      await _native.invokeMethod('requestOverlayPermission');
    } catch (_) {}
  }

  // ---------------- Battery methods ----------------

  static Future<bool> isBackgroundRestricted() async {
    if (!Platform.isAndroid) return false;
    try {
      final restricted =
      await _native.invokeMethod<bool>('isBackgroundRestricted');
      return restricted ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    try {
      final ok =
      await _native.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  // static Future<void> openBatteryUnrestrictedSettings() async {
  //   if (!Platform.isAndroid) return;
  //   try {
  //     await _native.invokeMethod('openBatteryUnrestrictedSettings');
  //   } catch (_) {}
  // }

  static Future<void> requestIgnoreBatteryOptimization() async {
    if (!Platform.isAndroid) return;
    try {
      await _native.invokeMethod('requestIgnoreBatteryOptimization');
    } catch (_) {}
  }
}*/


