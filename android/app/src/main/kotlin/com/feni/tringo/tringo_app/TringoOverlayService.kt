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
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import coil.load
import kotlinx.coroutines.*
import kotlin.math.abs
import kotlin.math.max

class TringoOverlayService : Service() {

    private val TAG = "TRINGO_OVERLAY"

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null

    private val serviceJob = SupervisorJob()
    private val serviceScope = CoroutineScope(Dispatchers.Main + serviceJob)

    private val PREF = "tringo_call_state"
    private val KEY_USER_CLOSED = "user_closed_during_call"
    private val KEY_LAST_NUMBER = "last_number"

    private var adsAdapter: OverlayAdsAdapter? = null

    private var pendingPhone: String = ""
    private var pendingContact: String = ""

    private var launchedByReceiver = false
    private var postCallPopupMode = false
    private var showOnlyAfterEnd = false

    private var telephonyManager: TelephonyManager? = null
    private var telephonyCallback: TelephonyCallback? = null

    @Suppress("DEPRECATION")
    private var phoneStateListener: android.telephony.PhoneStateListener? = null

    private var isWatchingCallEnd = false
    private var lastState: Int = TelephonyManager.CALL_STATE_IDLE

    private var endConfirmJob: Job? = null
    private var lastNonIdleAt: Long = 0L

    private var incomingAutoHideJob: Job? = null

    // ✅ debounce
    private var lastOverlayShownAt: Long = 0L
    private val OVERLAY_DEBOUNCE_MS = 900L

    private var postCallShownOnce = false

    private val INCOMING_SHOW_MS = 10_000L
    private val POST_CALL_SHOW_MS = 15_000L

    // ==========================================================
    // ✅ CACHE (API only once)
    // ==========================================================
    private val CACHE_VALID_MS = 90_000L
    private var cachePhone: String? = null
    private var cacheAt: Long = 0L

    private var cacheIsShop: Boolean = false
    private var cacheTitle: String = ""
    private var cacheSubtitleLine: String = ""
    private var cacheImageUrl: String = ""

    private var cacheAdsTitle: String = "Advertisements"
    private var cacheAdsCards: List<OverlayAdCard> = emptyList()

    private fun isCacheValidFor(phone: String): Boolean {
        val ok = cachePhone == phone && (System.currentTimeMillis() - cacheAt) <= CACHE_VALID_MS
        Log.d(TAG, "isCacheValidFor($phone) => $ok")
        return ok
    }

    private fun saveCache(
        phone: String,
        isShop: Boolean,
        title: String,
        subtitleLine: String,
        imageUrl: String,
        adsTitle: String,
        adsCards: List<OverlayAdCard>
    ) {
        cachePhone = phone
        cacheAt = System.currentTimeMillis()
        cacheIsShop = isShop
        cacheTitle = title
        cacheSubtitleLine = subtitleLine
        cacheImageUrl = imageUrl
        cacheAdsTitle = adsTitle
        cacheAdsCards = adsCards
        Log.d(TAG, "CACHE SAVED phone=$phone isShop=$isShop ads=${adsCards.size}")
    }

    companion object {
        @Volatile var isRunning: Boolean = false

        fun start(
            ctx: Context,
            phone: String,
            contactName: String = "",
            showOnCallEnd: Boolean = false,
            launchedByReceiver: Boolean = false
        ): Boolean {
            val i = Intent(ctx, TringoOverlayService::class.java).apply {
                putExtra("phone", phone)
                putExtra("contactName", contactName)
                putExtra("showOnCallEnd", showOnCallEnd)
                putExtra("launchedByReceiver", launchedByReceiver)
            }

            return try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    try { ctx.startForegroundService(i) }
                    catch (t: Throwable) {
                        Log.e("TRINGO_OVERLAY", "startForegroundService blocked => fallback: ${t.message}")
                        ctx.startService(i)
                    }
                } else {
                    ctx.startService(i)
                }
                true
            } catch (e: Throwable) {
                Log.e("TRINGO_OVERLAY", "start() failed: ${e.message}", e)
                false
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {

        pendingPhone = intent?.getStringExtra("phone") ?: ""
        pendingContact = intent?.getStringExtra("contactName") ?: ""
        launchedByReceiver = intent?.getBooleanExtra("launchedByReceiver", false) ?: false
        showOnlyAfterEnd = intent?.getBooleanExtra("showOnCallEnd", false) ?: false

        Log.d(TAG, "onStartCommand phone=$pendingPhone showOnlyAfterEnd=$showOnlyAfterEnd")

        // ✅ NEVER allow UNKNOWN / empty
        val prefs = getSharedPreferences(PREF, MODE_PRIVATE)
        if (pendingPhone.isBlank() || pendingPhone.equals("UNKNOWN", true)) {
            val last = prefs.getString(KEY_LAST_NUMBER, "") ?: ""
            if (last.isNotBlank() && !last.equals("UNKNOWN", true)) {
                pendingPhone = last
            } else {
                stopSelf()
                return START_NOT_STICKY
            }
        }

        // ✅ store final phone
        prefs.edit().putString(KEY_LAST_NUMBER, pendingPhone).apply()

        startForegroundDataSyncSafe()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            showCallerHeadsUp("Tringo Caller ID", "Enable overlay permission to show popup", "overlay_permission_missing")
            openAppSettings()
            stopSelf()
            return START_NOT_STICKY
        }

        postCallShownOnce = false

        if (!showOnlyAfterEnd) {
            safeShowOverlay(pendingPhone, pendingContact, preferCache = true)
            scheduleIncomingAutoHide()
        }

        startWatchingForCallEnd()
        return START_STICKY
    }

    // ==========================================================
    // Foreground
    // ==========================================================
    private fun startForegroundDataSyncSafe() {
        val channelId = "tringo_overlay_service"
        try {
            val nm = getSystemService(NotificationManager::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                nm.createNotificationChannel(
                    NotificationChannel(channelId, "Tringo Overlay", NotificationManager.IMPORTANCE_LOW)
                )
            }

            val notif = NotificationCompat.Builder(this, channelId)
                .setSmallIcon(android.R.drawable.ic_menu_call)
                .setContentTitle("Tringo Caller ID")
                .setContentText("Running...")
                .setOngoing(true)
                .setOnlyAlertOnce(true)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .build()

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                ServiceCompat.startForeground(this, 101, notif, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
            } else {
                startForeground(101, notif)
            }
        } catch (t: Throwable) {
            Log.e(TAG, "startForegroundDataSyncSafe failed: ${t.message}", t)
        }
    }

    // ==========================================================
    // Prefs
    // ==========================================================
    private fun markUserClosedDuringCall(phone: String) {
        try {
            getSharedPreferences(PREF, MODE_PRIVATE).edit()
                .putBoolean(KEY_USER_CLOSED, true)
                .putString(KEY_LAST_NUMBER, phone)
                .apply()
        } catch (e: Exception) {
            Log.e(TAG, "markUserClosedDuringCall failed: ${e.message}", e)
        }
    }

    private fun clearUserClosedFlag() {
        try {
            getSharedPreferences(PREF, MODE_PRIVATE).edit()
                .putBoolean(KEY_USER_CLOSED, false)
                .apply()
        } catch (_: Exception) {}
    }

    // ==========================================================
    // Call watch
    // ==========================================================
    private fun hasReadPhoneState(): Boolean {
        return ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) ==
                PackageManager.PERMISSION_GRANTED
    }

    private fun safeCallState(): Int {
        return try {
            telephonyManager?.callState ?: TelephonyManager.CALL_STATE_IDLE
        } catch (_: Throwable) {
            TelephonyManager.CALL_STATE_IDLE
        }
    }

    private fun startWatchingForCallEnd() {
        if (isWatchingCallEnd) return
        if (!hasReadPhoneState()) {
            Log.e(TAG, "READ_PHONE_STATE not granted -> cannot detect call end.")
            return
        }

        isWatchingCallEnd = true
        endConfirmJob?.cancel()

        lastNonIdleAt = System.currentTimeMillis()
        lastState = safeCallState()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val cb = object : TelephonyCallback(), TelephonyCallback.CallStateListener {
                override fun onCallStateChanged(state: Int) {
                    handleCallState(state)
                }
            }
            telephonyCallback = cb
            try {
                telephonyManager?.registerTelephonyCallback(mainExecutor, cb)
            } catch (_: Exception) {
                startWatchingForCallEndLegacy()
            }
        } else {
            startWatchingForCallEndLegacy()
        }
    }

    @Suppress("DEPRECATION")
    private fun startWatchingForCallEndLegacy() {
        if (!hasReadPhoneState()) return
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

        endConfirmJob?.cancel()
        endConfirmJob = null

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
        } catch (_: Exception) {}
    }

    private fun handleCallState(state: Int) {
        val now = System.currentTimeMillis()

        if (state == TelephonyManager.CALL_STATE_RINGING) {
            lastNonIdleAt = now
            if (!showOnlyAfterEnd) {
                if (overlayView == null) safeShowOverlay(pendingPhone, pendingContact, preferCache = true)
                scheduleIncomingAutoHide()
            }
        }

        if (state == TelephonyManager.CALL_STATE_OFFHOOK) {
            lastNonIdleAt = now
            incomingAutoHideJob?.cancel()
            incomingAutoHideJob = null
        }

        if (state != TelephonyManager.CALL_STATE_IDLE) {
            endConfirmJob?.cancel()
            lastState = state
            return
        }

        endConfirmJob?.cancel()
        endConfirmJob = serviceScope.launch {
            delay(1200)
            if (safeCallState() != TelephonyManager.CALL_STATE_IDLE) return@launch
            val idleFor = System.currentTimeMillis() - lastNonIdleAt
            if (idleFor < 900) return@launch
            onCallEndedConfirmed()
        }

        lastState = state
    }

    private fun scheduleIncomingAutoHide() {
        incomingAutoHideJob?.cancel()
        incomingAutoHideJob = serviceScope.launch {
            delay(INCOMING_SHOW_MS)
            if (!postCallPopupMode) removeOverlay()
        }
    }

    private fun onCallEndedConfirmed() {
        if (postCallShownOnce) return
        postCallShownOnce = true

        serviceScope.launch {
            stopWatchingForCallEnd()

            postCallPopupMode = true
            safeShowOverlay(pendingPhone, pendingContact, preferCache = true)

            delay(POST_CALL_SHOW_MS)
            removeOverlay()

            postCallPopupMode = false
            clearUserClosedFlag()
            stopSelf()
        }
    }

    // ==========================================================
    // Overlay show (debounced)
    // ==========================================================
    private fun safeShowOverlay(phone: String, contactName: String, preferCache: Boolean) {
        val now = System.currentTimeMillis()
        if (now - lastOverlayShownAt < OVERLAY_DEBOUNCE_MS) return
        lastOverlayShownAt = now
        showOverlay(phone, contactName, preferCache)
    }

    // ==========================================================
    // Dynamic ID helpers
    // ==========================================================
    private fun idByName(name: String): Int = resources.getIdentifier(name, "id", packageName)

    private fun findFirstView(root: View, vararg names: String): View? {
        for (n in names) {
            val id = idByName(n)
            if (id != 0) return root.findViewById(id)
        }
        return null
    }

    // ==========================================================
    // ✅ FORCE 18dp ICON (works for PNG also)
    // ==========================================================
    private fun setButtonIcon18dp(v: View?, drawableRes: Int) {
        val tv = v as? TextView ?: return
        val d = ContextCompat.getDrawable(this, drawableRes) ?: return
        val px = (18f * resources.displayMetrics.density).toInt().coerceAtLeast(1)
        d.setBounds(0, 0, px, px)
        tv.setCompoundDrawablesRelative(d, null, null, null)
        tv.compoundDrawablePadding = (8f * resources.displayMetrics.density).toInt()
    }

    // ==========================================================
    // Overlay UI (CACHE FIRST)
    // ==========================================================
    private fun showOverlay(phone: String, contactName: String, preferCache: Boolean) {
        removeOverlay()

        val inflater = getSystemService(LAYOUT_INFLATER_SERVICE) as LayoutInflater
        val v = inflater.inflate(R.layout.tringo_overlay, null)
        overlayView = v

        val rootFull = v.findViewById<View>(R.id.overlayRootFull)
        val rootCard = v.findViewById<View>(R.id.rootCard)
        val closeBtn = v.findViewById<View>(R.id.closeBtn)

        val callBtn = findFirstView(v, "callBtn", "btnCall", "callIcon", "ivCall", "imgCall", "call_button")
        val chatBtn = findFirstView(v, "chatBtn", "btnChat", "chatIcon", "ivChat", "imgChat", "whatsappBtn", "btnWhatsapp", "whatsappIcon")

        // ✅ YOUR REAL drawable names (match XML)
        setButtonIcon18dp(callBtn, R.drawable.ic_call_png)
        setButtonIcon18dp(chatBtn, R.drawable.ic_whatsapp_png)

        val outsideLayer = v.findViewById<View>(R.id.outsideCloseLayer)
        outsideLayer?.visibility = View.GONE

        val headerBusiness = v.findViewById<View>(R.id.headerBusiness)
        val headerPerson = v.findViewById<View>(R.id.headerPerson)

        val businessTv = v.findViewById<TextView>(R.id.businessNameText)
        val personTv = v.findViewById<TextView>(R.id.personNameText)
        val metaTv = v.findViewById<TextView>(R.id.metaText)
        val smallTop = v.findViewById<TextView>(R.id.smallTopText)

        val logoBiz = v.findViewById<ImageView>(R.id.logoImageBusiness)
        val logoPerson = v.findViewById<ImageView>(R.id.logoImagePerson)

        val divider = v.findViewById<View>(R.id.dividerLine)
        val adsTitleTv = v.findViewById<TextView>(R.id.adsTitle)
        val recycler = v.findViewById<RecyclerView>(R.id.adsRecycler)

        recycler.layoutManager = LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false)
        adsAdapter = OverlayAdsAdapter()
        recycler.adapter = adsAdapter

        smallTop.text = if (postCallPopupMode) "Tringo Call Ended" else "Tringo Identifies"

        closeBtn?.setOnClickListener {
            markUserClosedDuringCall(pendingPhone)
            removeOverlay()
        }

        callBtn?.setOnClickListener {
            val num = (cachePhone ?: pendingPhone).trim()
            if (num.isNotBlank() && !num.equals("UNKNOWN", true)) dialNumber(num)
        }

        chatBtn?.setOnClickListener {
            val num = (cachePhone ?: pendingPhone).trim()
            if (num.isNotBlank() && !num.equals("UNKNOWN", true)) openWhatsAppChat(num)
        }

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
        }

        try {
            windowManager?.addView(v, params)
        } catch (e: Exception) {
            showCallerHeadsUp("Tringo Caller ID", if (contactName.isNotBlank()) contactName else phone, "addView_failed")
            stopSelf()
            return
        }

        // default
        headerBusiness.visibility = View.GONE
        headerPerson.visibility = View.VISIBLE
        personTv.text = if (contactName.isNotBlank()) contactName else phone
        businessTv.text = ""
        metaTv.text = ""

        fun applyAdsVisibilityNow() {
            val allowAds = postCallPopupMode
            val hasAds = cacheAdsCards.isNotEmpty()
            if (allowAds && hasAds) {
                divider.visibility = View.VISIBLE
                adsTitleTv.text = cacheAdsTitle
                adsTitleTv.visibility = View.VISIBLE
                recycler.visibility = View.VISIBLE
            } else {
                divider.visibility = View.GONE
                adsTitleTv.visibility = View.GONE
                recycler.visibility = View.GONE
            }
        }

        divider.visibility = View.GONE
        adsTitleTv.visibility = View.GONE
        recycler.visibility = View.GONE

        if (preferCache && isCacheValidFor(phone)) {
            applyCacheToUi(headerBusiness, headerPerson, businessTv, personTv, metaTv, logoBiz, logoPerson)
            adsAdapter?.submitList(cacheAdsCards)
            applyAdsVisibilityNow()
            return
        }

        serviceScope.launch {
            try {
                val res = withContext(Dispatchers.IO) { ApiClient.api.phoneInfo(phone) }

                val dataAny = tryRead(res, "data")
                val typeStr = (readAny(dataAny, "type") as? String).orEmpty()
                val cardAny = readAny(dataAny, "card")

                val cardTitle = (readAny(cardAny, "title") as? String)?.trim().orEmpty()
                val cardSubtitle = (readAny(cardAny, "subtitle") as? String)?.trim().orEmpty()
                val cardImageUrl = (readAny(cardAny, "imageUrl") as? String)?.trim().orEmpty()

                val detailsAny = readAny(cardAny, "details")
                val cat = (readAny(detailsAny, "category") as? String)?.trim().orEmpty()
                val opensAt = (readAny(detailsAny, "opensAt") as? String)?.trim().orEmpty()
                val closesAt = (readAny(detailsAny, "closesAt") as? String)?.trim().orEmpty()
                val addr = (readAny(detailsAny, "address") as? String)?.trim().orEmpty()

                val isShop = typeStr.equals("OWNER_SHOP", true)

                val subtitleLine = listOfNotNull(
                    (if (cat.isNotBlank()) cat else null) ?: cardSubtitle.takeIf { it.isNotBlank() },
                    if (opensAt.isNotBlank() && closesAt.isNotBlank()) "$opensAt - $closesAt" else null,
                    addr.takeIf { it.isNotBlank() }
                ).joinToString(" • ")

                val adsAny = readAny(dataAny, "advertisements")
                val adsTitle = (readAny(adsAny, "title") as? String)?.trim().takeUnless { it.isNullOrBlank() } ?: "Advertisements"
                val listAny = readAny(adsAny, "items") as? List<*>
                val rawItems: List<Any> = listAny?.mapNotNull { it as? Any } ?: emptyList()

                val cards = rawItems.mapIndexed { idx, item ->
                    OverlayAdCard(
                        id = pickString(item, "id", "_id") ?: "ad_$idx",
                        title = pickString(item, "englishName", "title", "name") ?: "Ad ${idx + 1}",
                        subtitle = buildAdSubtitle(item),
                        rating = pickDouble(item, "rating", "avgRating"),
                        ratingCount = pickInt(item, "ratingCount", "totalRatings"),
                        openText = pickString(item, "openLabel", "openText"),
                        isTrusted = pickBool(item, "isTrusted", "trusted") ?: false,
                        imageUrl = pickString(item, "primaryImageUrl", "imageUrl") ?: ""
                    )
                }

                saveCache(
                    phone = phone,
                    isShop = isShop,
                    title = cardTitle.ifBlank { if (contactName.isNotBlank()) contactName else phone },
                    subtitleLine = subtitleLine,
                    imageUrl = cardImageUrl,
                    adsTitle = adsTitle,
                    adsCards = cards
                )

                applyCacheToUi(headerBusiness, headerPerson, businessTv, personTv, metaTv, logoBiz, logoPerson)
                adsAdapter?.submitList(cacheAdsCards)
                applyAdsVisibilityNow()

            } catch (e: Exception) {
                Log.e("TRINGO_API", "API failed: ${e.message}", e)
            }
        }
    }

    private fun buildAdSubtitle(item: Any?): String {
        val addr = pickString(item, "addressEn", "addressTa") ?: ""
        val city = pickString(item, "city") ?: ""
        val state = pickString(item, "state") ?: ""
        val country = pickString(item, "country") ?: ""
        val place = listOf(city, state, country).filter { it.isNotBlank() }.joinToString(", ")
        return listOf(addr, place).filter { it.isNotBlank() }.joinToString(" • ")
    }

    private fun applyCacheToUi(
        headerBusiness: View?, headerPerson: View?,
        businessTv: TextView?, personTv: TextView?, metaTv: TextView?,
        logoBiz: ImageView?, logoPerson: ImageView?
    ) {
        if (cacheIsShop) {
            headerBusiness?.visibility = View.VISIBLE
            headerPerson?.visibility = View.GONE
            businessTv?.text = cacheTitle
            metaTv?.text = cacheSubtitleLine
            logoBiz?.load(cacheImageUrl) {
                crossfade(true)
                placeholder(android.R.drawable.ic_menu_gallery)
                error(android.R.drawable.ic_menu_gallery)
            }
        } else {
            headerBusiness?.visibility = View.GONE
            headerPerson?.visibility = View.VISIBLE
            personTv?.text = cacheTitle
            metaTv?.text = cacheSubtitleLine
            logoPerson?.load(cacheImageUrl) {
                crossfade(true)
                placeholder(android.R.drawable.ic_menu_gallery)
                error(android.R.drawable.ic_menu_gallery)
            }
        }
    }

    private fun removeOverlay() {
        overlayView?.let { try { windowManager?.removeView(it) } catch (_: Exception) {} }
        overlayView = null
    }

    override fun onDestroy() {
        isRunning = false
        incomingAutoHideJob?.cancel()
        incomingAutoHideJob = null
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
            nm.createNotificationChannel(
                NotificationChannel(channelId, "Tringo Call Alerts", NotificationManager.IMPORTANCE_HIGH)
            )
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
        Log.d(TAG, "HeadsUp shown reason=$reason")
    }

    private fun openAppSettings() {
        try {
            val i = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(i)
        } catch (_: Exception) {}
    }

    private fun normalizePhoneForDial(raw: String): String {
        return raw.trim().replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
    }

    private fun normalizePhoneForWhatsApp(raw: String): String {
        var p = raw.trim().replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
        if (p.startsWith("+")) p = p.substring(1)
        return p
    }

    private fun dialNumber(phone: String) {
        try {
            val p = normalizePhoneForDial(phone)
            val i = Intent(Intent.ACTION_DIAL).apply {
                data = Uri.parse("tel:$p")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(i)
        } catch (e: Exception) {
            Log.e(TAG, "dialNumber failed: ${e.message}", e)
        }
    }

    private fun openWhatsAppChat(phone: String) {
        try {
            val p = normalizePhoneForWhatsApp(phone)
            if (p.isBlank()) return

            val url = "https://wa.me/$p"
            val i = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            try {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo("com.whatsapp", 0)
                i.setPackage("com.whatsapp")
            } catch (_: Exception) {}

            startActivity(i)
        } catch (e: Exception) {
            Log.e(TAG, "openWhatsAppChat failed: ${e.message}", e)
        }
    }

    // Reflection helpers
    private fun tryRead(obj: Any?, field: String): Any? {
        if (obj == null) return null
        return try {
            val m = obj::class.java.methods.firstOrNull {
                it.name == "get${field.replaceFirstChar { c -> c.uppercase() }}"
            }
            if (m != null) m.invoke(obj) else readAny(obj, field)
        } catch (_: Exception) {
            readAny(obj, field)
        }
    }

    private fun readAny(obj: Any?, name: String): Any? {
        if (obj == null) return null
        return try {
            val f = obj::class.java.declaredFields.firstOrNull { it.name == name }
            if (f != null) {
                f.isAccessible = true
                f.get(obj)
            } else {
                val m = obj::class.java.methods.firstOrNull {
                    it.parameterTypes.isEmpty() && (it.name.equals(name, true) ||
                            it.name.equals("get${name.replaceFirstChar { c -> c.uppercase() }}", true))
                }
                m?.invoke(obj)
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun pickString(obj: Any?, vararg keys: String): String? {
        for (k in keys) {
            val v = readAny(obj, k)
            if (v is String && v.trim().isNotEmpty()) return v.trim()
        }
        return null
    }

    private fun pickDouble(obj: Any?, vararg keys: String): Double? {
        for (k in keys) {
            val v = readAny(obj, k)
            when (v) {
                is Double -> return v
                is Float -> return v.toDouble()
                is Int -> return v.toDouble()
                is Long -> return v.toDouble()
                is String -> v.toDoubleOrNull()?.let { return it }
            }
        }
        return null
    }

    private fun pickInt(obj: Any?, vararg keys: String): Int? {
        for (k in keys) {
            val v = readAny(obj, k)
            when (v) {
                is Int -> return v
                is Long -> return v.toInt()
                is Double -> return v.toInt()
                is Float -> return v.toInt()
                is String -> v.toIntOrNull()?.let { return it }
            }
        }
        return null
    }

    private fun pickBool(obj: Any?, vararg keys: String): Boolean? {
        for (k in keys) {
            val v = readAny(obj, k)
            when (v) {
                is Boolean -> return v
                is String -> {
                    val s = v.trim().lowercase()
                    if (s == "true" || s == "1" || s == "yes") return true
                    if (s == "false" || s == "0" || s == "no") return false
                }
                is Int -> return v != 0
                is Long -> return v != 0L
            }
        }
        return null
    }
}

