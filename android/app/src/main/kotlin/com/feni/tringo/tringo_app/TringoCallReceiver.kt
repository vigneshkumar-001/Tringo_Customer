package com.feni.tringo.tringo_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class TringoCallReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "TRINGO_CALL_RX"
        private const val INCOMING_NOTIF_CH = "tringo_incoming_overlay"
        private const val INCOMING_NOTIF_ID = 301
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != TelephonyManager.ACTION_PHONE_STATE_CHANGED &&
            intent.action != "android.intent.action.PHONE_STATE"
        ) return

        val stateStr = intent.getStringExtra(TelephonyManager.EXTRA_STATE) ?: return
        if (stateStr != TelephonyManager.EXTRA_STATE_RINGING) return

        val numberFromBroadcast = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER) ?: ""
        val last = try {
            context.getSharedPreferences("tringo_call_state", Context.MODE_PRIVATE)
                .getString("last_number", "")
                ?.trim()
                .orEmpty()
        } catch (_: Throwable) {
            ""
        }

        val phone = normalizePhoneForPhoneInfo(
            when {
                numberFromBroadcast.isNotBlank() -> numberFromBroadcast
                last.isNotBlank() && !last.equals("UNKNOWN", true) -> last
                else -> "UNKNOWN"
            }
        )

        val finalPhone = if (phone.isBlank()) "UNKNOWN" else phone
        Log.d(TAG, "RINGING phone=$finalPhone")

        // Persist only real numbers (avoid storing UNKNOWN/blank).
        if (!finalPhone.equals("UNKNOWN", true)) {
            try {
                context.getSharedPreferences("tringo_call_state", Context.MODE_PRIVATE)
                    .edit()
                    .putString("last_number", finalPhone)
                    .apply()
            } catch (_: Throwable) {}
        }

        // Start a tiny foreground trampoline activity to reliably start the overlay service
        // (Android blocks starting FGS directly from background receivers on newer versions).
        launchIncomingTrampoline(context, finalPhone)
    }

    private fun launchIncomingTrampoline(context: Context, phone: String) {
        val i = Intent(context, TringoIncomingPopupActivity::class.java).apply {
            putExtra("phone", phone)
            putExtra("contactName", "")
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_NO_ANIMATION or
                    Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
            )
        }

        try {
            context.startActivity(i)
            return
        } catch (t: Throwable) {
            Log.e(TAG, "startActivity trampoline failed: ${t.message}", t)
        }

        // Fallback: heads-up / full-screen notification that can launch the trampoline.
        try {
            if (!NotificationManagerCompat.from(context).areNotificationsEnabled()) return

            val nm = context.getSystemService(NotificationManager::class.java)
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                nm.createNotificationChannel(
                    NotificationChannel(
                        INCOMING_NOTIF_CH,
                        "Tringo Incoming Overlay",
                        NotificationManager.IMPORTANCE_HIGH
                    )
                )
            }

            val pi = PendingIntent.getActivity(
                context,
                0,
                i,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val n = NotificationCompat.Builder(context, INCOMING_NOTIF_CH)
                .setSmallIcon(android.R.drawable.ic_menu_call)
                .setContentTitle("Incoming call")
                .setContentText("Tringo Caller ID")
                .setCategory(NotificationCompat.CATEGORY_CALL)
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setAutoCancel(true)
                .setFullScreenIntent(pi, true)
                .setContentIntent(pi)
                .build()

            NotificationManagerCompat.from(context).notify(INCOMING_NOTIF_ID, n)
        } catch (t: Throwable) {
            Log.e(TAG, "incoming notification fallback failed: ${t.message}", t)
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
