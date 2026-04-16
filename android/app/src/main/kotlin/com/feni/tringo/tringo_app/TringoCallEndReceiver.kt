package com.feni.tringo.tringo_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
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
        private const val KEY_USER_CLOSED = "user_closed_during_call"
        private const val KEY_USER_CLOSED_NUMBER = "user_closed_number"
        private const val KEY_RINGING_AT = "ringing_at"
        private const val KEY_SAW_OFFHOOK = "saw_offhook"
        private const val KEY_LAST_POSTCALL_AT = "last_postcall_at"

        // Keep small but non-zero to avoid noisy/false IDLE bursts on some OEMs.
        // Allow post-call overlay even for quick reject/missed calls.
        private const val MIN_RING_MS_FOR_MISSED = 200L
        private const val POSTCALL_DEDUP_MS = 20_000L
        private const val POSTCALL_NOTIF_CH = "tringo_postcall_overlay"
        private const val POSTCALL_NOTIF_ID = 302
        private const val OUTGOING_NOTIF_CH = "tringo_outgoing_overlay"
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
        val userClosed = prefs.getBoolean(KEY_USER_CLOSED, false)
        val ringingAt = prefs.getLong(KEY_RINGING_AT, 0L)
        val sawOffhook = prefs.getBoolean(KEY_SAW_OFFHOOK, false)
        val lastPostAt = prefs.getLong(KEY_LAST_POSTCALL_AT, 0L)

        val number = normalizePhoneForPhoneInfo(numberRaw)
        if (number.isNotBlank()) prefs.edit().putString(KEY_LAST_NUMBER, number).apply()

        val finalNumber = when {
            number.isNotBlank() -> number
            savedNumber.isNotBlank() -> normalizePhoneForPhoneInfo(savedNumber).ifBlank { savedNumber.trim() }
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
                // Outgoing calls often won't emit RINGING; treat OFFHOOK as session start.
                .putLong(KEY_RINGING_AT, now)
                .putBoolean(KEY_SAW_OFFHOOK, true)
                .apply()

            // Outgoing overlay: show when an outgoing call starts (IDLE -> OFFHOOK).
            // Incoming calls already handled by TringoCallReceiver (RINGING -> trampoline).
            if (lastState == TelephonyManager.EXTRA_STATE_IDLE) {
                val outgoingPhone = if (number.isNotBlank()) number else "UNKNOWN"
                launchOutgoingTrampoline(context, outgoingPhone)
            }
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

            // Use the same trampoline as incoming calls; directly starting a service from a
            // background receiver is blocked on many Android 12+ devices/OEMs.
            launchPostCallTrampoline(context, finalNumber)
        }

        // Update last state and clear session markers on idle to avoid stale ring duration.
        val edit = prefs.edit().putString(KEY_LAST_STATE, stateStr)
        if (stateStr == TelephonyManager.EXTRA_STATE_IDLE) {
            edit.putLong(KEY_RINGING_AT, 0L).putBoolean(KEY_SAW_OFFHOOK, false)
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

        try {
            context.startActivity(i)
            return
        } catch (t: Throwable) {
            Log.e(TAG, "startActivity post-call trampoline failed: ${t.message}", t)
        }

        // Fallback: heads-up / full-screen notification that can launch the trampoline.
        try {
            if (!NotificationManagerCompat.from(context).areNotificationsEnabled()) return

            val nm = context.getSystemService(NotificationManager::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                nm.createNotificationChannel(
                    NotificationChannel(
                        POSTCALL_NOTIF_CH,
                        "Tringo Post-call Overlay",
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

            val n = NotificationCompat.Builder(context, POSTCALL_NOTIF_CH)
                .setSmallIcon(android.R.drawable.ic_menu_call)
                .setContentTitle("Call ended")
                .setContentText("Tap to view Tringo details")
                .setCategory(NotificationCompat.CATEGORY_CALL)
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setAutoCancel(true)
                .setFullScreenIntent(pi, true)
                .setContentIntent(pi)
                .build()

            NotificationManagerCompat.from(context).notify(POSTCALL_NOTIF_ID, n)
        } catch (t: Throwable) {
            Log.e(TAG, "post-call notification fallback failed: ${t.message}", t)
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

        try {
            context.startActivity(i)
            return
        } catch (t: Throwable) {
            Log.e(TAG, "startActivity outgoing trampoline failed: ${t.message}", t)
        }

        try {
            if (!NotificationManagerCompat.from(context).areNotificationsEnabled()) return

            val nm = context.getSystemService(NotificationManager::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                nm.createNotificationChannel(
                    NotificationChannel(
                        OUTGOING_NOTIF_CH,
                        "Tringo Outgoing Overlay",
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

            val n = NotificationCompat.Builder(context, OUTGOING_NOTIF_CH)
                .setSmallIcon(android.R.drawable.ic_menu_call)
                .setContentTitle("Calling…")
                .setContentText("Tringo Caller ID")
                .setCategory(NotificationCompat.CATEGORY_CALL)
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setAutoCancel(true)
                .setFullScreenIntent(pi, true)
                .setContentIntent(pi)
                .build()

            NotificationManagerCompat.from(context).notify(OUTGOING_NOTIF_ID, n)
        } catch (t: Throwable) {
            Log.e(TAG, "outgoing notification fallback failed: ${t.message}", t)
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
