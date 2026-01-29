package com.feni.tringo.tringo_app

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.graphics.PixelFormat
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.telephony.TelephonyCallback
import android.telephony.TelephonyManager
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.TextView
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import coil.load
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min

class TringoOverlayService : Service() {

    private val TAG = "TRINGO_OVERLAY"

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null

    private val serviceJob = SupervisorJob()
    private val serviceScope = CoroutineScope(Dispatchers.Main + serviceJob)

    private var adsAdapter: AdsAdapter? = null

    private var pendingPhone: String = ""
    private var pendingContact: String = ""

    // ✅ user close pannina remember
    private var userClosedThisSession = false

    // ✅ receiver-la irundhu start aacha
    private var launchedByReceiver = false

    // ✅ post-call popup mode (auto dismiss)
    private var postCallPopupMode = false

    private var telephonyManager: TelephonyManager? = null
    private var telephonyCallback: TelephonyCallback? = null

    @Suppress("DEPRECATION")
    private var phoneStateListener: android.telephony.PhoneStateListener? = null

    private var isWatchingCallEnd = false
    private var callWasActive = false
    private var lastState: Int = TelephonyManager.CALL_STATE_IDLE

    companion object {
        fun start(
            ctx: Context,
            phone: String,
            contactName: String = "",
            showOnCallEnd: Boolean = false, // kept for compatibility
            launchedByReceiver: Boolean = false
        ): Boolean {
            val i = Intent(ctx, TringoOverlayService::class.java).apply {
                putExtra("phone", phone)
                putExtra("contactName", contactName)
                putExtra("showOnCallEnd", showOnCallEnd)
                putExtra("launchedByReceiver", launchedByReceiver)
            }
            return try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) ctx.startForegroundService(i)
                else ctx.startService(i)
                true
            } catch (e: Exception) {
                Log.e("TRINGO_OVERLAY", "start() failed: ${e.message}", e)
                false
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {

        pendingPhone = intent?.getStringExtra("phone") ?: ""
        pendingContact = intent?.getStringExtra("contactName") ?: ""
        launchedByReceiver = intent?.getBooleanExtra("launchedByReceiver", false) ?: false

        startAsForegroundSafe()

        Log.d(TAG, "onStartCommand phone=$pendingPhone launchedByReceiver=$launchedByReceiver")

        if (pendingPhone.isBlank()) {
            stopSelf()
            return START_NOT_STICKY
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            showCallerHeadsUp(
                title = "Tringo Caller ID",
                message = "Enable overlay permission to show popup",
                reason = "overlay_permission_missing"
            )
            openAppSettings()
            stopSelf()
            return START_NOT_STICKY
        }

        // ✅ show immediately on call
        showOverlay(pendingPhone, pendingContact)

        // ✅ always watch call end
        startWatchingForCallEnd()

        return START_STICKY
    }

    // ==========================================================
    // ✅ WATCH CALL END
    // ==========================================================
    private fun startWatchingForCallEnd() {
        if (isWatchingCallEnd) return

        val hasReadPhoneState =
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) ==
                    PackageManager.PERMISSION_GRANTED

        if (!hasReadPhoneState) {
            Log.e(TAG, "READ_PHONE_STATE not granted -> cannot detect call end.")
            return
        }

        isWatchingCallEnd = true
        callWasActive = false
        lastState = telephonyManager?.callState ?: TelephonyManager.CALL_STATE_IDLE

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val cb = object : TelephonyCallback(), TelephonyCallback.CallStateListener {
                override fun onCallStateChanged(state: Int) {
                    handleCallState(state)
                }
            }
            telephonyCallback = cb
            try {
                telephonyManager?.registerTelephonyCallback(mainExecutor, cb)
            } catch (e: Exception) {
                Log.e(TAG, "registerTelephonyCallback failed: ${e.message}", e)
                startWatchingForCallEndLegacy()
            }
        } else {
            startWatchingForCallEndLegacy()
        }
    }

    @Suppress("DEPRECATION")
    private fun startWatchingForCallEndLegacy() {
        val listener = object : android.telephony.PhoneStateListener() {
            override fun onCallStateChanged(state: Int, phoneNumber: String?) {
                handleCallState(state)
            }
        }
        phoneStateListener = listener
        telephonyManager?.listen(listener, android.telephony.PhoneStateListener.LISTEN_CALL_STATE)
    }

    private fun stopWatchingForCallEnd() {
        if (!isWatchingCallEnd) return
        isWatchingCallEnd = false

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                telephonyCallback?.let { telephonyManager?.unregisterTelephonyCallback(it) }
                telephonyCallback = null
            } else {
                @Suppress("DEPRECATION")
                phoneStateListener?.let {
                    telephonyManager?.listen(it, android.telephony.PhoneStateListener.LISTEN_NONE)
                }
                phoneStateListener = null
            }
        } catch (e: Exception) {
            Log.e(TAG, "stopWatchingForCallEnd error: ${e.message}", e)
        }
    }

    private fun handleCallState(state: Int) {
        if (state == TelephonyManager.CALL_STATE_RINGING || state == TelephonyManager.CALL_STATE_OFFHOOK) {
            callWasActive = true
        }

        val endedNow =
            (lastState == TelephonyManager.CALL_STATE_RINGING || lastState == TelephonyManager.CALL_STATE_OFFHOOK) &&
                    state == TelephonyManager.CALL_STATE_IDLE

        Log.d(TAG, "CallState last=$lastState now=$state endedNow=$endedNow userClosed=$userClosedThisSession")

        lastState = state

        if (endedNow && callWasActive) {
            serviceScope.launch {
                stopWatchingForCallEnd()
                delay(550)

                // ✅ If user closed popup during call -> show again AFTER call ends
                if (userClosedThisSession) {
                    postCallPopupMode = true
                    showOverlay(pendingPhone, pendingContact)

                    // ✅ Auto dismiss post-call popup
                    delay(4500)
                    removeOverlay()

                } else {
                    // ✅ user close pannala -> just remove (avoid stuck)
                    removeOverlay()
                }

                // ✅ reset for next call
                userClosedThisSession = false
                postCallPopupMode = false
                stopSelf()
            }
        }
    }

    // ==========================================================
    // FOREGROUND
    // ==========================================================
    private fun startAsForegroundSafe() {
        val channelId = "tringo_overlay"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Tringo Overlay",
                NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Tringo")
            .setContentText("Caller identification running")
            .setSmallIcon(android.R.drawable.ic_menu_call)
            .setOngoing(true)
            .build()

        try {
            val fgsType =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_PHONE_CALL or ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
                } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_PHONE_CALL
                } else 0

            ServiceCompat.startForeground(this, 101, notification, fgsType)
        } catch (e: Exception) {
            startForeground(101, notification)
        }
    }

    // ==========================================================
    // ✅ OVERLAY UI (உன் code same, only close behavior fixed)
    // ==========================================================
    private fun showOverlay(phone: String, contactName: String) {
        removeOverlay()

        val inflater = getSystemService(LAYOUT_INFLATER_SERVICE) as LayoutInflater
        val v = inflater.inflate(R.layout.tringo_overlay, null)
        overlayView = v

        val closeBtn = v.findViewById<View>(R.id.closeBtn)
        val outsideLayer = v.findViewById<View>(R.id.outsideCloseLayer)
        val rootCard = v.findViewById<View>(R.id.rootCard)

        val headerBusiness = v.findViewById<View>(R.id.headerBusiness)
        val headerPerson = v.findViewById<View>(R.id.headerPerson)

        closeBtn?.apply {
            isClickable = true
            isFocusable = true
            setOnClickListener {
                // ✅ remember user closed during call
                userClosedThisSession = true
                removeOverlay()
                // watcher already running -> call end வந்ததும் மீண்டும் open ஆகும்
            }
            bringToFront()
        }

        outsideLayer?.setOnClickListener {
            userClosedThisSession = true
            removeOverlay()
        }

        val businessTv = v.findViewById<TextView>(R.id.businessNameText)
        val personTv = v.findViewById<TextView>(R.id.personNameText)
        val metaTv = v.findViewById<TextView>(R.id.metaText)
        val smallTop = v.findViewById<TextView>(R.id.smallTopText)
        val ratingChip = v.findViewById<TextView>(R.id.ratingChip)

        val logoBiz = v.findViewById<ImageView>(R.id.logoImageBusiness)
        val logoPerson = v.findViewById<ImageView>(R.id.logoImagePerson)

        val recycler = v.findViewById<RecyclerView>(R.id.adsRecycler)
        recycler.layoutManager = GridLayoutManager(this, 2)
        adsAdapter = AdsAdapter(emptyList())
        recycler.adapter = adsAdapter

        smallTop.text = if (postCallPopupMode) "Tringo Call Ended" else "Tringo Identifies"
        businessTv.text = "Loading..."
        personTv.text = ""
        metaTv.text = ""
        ratingChip.visibility = View.GONE

        val flags =
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            flags,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                layoutInDisplayCutoutMode =
                    WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
            }
        }

        try {
            windowManager?.addView(v, params)
        } catch (e: Exception) {
            showCallerHeadsUp(
                title = "Tringo Caller ID",
                message = if (contactName.isNotBlank()) contactName else phone,
                reason = "addView_failed"
            )
            stopSelf()
            return
        }

        attachDragToCard(rootCard, headerPerson, headerBusiness)

        headerBusiness?.visibility = View.GONE
        headerPerson?.visibility = View.VISIBLE
        personTv.text = if (contactName.isNotBlank()) contactName else phone

        serviceScope.launch {
            try {
                val res = withContext(Dispatchers.IO) { ApiClient.api.phoneInfo(phone) }
                val data = res.data
                val cardData = data?.card
                val details = cardData?.details

                if (res.status != true || cardData == null) return@launch

                val isShop = (data.type == "OWNER_SHOP")
                val imgUrl = cardData.imageUrl

                if (isShop) {
                    headerBusiness?.visibility = View.VISIBLE
                    headerPerson?.visibility = View.GONE

                    val title = cardData.title?.trim().takeUnless { it.isNullOrBlank() } ?: "Unknown Shop"
                    businessTv.text = title

                    val detailsLine = listOfNotNull(
                        details?.category ?: cardData.subtitle,
                        details?.closesAt?.let { "Opens Upto $it" },
                        details?.address
                    ).joinToString(" • ")

                    metaTv.text = detailsLine

                    logoBiz.load(imgUrl) {
                        crossfade(true)
                        placeholder(android.R.drawable.ic_menu_gallery)
                        error(android.R.drawable.ic_menu_gallery)
                    }
                } else {
                    headerBusiness?.visibility = View.GONE
                    headerPerson?.visibility = View.VISIBLE

                    val rawTitle = cardData.title?.trim().orEmpty()
                    val looksUnregistered =
                        rawTitle.isBlank() || rawTitle.equals("customer", true) || rawTitle.equals("unknown", true)

                    val finalTitle =
                        if (looksUnregistered) (if (contactName.isNotBlank()) contactName else phone)
                        else rawTitle

                    personTv.text = finalTitle

                    logoPerson.load(imgUrl) {
                        crossfade(true)
                        placeholder(android.R.drawable.ic_menu_gallery)
                        error(android.R.drawable.ic_menu_gallery)
                    }
                }
            } catch (e: Exception) {
                Log.e("TRINGO_API", "API failed: ${e.message}", e)
            }
        }
    }

    private fun attachDragToCard(card: View?, vararg handles: View?) {
        if (card == null) return
        val handleViews = handles.filterNotNull().ifEmpty { listOf(card) }

        val display = resources.displayMetrics
        val screenW = display.widthPixels
        val screenH = display.heightPixels

        var downRawX = 0f
        var downRawY = 0f
        var startTx = 0f
        var startTy = 0f
        var dragging = false

        val dragThreshold = 8f

        handleViews.forEach { hv ->
            hv.isClickable = true
            hv.isFocusable = true

            hv.setOnTouchListener { _, event ->
                when (event.actionMasked) {
                    MotionEvent.ACTION_DOWN -> {
                        downRawX = event.rawX
                        downRawY = event.rawY
                        startTx = card.translationX
                        startTy = card.translationY
                        dragging = false
                        true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        val dx = event.rawX - downRawX
                        val dy = event.rawY - downRawY

                        if (!dragging) {
                            if (abs(dx) < dragThreshold && abs(dy) < dragThreshold) return@setOnTouchListener true
                            dragging = true
                        }

                        var newTx = startTx + dx
                        var newTy = startTy + dy

                        val cardW = card.width.takeIf { it > 0 } ?: 1
                        val cardH = card.height.takeIf { it > 0 } ?: 1

                        val maxX = (screenW - cardW) / 2f
                        val maxY = (screenH - cardH) / 2f

                        newTx = min(max(newTx, -maxX), maxX)
                        newTy = min(max(newTy, -maxY), maxY)

                        card.translationX = newTx
                        card.translationY = newTy
                        true
                    }
                    MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                        if (!dragging) hv.performClick()
                        dragging = false
                        true
                    }
                    else -> false
                }
            }
        }
    }

    private fun removeOverlay() {
        overlayView?.let {
            try { windowManager?.removeView(it) } catch (_: Exception) {}
        }
        overlayView = null
    }

    override fun onDestroy() {
        stopWatchingForCallEnd()
        serviceJob.cancel()
        removeOverlay()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun showCallerHeadsUp(title: String, message: String, reason: String) {
        if (!NotificationManagerCompat.from(this).areNotificationsEnabled()) return

        val channelId = "tringo_call_alert"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(NotificationManager::class.java)
            val ch = NotificationChannel(channelId, "Tringo Call Alerts", NotificationManager.IMPORTANCE_HIGH)
            nm.createNotificationChannel(ch)
        }

        val builder = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.ic_menu_call)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setAutoCancel(true)
            .setOnlyAlertOnce(true)

        getSystemService(NotificationManager::class.java).notify(202, builder.build())
    }

    private fun openAppSettings() {
        try {
            val i = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(i)
        } catch (e: Exception) {
            Log.e(TAG, "openAppSettings failed: ${e.message}", e)
        }
    }
}

//package com.feni.tringo.tringo_app
//
//import android.Manifest
//import android.app.NotificationChannel
//import android.app.NotificationManager
//import android.app.Service
//import android.content.Context
//import android.content.Intent
//import android.content.pm.PackageManager
//import android.content.pm.ServiceInfo
//import android.graphics.PixelFormat
//import android.net.Uri
//import android.os.Build
//import android.os.IBinder
//import android.provider.Settings
//import android.telephony.TelephonyCallback
//import android.telephony.TelephonyManager
//import android.util.Log
//import android.view.Gravity
//import android.view.LayoutInflater
//import android.view.MotionEvent
//import android.view.View
//import android.view.WindowManager
//import android.widget.ImageView
//import android.widget.TextView
//import androidx.core.app.NotificationCompat
//import androidx.core.app.NotificationManagerCompat
//import androidx.core.app.ServiceCompat
//import androidx.core.content.ContextCompat
//import androidx.recyclerview.widget.GridLayoutManager
//import androidx.recyclerview.widget.RecyclerView
//import coil.load
//import kotlinx.coroutines.CoroutineScope
//import kotlinx.coroutines.Dispatchers
//import kotlinx.coroutines.SupervisorJob
//import kotlinx.coroutines.delay
//import kotlinx.coroutines.launch
//import kotlinx.coroutines.withContext
//import kotlin.math.abs
//import kotlin.math.max
//import kotlin.math.min
//
//class TringoOverlayService : Service() {
//
//    private val TAG = "TRINGO_OVERLAY"
//    private var userClosedThisSession = false
//
//    private var windowManager: WindowManager? = null
//    private var overlayView: View? = null
//
//    private val serviceJob = SupervisorJob()
//    private val serviceScope = CoroutineScope(Dispatchers.Main + serviceJob)
//
//    private var adsAdapter: AdsAdapter? = null
//
//    private var pendingPhone: String = ""
//    private var pendingContact: String = ""
//    private var showOnCallEnd: Boolean = false
//
//    private var telephonyManager: TelephonyManager? = null
//    private var telephonyCallback: TelephonyCallback? = null
//
//    @Suppress("DEPRECATION")
//    private var phoneStateListener: android.telephony.PhoneStateListener? = null
//
//    // ===========================
//    // ✅ CALL-END WATCH STATE
//    // ===========================
//    private var isWatchingCallEnd = false
//    private var callWasActive = false
//    private var lastState: Int = TelephonyManager.CALL_STATE_IDLE
//
//    companion object {
//        fun start(
//            ctx: Context,
//            phone: String,
//            contactName: String = "",
//            showOnCallEnd: Boolean = false
//        ): Boolean {
//            val i = Intent(ctx, TringoOverlayService::class.java).apply {
//                putExtra("phone", phone)
//                putExtra("contactName", contactName)
//                putExtra("showOnCallEnd", showOnCallEnd)
//            }
//            return try {
//                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) ctx.startForegroundService(i)
//                else ctx.startService(i)
//                true
//            } catch (e: Exception) {
//                Log.e("TRINGO_OVERLAY", "start() failed: ${e.message}", e)
//                false
//            }
//        }
//    }
//
//    override fun onCreate() {
//        super.onCreate()
//        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
//        telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager
//    }
//
//    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
//
//        // ✅ FIRST read extras
//        pendingPhone = intent?.getStringExtra("phone") ?: ""
//        pendingContact = intent?.getStringExtra("contactName") ?: ""
//        showOnCallEnd = intent?.getBooleanExtra("showOnCallEnd", false) ?: false
//
//        // ✅ THEN start foreground (notification text now correct)
//        startAsForegroundSafe()
//
//        Log.d(TAG, "onStartCommand phone=$pendingPhone showOnCallEnd=$showOnCallEnd")
//
//        if (pendingPhone.isBlank()) {
//            Log.w(TAG, "No phone received. stopSelf()")
//            stopSelf()
//            return START_NOT_STICKY
//        }
//
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
//            Log.e(TAG, "Overlay permission missing -> headsup + open settings")
//            showCallerHeadsUp(
//                title = "Tringo Caller ID",
//                message = "Enable overlay permission to show popup",
//                reason = "overlay_permission_missing"
//            )
//            openAppSettings()
//            stopSelf()
//            return START_NOT_STICKY
//        }
//
//        // ✅ If user wants TRUECALLER style (show after call ends)
//        if (showOnCallEnd) {
//            startWatchingForCallEnd()
//            return START_STICKY
//        }
//
//// ✅ Otherwise show immediately
//        showOverlay(pendingPhone, pendingContact)
//
//// ✅ NEW: always watch call end so popup won't stick
//        startWatchingForCallEnd()
//
//        return START_STICKY
//
//    }
//
//    // ==========================================================
//    // ✅ WATCH CALL END (RINGING/OFFHOOK -> IDLE)
//    // ==========================================================
//
//    private fun startWatchingForCallEnd() {
//        if (isWatchingCallEnd) {
//            Log.d(TAG, "Already watching call end")
//            return
//        }
//
//        val hasReadPhoneState =
//            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) ==
//                    PackageManager.PERMISSION_GRANTED
//
//        if (!hasReadPhoneState) {
//            Log.e(TAG, "READ_PHONE_STATE not granted. Cannot detect call end reliably.")
//            showCallerHeadsUp(
//                title = "Tringo Caller ID",
//                message = "Phone permission required to show popup after call ends",
//                reason = "read_phone_state_missing"
//            )
//            // fallback
//            showOverlay(pendingPhone, pendingContact)
//            return
//        }
//
//        isWatchingCallEnd = true
//        callWasActive = false
//        lastState = telephonyManager?.callState ?: TelephonyManager.CALL_STATE_IDLE
//
//        Log.d(TAG, "Start watch call end. initialState=$lastState")
//
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//            val cb = object : TelephonyCallback(), TelephonyCallback.CallStateListener {
//                override fun onCallStateChanged(state: Int) {
//                    handleCallState(state)
//                }
//            }
//            telephonyCallback = cb
//            try {
//                telephonyManager?.registerTelephonyCallback(mainExecutor, cb)
//            } catch (e: Exception) {
//                Log.e(TAG, "registerTelephonyCallback failed: ${e.message}", e)
//                startWatchingForCallEndLegacy()
//            }
//        } else {
//            startWatchingForCallEndLegacy()
//        }
//    }
//
//    @Suppress("DEPRECATION")
//    private fun startWatchingForCallEndLegacy() {
//        val listener = object : android.telephony.PhoneStateListener() {
//            override fun onCallStateChanged(state: Int, phoneNumber: String?) {
//                handleCallState(state)
//            }
//        }
//        phoneStateListener = listener
//        try {
//            telephonyManager?.listen(listener, android.telephony.PhoneStateListener.LISTEN_CALL_STATE)
//        } catch (e: Exception) {
//            Log.e(TAG, "PhoneStateListener listen failed: ${e.message}", e)
//            showOverlay(pendingPhone, pendingContact)
//        }
//    }
//
//    private fun stopWatchingForCallEnd() {
//        if (!isWatchingCallEnd) return
//        isWatchingCallEnd = false
//
//        try {
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//                telephonyCallback?.let { telephonyManager?.unregisterTelephonyCallback(it) }
//                telephonyCallback = null
//            } else {
//                @Suppress("DEPRECATION")
//                phoneStateListener?.let {
//                    telephonyManager?.listen(it, android.telephony.PhoneStateListener.LISTEN_NONE)
//                }
//                phoneStateListener = null
//            }
//        } catch (e: Exception) {
//            Log.e(TAG, "stopWatchingForCallEnd error: ${e.message}", e)
//        }
//    }
//
//    private fun handleCallState(state: Int) {
//
//        // ✅ once active, keep it true
//        if (state == TelephonyManager.CALL_STATE_RINGING || state == TelephonyManager.CALL_STATE_OFFHOOK) {
//            callWasActive = true
//        }
//
//        val endedNow =
//            (lastState == TelephonyManager.CALL_STATE_RINGING || lastState == TelephonyManager.CALL_STATE_OFFHOOK) &&
//                    state == TelephonyManager.CALL_STATE_IDLE
//
//        Log.d(TAG, "CallState: last=$lastState now=$state callWasActive=$callWasActive endedNow=$endedNow")
//
//        lastState = state
//        if (endedNow && callWasActive) {
//            serviceScope.launch {
//                stopWatchingForCallEnd()
//                delay(650)
//
//                // ✅ If user closed popup during the call, show it after call ends
//                if (userClosedThisSession) {
//                    showOverlay(pendingPhone, pendingContact)
//                } else {
//                    // ✅ If user didn't close, ensure overlay is not stuck
//                    removeOverlay()
//                }
//
//                // ✅ Reset for next call (same number calling again -> popup will show)
//                userClosedThisSession = false
//
//                // Optional: stop service after cleanup if you want
//                // stopSelf()
//            }
//        }
//
//    }
//
//
//    // ==========================================================
//    // FOREGROUND
//    // ==========================================================
//
//    private fun startAsForegroundSafe() {
//        val channelId = "tringo_overlay"
//
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            val channel = NotificationChannel(
//                channelId,
//                "Tringo Overlay",
//                NotificationManager.IMPORTANCE_LOW
//            )
//            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
//        }
//
//        val notification = NotificationCompat.Builder(this, channelId)
//            .setContentTitle("Tringo")
//            .setContentText(
//                if (showOnCallEnd) "Waiting to show popup after call ends"
//                else "Caller identification running"
//            )
//            .setSmallIcon(android.R.drawable.ic_menu_call)
//            .setOngoing(true)
//            .build()
//
//        try {
//            val fgsType =
//                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
//                    ServiceInfo.FOREGROUND_SERVICE_TYPE_PHONE_CALL or
//                            ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
//                } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//                    ServiceInfo.FOREGROUND_SERVICE_TYPE_PHONE_CALL
//                } else 0
//
//            ServiceCompat.startForeground(this, 101, notification, fgsType)
//        } catch (e: Exception) {
//            Log.e(TAG, "Foreground safe failed -> fallback", e)
//            startForeground(101, notification)
//        }
//    }
//
//    // ==========================================================
//    // OVERLAY UI + DRAG (YOUR ORIGINAL)
//    // ==========================================================
//    // ✅ BELOW THIS = SAME AS YOUR CODE (UNCHANGED)
//    // (I’m keeping your original exactly; only changes above)
//
//    private fun showOverlay(phone: String, contactName: String) {
//        removeOverlay()
//
//        val inflater = getSystemService(LAYOUT_INFLATER_SERVICE) as LayoutInflater
//        val v = inflater.inflate(R.layout.tringo_overlay, null)
//        overlayView = v
//
//        val closeBtn = v.findViewById<View>(R.id.closeBtn)
//        val outsideLayer = v.findViewById<View>(R.id.outsideCloseLayer)
//        val rootCard = v.findViewById<View>(R.id.rootCard)
//
//        val headerBusiness = v.findViewById<View>(R.id.headerBusiness)
//        val headerPerson = v.findViewById<View>(R.id.headerPerson)
//
//        closeBtn?.apply {
//            isClickable = true
//            isFocusable = true
//            setOnClickListener {
//                // ✅ close only for this call session
//                userClosedThisSession = true
//                removeOverlay()
//
//                // ✅ keep watcher running so when call ends we can show again
//                startWatchingForCallEnd()
//            }
//            bringToFront()
//        }
//
//        outsideLayer?.setOnClickListener {
//            userClosedThisSession = true
//            removeOverlay()
//            startWatchingForCallEnd()
//        }
//
//
//        val businessTv = v.findViewById<TextView>(R.id.businessNameText)
//        val personTv = v.findViewById<TextView>(R.id.personNameText)
//        val metaTv = v.findViewById<TextView>(R.id.metaText)
//        val smallTop = v.findViewById<TextView>(R.id.smallTopText)
//        val ratingChip = v.findViewById<TextView>(R.id.ratingChip)
//
//        val logoBiz = v.findViewById<ImageView>(R.id.logoImageBusiness)
//        val logoPerson = v.findViewById<ImageView>(R.id.logoImagePerson)
//
//        val btnCallBiz = v.findViewById<View>(R.id.btnCallBiz)
//        val btnWaBiz = v.findViewById<View>(R.id.btnWhatsappBiz)
//        val btnCallPerson = v.findViewById<View>(R.id.btnCallPerson)
//        val btnWaPerson = v.findViewById<View>(R.id.btnWhatsappPerson)
//
//        btnCallBiz?.setOnClickListener { startCall(phone) }
//        btnWaBiz?.setOnClickListener { openWhatsApp(phone) }
//        btnCallPerson?.setOnClickListener { startCall(phone) }
//        btnWaPerson?.setOnClickListener { openWhatsApp(phone) }
//
//        val recycler = v.findViewById<RecyclerView>(R.id.adsRecycler)
//        recycler.layoutManager = GridLayoutManager(this, 2)
//        adsAdapter = AdsAdapter(emptyList())
//        recycler.adapter = adsAdapter
//
//        smallTop.text = "Tringo Identifies"
//        businessTv.text = "Loading..."
//        personTv.text = ""
//        metaTv.text = ""
//        ratingChip.visibility = View.GONE
//
//        val flags =
//            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
//                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
//                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
//
//        val params = WindowManager.LayoutParams(
//            WindowManager.LayoutParams.MATCH_PARENT,
//            WindowManager.LayoutParams.MATCH_PARENT,
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
//                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
//            else
//                WindowManager.LayoutParams.TYPE_PHONE,
//            flags,
//            PixelFormat.TRANSLUCENT
//        ).apply {
//            gravity = Gravity.TOP or Gravity.START
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
//                layoutInDisplayCutoutMode =
//                    WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
//            }
//        }
//
//        try {
//            windowManager?.addView(v, params)
//            Log.d(TAG, "Overlay added successfully")
//        } catch (e: Exception) {
//            Log.e(TAG, "Overlay add FAILED", e)
//            showCallerHeadsUp(
//                title = "Tringo Caller ID",
//                message = if (contactName.isNotBlank()) contactName else phone,
//                reason = "addView_failed"
//            )
//            stopSelf()
//            return
//        }
//
//        attachDragToCard(rootCard, headerPerson, headerBusiness)
//
//        headerBusiness?.visibility = View.GONE
//        headerPerson?.visibility = View.VISIBLE
//        personTv.text = if (contactName.isNotBlank()) contactName else phone
//
//        serviceScope.launch {
//            try {
//                val res = withContext(Dispatchers.IO) { ApiClient.api.phoneInfo(phone) }
//                val data = res.data
//                val cardData = data?.card
//                val details = cardData?.details
//
//                if (res.status != true || cardData == null) return@launch
//
//                val isShop = (data.type == "OWNER_SHOP")
//                val imgUrl = cardData.imageUrl
//
//                if (isShop) {
//                    headerBusiness?.visibility = View.VISIBLE
//                    headerPerson?.visibility = View.GONE
//
//                    val title =
//                        cardData.title?.trim().takeUnless { it.isNullOrBlank() } ?: "Unknown Shop"
//                    businessTv.text = title
//
//                    val detailsLine = listOfNotNull(
//                        details?.category ?: cardData.subtitle,
//                        details?.closesAt?.let { "Opens Upto $it" },
//                        details?.address
//                    ).joinToString(" • ")
//
//                    metaTv.text = detailsLine
//
//                    logoBiz.load(imgUrl) {
//                        crossfade(true)
//                        placeholder(android.R.drawable.ic_menu_gallery)
//                        error(android.R.drawable.ic_menu_gallery)
//                    }
//                } else {
//                    headerBusiness?.visibility = View.GONE
//                    headerPerson?.visibility = View.VISIBLE
//
//                    val rawTitle = cardData.title?.trim().orEmpty()
//                    val looksUnregistered =
//                        rawTitle.isBlank() ||
//                                rawTitle.equals("customer", true) ||
//                                rawTitle.equals("unknown", true)
//
//                    val finalTitle =
//                        if (looksUnregistered) (if (contactName.isNotBlank()) contactName else phone)
//                        else rawTitle
//
//                    personTv.text = finalTitle
//
//                    logoPerson.load(imgUrl) {
//                        crossfade(true)
//                        placeholder(android.R.drawable.ic_menu_gallery)
//                        error(android.R.drawable.ic_menu_gallery)
//                    }
//                }
//            } catch (e: Exception) {
//                Log.e("TRINGO_API", "API failed: ${e.message}", e)
//            }
//        }
//    }
//
//    private fun attachDragToCard(card: View?, vararg handles: View?) {
//        if (card == null) return
//
//        val handleViews = handles.filterNotNull().ifEmpty { listOf(card) }
//
//        val display = resources.displayMetrics
//        val screenW = display.widthPixels
//        val screenH = display.heightPixels
//
//        var downRawX = 0f
//        var downRawY = 0f
//        var startTx = 0f
//        var startTy = 0f
//        var dragging = false
//
//        val dragThreshold = 8f
//
//        handleViews.forEach { hv ->
//            hv.isClickable = true
//            hv.isFocusable = true
//
//            hv.setOnTouchListener { _, event ->
//                when (event.actionMasked) {
//                    MotionEvent.ACTION_DOWN -> {
//                        downRawX = event.rawX
//                        downRawY = event.rawY
//                        startTx = card.translationX
//                        startTy = card.translationY
//                        dragging = false
//                        true
//                    }
//                    MotionEvent.ACTION_MOVE -> {
//                        val dx = event.rawX - downRawX
//                        val dy = event.rawY - downRawY
//
//                        if (!dragging) {
//                            if (abs(dx) < dragThreshold && abs(dy) < dragThreshold) return@setOnTouchListener true
//                            dragging = true
//                        }
//
//                        var newTx = startTx + dx
//                        var newTy = startTy + dy
//
//                        val cardW = card.width.takeIf { it > 0 } ?: 1
//                        val cardH = card.height.takeIf { it > 0 } ?: 1
//
//                        val maxX = (screenW - cardW) / 2f
//                        val maxY = (screenH - cardH) / 2f
//
//                        newTx = min(max(newTx, -maxX), maxX)
//                        newTy = min(max(newTy, -maxY), maxY)
//
//                        card.translationX = newTx
//                        card.translationY = newTy
//                        true
//                    }
//                    MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
//                        if (!dragging) hv.performClick()
//                        dragging = false
//                        true
//                    }
//                    else -> false
//                }
//            }
//        }
//    }
//
//    private fun removeOverlay() {
//        overlayView?.let {
//            try { windowManager?.removeView(it) } catch (_: Exception) {}
//        }
//        overlayView = null
//    }
//
//    override fun onDestroy() {
//        stopWatchingForCallEnd()
//        serviceJob.cancel()
//        removeOverlay()
//        super.onDestroy()
//    }
//
//    override fun onBind(intent: Intent?): IBinder? = null
//
//    // ==========================================================
//    // CALL + WHATSAPP
//    // ==========================================================
//
//    private fun startCall(phone: String) {
//        val uri = Uri.parse("tel:$phone")
//
//        // ✅ If Tringo app itself starts the call, also start watcher (covers in-app outgoing)
//        TringoOverlayService.start(
//            ctx = this,
//            phone = phone,
//            contactName = pendingContact,
//            showOnCallEnd = true
//        )
//
//        val hasPermission =
//            ContextCompat.checkSelfPermission(this, Manifest.permission.CALL_PHONE) ==
//                    PackageManager.PERMISSION_GRANTED
//
//        val intent = if (hasPermission) Intent(Intent.ACTION_CALL, uri) else Intent(Intent.ACTION_DIAL, uri)
//            .apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }
//
//        try {
//            startActivity(intent)
//        } catch (e: Exception) {
//            Log.e(TAG, "startCall failed: ${e.message}", e)
//        }
//    }
//
//    private fun normalizePhoneForWa(raw: String): String {
//        val cleaned = raw.replace("[^0-9+]".toRegex(), "")
//        return if (cleaned.startsWith("+")) cleaned.substring(1) else cleaned
//    }
//
//    private fun openWhatsApp(phone: String) {
//        val waNumber = normalizePhoneForWa(phone)
//        val uri = Uri.parse("https://wa.me/$waNumber")
//
//        val intent = Intent(Intent.ACTION_VIEW, uri).apply {
//            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//            setPackage("com.whatsapp")
//        }
//
//        try {
//            startActivity(intent)
//        } catch (_: Exception) {
//            try {
//                startActivity(Intent(Intent.ACTION_VIEW, uri).apply {
//                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//                })
//            } catch (e2: Exception) {
//                Log.e(TAG, "openWhatsApp failed: ${e2.message}", e2)
//            }
//        }
//    }
//
//    // ==========================================================
//    // HEADS-UP + SETTINGS
//    // ==========================================================
//
//    private fun showCallerHeadsUp(title: String, message: String, reason: String) {
//        if (!NotificationManagerCompat.from(this).areNotificationsEnabled()) {
//            Log.e("TRINGO_NOTIF", "Notifications disabled. reason=$reason")
//            return
//        }
//
//        val channelId = "tringo_call_alert"
//
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            val nm = getSystemService(NotificationManager::class.java)
//            val ch = NotificationChannel(
//                channelId,
//                "Tringo Call Alerts",
//                NotificationManager.IMPORTANCE_HIGH
//            )
//            nm.createNotificationChannel(ch)
//        }
//
//        val builder = NotificationCompat.Builder(this, channelId)
//            .setSmallIcon(android.R.drawable.ic_menu_call)
//            .setContentTitle(title)
//            .setContentText(message)
//            .setPriority(NotificationCompat.PRIORITY_HIGH)
//            .setCategory(NotificationCompat.CATEGORY_CALL)
//            .setAutoCancel(true)
//            .setOnlyAlertOnce(true)
//
//        getSystemService(NotificationManager::class.java).notify(202, builder.build())
//    }
//
//    private fun openAppSettings() {
//        try {
//            val i = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
//                data = Uri.parse("package:$packageName")
//                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//            }
//            startActivity(i)
//        } catch (e: Exception) {
//            Log.e(TAG, "openAppSettings failed: ${e.message}", e)
//        }
//    }
//}
//