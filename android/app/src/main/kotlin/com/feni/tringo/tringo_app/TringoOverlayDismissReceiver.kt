package com.feni.tringo.tringo_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.app.NotificationManagerCompat

class TringoOverlayDismissReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "TRINGO_OVERLAY_DISMISS"
        const val ACTION_DISMISS_OVERLAY = "com.feni.tringo.tringo_app.ACTION_DISMISS_OVERLAY"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_DISMISS_OVERLAY) return

        try {
            // Stop overlay service (if running). This removes the window in onDestroy.
            context.stopService(Intent(context, TringoOverlayService::class.java))
        } catch (t: Throwable) {
            Log.e(TAG, "stopService failed: ${t.message}", t)
        }

        // Also clear any overlay-related notifications.
        try {
            NotificationManagerCompat.from(context).cancel(301) // incoming fallback
            NotificationManagerCompat.from(context).cancel(302) // post-call fallback
            NotificationManagerCompat.from(context).cancel(303) // outgoing fallback
        } catch (_: Throwable) {}
    }
}

