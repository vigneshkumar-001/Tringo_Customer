package com.feni.tringo.tringo_app

import android.Manifest
import android.app.AlertDialog
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.content.res.ColorStateList
import android.graphics.PixelFormat
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.provider.ContactsContract
import android.provider.Settings
import android.telephony.TelephonyCallback
import android.telephony.TelephonyManager
import android.text.InputType
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.EditText
import android.widget.ImageView
import android.widget.TextView
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import coil.load
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import retrofit2.HttpException
import java.util.concurrent.TimeUnit

class TringoOverlayService : Service() {

    private val TAG = "TRINGO_OVERLAY"

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null

    private val serviceJob = SupervisorJob()
    private val serviceScope = CoroutineScope(Dispatchers.Main + serviceJob)

    private val PREF = "tringo_call_state"
    private val KEY_USER_CLOSED = "user_closed_during_call"
    private val KEY_USER_CLOSED_NUMBER = "user_closed_number"
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

    // Call session guards (avoid false "Call Ended" on noisy devices)
    private var callSessionStartedAt: Long = 0L
    private var sawOffhookInSession: Boolean = false

    private val contactSyncHttp by lazy {
        OkHttpClient.Builder()
            .connectTimeout(15, TimeUnit.SECONDS)
            .readTimeout(15, TimeUnit.SECONDS)
            .writeTimeout(15, TimeUnit.SECONDS)
            .callTimeout(20, TimeUnit.SECONDS)
            .build()
    }

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
    private var cacheCanEditName: Boolean = true

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
        adsCards: List<OverlayAdCard>,
        canEditName: Boolean = true
    ) {
        cachePhone = phone
        cacheAt = System.currentTimeMillis()
        cacheIsShop = isShop
        cacheTitle = title
        cacheSubtitleLine = subtitleLine
        cacheImageUrl = imageUrl
        cacheAdsTitle = adsTitle
        cacheAdsCards = adsCards
        cacheCanEditName = canEditName
        Log.d(TAG, "CACHE SAVED phone=$phone isShop=$isShop ads=${adsCards.size}")
    }

    companion object {
        @Volatile var isRunning: Boolean = false

        private const val FLUTTER_PREFS = "FlutterSharedPreferences"
        private const val KEY_OVERLAY_ENABLED = "flutter.caller_id_overlay_enabled"

        private fun isOverlayFeatureEnabled(ctx: Context): Boolean {
            return try {
                val sp = ctx.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
                val raw = sp.all[KEY_OVERLAY_ENABLED]
                when (raw) {
                    is Boolean -> raw
                    is String -> raw.equals("true", ignoreCase = true)
                    else -> true // default ON; user can disable from Profile toggle
                }
            } catch (_: Throwable) {
                true
            }
        }

        fun start(
            ctx: Context,
            phone: String,
            contactName: String = "",
            showOnCallEnd: Boolean = false,
            launchedByReceiver: Boolean = false
        ): Boolean {
            if (!isOverlayFeatureEnabled(ctx)) {
                Log.d("TRINGO_OVERLAY", "start() skipped (Caller ID Overlay disabled)")
                return false
            }

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
        if (!isOverlayFeatureEnabled(this)) {
            Log.d(TAG, "onStartCommand ignored (Caller ID Overlay disabled)")
            stopSelf()
            return START_NOT_STICKY
        }

        pendingPhone = intent?.getStringExtra("phone") ?: ""
        pendingContact = intent?.getStringExtra("contactName") ?: ""
        launchedByReceiver = intent?.getBooleanExtra("launchedByReceiver", false) ?: false
        showOnlyAfterEnd = intent?.getBooleanExtra("showOnCallEnd", false) ?: false

        Log.d(TAG, "onStartCommand phone=$pendingPhone showOnlyAfterEnd=$showOnlyAfterEnd")


        val prefs = getSharedPreferences(PREF, MODE_PRIVATE)
        val last = (prefs.getString(KEY_LAST_NUMBER, "") ?: "").trim()
        val userClosed = prefs.getBoolean(KEY_USER_CLOSED, false)
        val closedNumber = (prefs.getString(KEY_USER_CLOSED_NUMBER, "") ?: "").trim()

        // Android may hide EXTRA_INCOMING_NUMBER on newer versions/devices.
        // Still show overlay; use last known number if available.
        if (pendingPhone.isBlank() || pendingPhone.equals("UNKNOWN", true)) {
            pendingPhone = if (last.isNotBlank() && !last.equals("UNKNOWN", true)) last else "UNKNOWN"
        }

        val suppressedForThisNumber =
            userClosed &&
                closedNumber.isNotBlank() &&
                pendingPhone.isNotBlank() &&
                !pendingPhone.equals("UNKNOWN", true) &&
                pendingPhone.equals(closedNumber, ignoreCase = true)

        if (userClosed && !suppressedForThisNumber) {
            // User closed overlay for some previous call/number; don't block future calls.
            clearUserClosedFlag()
        }

        // Store only real numbers (avoid persisting UNKNOWN/blank).
        if (pendingPhone.isNotBlank() && !pendingPhone.equals("UNKNOWN", true)) {
            prefs.edit().putString(KEY_LAST_NUMBER, pendingPhone).apply()
        }

        startForegroundDataSyncSafe()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            showCallerHeadsUp("Tringo Caller ID", "Enable overlay permission to show popup", "overlay_permission_missing")
            stopSelf()
            return START_NOT_STICKY
        }

        postCallShownOnce = false
        callSessionStartedAt = 0L
        sawOffhookInSession = false

        if (showOnlyAfterEnd) {
            val callStateNow = try {
                telephonyManager?.callState ?: TelephonyManager.CALL_STATE_IDLE
            } catch (_: Exception) {
                TelephonyManager.CALL_STATE_IDLE
            }

            // Some devices send noisy PHONE_STATE broadcasts that can trigger the "call end" receiver
            // even while the call is still RINGING/OFFHOOK. Guard against showing the post-call overlay
            // unless the device is truly IDLE.
            if (callStateNow != TelephonyManager.CALL_STATE_IDLE) {
                Log.w(TAG, "showOnlyAfterEnd requested but callState=$callStateNow; treating as incoming")
                showOnlyAfterEnd = false
            }
        }

        if (showOnlyAfterEnd) {
            // Some devices are noisy: PHONE_STATE broadcast can arrive while call is still ringing.
            // Confirm IDLE after a short delay before showing "Call Ended".
            Log.d(TAG, "postCall requested; confirming idle phone=$pendingPhone")
            serviceScope.launch {
                delay(1500)
                val stillIdle = safeCallState() == TelephonyManager.CALL_STATE_IDLE
                if (!stillIdle) {
                    Log.w(TAG, "postCall confirmation failed; treating as incoming")
                    showOnlyAfterEnd = false
                    postCallPopupMode = false

                    if (!suppressedForThisNumber) {
                        safeShowOverlay(pendingPhone, pendingContact, preferCache = true)
                        scheduleIncomingAutoHide()
                    }
                    startWatchingForCallEnd()
                    return@launch
                }

                postCallPopupMode = true
                lastOverlayShownAt = 0L
                showOverlay(pendingPhone, pendingContact, preferCache = true)

                delay(POST_CALL_SHOW_MS)
                removeOverlay()
                postCallPopupMode = false
                clearUserClosedFlag()
                stopSelf()
            }

            return START_STICKY
        }

        if (!showOnlyAfterEnd) {
            if (!suppressedForThisNumber) {
                safeShowOverlay(pendingPhone, pendingContact, preferCache = true)
                scheduleIncomingAutoHide()
            }
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
            val edit = getSharedPreferences(PREF, MODE_PRIVATE).edit()
                .putBoolean(KEY_USER_CLOSED, true)

            if (phone.isNotBlank() && !phone.equals("UNKNOWN", true)) {
                edit.putString(KEY_USER_CLOSED_NUMBER, phone)
                edit.putString(KEY_LAST_NUMBER, phone)
            }

            edit.apply()
        } catch (e: Exception) {
            Log.e(TAG, "markUserClosedDuringCall failed: ${e.message}", e)
        }
    }

    private fun clearUserClosedFlag() {
        try {
            getSharedPreferences(PREF, MODE_PRIVATE).edit()
                .putBoolean(KEY_USER_CLOSED, false)
                .remove(KEY_USER_CLOSED_NUMBER)
                .apply()
        } catch (_: Exception) {}
    }

    private fun dismissOverlayFromUser() {
        markUserClosedDuringCall(pendingPhone)
        removeOverlay()

        if (postCallPopupMode) {
            postCallPopupMode = false
            clearUserClosedFlag()
            stopSelf()
        }
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
            if (callSessionStartedAt == 0L) callSessionStartedAt = now
            lastNonIdleAt = now
            if (!showOnlyAfterEnd) {
                if (overlayView == null) safeShowOverlay(pendingPhone, pendingContact, preferCache = true)
                scheduleIncomingAutoHide()
            }
        }

        if (state == TelephonyManager.CALL_STATE_OFFHOOK) {
            if (callSessionStartedAt == 0L) callSessionStartedAt = now
            sawOffhookInSession = true
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
            // Longer + double-check to avoid false IDLE during ringing on some OEMs.
            delay(2500)
            if (safeCallState() != TelephonyManager.CALL_STATE_IDLE) return@launch
            delay(700)
            if (safeCallState() != TelephonyManager.CALL_STATE_IDLE) return@launch

            val idleFor = System.currentTimeMillis() - lastNonIdleAt
            val sessionFor = if (callSessionStartedAt == 0L) 0L else (System.currentTimeMillis() - callSessionStartedAt)

            // If call was never answered, require a longer session to treat it as ended (missed/rejected).
            val minIdle = 2400L
            val minSession = if (sawOffhookInSession) 1200L else 4500L

            if (idleFor < minIdle) return@launch
            if (sessionFor in 1 until minSession) return@launch

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
    // ✅ Icon size like Figma (16dp)
    // ==========================================================
    private fun setButtonIconDp(
        v: View?,
        drawableRes: Int,
        dp: Float = 18f,
        tintColor: Int? = null
    ) {
        val tv = v as? TextView ?: return
        val d = ContextCompat.getDrawable(this, drawableRes) ?: return
        if (tintColor != null) {
            try { d.setTint(tintColor) } catch (_: Exception) {}
        }
        val px = (dp * resources.displayMetrics.density).toInt().coerceAtLeast(1)
        d.setBounds(0, 0, px, px)
        tv.setCompoundDrawablesRelative(d, null, null, null)
        tv.compoundDrawablePadding = (6f * resources.displayMetrics.density).toInt()
    }

    // ==========================================================
    // ✅ OPEN FLUTTER SCREEN FROM OVERLAY (Deep link)
    // ==========================================================
    private fun openFlutterShopDetails(shopId: String, tabIndex: Int = 4) {
        try {
            val i = Intent(this, MainActivity::class.java).apply {
                putExtra("overlay_action", "open_shop_details")
                putExtra("shopId", shopId)
                putExtra("tab", tabIndex)

                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                )
            }


            startActivity(i)
            removeOverlay()
        } catch (e: Exception) {
            Log.e(TAG, "openFlutterShopDetails failed: ${e.message}", e)
        }
    }

    // ==========================================================
    // ✅ Fallback UI when API fails (522 etc.)
    // ==========================================================
    private fun applyFallbackUi(
        headerBusiness: View?,
        headerPerson: View?,
        businessTv: TextView?,
        businessMetaTv: TextView?,
        personTv: TextView?,
        personMetaTv: TextView?,
        personPhoneTv: TextView?,
        personBadgeTv: TextView?,
        logoBiz: ImageView?,
        logoPerson: ImageView?,
        phone: String,
        contactName: String,
        reason: String
    ) {
        // If overlay already removed, don't touch views
        if (overlayView == null) return

        headerBusiness?.visibility = View.GONE
        headerPerson?.visibility = View.VISIBLE

        val displayName = contactName.trim()
        personPhoneTv?.text = formatPhoneForDisplay(phone)
        personPhoneTv?.visibility = if (displayName.isNotBlank()) View.GONE else View.VISIBLE
        personTv?.text = displayName
        personTv?.visibility = if (displayName.isNotBlank()) View.VISIBLE else View.GONE
        personMetaTv?.text = "India • Just now"
        personBadgeTv?.text = if (displayName.isNotBlank()) "CALLER" else "UNKNOWN CALLER"

        try {
            logoPerson?.scaleType = ImageView.ScaleType.CENTER_INSIDE
            logoPerson?.imageTintList = ColorStateList.valueOf(0xFFEAF7FF.toInt())
            logoPerson?.setImageResource(android.R.drawable.ic_menu_myplaces)
        } catch (_: Exception) {}
    }

    // ==========================================================
    // Overlay UI (CACHE FIRST)
    // ==========================================================
    private fun showOverlay(phone: String, contactName: String, preferCache: Boolean) {
        removeOverlay()

        val inflater = getSystemService(LAYOUT_INFLATER_SERVICE) as LayoutInflater
        val v = inflater.inflate(R.layout.tringo_overlay, null)
        overlayView = v

        // Headers
        val headerBusiness = v.findViewById<View>(R.id.headerBusiness)
        val headerPerson = v.findViewById<View>(R.id.headerPerson)

        // Business views (kept for backward compatibility; we force person layout)
        val businessTv = v.findViewById<TextView>(R.id.businessNameText)
        val businessMetaTv = v.findViewById<TextView>(R.id.metaText)
        val logoBiz = v.findViewById<ImageView>(R.id.logoImageBusiness)

        val callBtnBusiness = v.findViewById<View>(R.id.callBtn)
        val chatBtnBusiness = v.findViewById<View>(R.id.chatBtn)

        // Person views
        val personTv = v.findViewById<TextView>(R.id.personNameText)
        val personMetaTv = v.findViewById<TextView>(R.id.personMetaText)
        val personPhoneTv = v.findViewById<TextView>(R.id.personPhoneText)
        val personBadgeTv = v.findViewById<TextView>(R.id.personBadgeText)
        val personAvatarBadge = v.findViewById<View>(R.id.personAvatarBadge)
        val suggestedEditBtn = v.findViewById<View>(R.id.suggestedEditBtn)
        val confirmSaveBtnPerson = v.findViewById<View>(R.id.confirmSaveBtnPerson)
        val logoPerson = v.findViewById<ImageView>(R.id.logoImagePerson)
        val editConfirmSpacer = v.findViewById<View>(R.id.editConfirmSpacer)

        // Person buttons
        val actionRowPerson = v.findViewById<View>(R.id.actionRowPerson)
        val callBtnPerson = v.findViewById<View>(R.id.callBtnPerson)
        val chatBtnPerson = v.findViewById<View>(R.id.chatBtnPerson)
        val saveContactBtnPerson = v.findViewById<View>(R.id.saveContactBtnPerson)

        // Top title
        val smallTop = v.findViewById<TextView>(R.id.smallTopText)
        smallTop.text = if (postCallPopupMode) "Tringo Call Ended" else "Tringo Identifies"

        // Dismiss overlay on outside tap + close button
        val outsideLayer = v.findViewById<View>(R.id.outsideCloseLayer)
        val rootCard = v.findViewById<View>(R.id.rootCard)
        outsideLayer?.setOnClickListener { dismissOverlayFromUser() }

        // On some devices, the "end call" tap-up can land on the newly shown post-call overlay
        // and instantly dismiss it. Guard dismiss for a short window after showing post-call UI.
        if (postCallPopupMode) {
            outsideLayer?.isClickable = false
            serviceScope.launch {
                delay(700)
                if (overlayView !== v) return@launch
                outsideLayer?.isClickable = true
            }
        }

        // Close
        val closeBtn = v.findViewById<View>(R.id.closeBtn)
        closeBtn?.setOnClickListener { dismissOverlayFromUser() }

        setButtonIconDp(callBtnBusiness, R.drawable.ic_call_png, 16f)
        setButtonIconDp(chatBtnBusiness, R.drawable.ic_whatsapp_png, 16f)
        setButtonIconDp(
            callBtnPerson,
            R.drawable.ic_call_outline,
            16f,
            tintColor = 0xFF39E38C.toInt()
        )
        setButtonIconDp(
            saveContactBtnPerson,
            R.drawable.ic_person_add_outline,
            16f,
            tintColor = 0xFF2A74FF.toInt()
        )
        setButtonIconDp(
            chatBtnPerson,
            R.drawable.ic_message_outline,
            16f,
            tintColor = 0xFFB37CFF.toInt()
        )
        setButtonIconDp(
            suggestedEditBtn,
            R.drawable.ic_edit_outline,
            16f,
            tintColor = 0xFFB37CFF.toInt()
        )
        setButtonIconDp(confirmSaveBtnPerson, R.drawable.ic_check_outline, 16f)

        val dialClick = View.OnClickListener {
            val num = (cachePhone ?: pendingPhone).trim()
            if (num.isNotBlank() && !num.equals("UNKNOWN", true)) dialNumber(num)
        }
        val whatsappClick = View.OnClickListener {
            val num = (cachePhone ?: pendingPhone).trim()
            if (num.isNotBlank() && !num.equals("UNKNOWN", true)) openWhatsAppChat(num)
        }
        val smsClick = View.OnClickListener {
            val num = (cachePhone ?: pendingPhone).trim()
            if (num.isNotBlank() && !num.equals("UNKNOWN", true)) openSms(num)
        }
        val saveContactClick = View.OnClickListener {
            val num = (cachePhone ?: pendingPhone).trim()
            if (num.isBlank() || num.equals("UNKNOWN", true)) return@OnClickListener
            val name = personTv?.text?.toString()?.trim().orEmpty()
            openAddContact(name = name, phone = num)
        }

        // Never show business call/whatsapp UI for this design
        headerBusiness?.visibility = View.GONE
        callBtnPerson?.setOnClickListener(dialClick)
        saveContactBtnPerson?.setOnClickListener(saveContactClick)
        chatBtnPerson?.setOnClickListener(smsClick)

        // UX: Incoming overlay -> only Edit. After-call overlay -> Call/Save/Msg + Ads.
        actionRowPerson?.visibility = if (postCallPopupMode) View.VISIBLE else View.GONE
        confirmSaveBtnPerson?.visibility = View.GONE
        editConfirmSpacer?.visibility = View.GONE

        suggestedEditBtn?.setOnClickListener {
            val num = (cachePhone ?: pendingPhone).trim()
            if (num.isBlank() || num.equals("UNKNOWN", true)) return@setOnClickListener
            val current = personTv?.text?.toString()?.trim().orEmpty()
            showEditNameDialog(initialName = current, phone = num) { newName ->
                if (overlayView !== v) return@showEditNameDialog
                personTv?.text = newName
                personBadgeTv?.text = "CALLER"
                personAvatarBadge?.visibility = View.GONE
                personPhoneTv?.visibility = View.GONE
                cachePhone = num
                cacheTitle = newName
                cacheAt = System.currentTimeMillis()

                submitPublicPhoneInfoNameBestEffort(name = newName, phone = num)
                syncSingleContactBestEffort(name = newName, phone = num)
            }
        }

        confirmSaveBtnPerson?.setOnClickListener {
            val num = (cachePhone ?: pendingPhone).trim()
            if (num.isBlank() || num.equals("UNKNOWN", true)) return@setOnClickListener
            val name = personTv?.text?.toString()?.trim().orEmpty()
            openAddContact(name = name, phone = num)
            if (name.isNotBlank()) syncSingleContactBestEffort(name = name, phone = num)
            dismissOverlayFromUser()
        }

        // Ads
        val divider = v.findViewById<View>(R.id.dividerLine)
        val adsTitleTv = v.findViewById<TextView>(R.id.adsTitle)
        val recycler = v.findViewById<RecyclerView>(R.id.adsRecycler)

        recycler.layoutManager = LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false)
        clampAdsRecyclerHeight(recycler)

        // ✅ click callback -> open flutter page
        adsAdapter = OverlayAdsAdapter { ad ->
            val sid = ad.shopId.ifBlank { ad.id } // fallback
            openFlutterShopDetails(sid, tabIndex = 4)
        }
        recycler.adapter = adsAdapter

        val flags =
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            flags,
            PixelFormat.TRANSLUCENT
        ).apply { gravity = Gravity.TOP or Gravity.START }

        try {
            windowManager?.addView(v, params)
            Log.d(TAG, "addView ok postCall=$postCallPopupMode phone=$phone")
        } catch (e: Exception) {
            showCallerHeadsUp(
                "Tringo Caller ID",
                if (contactName.isNotBlank()) contactName else if (phone.isBlank() || phone.equals("UNKNOWN", true)) "Incoming Call" else phone,
                "addView_failed"
            )
            stopSelf()
            return
        }

        // ✅ default loading UI
        headerBusiness.visibility = View.GONE
        headerPerson.visibility = View.VISIBLE
        val displayName = contactName.trim()
        personPhoneTv?.text = formatPhoneForDisplay(phone)
        personTv.text = displayName
        personTv.visibility = if (displayName.isNotBlank()) View.VISIBLE else View.GONE
        personMetaTv.text = "India • Just now"
        personBadgeTv?.text = if (displayName.isNotBlank()) "CALLER" else "UNKNOWN CALLER"
        personAvatarBadge?.visibility = if (displayName.isNotBlank()) View.GONE else View.VISIBLE
        try {
            logoPerson?.scaleType = ImageView.ScaleType.CENTER_INSIDE
            logoPerson?.imageTintList = ColorStateList.valueOf(0xFFEAF7FF.toInt())
            logoPerson?.setImageResource(android.R.drawable.ic_menu_myplaces)
        } catch (_: Exception) {}

        // ✅ ads default hidden (only show postCallPopupMode)
        divider.visibility = View.GONE
        adsTitleTv.visibility = View.GONE
        recycler.visibility = View.GONE

        fun applyAdsVisibilityNow() {
            val allowAds = postCallPopupMode
            val hasAds = cacheAdsCards.isNotEmpty()
            if (allowAds && hasAds) {
                divider.visibility = View.VISIBLE
                adsTitleTv.visibility = View.VISIBLE
                recycler.visibility = View.VISIBLE
            } else {
                divider.visibility = View.GONE
                adsTitleTv.visibility = View.GONE
                recycler.visibility = View.GONE
            }
        }

        // ✅ CACHE instant apply
        if (preferCache && isCacheValidFor(phone)) {
            applyCacheToUi(
                headerBusiness = headerBusiness,
                headerPerson = headerPerson,
                businessTv = businessTv,
                businessMetaTv = businessMetaTv,
                personTv = personTv,
                personMetaTv = personMetaTv,
                personPhoneTv = personPhoneTv,
                personBadgeTv = personBadgeTv,
                logoBiz = logoBiz,
                logoPerson = logoPerson,
                personAvatarBadge = personAvatarBadge
            )
            adsAdapter?.submitList(cacheAdsCards)
            applyAdsVisibilityNow()
            suggestedEditBtn?.visibility = if (cacheCanEditName) View.VISIBLE else View.GONE
            return
        }

        // ✅ API fetch
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

                val actionsAny = readAny(cardAny, "actions") ?: readAny(cardAny, "editable")
                val canEditName =
                    pickBool(actionsAny, "canEditName", "showEditIcon") ?:
                        pickBool(cardAny, "editable") ?: true

                val subtitleLine = listOfNotNull(
                    (if (cat.isNotBlank()) cat else null) ?: cardSubtitle.takeIf { it.isNotBlank() },
                    if (opensAt.isNotBlank() && closesAt.isNotBlank()) "$opensAt - $closesAt" else null,
                    addr.takeIf { it.isNotBlank() }
                ).joinToString(" • ")

                val adsAny = readAny(dataAny, "advertisements")
                val adsTitle = (readAny(adsAny, "title") as? String)?.trim()
                    .takeUnless { it.isNullOrBlank() } ?: "Advertisements"

                val listAny = readAny(adsAny, "items") as? List<*>
                val rawItems: List<Any> = listAny?.mapNotNull { it as? Any } ?: emptyList()

                val cards = rawItems.mapIndexed { idx, item ->
                    val adId = pickString(item, "id", "_id") ?: "ad_$idx"
                    val shopId = pickString(item, "shopId") ?: adId // ✅ fallback to adId

                    OverlayAdCard(
                        id = adId,
                        shopId = shopId,
                        title = pickString(item, "englishName", "title", "name") ?: "Ad ${idx + 1}",
                        subtitle = buildAdSubtitle(item),
                        viewCountLabel = pickString(item, "viewCountLabel"),
                        offerText = pickOfferText(item),
                        openText = pickString(item, "openLabel", "openText"),
                        isTrusted = pickBool(item, "isTrusted", "trusted") ?: false,
                        imageUrl = pickString(item, "primaryImageUrl", "imageUrl") ?: "",
                        phone = pickString(item, "primaryPhone", "phone")
                    )
                }

                saveCache(
                    phone = phone,
                    isShop = isShop,
                    title = cardTitle.ifBlank { contactName.trim() },
                    subtitleLine = subtitleLine,
                    imageUrl = cardImageUrl,
                    adsTitle = adsTitle,
                    adsCards = cards,
                    canEditName = canEditName
                )

                applyCacheToUi(
                    headerBusiness = headerBusiness,
                    headerPerson = headerPerson,
                    businessTv = businessTv,
                    businessMetaTv = businessMetaTv,
                    personTv = personTv,
                    personMetaTv = personMetaTv,
                    personPhoneTv = personPhoneTv,
                    personBadgeTv = personBadgeTv,
                    logoBiz = logoBiz,
                    logoPerson = logoPerson,
                    personAvatarBadge = personAvatarBadge
                )

                adsAdapter?.submitList(cacheAdsCards)
                applyAdsVisibilityNow()
                suggestedEditBtn?.visibility = if (cacheCanEditName) View.VISIBLE else View.GONE

            } catch (e: Exception) {
                // ✅ Ignore cancellation (normal)
                if (e is CancellationException) {
                    Log.w("TRINGO_API", "API cancelled (normal)")
                    return@launch
                }

                val reason = when (e) {
                    is HttpException -> {
                        val code = e.code()
                        if (code == 522 || code == 524) "Server busy (HTTP $code). Try again."
                        else "API error (HTTP $code)"
                    }
                    else -> "Network error. Check internet."
                }

                Log.e("TRINGO_API", "API failed: ${e.message}", e)

                applyFallbackUi(
                    headerBusiness = headerBusiness,
                    headerPerson = headerPerson,
                    businessTv = businessTv,
                    businessMetaTv = businessMetaTv,
                    personTv = personTv,
                    personMetaTv = personMetaTv,
                    personPhoneTv = personPhoneTv,
                    personBadgeTv = personBadgeTv,
                    logoBiz = logoBiz,
                    logoPerson = logoPerson,
                    phone = phone,
                    contactName = contactName,
                    reason = reason
                )
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

    private fun pickOfferText(item: Any?): String? {
        val offerAny = readAny(item, "appOffer") ?: return null
        if (offerAny is String) return offerAny.trim().takeIf { it.isNotBlank() }

        val direct =
            pickString(offerAny, "offerText", "discountText", "text", "label", "title", "description")
                ?.trim()
                ?.takeIf { it.isNotBlank() }
        if (direct != null) return direct

        val pct = pickString(offerAny, "percent", "percentage")?.trim()?.takeIf { it.isNotBlank() }
        val min = pickString(offerAny, "minOrder", "minOrderAmount", "minAmount", "thresholdAmount")
            ?.trim()
            ?.takeIf { it.isNotBlank() }

        if (pct != null && min != null) return "$pct DISCOUNT\non orders above ₹ $min"
        if (pct != null) return "$pct DISCOUNT"

        return null
    }

    private fun applyCacheToUi(
        headerBusiness: View?,
        headerPerson: View?,
        businessTv: TextView?,
        businessMetaTv: TextView?,
        personTv: TextView?,
        personMetaTv: TextView?,
        personPhoneTv: TextView?,
        personBadgeTv: TextView?,
        logoBiz: ImageView?,
        logoPerson: ImageView?,
        personAvatarBadge: View?
    ) {
        // Always use the SAME overlay design (person layout) for both shop/person results.
        headerBusiness?.visibility = View.GONE
        headerPerson?.visibility = View.VISIBLE

        val phone = (cachePhone ?: pendingPhone).trim()
        val displayName = cacheTitle.trim()
        val hasName = displayName.isNotBlank()

        personPhoneTv?.text = formatPhoneForDisplay(phone)
        personPhoneTv?.visibility = if (hasName) View.GONE else View.VISIBLE
        personTv?.text = displayName
        personTv?.visibility = if (hasName) View.VISIBLE else View.GONE
        personMetaTv?.text = "India • Just now"
        personBadgeTv?.text = if (hasName) "CALLER" else "UNKNOWN CALLER"
        personAvatarBadge?.visibility = if (hasName) View.GONE else View.VISIBLE

        val hasPhoto = cacheImageUrl.isNotBlank()
        if (hasPhoto) {
            try {
                logoPerson?.scaleType = ImageView.ScaleType.CENTER_CROP
                logoPerson?.imageTintList = null
            } catch (_: Exception) {}
            logoPerson?.load(cacheImageUrl) {
                allowHardware(false)
                crossfade(true)
                placeholder(android.R.drawable.ic_menu_myplaces)
                error(android.R.drawable.ic_menu_myplaces)
            }
            personAvatarBadge?.visibility = View.GONE
        } else {
            try {
                logoPerson?.scaleType = ImageView.ScaleType.CENTER_INSIDE
                logoPerson?.imageTintList = ColorStateList.valueOf(0xFFEAF7FF.toInt())
                logoPerson?.setImageResource(android.R.drawable.ic_menu_myplaces)
            } catch (_: Exception) {}
            personAvatarBadge?.visibility = if (hasName) View.GONE else View.VISIBLE
        }
    }

    private fun removeOverlay() {
        overlayView?.let {
            try { windowManager?.removeView(it) } catch (_: Exception) {}
            Log.d(TAG, "removeOverlay()")
        }
        overlayView = null
    }

    private fun clampAdsRecyclerHeight(recycler: RecyclerView?) {
        if (recycler == null) return
        try {
            val density = resources.displayMetrics.density
            val desiredPx = (270f * density).toInt()
            val screenH = resources.displayMetrics.heightPixels
            val maxPx = (screenH * 0.40f).toInt().coerceAtLeast((160f * density).toInt())
            val h = desiredPx.coerceAtMost(maxPx).coerceAtLeast((140f * density).toInt())
            recycler.layoutParams = recycler.layoutParams.apply { height = h }
        } catch (_: Exception) {}
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

    private fun formatPhoneForDisplay(raw: String): String {
        val digits = raw.filter { it.isDigit() }
        if (digits.length == 10) {
            return "+91 ${digits.substring(0, 5)} ${digits.substring(5)}"
        }
        if (digits.length == 12 && digits.startsWith("91")) {
            val n = digits.substring(2)
            return "+91 ${n.substring(0, 5)} ${n.substring(5)}"
        }
        return raw.ifBlank { "UNKNOWN" }
    }

    private fun openSms(phone: String) {
        try {
            val p = normalizePhoneForDial(phone)
            if (p.isBlank()) return
            val i = Intent(Intent.ACTION_SENDTO).apply {
                data = Uri.parse("smsto:$p")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(i)
        } catch (e: Exception) {
            Log.e(TAG, "openSms failed: ${e.message}", e)
        }
    }

    private fun openAddContact(name: String, phone: String) {
        try {
            val p = normalizePhoneForDial(phone)
            if (p.isBlank()) return
            val i = Intent(ContactsContract.Intents.Insert.ACTION).apply {
                type = ContactsContract.RawContacts.CONTENT_TYPE
                putExtra(ContactsContract.Intents.Insert.NAME, name)
                putExtra(ContactsContract.Intents.Insert.PHONE, p)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(i)
        } catch (e: Exception) {
            Log.e(TAG, "openAddContact failed: ${e.message}", e)
        }
    }

    private fun showEditNameDialog(
        initialName: String,
        phone: String,
        onSaved: (String) -> Unit
    ) {
        try {
            val input = EditText(this).apply {
                inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_CAP_WORDS
                setText(initialName)
                setSelection(text?.length ?: 0)
                hint = "Enter name"
            }

            val d = AlertDialog.Builder(this)
                .setTitle("Edit name")
                .setMessage(formatPhoneForDisplay(phone))
                .setView(input)
                .setNegativeButton("Cancel", null)
                .setPositiveButton("Save") { _, _ ->
                    val v = input.text?.toString()?.trim().orEmpty()
                    if (v.isNotBlank()) onSaved(v)
                }
                .create()

            try {
                val t = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                else
                    @Suppress("DEPRECATION") WindowManager.LayoutParams.TYPE_PHONE
                d.window?.setType(t)
            } catch (_: Exception) {}

            d.show()
        } catch (e: Exception) {
            Log.e(TAG, "showEditNameDialog failed: ${e.message}", e)
        }
    }

    private fun getFlutterPref(key: String): String? {
        return try {
            val p = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            p.getString("flutter.$key", null)
        } catch (_: Exception) {
            null
        }
    }

    private fun normalizePhoneForSync(raw: String): String {
        val digits = raw.filter { it.isDigit() }
        if (digits.length == 10) return "+91$digits"
        if (digits.length == 12 && digits.startsWith("91")) return "+$digits"
        return raw.trim()
    }

    private fun normalizePhoneForPublicPhoneInfo(raw: String): String {
        val digits = raw.filter { it.isDigit() }
        if (digits.length == 12 && digits.startsWith("91")) return digits.substring(2)
        if (digits.length == 10) return digits
        return digits.ifBlank { raw.trim() }
    }

    private fun submitPublicPhoneInfoNameBestEffort(name: String, phone: String) {
        serviceScope.launch {
            try {
                val token = getFlutterPref("token")?.trim().orEmpty()
                val sessionToken = getFlutterPref("sessionToken")?.trim().orEmpty()

                val payload = JSONObject().apply {
                    put("phone", normalizePhoneForPublicPhoneInfo(phone))
                    put("name", name)
                }

                val body = payload.toString()
                    .toRequestBody("application/json; charset=utf-8".toMediaType())

                val req = Request.Builder()
                    .url("https://bknd.tringobiz.com/api/v1/public/phone-info/name")
                    .post(body)
                    .apply {
                        if (token.isNotBlank()) addHeader("Authorization", "Bearer $token")
                        if (sessionToken.isNotBlank()) addHeader("x-session-token", sessionToken)
                    }
                    .build()

                withContext(Dispatchers.IO) {
                    contactSyncHttp.newCall(req).execute().use { res ->
                        Log.d(TAG, "phone-info/name http=${res.code}")
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "phone-info/name failed: ${e.message}", e)
            }
        }
    }

    private fun syncSingleContactBestEffort(name: String, phone: String) {
        serviceScope.launch {
            try {
                val token = getFlutterPref("token")?.trim().orEmpty()
                val sessionToken = getFlutterPref("sessionToken")?.trim().orEmpty()
                if (token.isBlank()) {
                    Log.w(TAG, "syncSingleContact skipped: no auth token")
                    return@launch
                }

                val payload = JSONObject().apply {
                    put(
                        "items",
                        JSONArray().put(
                            JSONObject()
                                .put("name", name)
                                .put("phone", normalizePhoneForSync(phone))
                        )
                    )
                }

                val body = payload.toString()
                    .toRequestBody("application/json; charset=utf-8".toMediaType())

                val req = Request.Builder()
                    .url("https://bknd.tringobiz.com/api/v1/contacts/sync")
                    .post(body)
                    .addHeader("Authorization", "Bearer $token")
                    .apply {
                        if (sessionToken.isNotBlank()) addHeader("x-session-token", sessionToken)
                    }
                    .build()

                withContext(Dispatchers.IO) {
                    contactSyncHttp.newCall(req).execute().use { res ->
                        Log.d(TAG, "syncSingleContact http=${res.code}")
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "syncSingleContact failed: ${e.message}", e)
            }
        }
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

//
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
//import androidx.recyclerview.widget.LinearLayoutManager
//import androidx.recyclerview.widget.RecyclerView
//import coil.load
//import kotlinx.coroutines.*
//import kotlin.math.abs
//import kotlin.math.max
//
//class TringoOverlayService : Service() {
//
//    private val TAG = "TRINGO_OVERLAY"
//
//    private var windowManager: WindowManager? = null
//    private var overlayView: View? = null
//
//    private val serviceJob = SupervisorJob()
//    private val serviceScope = CoroutineScope(Dispatchers.Main + serviceJob)
//
//    private val PREF = "tringo_call_state"
//    private val KEY_USER_CLOSED = "user_closed_during_call"
//    private val KEY_LAST_NUMBER = "last_number"
//
//    private var adsAdapter: OverlayAdsAdapter? = null
//
//    private var pendingPhone: String = ""
//    private var pendingContact: String = ""
//
//    private var launchedByReceiver = false
//    private var postCallPopupMode = false
//    private var showOnlyAfterEnd = false
//
//    private var telephonyManager: TelephonyManager? = null
//    private var telephonyCallback: TelephonyCallback? = null
//
//    @Suppress("DEPRECATION")
//    private var phoneStateListener: android.telephony.PhoneStateListener? = null
//
//    private var isWatchingCallEnd = false
//    private var lastState: Int = TelephonyManager.CALL_STATE_IDLE
//
//    private var endConfirmJob: Job? = null
//    private var lastNonIdleAt: Long = 0L
//
//    private var incomingAutoHideJob: Job? = null
//
//    // ✅ debounce
//    private var lastOverlayShownAt: Long = 0L
//    private val OVERLAY_DEBOUNCE_MS = 900L
//
//    private var postCallShownOnce = false
//
//    private val INCOMING_SHOW_MS = 10_000L
//    private val POST_CALL_SHOW_MS = 15_000L
//
//    // ==========================================================
//    // ✅ CACHE (API only once)
//    // ==========================================================
//    private val CACHE_VALID_MS = 90_000L
//    private var cachePhone: String? = null
//    private var cacheAt: Long = 0L
//
//    private var cacheIsShop: Boolean = false
//    private var cacheTitle: String = ""
//    private var cacheSubtitleLine: String = ""
//    private var cacheImageUrl: String = ""
//
//    private var cacheAdsTitle: String = "Advertisements"
//    private var cacheAdsCards: List<OverlayAdCard> = emptyList()
//
//    private fun isCacheValidFor(phone: String): Boolean {
//        val ok = cachePhone == phone && (System.currentTimeMillis() - cacheAt) <= CACHE_VALID_MS
//        Log.d(TAG, "isCacheValidFor($phone) => $ok")
//        return ok
//    }
//
//    private fun saveCache(
//        phone: String,
//        isShop: Boolean,
//        title: String,
//        subtitleLine: String,
//        imageUrl: String,
//        adsTitle: String,
//        adsCards: List<OverlayAdCard>
//    ) {
//        cachePhone = phone
//        cacheAt = System.currentTimeMillis()
//        cacheIsShop = isShop
//        cacheTitle = title
//        cacheSubtitleLine = subtitleLine
//        cacheImageUrl = imageUrl
//        cacheAdsTitle = adsTitle
//        cacheAdsCards = adsCards
//        Log.d(TAG, "CACHE SAVED phone=$phone isShop=$isShop ads=${adsCards.size}")
//    }
//
//    companion object {
//        @Volatile var isRunning: Boolean = false
//
//        fun start(
//            ctx: Context,
//            phone: String,
//            contactName: String = "",
//            showOnCallEnd: Boolean = false,
//            launchedByReceiver: Boolean = false
//        ): Boolean {
//            val i = Intent(ctx, TringoOverlayService::class.java).apply {
//                putExtra("phone", phone)
//                putExtra("contactName", contactName)
//                putExtra("showOnCallEnd", showOnCallEnd)
//                putExtra("launchedByReceiver", launchedByReceiver)
//            }
//
//            return try {
//                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//                    try { ctx.startForegroundService(i) }
//                    catch (t: Throwable) {
//                        Log.e("TRINGO_OVERLAY", "startForegroundService blocked => fallback: ${t.message}")
//                        ctx.startService(i)
//                    }
//                } else {
//                    ctx.startService(i)
//                }
//                true
//            } catch (e: Throwable) {
//                Log.e("TRINGO_OVERLAY", "start() failed: ${e.message}", e)
//                false
//            }
//        }
//    }
//
//    override fun onCreate() {
//        super.onCreate()
//        isRunning = true
//        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
//        telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager
//    }
//
//    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
//
//        pendingPhone = intent?.getStringExtra("phone") ?: ""
//        pendingContact = intent?.getStringExtra("contactName") ?: ""
//        launchedByReceiver = intent?.getBooleanExtra("launchedByReceiver", false) ?: false
//        showOnlyAfterEnd = intent?.getBooleanExtra("showOnCallEnd", false) ?: false
//
//        Log.d(TAG, "onStartCommand phone=$pendingPhone showOnlyAfterEnd=$showOnlyAfterEnd")
//

//        val prefs = getSharedPreferences(PREF, MODE_PRIVATE)
//        val last = (prefs.getString(KEY_LAST_NUMBER, "") ?: "").trim()

        // Android may hide EXTRA_INCOMING_NUMBER on newer versions/devices.
        // Still show overlay; use last known number if available.
//        if (pendingPhone.isBlank() || pendingPhone.equals("UNKNOWN", true)) {
//            pendingPhone = if (last.isNotBlank() && !last.equals("UNKNOWN", true)) last else "UNKNOWN"
//        }

        // Store only real numbers (avoid persisting UNKNOWN/blank).
//        if (pendingPhone.isNotBlank() && !pendingPhone.equals("UNKNOWN", true)) {
//            prefs.edit().putString(KEY_LAST_NUMBER, pendingPhone).apply()
//        }
//
//        startForegroundDataSyncSafe()
//
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
//            showCallerHeadsUp("Tringo Caller ID", "Enable overlay permission to show popup", "overlay_permission_missing")
//            openAppSettings()
//            stopSelf()
//            return START_NOT_STICKY
//        }
//
//        postCallShownOnce = false
//
//        if (!showOnlyAfterEnd) {
//            safeShowOverlay(pendingPhone, pendingContact, preferCache = true)
//            scheduleIncomingAutoHide()
//        }
//
//        startWatchingForCallEnd()
//        return START_STICKY
//    }
//
//    // ==========================================================
//    // Foreground
//    // ==========================================================
//    private fun startForegroundDataSyncSafe() {
//        val channelId = "tringo_overlay_service"
//        try {
//            val nm = getSystemService(NotificationManager::class.java)
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//                nm.createNotificationChannel(
//                    NotificationChannel(channelId, "Tringo Overlay", NotificationManager.IMPORTANCE_LOW)
//                )
//            }
//
//            val notif = NotificationCompat.Builder(this, channelId)
//                .setSmallIcon(android.R.drawable.ic_menu_call)
//                .setContentTitle("Tringo Caller ID")
//                .setContentText("Running...")
//                .setOngoing(true)
//                .setOnlyAlertOnce(true)
//                .setPriority(NotificationCompat.PRIORITY_LOW)
//                .build()
//
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//                ServiceCompat.startForeground(this, 101, notif, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
//            } else {
//                startForeground(101, notif)
//            }
//        } catch (t: Throwable) {
//            Log.e(TAG, "startForegroundDataSyncSafe failed: ${t.message}", t)
//        }
//    }
//
//    // ==========================================================
//    // Prefs
//    // ==========================================================
//    private fun markUserClosedDuringCall(phone: String) {
//        try {
//            getSharedPreferences(PREF, MODE_PRIVATE).edit()
//                .putBoolean(KEY_USER_CLOSED, true)
//                .putString(KEY_LAST_NUMBER, phone)
//                .apply()
//        } catch (e: Exception) {
//            Log.e(TAG, "markUserClosedDuringCall failed: ${e.message}", e)
//        }
//    }
//
//    private fun clearUserClosedFlag() {
//        try {
//            getSharedPreferences(PREF, MODE_PRIVATE).edit()
//                .putBoolean(KEY_USER_CLOSED, false)
//                .apply()
//        } catch (_: Exception) {}
//    }
//
//    // ==========================================================
//    // Call watch
//    // ==========================================================
//    private fun hasReadPhoneState(): Boolean {
//        return ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) ==
//                PackageManager.PERMISSION_GRANTED
//    }
//
//    private fun safeCallState(): Int {
//        return try {
//            telephonyManager?.callState ?: TelephonyManager.CALL_STATE_IDLE
//        } catch (_: Throwable) {
//            TelephonyManager.CALL_STATE_IDLE
//        }
//    }
//
//    private fun startWatchingForCallEnd() {
//        if (isWatchingCallEnd) return
//        if (!hasReadPhoneState()) {
//            Log.e(TAG, "READ_PHONE_STATE not granted -> cannot detect call end.")
//            return
//        }
//
//        isWatchingCallEnd = true
//        endConfirmJob?.cancel()
//
//        lastNonIdleAt = System.currentTimeMillis()
//        lastState = safeCallState()
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
//            } catch (_: Exception) {
//                startWatchingForCallEndLegacy()
//            }
//        } else {
//            startWatchingForCallEndLegacy()
//        }
//    }
//
//    @Suppress("DEPRECATION")
//    private fun startWatchingForCallEndLegacy() {
//        if (!hasReadPhoneState()) return
//        val listener = object : android.telephony.PhoneStateListener() {
//            override fun onCallStateChanged(state: Int, phoneNumber: String?) {
//                handleCallState(state)
//            }
//        }
//        phoneStateListener = listener
//        telephonyManager?.listen(listener, android.telephony.PhoneStateListener.LISTEN_CALL_STATE)
//    }
//
//    private fun stopWatchingForCallEnd() {
//        if (!isWatchingCallEnd) return
//        isWatchingCallEnd = false
//
//        endConfirmJob?.cancel()
//        endConfirmJob = null
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
//        } catch (_: Exception) {}
//    }
//
//    private fun handleCallState(state: Int) {
//        val now = System.currentTimeMillis()
//
//        if (state == TelephonyManager.CALL_STATE_RINGING) {
//            lastNonIdleAt = now
//            if (!showOnlyAfterEnd) {
//                if (overlayView == null) safeShowOverlay(pendingPhone, pendingContact, preferCache = true)
//                scheduleIncomingAutoHide()
//            }
//        }
//
//        if (state == TelephonyManager.CALL_STATE_OFFHOOK) {
//            lastNonIdleAt = now
//            incomingAutoHideJob?.cancel()
//            incomingAutoHideJob = null
//        }
//
//        if (state != TelephonyManager.CALL_STATE_IDLE) {
//            endConfirmJob?.cancel()
//            lastState = state
//            return
//        }
//
//        endConfirmJob?.cancel()
//        endConfirmJob = serviceScope.launch {
//            delay(1200)
//            if (safeCallState() != TelephonyManager.CALL_STATE_IDLE) return@launch
//            val idleFor = System.currentTimeMillis() - lastNonIdleAt
//            if (idleFor < 900) return@launch
//            onCallEndedConfirmed()
//        }
//
//        lastState = state
//    }
//
//    private fun scheduleIncomingAutoHide() {
//        incomingAutoHideJob?.cancel()
//        incomingAutoHideJob = serviceScope.launch {
//            delay(INCOMING_SHOW_MS)
//            if (!postCallPopupMode) removeOverlay()
//        }
//    }
//
//    private fun onCallEndedConfirmed() {
//        if (postCallShownOnce) return
//        postCallShownOnce = true
//
//        serviceScope.launch {
//            stopWatchingForCallEnd()
//
//            postCallPopupMode = true
//            safeShowOverlay(pendingPhone, pendingContact, preferCache = true)
//
//            delay(POST_CALL_SHOW_MS)
//            removeOverlay()
//
//            postCallPopupMode = false
//            clearUserClosedFlag()
//            stopSelf()
//        }
//    }
//
//    // ==========================================================
//    // Overlay show (debounced)
//    // ==========================================================
//    private fun safeShowOverlay(phone: String, contactName: String, preferCache: Boolean) {
//        val now = System.currentTimeMillis()
//        if (now - lastOverlayShownAt < OVERLAY_DEBOUNCE_MS) return
//        lastOverlayShownAt = now
//        showOverlay(phone, contactName, preferCache)
//    }
//
//    // ==========================================================
//    // Dynamic ID helpers
//    // ==========================================================
//    private fun idByName(name: String): Int = resources.getIdentifier(name, "id", packageName)
//
//    private fun findFirstView(root: View, vararg names: String): View? {
//        for (n in names) {
//            val id = idByName(n)
//            if (id != 0) return root.findViewById(id)
//        }
//        return null
//    }
//
//    // ==========================================================
//    // ✅ FORCE 18dp ICON (works for PNG also)
//    // ==========================================================
//    private fun setButtonIcon18dp(v: View?, drawableRes: Int) {
//        val tv = v as? TextView ?: return
//        val d = ContextCompat.getDrawable(this, drawableRes) ?: return
//        val px = (18f * resources.displayMetrics.density).toInt().coerceAtLeast(1)
//        d.setBounds(0, 0, px, px)
//        tv.setCompoundDrawablesRelative(d, null, null, null)
//        tv.compoundDrawablePadding = (8f * resources.displayMetrics.density).toInt()
//    }
//
//    // ==========================================================
//    // Overlay UI (CACHE FIRST)
//    // ==========================================================
//    private fun showOverlay(phone: String, contactName: String, preferCache: Boolean) {
//        removeOverlay()
//
//        val inflater = getSystemService(LAYOUT_INFLATER_SERVICE) as LayoutInflater
//        val v = inflater.inflate(R.layout.tringo_overlay, null)
//        overlayView = v
//
//        val rootFull = v.findViewById<View>(R.id.overlayRootFull)
//        val rootCard = v.findViewById<View>(R.id.rootCard)
//        val closeBtn = v.findViewById<View>(R.id.closeBtn)
//
//        val callBtn = findFirstView(v, "callBtn", "btnCall", "callIcon", "ivCall", "imgCall", "call_button")
//        val chatBtn = findFirstView(v, "chatBtn", "btnChat", "chatIcon", "ivChat", "imgChat", "whatsappBtn", "btnWhatsapp", "whatsappIcon")
//
//        // ✅ YOUR REAL drawable names (match XML)
//        setButtonIcon18dp(callBtn, R.drawable.ic_call_png)
//        setButtonIcon18dp(chatBtn, R.drawable.ic_whatsapp_png)
//
//        val outsideLayer = v.findViewById<View>(R.id.outsideCloseLayer)
//        outsideLayer?.visibility = View.GONE
//
//        val headerBusiness = v.findViewById<View>(R.id.headerBusiness)
//        val headerPerson = v.findViewById<View>(R.id.headerPerson)
//
//        val businessTv = v.findViewById<TextView>(R.id.businessNameText)
//        val personTv = v.findViewById<TextView>(R.id.personNameText)
//        val metaTv = v.findViewById<TextView>(R.id.metaText)
//        val smallTop = v.findViewById<TextView>(R.id.smallTopText)
//
//        val logoBiz = v.findViewById<ImageView>(R.id.logoImageBusiness)
//        val logoPerson = v.findViewById<ImageView>(R.id.logoImagePerson)
//
//        val divider = v.findViewById<View>(R.id.dividerLine)
//        val adsTitleTv = v.findViewById<TextView>(R.id.adsTitle)
//        val recycler = v.findViewById<RecyclerView>(R.id.adsRecycler)
//
//        recycler.layoutManager = LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false)
//        adsAdapter = OverlayAdsAdapter()
//        recycler.adapter = adsAdapter
//
//        smallTop.text = if (postCallPopupMode) "Tringo Call Ended" else "Tringo Identifies"
//
//        closeBtn?.setOnClickListener {
//            markUserClosedDuringCall(pendingPhone)
//            removeOverlay()
//        }
//
//        callBtn?.setOnClickListener {
//            val num = (cachePhone ?: pendingPhone).trim()
//            if (num.isNotBlank() && !num.equals("UNKNOWN", true)) dialNumber(num)
//        }
//
//        chatBtn?.setOnClickListener {
//            val num = (cachePhone ?: pendingPhone).trim()
//            if (num.isNotBlank() && !num.equals("UNKNOWN", true)) openWhatsAppChat(num)
//        }
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
//        }
//
//        try {
//            windowManager?.addView(v, params)
//        } catch (e: Exception) {
//            showCallerHeadsUp("Tringo Caller ID", if (contactName.isNotBlank()) contactName else phone, "addView_failed")
//            stopSelf()
//            return
//        }
//
//        // default
//        headerBusiness.visibility = View.GONE
//        headerPerson.visibility = View.VISIBLE
//        personTv.text = if (contactName.isNotBlank()) contactName else phone
//        businessTv.text = ""
//        metaTv.text = ""
//
//        fun applyAdsVisibilityNow() {
//            val allowAds = postCallPopupMode
//            val hasAds = cacheAdsCards.isNotEmpty()
//            if (allowAds && hasAds) {
//                divider.visibility = View.VISIBLE
//                adsTitleTv.text = cacheAdsTitle
//                adsTitleTv.visibility = View.VISIBLE
//                recycler.visibility = View.VISIBLE
//            } else {
//                divider.visibility = View.GONE
//                adsTitleTv.visibility = View.GONE
//                recycler.visibility = View.GONE
//            }
//        }
//
//        divider.visibility = View.GONE
//        adsTitleTv.visibility = View.GONE
//        recycler.visibility = View.GONE
//
//        if (preferCache && isCacheValidFor(phone)) {
//            applyCacheToUi(headerBusiness, headerPerson, businessTv, personTv, metaTv, logoBiz, logoPerson)
//            adsAdapter?.submitList(cacheAdsCards)
//            applyAdsVisibilityNow()
//            return
//        }
//
//        serviceScope.launch {
//            try {
//                val res = withContext(Dispatchers.IO) { ApiClient.api.phoneInfo(phone) }
//
//                val dataAny = tryRead(res, "data")
//                val typeStr = (readAny(dataAny, "type") as? String).orEmpty()
//                val cardAny = readAny(dataAny, "card")
//
//                val cardTitle = (readAny(cardAny, "title") as? String)?.trim().orEmpty()
//                val cardSubtitle = (readAny(cardAny, "subtitle") as? String)?.trim().orEmpty()
//                val cardImageUrl = (readAny(cardAny, "imageUrl") as? String)?.trim().orEmpty()
//
//                val detailsAny = readAny(cardAny, "details")
//                val cat = (readAny(detailsAny, "category") as? String)?.trim().orEmpty()
//                val opensAt = (readAny(detailsAny, "opensAt") as? String)?.trim().orEmpty()
//                val closesAt = (readAny(detailsAny, "closesAt") as? String)?.trim().orEmpty()
//                val addr = (readAny(detailsAny, "address") as? String)?.trim().orEmpty()
//
//                val isShop = typeStr.equals("OWNER_SHOP", true)
//
//                val subtitleLine = listOfNotNull(
//                    (if (cat.isNotBlank()) cat else null) ?: cardSubtitle.takeIf { it.isNotBlank() },
//                    if (opensAt.isNotBlank() && closesAt.isNotBlank()) "$opensAt - $closesAt" else null,
//                    addr.takeIf { it.isNotBlank() }
//                ).joinToString(" • ")
//
//                val adsAny = readAny(dataAny, "advertisements")
//                val adsTitle = (readAny(adsAny, "title") as? String)?.trim().takeUnless { it.isNullOrBlank() } ?: "Advertisements"
//                val listAny = readAny(adsAny, "items") as? List<*>
//                val rawItems: List<Any> = listAny?.mapNotNull { it as? Any } ?: emptyList()
//
//                val cards = rawItems.mapIndexed { idx, item ->
//                    OverlayAdCard(
//                        id = pickString(item, "id", "_id") ?: "ad_$idx",
//                        title = pickString(item, "englishName", "title", "name") ?: "Ad ${idx + 1}",
//                        subtitle = buildAdSubtitle(item),
//                        rating = pickDouble(item, "rating", "avgRating"),
//                        ratingCount = pickInt(item, "ratingCount", "totalRatings"),
//                        openText = pickString(item, "openLabel", "openText"),
//                        isTrusted = pickBool(item, "isTrusted", "trusted") ?: false,
//                        imageUrl = pickString(item, "primaryImageUrl", "imageUrl") ?: ""
//                    )
//                }
//
//                saveCache(
//                    phone = phone,
//                    isShop = isShop,
//                    title = cardTitle.ifBlank { if (contactName.isNotBlank()) contactName else phone },
//                    subtitleLine = subtitleLine,
//                    imageUrl = cardImageUrl,
//                    adsTitle = adsTitle,
//                    adsCards = cards
//                )
//
//                applyCacheToUi(headerBusiness, headerPerson, businessTv, personTv, metaTv, logoBiz, logoPerson)
//                adsAdapter?.submitList(cacheAdsCards)
//                applyAdsVisibilityNow()
//
//            } catch (e: Exception) {
//                Log.e("TRINGO_API", "API failed: ${e.message}", e)
//            }
//        }
//    }
//
//    private fun buildAdSubtitle(item: Any?): String {
//        val addr = pickString(item, "addressEn", "addressTa") ?: ""
//        val city = pickString(item, "city") ?: ""
//        val state = pickString(item, "state") ?: ""
//        val country = pickString(item, "country") ?: ""
//        val place = listOf(city, state, country).filter { it.isNotBlank() }.joinToString(", ")
//        return listOf(addr, place).filter { it.isNotBlank() }.joinToString(" • ")
//    }
//
//    private fun applyCacheToUi(
//        headerBusiness: View?, headerPerson: View?,
//        businessTv: TextView?, personTv: TextView?, metaTv: TextView?,
//        logoBiz: ImageView?, logoPerson: ImageView?
//    ) {
//        if (cacheIsShop) {
//            headerBusiness?.visibility = View.VISIBLE
//            headerPerson?.visibility = View.GONE
//            businessTv?.text = cacheTitle
//            metaTv?.text = cacheSubtitleLine
//            logoBiz?.load(cacheImageUrl) {
//                crossfade(true)
//                placeholder(android.R.drawable.ic_menu_gallery)
//                error(android.R.drawable.ic_menu_gallery)
//            }
//        } else {
//            headerBusiness?.visibility = View.GONE
//            headerPerson?.visibility = View.VISIBLE
//            personTv?.text = cacheTitle
//            metaTv?.text = cacheSubtitleLine
//            logoPerson?.load(cacheImageUrl) {
//                crossfade(true)
//                placeholder(android.R.drawable.ic_menu_gallery)
//                error(android.R.drawable.ic_menu_gallery)
//            }
//        }
//    }
//
//    private fun removeOverlay() {
//        overlayView?.let { try { windowManager?.removeView(it) } catch (_: Exception) {} }
//        overlayView = null
//    }
//
//    override fun onDestroy() {
//        isRunning = false
//        incomingAutoHideJob?.cancel()
//        incomingAutoHideJob = null
//        stopWatchingForCallEnd()
//        serviceJob.cancel()
//        removeOverlay()
//        super.onDestroy()
//    }
//
//    override fun onBind(intent: Intent?): IBinder? = null
//
//    private fun showCallerHeadsUp(title: String, message: String, reason: String) {
//        if (!NotificationManagerCompat.from(this).areNotificationsEnabled()) return
//
//        val channelId = "tringo_call_alert"
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            val nm = getSystemService(NotificationManager::class.java)
//            nm.createNotificationChannel(
//                NotificationChannel(channelId, "Tringo Call Alerts", NotificationManager.IMPORTANCE_HIGH)
//            )
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
//        Log.d(TAG, "HeadsUp shown reason=$reason")
//    }
//
//    private fun openAppSettings() {
//        try {
//            val i = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
//                data = Uri.parse("package:$packageName")
//                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//            }
//            startActivity(i)
//        } catch (_: Exception) {}
//    }
//
//    private fun normalizePhoneForDial(raw: String): String {
//        return raw.trim().replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
//    }
//
//    private fun normalizePhoneForWhatsApp(raw: String): String {
//        var p = raw.trim().replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
//        if (p.startsWith("+")) p = p.substring(1)
//        return p
//    }
//
//    private fun dialNumber(phone: String) {
//        try {
//            val p = normalizePhoneForDial(phone)
//            val i = Intent(Intent.ACTION_DIAL).apply {
//                data = Uri.parse("tel:$p")
//                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//            }
//            startActivity(i)
//        } catch (e: Exception) {
//            Log.e(TAG, "dialNumber failed: ${e.message}", e)
//        }
//    }
//
//    private fun openWhatsAppChat(phone: String) {
//        try {
//            val p = normalizePhoneForWhatsApp(phone)
//            if (p.isBlank()) return
//
//            val url = "https://wa.me/$p"
//            val i = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
//                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//            }
//
//            try {
//                @Suppress("DEPRECATION")
//                packageManager.getPackageInfo("com.whatsapp", 0)
//                i.setPackage("com.whatsapp")
//            } catch (_: Exception) {}
//
//            startActivity(i)
//        } catch (e: Exception) {
//            Log.e(TAG, "openWhatsAppChat failed: ${e.message}", e)
//        }
//    }
//
//    // Reflection helpers
//    private fun tryRead(obj: Any?, field: String): Any? {
//        if (obj == null) return null
//        return try {
//            val m = obj::class.java.methods.firstOrNull {
//                it.name == "get${field.replaceFirstChar { c -> c.uppercase() }}"
//            }
//            if (m != null) m.invoke(obj) else readAny(obj, field)
//        } catch (_: Exception) {
//            readAny(obj, field)
//        }
//    }
//
//    private fun readAny(obj: Any?, name: String): Any? {
//        if (obj == null) return null
//        return try {
//            val f = obj::class.java.declaredFields.firstOrNull { it.name == name }
//            if (f != null) {
//                f.isAccessible = true
//                f.get(obj)
//            } else {
//                val m = obj::class.java.methods.firstOrNull {
//                    it.parameterTypes.isEmpty() && (it.name.equals(name, true) ||
//                            it.name.equals("get${name.replaceFirstChar { c -> c.uppercase() }}", true))
//                }
//                m?.invoke(obj)
//            }
//        } catch (_: Exception) {
//            null
//        }
//    }
//
//    private fun pickString(obj: Any?, vararg keys: String): String? {
//        for (k in keys) {
//            val v = readAny(obj, k)
//            if (v is String && v.trim().isNotEmpty()) return v.trim()
//        }
//        return null
//    }
//
//    private fun pickDouble(obj: Any?, vararg keys: String): Double? {
//        for (k in keys) {
//            val v = readAny(obj, k)
//            when (v) {
//                is Double -> return v
//                is Float -> return v.toDouble()
//                is Int -> return v.toDouble()
//                is Long -> return v.toDouble()
//                is String -> v.toDoubleOrNull()?.let { return it }
//            }
//        }
//        return null
//    }
//
//    private fun pickInt(obj: Any?, vararg keys: String): Int? {
//        for (k in keys) {
//            val v = readAny(obj, k)
//            when (v) {
//                is Int -> return v
//                is Long -> return v.toInt()
//                is Double -> return v.toInt()
//                is Float -> return v.toInt()
//                is String -> v.toIntOrNull()?.let { return it }
//            }
//        }
//        return null
//    }
//
//    private fun pickBool(obj: Any?, vararg keys: String): Boolean? {
//        for (k in keys) {
//            val v = readAny(obj, k)
//            when (v) {
//                is Boolean -> return v
//                is String -> {
//                    val s = v.trim().lowercase()
//                    if (s == "true" || s == "1" || s == "yes") return true
//                    if (s == "false" || s == "0" || s == "no") return false
//                }
//                is Int -> return v != 0
//                is Long -> return v != 0L
//            }
//        }
//        return null
//    }
//}
//
