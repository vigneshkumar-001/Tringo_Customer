package com.feni.tringo.tringo_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.KeyguardManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class TringoCallEndReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "TRINGO_CALL_END_RX"
        private const val PREF = "tringo_call_state"
        private const val KEY_LAST_STATE = "last_state"
        private const val KEY_LAST_NUMBER = "last_number"
        private const val KEY_LAST_NUMBER_AT = "last_number_at"
        private const val KEY_USER_CLOSED = "user_closed_during_call"
        private const val KEY_USER_CLOSED_NUMBER = "user_closed_number"
        private const val KEY_RINGING_AT = "ringing_at"
        private const val KEY_SAW_OFFHOOK = "saw_offhook"
        private const val KEY_LAST_POSTCALL_AT = "last_postcall_at"
        private const val KEY_LAST_POSTCALL_SESSION = "last_postcall_session"
        private const val KEY_LAST_OUTGOING_OVERLAY_SESSION = "last_outgoing_overlay_session"

        // IMPORTANT: channel importance cannot be upgraded once created on Android O+.
        // Use a versioned channel id so older installs with a low-importance channel still get full-screen behavior.
        private const val POSTCALL_NOTIF_CH = "tringo_postcall_overlay_v2"
        private const val POSTCALL_NOTIF_ID = 302
        private const val OUTGOING_NOTIF_CH = "tringo_outgoing_overlay_v2"
        private const val OUTGOING_NOTIF_ID = 303

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

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != TelephonyManager.ACTION_PHONE_STATE_CHANGED &&
            intent.action != "android.intent.action.PHONE_STATE"
        ) return

        val stateStr = intent.getStringExtra(TelephonyManager.EXTRA_STATE) ?: return
        val numberRaw = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER) ?: ""
        val now = System.currentTimeMillis()

        val prefs = context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
        val lastState = prefs.getString(KEY_LAST_STATE, "") ?: ""
        val savedNumber = prefs.getString(KEY_LAST_NUMBER, "") ?: ""
        val savedNumberAt = prefs.getLong(KEY_LAST_NUMBER_AT, 0L)
        val userClosed = prefs.getBoolean(KEY_USER_CLOSED, false)
        val ringingAt = prefs.getLong(KEY_RINGING_AT, 0L)
        val sawOffhook = prefs.getBoolean(KEY_SAW_OFFHOOK, false)
        val lastPostAt = prefs.getLong(KEY_LAST_POSTCALL_AT, 0L)
        val lastPostSession = prefs.getLong(KEY_LAST_POSTCALL_SESSION, 0L)

        val number = normalizePhoneForPhoneInfo(numberRaw)
        if (number.isNotBlank()) {
            prefs.edit()
                .putString(KEY_LAST_NUMBER, number)
                .putLong(KEY_LAST_NUMBER_AT, now)
                .apply()
        }

        // Session-aware: never reuse an old "last_number" from a previous call.
        // If Android doesn't provide EXTRA_INCOMING_NUMBER, only trust savedNumber when it was updated
        // during the current call session.
        val sessionStartForNumber = if (ringingAt > 0L) ringingAt else now
        val savedFreshForThisSession =
            savedNumber.isNotBlank() &&
                savedNumberAt > 0L &&
                // allow slight clock/order skew
                savedNumberAt >= (sessionStartForNumber - 1500L) &&
                // and must be recent
                (now - savedNumberAt) <= 120_000L

        val finalNumber = when {
            number.isNotBlank() -> number
            savedFreshForThisSession -> normalizePhoneForPhoneInfo(savedNumber).ifBlank { savedNumber.trim() }
            else -> "UNKNOWN"
        }

        val ringFor = if (ringingAt > 0) (now - ringingAt) else 0L
        Log.d(TAG, "state=$stateStr lastState=$lastState final=$finalNumber closed=$userClosed offhook=$sawOffhook ringMs=$ringFor lastPostAt=$lastPostAt")

        // Track call session.
        if (stateStr == TelephonyManager.EXTRA_STATE_RINGING) {
            prefs.edit()
                .putLong(KEY_RINGING_AT, now)
                .putBoolean(KEY_SAW_OFFHOOK, false)
                .remove(KEY_LAST_OUTGOING_OVERLAY_SESSION)
                .apply()
        } else if (stateStr == TelephonyManager.EXTRA_STATE_OFFHOOK) {
            // Outgoing calls often won't emit RINGING; treat OFFHOOK as session start ONLY if we don't have one yet.
            val sessionStart = if (ringingAt > 0L) ringingAt else now
            val outgoingOverlaySession = prefs.getLong(KEY_LAST_OUTGOING_OVERLAY_SESSION, 0L)

            prefs.edit()
                .putLong(KEY_RINGING_AT, sessionStart)
                .putBoolean(KEY_SAW_OFFHOOK, true)
                .apply()

            // Outgoing overlay: show when OFFHOOK is part of an outgoing session.
            // Some devices can leave prefs in a stale "RINGING" state if we miss the final IDLE broadcast.
            // So only treat OFFHOOK as "incoming answered" when we have a fresh ringingAt timestamp.
            val isLikelyIncomingAnswer =
                lastState == TelephonyManager.EXTRA_STATE_RINGING &&
                    ringingAt > 0L &&
                    (now - ringingAt) <= 120_000L

            if (!isLikelyIncomingAnswer && outgoingOverlaySession != sessionStart) {
                val savedFreshForOutgoingSession =
                    savedNumber.isNotBlank() &&
                        savedNumberAt > 0L &&
                        savedNumberAt >= (sessionStart - 1500L) &&
                        (now - savedNumberAt) <= 120_000L

                val outgoingPhone = when {
                    number.isNotBlank() -> number
                    savedFreshForOutgoingSession -> normalizePhoneForPhoneInfo(savedNumber).ifBlank { savedNumber.trim() }
                    else -> "UNKNOWN"
                }

                prefs.edit().putLong(KEY_LAST_OUTGOING_OVERLAY_SESSION, sessionStart).apply()
                launchOutgoingTrampoline(context, outgoingPhone)
            }
        }

        val endedNow =
            stateStr == TelephonyManager.EXTRA_STATE_IDLE &&
                lastState != TelephonyManager.EXTRA_STATE_IDLE &&
                (lastState == TelephonyManager.EXTRA_STATE_RINGING ||
                    lastState == TelephonyManager.EXTRA_STATE_OFFHOOK ||
                    ringingAt > 0L ||
                    sawOffhook)

        // Always trigger post-call overlay from receiver to improve reliability on OEM devices.
        // The service will decide whether/what to show.
        if (endedNow) {
            // De-dupe ONLY for the same call session. OEMs can emit multiple IDLE broadcasts for a single hangup.
            // Use ringingAt (or OFFHOOK-start timestamp) as a stable session id.
            val sessionId = if (ringingAt > 0L) ringingAt else now
            if (lastPostSession == sessionId && lastPostAt > 0L && (now - lastPostAt) < 15_000L) {
                prefs.edit().putString(KEY_LAST_STATE, stateStr).apply()
                return
            }

            fun isDeviceIdleNow(): Boolean {
                return try {
                    val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
                    (tm?.callState ?: TelephonyManager.CALL_STATE_IDLE) == TelephonyManager.CALL_STATE_IDLE
                } catch (_: Throwable) {
                    true
                }
            }

            fun triggerPostCall() {
                // Clear "user closed" before starting, so the service doesn't read stale suppression flags.
                prefs.edit()
                    .putBoolean(KEY_USER_CLOSED, false)
                    .remove(KEY_USER_CLOSED_NUMBER)
                    .putLong(KEY_LAST_POSTCALL_AT, System.currentTimeMillis())
                    .putLong(KEY_LAST_POSTCALL_SESSION, sessionId)
                    .apply()

                // Use the same trampoline as incoming calls; directly starting a service from a
                // background receiver is blocked on many Android 12+ devices/OEMs.
                launchPostCallTrampoline(context, finalNumber)
            }

            // Guard against transient/false IDLE while still ringing (some OEMs), but be tolerant:
            // some devices update TelephonyManager.callState to IDLE slowly after the IDLE broadcast.
            val pending = goAsync()
            val handler = Handler(Looper.getMainLooper())
            val startedAt = System.currentTimeMillis()
            val maxWaitMs = 7_000L
            val pollMs = 250L

            fun finishAsync() {
                try {
                    pending.finish()
                } catch (_: Throwable) {}
            }

            fun pollUntilIdle() {
                try {
                    if (isDeviceIdleNow()) {
                        triggerPostCall()
                        finishAsync()
                        return
                    }

                    if (System.currentTimeMillis() - startedAt >= maxWaitMs) {
                        Log.w(TAG, "post-call trigger skipped: callState not IDLE within ${maxWaitMs}ms")
                        finishAsync()
                        return
                    }

                    handler.postDelayed({ pollUntilIdle() }, pollMs)
                } catch (_: Throwable) {
                    finishAsync()
                }
            }

            pollUntilIdle()
        }

        // Update last state and clear session markers on idle to avoid stale ring duration.
        val edit = prefs.edit().putString(KEY_LAST_STATE, stateStr)
        if (stateStr == TelephonyManager.EXTRA_STATE_IDLE) {
            edit.putLong(KEY_RINGING_AT, 0L)
                .putBoolean(KEY_SAW_OFFHOOK, false)
                .remove(KEY_LAST_OUTGOING_OVERLAY_SESSION)
        }
        edit.apply()
    }

    private fun launchPostCallTrampoline(context: Context, phone: String) {
        val i = Intent(context, TringoIncomingPopupActivity::class.java).apply {
            putExtra("phone", phone)
            putExtra("contactName", "")
            putExtra("showOnCallEnd", true)
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
                showOnCallEnd = true,
                launchedByReceiver = true,
                outgoingOverlay = false
            )
        } catch (_: Throwable) {}

        fun showPostCallNotificationFallback(fullScreen: Boolean) {
            // Fallback: heads-up notification, and full-screen on lock screen when needed.
            try {
                if (!NotificationManagerCompat.from(context).areNotificationsEnabled()) return

                val nm = context.getSystemService(NotificationManager::class.java)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val ch = NotificationChannel(
                        POSTCALL_NOTIF_CH,
                        "Tringo Post-call Overlay",
                        NotificationManager.IMPORTANCE_HIGH
                    ).apply {
                        lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
                    }
                    nm.createNotificationChannel(ch)
                }

                val pi = PendingIntent.getActivity(
                    context,
                    POSTCALL_NOTIF_ID,
                    i,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

                val b = NotificationCompat.Builder(context, POSTCALL_NOTIF_CH)
                .setSmallIcon(android.R.drawable.ic_menu_call)
                .setContentTitle("Call ended")
                .setContentText("Tap to view Tringo details")
                .setCategory(NotificationCompat.CATEGORY_CALL)
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setAutoCancel(true)
                .setContentIntent(pi)
                if (fullScreen) {
                    b.setFullScreenIntent(pi, true)
                }
                val n = b.build()

                NotificationManagerCompat.from(context).notify(POSTCALL_NOTIF_ID, n)
            } catch (t: Throwable) {
                Log.e(TAG, "post-call notification fallback failed: ${t.message}", t)
            }
        }

        val isLocked = try {
            val km = context.getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
            km?.isKeyguardLocked == true
        } catch (_: Throwable) {
            false
        }

        if (isLocked) {
            // Locked device: prefer full-screen notification and trampoline activity for visibility.
            showPostCallNotificationFallback(fullScreen = true)

            try {
                context.startActivity(i)
            } catch (t: Throwable) {
                Log.e(TAG, "startActivity post-call trampoline failed: ${t.message}", t)
            }

            // Some OEMs silently deny background activity starts (no exception thrown).
            // If the overlay service doesn't come up shortly, use the notification trampoline.
            Handler(Looper.getMainLooper()).postDelayed({
                if (!TringoOverlayService.isRunning) showPostCallNotificationFallback(fullScreen = true)
            }, 500L)

            Handler(Looper.getMainLooper()).postDelayed({
                if (!TringoOverlayService.isRunning) showPostCallNotificationFallback(fullScreen = true)
            }, 1200L)

            Handler(Looper.getMainLooper()).postDelayed({
                if (!TringoOverlayService.isRunning) showPostCallNotificationFallback(fullScreen = true)
            }, 2500L)

            Handler(Looper.getMainLooper()).postDelayed({
                if (!TringoOverlayService.isRunning) showPostCallNotificationFallback(fullScreen = true)
            }, 4500L)
        } else {
            // Unlocked device: avoid popping an Activity (looks like "app opened").
            // If the overlay service doesn't come up, use a heads-up notification without full-screen.
            Handler(Looper.getMainLooper()).postDelayed({
                if (!TringoOverlayService.isRunning) showPostCallNotificationFallback(fullScreen = false)
            }, 800L)

            Handler(Looper.getMainLooper()).postDelayed({
                if (!TringoOverlayService.isRunning) showPostCallNotificationFallback(fullScreen = false)
            }, 2000L)
        }
    }

    private fun launchOutgoingTrampoline(context: Context, phone: String) {
        val i = Intent(context, TringoIncomingPopupActivity::class.java).apply {
            putExtra("phone", phone)
            putExtra("contactName", "")
            putExtra("showOnCallEnd", false)
            putExtra("outgoingOverlay", true)
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
                outgoingOverlay = true
            )
        } catch (_: Throwable) {}

        fun showOutgoingNotificationFallback(fullScreen: Boolean) {
            try {
                if (!NotificationManagerCompat.from(context).areNotificationsEnabled()) return

                val nm = context.getSystemService(NotificationManager::class.java)
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
                    context,
                    OUTGOING_NOTIF_ID,
                    i,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

                val b = NotificationCompat.Builder(context, OUTGOING_NOTIF_CH)
                    .setSmallIcon(android.R.drawable.ic_menu_call)
                    .setContentTitle("Calling...")
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

                NotificationManagerCompat.from(context).notify(OUTGOING_NOTIF_ID, n)
            } catch (t: Throwable) {
                Log.e(TAG, "outgoing notification fallback failed: ${t.message}", t)
            }
        }

        val isLocked = try {
            val km = context.getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
            km?.isKeyguardLocked == true
        } catch (_: Throwable) {
            false
        }

        if (isLocked) {
            // Locked: full-screen is acceptable (call UX) and more reliable.
            showOutgoingNotificationFallback(fullScreen = true)
            try {
                context.startActivity(i)
            } catch (t: Throwable) {
                Log.e(TAG, "startActivity outgoing trampoline failed: ${t.message}", t)
            }

            Handler(Looper.getMainLooper()).postDelayed({
                if (!TringoOverlayService.isRunning) showOutgoingNotificationFallback(fullScreen = true)
            }, 800L)

            Handler(Looper.getMainLooper()).postDelayed({
                if (!TringoOverlayService.isRunning) showOutgoingNotificationFallback(fullScreen = true)
            }, 2500L)
        } else {
            // Unlocked: avoid popping an Activity; show heads-up only if service doesn't come up.
            Handler(Looper.getMainLooper()).postDelayed({
                if (!TringoOverlayService.isRunning) showOutgoingNotificationFallback(fullScreen = false)
            }, 800L)

            Handler(Looper.getMainLooper()).postDelayed({
                if (!TringoOverlayService.isRunning) showOutgoingNotificationFallback(fullScreen = false)
            }, 2000L)
        }
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
