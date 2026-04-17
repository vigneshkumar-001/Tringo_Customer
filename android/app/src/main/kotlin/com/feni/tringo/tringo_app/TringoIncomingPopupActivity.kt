package com.feni.tringo.tringo_app

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.telephony.TelephonyManager
import android.view.WindowManager
import androidx.core.app.NotificationManagerCompat

class TringoIncomingPopupActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Cancel any overlay notification if present (we use this activity as a trampoline).
        try { NotificationManagerCompat.from(this).cancel(301) } catch (_: Exception) {}
        try { NotificationManagerCompat.from(this).cancel(302) } catch (_: Exception) {}
        try { NotificationManagerCompat.from(this).cancel(303) } catch (_: Exception) {}

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

        // Post-call overlay: start the service immediately while we're in the foreground.
        // Some OEMs take several seconds to report TelephonyManager.callState=IDLE after the IDLE broadcast,
        // so gating here can cause the post-call overlay to never start.
        if (showOnCallEnd) {
            TringoOverlayService.start(
                ctx = applicationContext,
                phone = phone,
                contactName = contactName,
                showOnCallEnd = true,
                launchedByReceiver = true,
                outgoingOverlay = false
            )
            try { overridePendingTransition(0, 0) } catch (_: Exception) {}
            finish()
            return
        }

        // Some OEMs are slow/noisy in updating TelephonyManager.callState.
        // If we check callState too early, we may finish and the overlay never starts.
        // Wait briefly for the expected state before giving up.
        val handler = Handler(Looper.getMainLooper())
        var attempts = 0
        val maxAttempts = 12 // ~1.2s

        fun expectedStateOk(state: Int): Boolean {
            return when {
                showOnCallEnd -> state == TelephonyManager.CALL_STATE_IDLE
                outgoingOverlay -> state == TelephonyManager.CALL_STATE_OFFHOOK
                else -> state == TelephonyManager.CALL_STATE_RINGING || state == TelephonyManager.CALL_STATE_OFFHOOK
            }
        }

        fun tryStart() {
            val state = try {
                (getSystemService(TELEPHONY_SERVICE) as? TelephonyManager)?.callState
                    ?: TelephonyManager.CALL_STATE_IDLE
            } catch (_: Throwable) {
                TelephonyManager.CALL_STATE_IDLE
            }

            if (!expectedStateOk(state)) {
                if (attempts++ < maxAttempts) {
                    handler.postDelayed({ tryStart() }, 100L)
                } else {
                    // Outgoing call UX: if the system never reports OFFHOOK (some OEMs),
                    // still start the overlay best-effort. This is only reached after
                    // we already tried waiting ~1.2s.
                    if (outgoingOverlay) {
                        TringoOverlayService.start(
                            ctx = applicationContext,
                            phone = phone,
                            contactName = contactName,
                            showOnCallEnd = showOnCallEnd,
                            launchedByReceiver = true,
                            outgoingOverlay = true
                        )
                    }
                    finish()
                }
                return
            }

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

        tryStart()
    }

    override fun onDestroy() {
        super.onDestroy()
    }
}
