package com.feni.tringo.tringo_app

import android.content.Context
import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log

class TringoCallScreeningService : CallScreeningService() {

    companion object {
        private const val TAG = "TRINGO_SCREENING"
        private const val PREF = "tringo_call_state"
        private const val KEY_LAST_NUMBER = "last_number"
    }

    override fun onScreenCall(callDetails: Call.Details) {
        val phoneRaw = try {
            callDetails.handle?.schemeSpecificPart?.trim().orEmpty()
        } catch (_: Throwable) {
            ""
        }

        val phone = normalizePhoneForPhoneInfo(phoneRaw)

        if (phone.isNotBlank() && !phone.equals("UNKNOWN", true)) {
            try {
                applicationContext
                    .getSharedPreferences(PREF, Context.MODE_PRIVATE)
                    .edit()
                    .putString(KEY_LAST_NUMBER, phone)
                    .apply()
            } catch (_: Throwable) {}
        }

        try {
            val response = CallScreeningService.CallResponse.Builder()
                .setDisallowCall(false)
                .setRejectCall(false)
                .setSkipCallLog(false)
                .setSkipNotification(false)
                .build()
            respondToCall(callDetails, response)
        } catch (t: Throwable) {
            Log.e(TAG, "respondToCall failed: ${t.message}", t)
        }
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
