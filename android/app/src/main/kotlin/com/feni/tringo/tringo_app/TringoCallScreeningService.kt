package com.feni.tringo.tringo_app

import android.content.Intent
import android.os.Build
import android.telecom.Call
import android.telecom.CallScreeningService
import androidx.annotation.RequiresApi
import android.util.Log

@RequiresApi(Build.VERSION_CODES.N) // API 24+
class TringoCallScreeningService : CallScreeningService() {

    override fun onScreenCall(callDetails: Call.Details) {
        val number = callDetails.handle?.schemeSpecificPart ?: ""

        // ✅ LOG HERE
        Log.d("TRINGO_CALL", "Incoming call: $number")

        val i = Intent(this, TringoOverlayService::class.java)
        i.putExtra("phone", number)

        // ✅ start foreground service safely
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(i)
        } else {
            startService(i)
        }

        respondToCall(callDetails, CallResponse.Builder().build())
    }
}


//package com.feni.tringo.tringo_app
//
//import android.content.Intent
//import android.os.Build
//import android.telecom.Call
//import android.telecom.CallScreeningService
//import androidx.annotation.RequiresApi
//import android.util.Log
//
//
//@RequiresApi(Build.VERSION_CODES.N) // ✅ API 24
//class TringoCallScreeningService : CallScreeningService() {
//
//    override fun onScreenCall(callDetails: Call.Details) {
//        val number = callDetails.handle?.schemeSpecificPart ?: ""
//
//        val i = Intent(this, TringoOverlayService::class.java)
//        i.putExtra("phone", number)
//        startForegroundService(i)
//
//        respondToCall(callDetails, CallResponse.Builder().build())
//    }
//}
