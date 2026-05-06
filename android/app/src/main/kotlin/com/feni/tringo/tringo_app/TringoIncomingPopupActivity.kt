package com.feni.tringo.tringo_app

import android.app.Activity
import android.os.Build
import android.os.Bundle
import androidx.core.app.NotificationManagerCompat

class TringoIncomingPopupActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Cancel any overlay notification if present (we use this activity as a trampoline).
        try { NotificationManagerCompat.from(this).cancel(301) } catch (_: Exception) {}
        try { NotificationManagerCompat.from(this).cancel(302) } catch (_: Exception) {}
        try { NotificationManagerCompat.from(this).cancel(303) } catch (_: Exception) {}

        val phone = intent.getStringExtra("phone") ?: ""
        val contactName = intent.getStringExtra("contactName") ?: ""
        val showOnCallEnd = intent.getBooleanExtra("showOnCallEnd", false)
        val outgoingOverlay = intent.getBooleanExtra("outgoingOverlay", false)
        val sessionStartAt = intent.getLongExtra("sessionStartAt", 0L)

        // IMPORTANT:
        // This Activity runs with Theme.NoDisplay and MUST call finish() before onResume completes
        // (otherwise Android throws IllegalStateException). Keep it as a zero-UI trampoline only.
        TringoOverlayService.start(
            ctx = applicationContext,
            phone = phone,
            contactName = contactName,
            showOnCallEnd = showOnCallEnd,
            launchedByReceiver = false,
            outgoingOverlay = outgoingOverlay,
            sessionStartedAtMs = sessionStartAt
        )

        try { overridePendingTransition(0, 0) } catch (_: Exception) {}
        finish()
    }

    override fun onDestroy() {
        super.onDestroy()
    }
}
