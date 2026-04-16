package com.feni.tringo.tringo_app

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.telephony.TelephonyManager
import android.view.WindowManager
import androidx.core.app.NotificationManagerCompat

class TringoIncomingPopupActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Cancel any incoming overlay notification if present (we use this activity as a trampoline).
        try { NotificationManagerCompat.from(this).cancel(301) } catch (_: Exception) {}

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                        WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }

        val phone = intent.getStringExtra("phone") ?: ""
        val contactName = intent.getStringExtra("contactName") ?: ""
        val showOnCallEnd = intent.getBooleanExtra("showOnCallEnd", false)
        val outgoingOverlay = intent.getBooleanExtra("outgoingOverlay", false)

        // Avoid showing an "incoming" overlay after the call already ended (late RINGING broadcasts on some OEMs).
        // Also avoid showing a "post-call" overlay if the device isn't idle yet.
        try {
            val tm = getSystemService(TELEPHONY_SERVICE) as? TelephonyManager
            val state = tm?.callState ?: TelephonyManager.CALL_STATE_IDLE
            when {
                showOnCallEnd -> {
                    if (state != TelephonyManager.CALL_STATE_IDLE) {
                        finish()
                        return
                    }
                }
                outgoingOverlay -> {
                    if (state != TelephonyManager.CALL_STATE_OFFHOOK) {
                        finish()
                        return
                    }
                }
                else -> {
                    if (state != TelephonyManager.CALL_STATE_RINGING) {
                        finish()
                        return
                    }
                }
            }
        } catch (_: Throwable) {}

        // Start the overlay service while we're in the foreground (avoids background start restrictions).
        TringoOverlayService.start(
            ctx = applicationContext,
            phone = phone,
            contactName = contactName,
            showOnCallEnd = showOnCallEnd,
            launchedByReceiver = true,
            outgoingOverlay = outgoingOverlay
        )

        // No UI here: the overlay is drawn by TringoOverlayService.
        try { overridePendingTransition(0, 0) } catch (_: Exception) {}
        finish()
    }

    override fun onDestroy() {
        super.onDestroy()
    }
}
