package com.feni.tringo.tringo_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.KeyguardManager
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
        // Use a versioned channel id so older installs with a low-importance channel still get full-screen behavior.
        private const val INCOMING_NOTIF_CH = "tringo_incoming_overlay_v2"
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
        val (last, lastAt) = try {
            val sp = context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
            val num = sp.getString(KEY_LAST_NUMBER, "")?.trim().orEmpty()
            val at = sp.getLong(KEY_LAST_NUMBER_AT, 0L)
            num to at
        } catch (_: Throwable) {
            "" to 0L
        }
        val lastFresh = last.isNotBlank() && !last.equals("UNKNOWN", true) && lastAt > 0L && (now - lastAt) <= 1500L

        val phone = normalizePhoneForPhoneInfo(
            when {
                numberFromBroadcast.isNotBlank() -> numberFromBroadcast
                lastFresh -> last
                else -> "UNKNOWN"
            }
        )

        val finalPhone = if (phone.isBlank()) "UNKNOWN" else phone
        Log.d(TAG, "RINGING phone=$finalPhone")

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

        // Best-effort: try starting overlay service directly as well (works on some devices/roles).
        // If Android blocks it, TringoOverlayService.start() will fail safely and we’ll rely on the trampoline paths.
        try {
            TringoOverlayService.start(
                ctx = context.applicationContext,
                phone = phone,
                contactName = "",
                showOnCallEnd = false,
                launchedByReceiver = true,
                outgoingOverlay = false
            )
        } catch (_: Throwable) {}

        fun showIncomingNotificationFallback(fullScreen: Boolean) {
            // Fallback: heads-up notification, and full-screen on lock screen when needed.
            try {
                if (!NotificationManagerCompat.from(context).areNotificationsEnabled()) return

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

                val pi = PendingIntent.getActivity(
                    context,
                    INCOMING_NOTIF_ID,
                    i,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

                val b = NotificationCompat.Builder(context, INCOMING_NOTIF_CH)
                    .setSmallIcon(android.R.drawable.ic_menu_call)
                    .setContentTitle("Incoming call")
                    .setContentText("Tringo Caller ID")
                    .setCategory(NotificationCompat.CATEGORY_CALL)
                    .setPriority(NotificationCompat.PRIORITY_MAX)
                    .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                    .setAutoCancel(true)
                    .setContentIntent(pi)
                if (fullScreen) {
                    b.setFullScreenIntent(pi, true)
                }

                val n = b.build()

                NotificationManagerCompat.from(context).notify(INCOMING_NOTIF_ID, n)
            } catch (t: Throwable) {
                Log.e(TAG, "incoming notification fallback failed: ${t.message}", t)
            }
        }

        val isLocked = try {
            val km = context.getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
            km?.isKeyguardLocked == true
        } catch (_: Throwable) {
            false
        }

        // On many OEMs, starting an Activity from a background receiver while the device is locked is silently blocked.
        // A full-screen notification is the most reliable way to show UI on the lock screen.
        if (isLocked) {
            showIncomingNotificationFallback(fullScreen = true)
        }

        try {
            context.startActivity(i)
        } catch (t: Throwable) {
            Log.e(TAG, "startActivity trampoline failed: ${t.message}", t)
            showIncomingNotificationFallback(fullScreen = isLocked)
            return
        }

        // Some OEMs silently deny background activity starts (no exception thrown).
        // If the overlay service doesn't come up shortly, use the full-screen notification trampoline.
        Handler(Looper.getMainLooper()).postDelayed({
            if (!TringoOverlayService.isRunning) showIncomingNotificationFallback(fullScreen = isLocked)
        }, 500L)

        // Re-try once more in case the first notification was suppressed.
        Handler(Looper.getMainLooper()).postDelayed({
            if (!TringoOverlayService.isRunning) showIncomingNotificationFallback(fullScreen = isLocked)
        }, 1200L)

        // Additional retries for slower lock-screen / OEM pipelines.
        Handler(Looper.getMainLooper()).postDelayed({
            if (!TringoOverlayService.isRunning) showIncomingNotificationFallback(fullScreen = isLocked)
        }, 2500L)

        Handler(Looper.getMainLooper()).postDelayed({
            if (!TringoOverlayService.isRunning) showIncomingNotificationFallback(fullScreen = isLocked)
        }, 4500L)
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
