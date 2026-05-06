package com.feni.tringo.tringo_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.os.Handler
import android.os.Looper
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class TringoCallReceiver : BroadcastReceiver() {

        companion object {
        private const val TAG = "TRINGO_CALL_RX"
        private const val PREF = "tringo_call_state"
        private const val KEY_LAST_NUMBER = "last_number"
        private const val KEY_LAST_NUMBER_AT = "last_number_at"
        // IMPORTANT: channel importance cannot be upgraded once created on Android O+.
        // Use a versioned channel id so older installs with a low-importance channel still get heads-up.
        private const val INCOMING_NOTIF_CH = "tringo_incoming_overlay_v3"
        private const val INCOMING_NOTIF_ID = 301
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != TelephonyManager.ACTION_PHONE_STATE_CHANGED &&
            intent.action != "android.intent.action.PHONE_STATE"
        ) return

        val stateStr = intent.getStringExtra(TelephonyManager.EXTRA_STATE) ?: return
        if (stateStr != TelephonyManager.EXTRA_STATE_RINGING) return

        val numberFromBroadcast = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER) ?: ""
        val now = System.currentTimeMillis()

        val phone = normalizePhoneForPhoneInfo(
            when {
                numberFromBroadcast.isNotBlank() -> numberFromBroadcast
                else -> "UNKNOWN"
            }
        )

        val finalPhone = if (phone.isBlank()) "UNKNOWN" else phone
        Log.d(TAG, "RINGING phone=$finalPhone")

        // Always show a CALL category heads-up notification as a reliable fallback on OEM devices.
        // If the overlay window is shown successfully, the service will cancel this notification.
        showIncomingNotificationFallback(context, finalPhone)

        // Persist only real numbers (avoid storing UNKNOWN/blank).
        if (!finalPhone.equals("UNKNOWN", true)) {
            try {
                context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
                    .edit()
                    .putString(KEY_LAST_NUMBER, finalPhone)
                    .putLong(KEY_LAST_NUMBER_AT, now)
                    .apply()
            } catch (_: Throwable) {}
        }

        // Never auto-open the app: always prefer starting the overlay service, and fall back to a heads-up notification.
        val started = try {
            TringoOverlayService.start(
                ctx = context.applicationContext,
                phone = finalPhone,
                contactName = "",
                showOnCallEnd = false,
                launchedByReceiver = true,
                outgoingOverlay = false,
                sessionStartedAtMs = now
            )
        } catch (_: Throwable) {
            false
        }

        if (started) {
            // Give the service a short time to attach the overlay window.
            Handler(Looper.getMainLooper()).postDelayed({
                if (!TringoOverlayService.isRunning) {
                    startNoDisplayTrampoline(
                        context,
                        finalPhone,
                        showOnCallEnd = false,
                        outgoingOverlay = false,
                        sessionStartAt = now
                    )
                }
            }, 1200L)
            return
        }

        // Some devices block background service starts; fall back to a heads-up CALL notification.
        // Secondary attempt: no-UI trampoline (may still be blocked on some OEMs).
        startNoDisplayTrampoline(
            context,
            finalPhone,
            showOnCallEnd = false,
            outgoingOverlay = false,
            sessionStartAt = now
        )
    }

    private fun showIncomingNotificationFallback(context: Context, phone: String) {
        try {
            val nm = context.getSystemService(NotificationManager::class.java)
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                val ch = NotificationChannel(
                    INCOMING_NOTIF_CH,
                    "Tringo Incoming Overlay",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
                }
                nm.createNotificationChannel(ch)
            }

            val openAppIntent = Intent(context, MainActivity::class.java).apply {
                putExtra("overlay_action", "incoming_call")
                putExtra("phone", phone)
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                )
            }

            val pi = PendingIntent.getActivity(
                context,
                INCOMING_NOTIF_ID,
                openAppIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val b = NotificationCompat.Builder(context, INCOMING_NOTIF_CH)
                .setSmallIcon(android.R.drawable.ic_menu_call)
                .setContentTitle("Incoming call")
                .setContentText("Tringo Caller ID")
                .setCategory(NotificationCompat.CATEGORY_CALL)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setFullScreenIntent(pi, true)
                // Dark, ad-style look where supported (OEMs may ignore).
                .setColor(0xFF070A2A.toInt())
                .setColorized(true)
                .setAutoCancel(true)
                .setContentIntent(pi)

            NotificationManagerCompat.from(context).notify(INCOMING_NOTIF_ID, b.build())
        } catch (t: Throwable) {
            Log.e(TAG, "incoming notification fallback failed: ${t.message}", t)
        }
    }

    private fun startNoDisplayTrampoline(
        context: Context,
        phone: String,
        showOnCallEnd: Boolean,
        outgoingOverlay: Boolean,
        sessionStartAt: Long = 0L
    ) {
        try {
            val i = Intent(context, TringoIncomingPopupActivity::class.java).apply {
                putExtra("phone", phone)
                putExtra("contactName", "")
                putExtra("showOnCallEnd", showOnCallEnd)
                putExtra("outgoingOverlay", outgoingOverlay)
                putExtra("sessionStartAt", sessionStartAt)
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_NO_ANIMATION or
                        Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
                )
            }
            context.startActivity(i)
        } catch (t: Throwable) {
            Log.e(TAG, "startNoDisplayTrampoline failed: ${t.message}", t)
            showIncomingNotificationFallback(context, phone)
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
