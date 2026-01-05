package com.feni.tringo.tringo_app

import android.Manifest
import android.app.role.RoleManager
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
                            ).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                        }
                        result.success(true)
                    }

                    // ---------------- BATTERY OPTIMIZATION ----------------
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

                    // ---------------- BATTERY UNRESTRICTED SETTINGS (Android 12-15) ----------------
                    // ✅ This opens App Info page -> Battery -> user can set Unrestricted
                    "openBatteryUnrestrictedSettings" -> {
                        Log.d(TAG, "openBatteryUnrestrictedSettings invoked")
                        openBatteryUnrestrictedSettings()
                        result.success(true)
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
                Log.d(TAG, "Opened ROLE_CALL_SCREENING chooser")
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

    // ✅ catch system popup result and send to Flutter
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

    // ✅ Battery optimization status
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

    // ✅ Open App Info page so user can set Battery -> Unrestricted (Android 12-15 best)
    private fun openBatteryUnrestrictedSettings() {
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "openBatteryUnrestrictedSettings failed: ${e.message}", e)
            try {
                val i = Intent(Settings.ACTION_SETTINGS).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(i)
            } catch (_: Exception) {}
        }
    }

    // 🔹 Only check READ_PHONE_STATE
    private fun hasPhonePermission(): Boolean {
        val granted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_PHONE_STATE
        ) == PackageManager.PERMISSION_GRANTED

        Log.d(TAG, "READ_PHONE_STATE granted: $granted")
        return granted
    }

    private fun getSimInfoNative(): List<Map<String, Any?>> {
        if (!hasPhonePermission()) {
            Log.d(TAG, "No phone permission, returning empty list")
            return emptyList()
        }

        val subscriptionManager =
            getSystemService(SubscriptionManager::class.java) ?: run {
                Log.d(TAG, "SubscriptionManager is null")
                return emptyList()
            }

        val list: List<SubscriptionInfo> =
            try {
                subscriptionManager.activeSubscriptionInfoList ?: emptyList()
            } catch (e: SecurityException) {
                Log.e(TAG, "SecurityException getting activeSubscriptionInfoList: ${e.message}")
                emptyList()
            }

        Log.d(TAG, "activeSubscriptionInfoList size: ${list.size}")

        val telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager

        return list.map { info ->
            val slotIndex = info.simSlotIndex
            val displayName = info.displayName?.toString()
            val carrierName = info.carrierName?.toString()
            val countryIso = info.countryIso

            var number: String? = null
            try {
                number = info.number
            } catch (e: SecurityException) {
                Log.e(TAG, "SecurityException reading info.number: ${e.message}")
            }

            if (number.isNullOrEmpty()) {
                try {
                    val tmForSub = telephonyManager.createForSubscriptionId(info.subscriptionId)
                    number = tmForSub.line1Number
                } catch (e: Exception) {
                    Log.e(TAG, "Exception reading line1Number: ${e.message}")
                }
            }

            mapOf(
                "slotIndex" to slotIndex,
                "displayName" to displayName,
                "carrierName" to carrierName,
                "countryIso" to countryIso,
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
//                        requestSetAsDefaultCallerIdSpam(result) // returns bool after chooser closes
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
//                            )
//                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//                            startActivity(intent)
//                        }
//                        result.success(null)
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
//                // avoid multiple pending results
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
//                // Android < 10
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


