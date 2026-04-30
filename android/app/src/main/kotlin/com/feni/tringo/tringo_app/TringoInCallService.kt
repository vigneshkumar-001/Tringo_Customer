package com.feni.tringo.tringo_app

import android.content.Context
import android.content.Intent
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.telecom.Call
import android.telecom.InCallService
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class TringoInCallService : InCallService() {

    companion object {
        private const val TAG = "TRINGO_INCALL"
        private const val PREF = "tringo_call_state"
        private const val KEY_LAST_NUMBER = "last_number"
        private const val KEY_LAST_NUMBER_AT = "last_number_at"

        // IMPORTANT: channel importance cannot be upgraded once created on Android O+.
        // Use a versioned channel id so older installs with a low-importance channel still get full-screen behavior.
        private const val OUTGOING_NOTIF_CH = "tringo_outgoing_overlay_v2"
        private const val OUTGOING_NOTIF_ID = 303
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
                    .putLong(KEY_LAST_NUMBER_AT, System.currentTimeMillis())
                    .apply()
            } catch (_: Throwable) {}
        }

        Log.d(TAG, "onCallAdded state=${call.state} phone=$phone")

        // Outgoing calls often won't emit PHONE_STATE=RINGING. Show the overlay when the call is
        // added in a non-ringing state (dialing/connecting/active).
        if (call.state != Call.STATE_RINGING) {
            // Use the same trampoline activity approach as receivers to avoid background start restrictions.
            val i = Intent(applicationContext, TringoIncomingPopupActivity::class.java).apply {
                putExtra("phone", if (phone.isNotBlank()) phone else "UNKNOWN")
                putExtra("contactName", "")
                putExtra("showOnCallEnd", false)
                putExtra("outgoingOverlay", true)
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_NO_ANIMATION or
                        Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
                )
            }

            fun showOutgoingNotificationFallback() {
                try {
                    if (!NotificationManagerCompat.from(applicationContext).areNotificationsEnabled()) return

                    val nm = applicationContext.getSystemService(NotificationManager::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val ch = NotificationChannel(
                            OUTGOING_NOTIF_CH,
                            "Tringo Outgoing Overlay",
                            NotificationManager.IMPORTANCE_HIGH
                        ).apply {
                            lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
                        }
                        nm.createNotificationChannel(ch)
                    }

                    val pi = PendingIntent.getActivity(
                        applicationContext,
                        OUTGOING_NOTIF_ID,
                        i,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )

                    val n = NotificationCompat.Builder(applicationContext, OUTGOING_NOTIF_CH)
                        .setSmallIcon(android.R.drawable.ic_menu_call)
                        .setContentTitle("Calling...")
                        .setContentText("Tringo Caller ID")
                        .setCategory(NotificationCompat.CATEGORY_CALL)
                        .setPriority(NotificationCompat.PRIORITY_MAX)
                        .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                        .setAutoCancel(true)
                        .setFullScreenIntent(pi, true)
                        .setContentIntent(pi)
                        .build()

                    NotificationManagerCompat.from(applicationContext).notify(OUTGOING_NOTIF_ID, n)
                } catch (t2: Throwable) {
                    Log.e(TAG, "outgoing notification fallback failed: ${t2.message}", t2)
                }
            }

            try {
                applicationContext.startActivity(i)
            } catch (t: Throwable) {
                Log.e(TAG, "startActivity outgoing trampoline failed: ${t.message}", t)
                showOutgoingNotificationFallback()
            }

            // Always post a full-screen notification as a safety net.
            // If the activity starts successfully, it cancels this notification immediately.
            if (!TringoOverlayService.isRunning) {
                showOutgoingNotificationFallback()
            }

            // Some OEMs silently deny background activity starts (no exception thrown).
            // If the overlay service doesn't come up shortly, use a full-screen notification trampoline.
            Handler(Looper.getMainLooper()).postDelayed({
                if (!TringoOverlayService.isRunning) {
                    showOutgoingNotificationFallback()
                }
            }, 800L)
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
