package com.feni.tringo.tringo_app

import android.Manifest
import android.app.ActivityManager
import android.app.role.RoleManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "sim_info"
    private val TAG = "TRINGO_NATIVE"

    private val REQ_ROLE_CALL_SCREENING = 9001
    private var pendingRoleResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    // ---------------- ✅ Background restricted (Android 9+ ActivityManager) ----------------
                    "isBackgroundRestricted" -> {
                        try {
                            val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                            val restricted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                                am.isBackgroundRestricted
                            } else {
                                false
                            }
                            Log.d(TAG, "isBackgroundRestricted => $restricted")
                            result.success(restricted)
                        } catch (e: Exception) {
                            Log.e(TAG, "isBackgroundRestricted failed: ${e.message}", e)
                            result.success(false)
                        }
                    }

                    // ---------------- ✅ Open battery/app settings (OEM best effort) ----------------
                    "openBatteryUnrestrictedSettings" -> {
                        Log.d(TAG, "openBatteryUnrestrictedSettings invoked")
                        openBatteryUnrestrictedSettingsBestEffort()
                        result.success(true)
                    }

                    // Optional: a more direct intent call if you want to use from Flutter
                    "openBatterySettingsDirect" -> {
                        Log.d(TAG, "openBatterySettingsDirect invoked")
                        openBatterySettingsDirect()
                        result.success(true)
                    }

                    // Optional: debug only
                    "isAppInPowerSaveMode" -> {
                        val ok = isAppInPowerSaveMode()
                        Log.d(TAG, "isAppInPowerSaveMode => $ok")
                        result.success(ok)
                    }

                    // ---------------- SIM INFO ----------------
                    "getSimInfo" -> result.success(getSimInfoNative())

                    // ---------------- CALLER ID ROLE ----------------
                    "isDefaultCallerIdApp" -> {
                        val ok = isTringoDefaultCallerIdSpam(this)
                        Log.d(TAG, "isDefaultCallerIdApp => $ok")
                        result.success(ok)
                    }

                    "requestDefaultCallerIdApp" -> {
                        Log.d(TAG, "requestDefaultCallerIdApp invoked")
                        requestSetAsDefaultCallerIdSpam(result)
                    }

                    // ---------------- OVERLAY PERMISSION ----------------
                    "isOverlayGranted" -> {
                        val ok = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            Settings.canDrawOverlays(this)
                        } else true
                        Log.d(TAG, "isOverlayGranted => $ok")
                        result.success(ok)
                    }

                    "requestOverlayPermission" -> {
                        Log.d(TAG, "requestOverlayPermission invoked")
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
                            val intent = Intent(
                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName")
                            ).apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }
                            startActivity(intent)
                        }
                        result.success(true)
                    }

                    // ---------------- ✅ Battery optimization whitelist ----------------
                    "isIgnoringBatteryOptimizations" -> {
                        val ok = isIgnoringBatteryOptimizations()
                        Log.d(TAG, "isIgnoringBatteryOptimizations => $ok")
                        result.success(ok)
                    }

                    "requestIgnoreBatteryOptimization" -> {
                        Log.d(TAG, "requestIgnoreBatteryOptimization invoked")

                        if (isIgnoringBatteryOptimizations()) {
                            result.success(true)
                            return@setMethodCallHandler
                        }

                        try {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                                    data = Uri.parse("package:$packageName")
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                }
                                startActivity(intent)
                            }
                            result.success(true)
                        } catch (e: Exception) {
                            Log.e(TAG, "requestIgnoreBatteryOptimization failed: ${e.message}", e)
                            try {
                                val s = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                }
                                startActivity(s)
                            } catch (_: Exception) {}
                            result.success(false)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    // ✅ Default caller id/spam role check
    private fun isTringoDefaultCallerIdSpam(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val rm = context.getSystemService(RoleManager::class.java)
            rm.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)
        } else {
            false
        }
    }

    // ✅ Request role chooser and return result to Flutter (true/false)
    private fun requestSetAsDefaultCallerIdSpam(result: MethodChannel.Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val rm = getSystemService(RoleManager::class.java)

                if (!rm.isRoleAvailable(RoleManager.ROLE_CALL_SCREENING)) {
                    Log.d(TAG, "ROLE_CALL_SCREENING not available -> open default apps settings")
                    startActivity(Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS))
                    result.success(false)
                    return
                }

                if (pendingRoleResult != null) {
                    Log.d(TAG, "Role request already in progress")
                    result.success(isTringoDefaultCallerIdSpam(this))
                    return
                }

                pendingRoleResult = result
                val intent = rm.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
                startActivityForResult(intent, REQ_ROLE_CALL_SCREENING)
            } else {
                startActivity(Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS))
                result.success(false)
            }

        } catch (e: Exception) {
            Log.e(TAG, "requestDefaultCallerIdApp failed: ${e.message}", e)
            try { startActivity(Intent(Settings.ACTION_SETTINGS)) } catch (_: Exception) {}
            result.success(false)
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == REQ_ROLE_CALL_SCREENING) {
            val granted = isTringoDefaultCallerIdSpam(this)
            Log.d(TAG, "ROLE_CALL_SCREENING result granted=$granted")
            pendingRoleResult?.success(granted)
            pendingRoleResult = null
        }
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                pm.isIgnoringBatteryOptimizations(packageName)
            } else true
        } catch (e: Exception) {
            Log.e(TAG, "isIgnoringBatteryOptimizations error: ${e.message}", e)
            false
        }
    }

    // ✅ Debug helper
    private fun isAppInPowerSaveMode(): Boolean {
        return try {
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            pm.isPowerSaveMode
        } catch (e: Exception) {
            Log.e(TAG, "isAppInPowerSaveMode error: ${e.message}", e)
            false
        }
    }

    // ---------------- ✅ OEM Battery Settings Opener (All Brands Best Effort) ----------------

    private fun openBatteryUnrestrictedSettingsBestEffort() {
        Log.d(TAG, "Manufacturer=${Build.MANUFACTURER}, Brand=${Build.BRAND}, Model=${Build.MODEL}")

        // 1) Try OEM specific Battery/Power manager screens
        if (tryOpenOemBatteryPage()) return

        // 2) Try Android battery optimization settings list
        if (tryStart(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))) return

        // 3) Try request ignore optimization for this app
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val appUri = Uri.parse("package:$packageName")
            if (tryStart(Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply { data = appUri })) return
        }

        // 4) App details (most reliable)
        if (openAppDetails()) return

        // 5) Fallback
        tryStart(Intent(Settings.ACTION_SETTINGS))
    }

    private fun openAppDetails(): Boolean {
        return tryStart(
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            }
        )
    }

    private fun tryStart(intent: Intent): Boolean {
        return try {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            true
        } catch (e: Exception) {
            Log.w(TAG, "tryStart failed: action=${intent.action} data=${intent.data} => ${e.message}")
            false
        }
    }

    private fun tryStart(component: ComponentName): Boolean {
        return try {
            val intent = Intent().apply {
                this.component = component
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            true
        } catch (e: Exception) {
            Log.w(TAG, "tryStart component failed: $component => ${e.message}")
            false
        }
    }

    private fun isPackageInstalled(pkg: String): Boolean {
        return try {
            packageManager.getPackageInfo(pkg, 0)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun tryOpenOemBatteryPage(): Boolean {
        val pkg = packageName

        // ---- Xiaomi / MIUI ----
        if (isPackageInstalled("com.miui.securitycenter")) {
            if (tryStart(ComponentName("com.miui.securitycenter", "com.miui.powercenter.PowerMainActivity"))) return true
            if (tryStart(ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity"))) return true
        }

        // ---- Oppo / Realme (ColorOS) ----
        if (isPackageInstalled("com.coloros.safecenter")) {
            if (tryStart(ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity"))) return true
            if (tryStart(ComponentName("com.coloros.safecenter", "com.coloros.safecenter.startupapp.StartupAppListActivity"))) return true
        }
        if (isPackageInstalled("com.oppo.safe")) {
            if (tryStart(ComponentName("com.oppo.safe", "com.oppo.safe.permission.startup.StartupAppListActivity"))) return true
        }

        // ---- Vivo / iQOO ----
        if (isPackageInstalled("com.iqoo.secure")) {
            if (tryStart(ComponentName("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity"))) return true
        }
        if (isPackageInstalled("com.vivo.permissionmanager")) {
            if (tryStart(ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"))) return true
        }

        // ---- Huawei / Honor (EMUI) ----
        if (isPackageInstalled("com.huawei.systemmanager")) {
            if (tryStart(ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.power.ui.PowerSettingsActivity"))) return true
            if (tryStart(ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"))) return true
            if (tryStart(ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity"))) return true
        }

        // ---- OnePlus ----
        if (isPackageInstalled("com.oneplus.security")) {
            if (tryStart(ComponentName("com.oneplus.security", "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity"))) return true
        }

        // ---- Samsung ----
        // Samsung components change a lot; App details is safest.
        // But try Device Care battery screen if available
        if (isPackageInstalled("com.samsung.android.lool")) {
            if (tryStart(ComponentName("com.samsung.android.lool", "com.samsung.android.sm.ui.battery.BatteryActivity"))) return true
        }

        // ---- Fallback to app details
        return openAppDetails()
    }

    /**
     * ✅ Alternative direct open
     * Opens App details page directly.
     */
    private fun openBatterySettingsDirect() {
        openAppDetails()
    }

    private fun hasPhonePermission(): Boolean {
        val granted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_PHONE_STATE
        ) == PackageManager.PERMISSION_GRANTED
        Log.d(TAG, "READ_PHONE_STATE granted: $granted")
        return granted
    }

    private fun getSimInfoNative(): List<Map<String, Any?>> {
        if (!hasPhonePermission()) return emptyList()

        val subscriptionManager =
            getSystemService(SubscriptionManager::class.java) ?: return emptyList()

        val list: List<SubscriptionInfo> =
            try {
                subscriptionManager.activeSubscriptionInfoList ?: emptyList()
            } catch (e: SecurityException) {
                Log.e(TAG, "SecurityException activeSubscriptionInfoList: ${e.message}")
                emptyList()
            }

        val telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager

        return list.map { info ->
            var number: String? = null
            try {
                number = info.number
            } catch (_: SecurityException) {}

            if (number.isNullOrEmpty()) {
                try {
                    val tmForSub = telephonyManager.createForSubscriptionId(info.subscriptionId)
                    number = tmForSub.line1Number
                } catch (_: Exception) {}
            }

            mapOf(
                "slotIndex" to info.simSlotIndex,
                "displayName" to info.displayName?.toString(),
                "carrierName" to info.carrierName?.toString(),
                "countryIso" to info.countryIso,
                "number" to (number ?: "")
            )
        }
    }
}

//package com.feni.tringo.tringo_app
//
//import android.Manifest
//import android.app.role.RoleManager
//import android.content.Context
//import android.content.Intent
//import android.content.pm.PackageManager
//import android.net.Uri
//import android.os.Build
//import android.os.PowerManager
//import android.provider.Settings
//import android.telephony.SubscriptionInfo
//import android.telephony.SubscriptionManager
//import android.telephony.TelephonyManager
//import android.util.Log
//import androidx.core.content.ContextCompat
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
//
//class MainActivity : FlutterActivity() {
//
//    private val CHANNEL = "sim_info"
//    private val TAG = "TRINGO_NATIVE"
//
//    private val REQ_ROLE_CALL_SCREENING = 9001
//    private var pendingRoleResult: MethodChannel.Result? = null
//
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
//            .setMethodCallHandler { call, result ->
//                when (call.method) {
//
//                    // ---------------- SIM INFO ----------------
//                    "getSimInfo" -> result.success(getSimInfoNative())
//
//                    // ---------------- CALLER ID ROLE ----------------
//                    "isDefaultCallerIdApp" -> {
//                        val ok = isTringoDefaultCallerIdSpam(this)
//                        Log.d(TAG, "isDefaultCallerIdApp => $ok")
//                        result.success(ok)
//                    }
//
//                    "requestDefaultCallerIdApp" -> {
//                        Log.d(TAG, "requestDefaultCallerIdApp invoked")
//                        requestSetAsDefaultCallerIdSpam(result)
//                    }
//
//                    // ---------------- OVERLAY PERMISSION ----------------
//                    "isOverlayGranted" -> {
//                        val ok = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//                            Settings.canDrawOverlays(this)
//                        } else true
//                        Log.d(TAG, "isOverlayGranted => $ok")
//                        result.success(ok)
//                    }
//
//                    "requestOverlayPermission" -> {
//                        Log.d(TAG, "requestOverlayPermission invoked")
//                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
//                            val intent = Intent(
//                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
//                                Uri.parse("package:$packageName")
//                            ).apply {
//                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//                            }
//                            startActivity(intent)
//                        }
//                        result.success(true)
//                    }
//
//                    // ---------------- BATTERY OPTIMIZATION ----------------
//                    "isIgnoringBatteryOptimizations" -> {
//                        val ok = isIgnoringBatteryOptimizations()
//                        Log.d(TAG, "isIgnoringBatteryOptimizations => $ok")
//                        result.success(ok)
//                    }
//
//                    "requestIgnoreBatteryOptimization" -> {
//                        Log.d(TAG, "requestIgnoreBatteryOptimization invoked")
//
//                        if (isIgnoringBatteryOptimizations()) {
//                            result.success(true)
//                            return@setMethodCallHandler
//                        }
//
//                        try {
//                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//                                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
//                                    data = Uri.parse("package:$packageName")
//                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//                                }
//                                startActivity(intent)
//                            }
//                            result.success(true)
//                        } catch (e: Exception) {
//                            Log.e(TAG, "requestIgnoreBatteryOptimization failed: ${e.message}", e)
//                            try {
//                                val s = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
//                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//                                }
//                                startActivity(s)
//                            } catch (_: Exception) {}
//                            result.success(false)
//                        }
//                    }
//
//                    // ---------------- BATTERY UNRESTRICTED SETTINGS (Android 12-15) ----------------
//                    // ✅ This opens App Info page -> Battery -> user can set Unrestricted
//                    "openBatteryUnrestrictedSettings" -> {
//                        Log.d(TAG, "openBatteryUnrestrictedSettings invoked")
//                        openBatteryUnrestrictedSettings()
//                        result.success(true)
//                    }
//
//                    else -> result.notImplemented()
//                }
//            }
//    }
//
//    // ✅ Default caller id/spam role check
//    private fun isTringoDefaultCallerIdSpam(context: Context): Boolean {
//        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//            val rm = context.getSystemService(RoleManager::class.java)
//            rm.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)
//        } else {
//            false
//        }
//    }
//
//    // ✅ Request role chooser and return result to Flutter (true/false)
//    private fun requestSetAsDefaultCallerIdSpam(result: MethodChannel.Result) {
//        try {
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//                val rm = getSystemService(RoleManager::class.java)
//
//                if (!rm.isRoleAvailable(RoleManager.ROLE_CALL_SCREENING)) {
//                    Log.d(TAG, "ROLE_CALL_SCREENING not available -> open default apps settings")
//                    startActivity(Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS))
//                    result.success(false)
//                    return
//                }
//
//                if (pendingRoleResult != null) {
//                    Log.d(TAG, "Role request already in progress")
//                    result.success(isTringoDefaultCallerIdSpam(this))
//                    return
//                }
//
//                pendingRoleResult = result
//                val intent = rm.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
//                Log.d(TAG, "Opened ROLE_CALL_SCREENING chooser")
//                startActivityForResult(intent, REQ_ROLE_CALL_SCREENING)
//
//            } else {
//                startActivity(Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS))
//                result.success(false)
//            }
//
//        } catch (e: Exception) {
//            Log.e(TAG, "requestDefaultCallerIdApp failed: ${e.message}", e)
//            try { startActivity(Intent(Settings.ACTION_SETTINGS)) } catch (_: Exception) {}
//            result.success(false)
//        }
//    }
//
//    // ✅ catch system popup result and send to Flutter
//    @Deprecated("Deprecated in Java")
//    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
//        super.onActivityResult(requestCode, resultCode, data)
//
//        if (requestCode == REQ_ROLE_CALL_SCREENING) {
//            val granted = isTringoDefaultCallerIdSpam(this)
//            Log.d(TAG, "ROLE_CALL_SCREENING result granted=$granted")
//
//            pendingRoleResult?.success(granted)
//            pendingRoleResult = null
//        }
//    }
//
//    // ✅ Battery optimization status
//    private fun isIgnoringBatteryOptimizations(): Boolean {
//        return try {
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//                val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
//                pm.isIgnoringBatteryOptimizations(packageName)
//            } else true
//        } catch (e: Exception) {
//            Log.e(TAG, "isIgnoringBatteryOptimizations error: ${e.message}", e)
//            false
//        }
//    }
//
//    // ✅ Open App Info page so user can set Battery -> Unrestricted (Android 12-15 best)
//    private fun openBatteryUnrestrictedSettings() {
//        try {
//            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
//                data = Uri.parse("package:$packageName")
//                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//            }
//            startActivity(intent)
//        } catch (e: Exception) {
//            Log.e(TAG, "openBatteryUnrestrictedSettings failed: ${e.message}", e)
//            try {
//                val i = Intent(Settings.ACTION_SETTINGS).apply {
//                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//                }
//                startActivity(i)
//            } catch (_: Exception) {}
//        }
//    }
//
//    // 🔹 Only check READ_PHONE_STATE
//    private fun hasPhonePermission(): Boolean {
//        val granted = ContextCompat.checkSelfPermission(
//            this,
//            Manifest.permission.READ_PHONE_STATE
//        ) == PackageManager.PERMISSION_GRANTED
//
//        Log.d(TAG, "READ_PHONE_STATE granted: $granted")
//        return granted
//    }
//
//    private fun getSimInfoNative(): List<Map<String, Any?>> {
//        if (!hasPhonePermission()) {
//            Log.d(TAG, "No phone permission, returning empty list")
//            return emptyList()
//        }
//
//        val subscriptionManager =
//            getSystemService(SubscriptionManager::class.java) ?: run {
//                Log.d(TAG, "SubscriptionManager is null")
//                return emptyList()
//            }
//
//        val list: List<SubscriptionInfo> =
//            try {
//                subscriptionManager.activeSubscriptionInfoList ?: emptyList()
//            } catch (e: SecurityException) {
//                Log.e(TAG, "SecurityException getting activeSubscriptionInfoList: ${e.message}")
//                emptyList()
//            }
//
//        Log.d(TAG, "activeSubscriptionInfoList size: ${list.size}")
//
//        val telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager
//
//        return list.map { info ->
//            val slotIndex = info.simSlotIndex
//            val displayName = info.displayName?.toString()
//            val carrierName = info.carrierName?.toString()
//            val countryIso = info.countryIso
//
//            var number: String? = null
//            try {
//                number = info.number
//            } catch (e: SecurityException) {
//                Log.e(TAG, "SecurityException reading info.number: ${e.message}")
//            }
//
//            if (number.isNullOrEmpty()) {
//                try {
//                    val tmForSub = telephonyManager.createForSubscriptionId(info.subscriptionId)
//                    number = tmForSub.line1Number
//                } catch (e: Exception) {
//                    Log.e(TAG, "Exception reading line1Number: ${e.message}")
//                }
//            }
//
//            mapOf(
//                "slotIndex" to slotIndex,
//                "displayName" to displayName,
//                "carrierName" to carrierName,
//                "countryIso" to countryIso,
//                "number" to (number ?: "")
//            )
//        }
//    }
//}
//
//