package com.feni.tringo.tringo_app

import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log

class TringoCallScreeningService : CallScreeningService() {

    override fun onScreenCall(callDetails: Call.Details) {
        try {
            val phone = callDetails.handle?.schemeSpecificPart ?: ""
            Log.d("TRINGO_SCREEN", "Incoming call: $phone")

            // ✅ Start your overlay (keep contactName empty here)
            TringoOverlayService.start(applicationContext, phone, "")

            // ✅ Allow call normally (just identify)
            val response = CallResponse.Builder()
                .setDisallowCall(false)
                .setRejectCall(false)
                .setSkipCallLog(false)
                .setSkipNotification(false)
                .build()

            respondToCall(callDetails, response)

        } catch (e: Exception) {
            Log.e("TRINGO_SCREEN", "onScreenCall error: ${e.message}", e)

            // ✅ Always allow call if any crash
            val response = CallResponse.Builder()
                .setDisallowCall(false)
                .setRejectCall(false)
                .setSkipCallLog(false)
                .setSkipNotification(false)
                .build()

            respondToCall(callDetails, response)
        }
    }
}

//package com.feni.tringo.tringo_app
//
//import android.app.NotificationChannel
//import android.app.NotificationManager
//import android.app.PendingIntent
//import android.content.Intent
//import android.os.Build
//import android.provider.Settings
//import android.telecom.Call
//import android.telecom.CallScreeningService
//import android.util.Log
//import androidx.annotation.RequiresApi
//import androidx.core.app.NotificationCompat
//import androidx.core.app.NotificationManagerCompat
//
//@RequiresApi(Build.VERSION_CODES.N)
//class TringoCallScreeningService : CallScreeningService() {
//
//    private val TAG = "TRINGO_SCREEN"
//
//    // ✅ debounce multiple triggers
//    private var lastNumber: String? = null
//    private var lastTime: Long = 0L
//
//    override fun onScreenCall(details: Call.Details) {
//        try {
//            val number = details.handle?.schemeSpecificPart.orEmpty()
//            if (number.isBlank()) return
//
//            val now = System.currentTimeMillis()
//            if (lastNumber == number && (now - lastTime) < 1500) {
//                Log.d(TAG, "Debounced duplicate onScreenCall for $number")
//                return
//            }
//            lastNumber = number
//            lastTime = now
//
//            Log.d(TAG, "onScreenCall fired. number=$number")
//
//            // Always allow call
//            val response = CallResponse.Builder()
//                .setDisallowCall(false)
//                .setRejectCall(false)
//                .setSkipCallLog(false)
//                .setSkipNotification(false)
//                .build()
//            respondToCall(details, response)
//
//            // ✅ Android 14+ => FullScreenIntent (reliable)
//            if (Build.VERSION.SDK_INT >= 34) {
//                showCallFullScreen(number)
//                return
//            }
//
//            // ✅ Android 12/13 => Overlay if allowed
//            val overlayAllowed =
//                Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)
//
//            if (overlayAllowed) {
//                TringoOverlayService.start(this, number, "")
//                Log.d(TAG, "Overlay service start requested for $number")
//            } else {
//                showBasicHeadsUp(number, "Enable overlay permission to show caller popup")
//            }
//
//        } catch (e: Exception) {
//            Log.e(TAG, "onScreenCall error: ${e.message}", e)
//        }
//    }
//
//    private fun showCallFullScreen(phone: String) {
//        if (!NotificationManagerCompat.from(this).areNotificationsEnabled()) {
//            Log.e(TAG, "Notifications disabled. Cannot show full-screen call alert.")
//            return
//        }
//
//        val channelId = "tringo_call_alert"
//        ensureChannel(channelId)
//
//        val intent = Intent(this, TringoCallerPopupActivity::class.java).apply {
//            putExtra("phone", phone)
//            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
//        }
//
//        val pi = PendingIntent.getActivity(
//            this, 911, intent,
//            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
//        )
//
//        val notif = NotificationCompat.Builder(this, channelId)
//            .setSmallIcon(android.R.drawable.ic_menu_call)
//            .setContentTitle("Tringo Caller ID")
//            .setContentText(phone)
//            .setPriority(NotificationCompat.PRIORITY_MAX)
//            .setCategory(NotificationCompat.CATEGORY_CALL)
//            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
//            .setAutoCancel(true)
//            .setFullScreenIntent(pi, true)
//            .build()
//
//        getSystemService(NotificationManager::class.java).notify(202, notif)
//        Log.d(TAG, "Full-screen call alert shown for $phone")
//    }
//
//    private fun showBasicHeadsUp(title: String, msg: String) {
//        if (!NotificationManagerCompat.from(this).areNotificationsEnabled()) return
//
//        val channelId = "tringo_call_alert"
//        ensureChannel(channelId)
//
//        val notif = NotificationCompat.Builder(this, channelId)
//            .setSmallIcon(android.R.drawable.ic_menu_call)
//            .setContentTitle(title)
//            .setContentText(msg)
//            .setPriority(NotificationCompat.PRIORITY_HIGH)
//            .setCategory(NotificationCompat.CATEGORY_CALL)
//            .setAutoCancel(true)
//            .build()
//
//        getSystemService(NotificationManager::class.java).notify(202, notif)
//    }
//
//    private fun ensureChannel(channelId: String) {
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            val nm = getSystemService(NotificationManager::class.java)
//            val ch = NotificationChannel(
//                channelId,
//                "Tringo Call Alerts",
//                NotificationManager.IMPORTANCE_HIGH
//            )
//            nm.createNotificationChannel(ch)
//        }
//    }
//}
