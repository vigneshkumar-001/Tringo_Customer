package com.feni.tringo.tringo_app

import android.content.Context
import android.telecom.Call
import android.telecom.InCallService
import android.util.Log

class TringoInCallService : InCallService() {

    companion object {
        private const val TAG = "TRINGO_INCALL"
        private const val PREF = "tringo_call_state"
        private const val KEY_LAST_NUMBER = "last_number"
    }

    override fun onCallAdded(call: Call) {
        super.onCallAdded(call)
        val phoneRaw = try {
            call.details?.handle?.schemeSpecificPart?.trim().orEmpty()
        } catch (_: Throwable) {
            ""
        }

        val phone = normalizePhoneForPhoneInfo(phoneRaw)
        if (phone.isNotBlank()) {
            try {
                applicationContext
                    .getSharedPreferences(PREF, Context.MODE_PRIVATE)
                    .edit()
                    .putString(KEY_LAST_NUMBER, phone)
                    .apply()
            } catch (_: Throwable) {}
        }

        Log.d(TAG, "onCallAdded state=${call.state} phone=$phone")

        // Outgoing calls often won't emit PHONE_STATE=RINGING. Show the overlay when the call is
        // added in a non-ringing state (dialing/connecting/active).
        if (call.state != Call.STATE_RINGING) {
            TringoOverlayService.start(
                ctx = applicationContext,
                phone = if (phone.isNotBlank()) phone else "UNKNOWN",
                contactName = "",
                showOnCallEnd = false,
                launchedByReceiver = false,
                outgoingOverlay = true
            )
        }
    }

    override fun onCallRemoved(call: Call) {
        super.onCallRemoved(call)
        val phone = try {
            call.details?.handle?.schemeSpecificPart?.trim().orEmpty()
        } catch (_: Throwable) {
            ""
        }
        Log.d(TAG, "onCallRemoved state=${call.state} phone=$phone")
    }

    private fun normalizePhoneForPhoneInfo(raw: String): String {
        val t = raw.trim()
        if (t.isBlank() || t.equals("UNKNOWN", true)) return ""
        val digits = t.filter { it.isDigit() }
        return when {
            t.startsWith("+") && digits.length >= 10 -> "+$digits"
            digits.length == 10 -> "+91$digits"
            digits.length == 12 && digits.startsWith("91") -> "+$digits"
            digits.isNotBlank() -> digits
            else -> t
        }
    }
}
