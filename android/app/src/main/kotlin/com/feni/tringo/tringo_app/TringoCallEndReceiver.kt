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
        if (intent.action != "android.intent.action.PHONE_STATE") return

        val stateStr = intent.getStringExtra(TelephonyManager.EXTRA_STATE) ?: return
        val number = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER) ?: ""

        val prefs = context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
        val lastState = prefs.getString(KEY_LAST_STATE, "") ?: ""
        val lastNumber = prefs.getString(KEY_LAST_NUMBER, "") ?: ""

        // Save number if available
        if (number.isNotBlank()) {
            prefs.edit().putString(KEY_LAST_NUMBER, number).apply()
        }

        Log.d(TAG, "state=$stateStr lastState=$lastState number=$number lastNumber=$lastNumber")

        // Detect "call ended": OFFHOOK -> IDLE OR RINGING -> IDLE
        if (stateStr == TelephonyManager.EXTRA_STATE_IDLE) {
            val endedFrom =
                (lastState == TelephonyManager.EXTRA_STATE_OFFHOOK) ||
                        (lastState == TelephonyManager.EXTRA_STATE_RINGING)

            if (endedFrom) {
                val finalNumber = if (number.isNotBlank()) number else lastNumber

                Log.d(TAG, "✅ CALL ENDED. Showing overlay for: $finalNumber")

                if (finalNumber.isNotBlank()) {
                    TringoOverlayService.start(
                        ctx = context.applicationContext,
                        phone = finalNumber,
                        contactName = "",
                        showOnCallEnd = false
                    )
                } else {
                    Log.w(TAG, "❌ number empty, cannot show overlay")
                }
            }
        }

        // Update last state
        prefs.edit().putString(KEY_LAST_STATE, stateStr).apply()
    }
}
