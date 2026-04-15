package com.feni.tringo.tringo_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import android.util.Log

class TringoCallEndReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "TRINGO_CALL_END_RX"
        private const val PREF = "tringo_call_state"
        private const val KEY_LAST_STATE = "last_state"
        private const val KEY_LAST_NUMBER = "last_number"
        private const val KEY_USER_CLOSED = "user_closed_during_call"
        private const val KEY_USER_CLOSED_NUMBER = "user_closed_number"
        private const val KEY_RINGING_AT = "ringing_at"
        private const val KEY_SAW_OFFHOOK = "saw_offhook"
        private const val KEY_LAST_POSTCALL_AT = "last_postcall_at"

        private const val MIN_RING_MS_FOR_MISSED = 10_000L
        private const val POSTCALL_DEDUP_MS = 20_000L
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != TelephonyManager.ACTION_PHONE_STATE_CHANGED &&
            intent.action != "android.intent.action.PHONE_STATE"
        ) return

        val stateStr = intent.getStringExtra(TelephonyManager.EXTRA_STATE) ?: return
        val number = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER) ?: ""
        val now = System.currentTimeMillis()

        val prefs = context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
        val lastState = prefs.getString(KEY_LAST_STATE, "") ?: ""
        val savedNumber = prefs.getString(KEY_LAST_NUMBER, "") ?: ""
        val userClosed = prefs.getBoolean(KEY_USER_CLOSED, false)
        val ringingAt = prefs.getLong(KEY_RINGING_AT, 0L)
        val sawOffhook = prefs.getBoolean(KEY_SAW_OFFHOOK, false)
        val lastPostAt = prefs.getLong(KEY_LAST_POSTCALL_AT, 0L)

        if (number.isNotBlank()) prefs.edit().putString(KEY_LAST_NUMBER, number).apply()

        val finalNumber = when {
            number.isNotBlank() -> number
            savedNumber.isNotBlank() -> savedNumber
            else -> "UNKNOWN"
        }

        val ringFor = if (ringingAt > 0) (now - ringingAt) else 0L
        Log.d(TAG, "state=$stateStr lastState=$lastState final=$finalNumber closed=$userClosed offhook=$sawOffhook ringMs=$ringFor")

        // Track call session.
        if (stateStr == TelephonyManager.EXTRA_STATE_RINGING) {
            prefs.edit()
                .putLong(KEY_RINGING_AT, now)
                .putBoolean(KEY_SAW_OFFHOOK, false)
                .apply()
        } else if (stateStr == TelephonyManager.EXTRA_STATE_OFFHOOK) {
            prefs.edit()
                .putBoolean(KEY_SAW_OFFHOOK, true)
                .apply()
        }

        val endedNow =
            stateStr == TelephonyManager.EXTRA_STATE_IDLE &&
                lastState.isNotBlank() &&
                lastState != TelephonyManager.EXTRA_STATE_IDLE

        // Always trigger post-call overlay from receiver to improve reliability on OEM devices.
        // The service will decide whether/what to show.
        if (endedNow) {
            // De-dupe multiple IDLE broadcasts.
            if (lastPostAt > 0 && (now - lastPostAt) < POSTCALL_DEDUP_MS) {
                prefs.edit().putString(KEY_LAST_STATE, stateStr).apply()
                return
            }

            // Avoid false IDLE while still ringing on some OEMs:
            // - Prefer showing post-call only when call was actually answered (OFFHOOK).
            // - Allow missed/rejected only if ringing lasted long enough.
            val allowPostCall = sawOffhook || (ringFor >= MIN_RING_MS_FOR_MISSED)
            if (!allowPostCall) {
                prefs.edit().putString(KEY_LAST_STATE, stateStr).apply()
                return
            }

            // Clear "user closed" before starting, so the service doesn't read stale suppression flags.
            prefs.edit()
                .putBoolean(KEY_USER_CLOSED, false)
                .remove(KEY_USER_CLOSED_NUMBER)
                .putLong(KEY_LAST_POSTCALL_AT, now)
                .apply()

            TringoOverlayService.start(
                ctx = context.applicationContext,
                phone = finalNumber,
                contactName = "",
                showOnCallEnd = true,
                launchedByReceiver = true
            )
        }

        prefs.edit().putString(KEY_LAST_STATE, stateStr).apply()
    }
}

/*

package com.feni.tringo.tringo_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import android.util.Log

class TringoCallEndReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "TRINGO_CALL_END_RX"
        private const val PREF = "tringo_call_state"
        private const val KEY_LAST_STATE = "last_state"
        private const val KEY_LAST_NUMBER = "last_number"
    }

    override fun onReceive(context: Context, intent: Intent) {
        // Both are same value internally, but safe:
        if (intent.action != TelephonyManager.ACTION_PHONE_STATE_CHANGED &&
            intent.action != "android.intent.action.PHONE_STATE"
        ) return

        val stateStr = intent.getStringExtra(TelephonyManager.EXTRA_STATE) ?: return
        val number = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER) ?: ""

        val prefs = context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
        val lastState = prefs.getString(KEY_LAST_STATE, "") ?: ""
        val lastNumber = prefs.getString(KEY_LAST_NUMBER, "") ?: ""

        if (number.isNotBlank()) {
            prefs.edit().putString(KEY_LAST_NUMBER, number).apply()
        }

        val finalNumber = when {
            number.isNotBlank() -> number
            lastNumber.isNotBlank() -> lastNumber
            else -> "UNKNOWN" // ✅ at least show popup even if number hidden by Android
        }

        Log.d(TAG, "state=$stateStr lastState=$lastState number=$number lastNumber=$lastNumber final=$finalNumber")

        // ✅ 1) Call வந்த உடனே popup show ஆகணும்
        if (stateStr == TelephonyManager.EXTRA_STATE_RINGING) {
            TringoOverlayService.start(
                ctx = context.applicationContext,
                phone = finalNumber,
                contactName = "",
                showOnCallEnd = false,
                launchedByReceiver = true
            )
        }

        // ✅ Save last state
        prefs.edit().putString(KEY_LAST_STATE, stateStr).apply()
    }
}
*/

//package com.feni.tringo.tringo_app
//
//import android.content.BroadcastReceiver
//import android.content.Context
//import android.content.Intent
//import android.telephony.TelephonyManager
//import android.util.Log
//
//class TringoCallEndReceiver : BroadcastReceiver() {
//
//    companion object {
//        private const val TAG = "TRINGO_CALL_END_RX"
//        private const val PREF = "tringo_call_state"
//        private const val KEY_LAST_STATE = "last_state"
//        private const val KEY_LAST_NUMBER = "last_number"
//    }
//
//    override fun onReceive(context: Context, intent: Intent) {
//        if (intent.action != "android.intent.action.PHONE_STATE") return
//
//        val stateStr = intent.getStringExtra(TelephonyManager.EXTRA_STATE) ?: return
//        val number = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER) ?: ""
//
//        val prefs = context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
//        val lastState = prefs.getString(KEY_LAST_STATE, "") ?: ""
//        val lastNumber = prefs.getString(KEY_LAST_NUMBER, "") ?: ""
//
//        // Save number if available
//        if (number.isNotBlank()) {
//            prefs.edit().putString(KEY_LAST_NUMBER, number).apply()
//        }
//
//        Log.d(TAG, "state=$stateStr lastState=$lastState number=$number lastNumber=$lastNumber")
//
//        // Detect "call ended": OFFHOOK -> IDLE OR RINGING -> IDLE
//        if (stateStr == TelephonyManager.EXTRA_STATE_IDLE) {
//            val endedFrom =
//                (lastState == TelephonyManager.EXTRA_STATE_OFFHOOK) ||
//                        (lastState == TelephonyManager.EXTRA_STATE_RINGING)
//
//            if (endedFrom) {
//                val finalNumber = if (number.isNotBlank()) number else lastNumber
//
//                Log.d(TAG, "✅ CALL ENDED. Showing overlay for: $finalNumber")
//
//                if (finalNumber.isNotBlank()) {
//                    TringoOverlayService.start(
//                        ctx = context.applicationContext,
//                        phone = finalNumber,
//                        contactName = "",
//                        showOnCallEnd = false
//                    )
//                } else {
//                    Log.w(TAG, "❌ number empty, cannot show overlay")
//                }
//            }
//        }
//
//        // Update last state
//        prefs.edit().putString(KEY_LAST_STATE, stateStr).apply()
//    }
//}
