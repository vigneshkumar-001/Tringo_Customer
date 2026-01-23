package com.feni.tringo.tringo_app

import android.net.Uri
import android.telecom.Call
import android.telecom.InCallService
import android.util.Log

class TringoInCallService : InCallService() {

    private val TAG = "TRINGO_INCALL"

    private var startedForThisCall = false
    private var lastNumber: String = ""

    private var activeCall: Call? = null
    private var callback: Call.Callback? = null

    override fun onCallAdded(call: Call) {
        super.onCallAdded(call)

        activeCall = call
        startedForThisCall = false
        lastNumber = extractNumber(call)

        Log.d(TAG, "onCallAdded state=${call.state} number=$lastNumber")

        val cb = object : Call.Callback() {
            override fun onStateChanged(call: Call, state: Int) {
                super.onStateChanged(call, state)

                val n = extractNumber(call)
                if (n.isNotBlank()) lastNumber = n

                Log.d(TAG, "stateChanged state=$state number=$lastNumber started=$startedForThisCall")

                // ✅ Outgoing start trigger (dialing/connecting/active)
                if (!startedForThisCall && isOutgoingLikeState(state) && lastNumber.isNotBlank()) {
                    startedForThisCall = true

                    TringoOverlayService.start(
                        ctx = this@TringoInCallService,
                        phone = lastNumber,
                        contactName = "",
                        showOnCallEnd = true
                    )

                    Log.d(TAG, "Started Overlay watcher for outgoing: $lastNumber")
                }

                // ✅ Incoming also: once it becomes ringing/active, start watcher (optional but useful)
                if (!startedForThisCall && isIncomingLikeState(state) && lastNumber.isNotBlank()) {
                    startedForThisCall = true

                    TringoOverlayService.start(
                        ctx = this@TringoInCallService,
                        phone = lastNumber,
                        contactName = "",
                        showOnCallEnd = true
                    )

                    Log.d(TAG, "Started Overlay watcher for incoming: $lastNumber")
                }
            }
        }

        callback = cb
        try {
            call.registerCallback(cb)
        } catch (e: Exception) {
            Log.e(TAG, "registerCallback failed: ${e.message}", e)
        }
    }

    override fun onCallRemoved(call: Call) {
        Log.d(TAG, "onCallRemoved number=$lastNumber")
        try {
            callback?.let { call.unregisterCallback(it) }
        } catch (_: Exception) {
        }
        callback = null
        activeCall = null
        super.onCallRemoved(call)
    }

    private fun isOutgoingLikeState(state: Int): Boolean {
        return state == Call.STATE_DIALING ||
                state == Call.STATE_CONNECTING ||
                state == Call.STATE_ACTIVE
    }

    private fun isIncomingLikeState(state: Int): Boolean {
        return state == Call.STATE_RINGING ||
                state == Call.STATE_ACTIVE
    }

    private fun extractNumber(call: Call): String {
        return try {
            val handle: Uri? = call.details?.handle
            val raw = handle?.schemeSpecificPart ?: ""
            raw.trim()
        } catch (e: Exception) {
            Log.e(TAG, "extractNumber failed: ${e.message}", e)
            ""
        }
    }
}
