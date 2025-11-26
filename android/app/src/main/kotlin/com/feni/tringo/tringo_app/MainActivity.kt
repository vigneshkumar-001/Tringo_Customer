package com.feni.tringo.tringo_app

import android.Manifest
import android.os.Build
import android.util.Log
import androidx.core.content.ContextCompat
import android.content.pm.PackageManager
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "sim_info"

    private val TAG = "SIM_INFO"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSimInfo" -> {
                    val sims = getSimInfoNative()
                    result.success(sims)
                }
                else -> result.notImplemented()
            }
        }
    }

    // 🔹 Only check READ_PHONE_STATE to avoid being too strict
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

            Log.d(
                TAG,
                "SIM slot=$slotIndex, displayName=$displayName, carrier=$carrierName, iso=$countryIso, number=$number"
            )

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
//import io.flutter.embedding.android.FlutterActivity
//
//class MainActivity : FlutterActivity()
