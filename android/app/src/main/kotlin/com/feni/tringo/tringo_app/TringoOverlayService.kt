package com.feni.tringo.tringo_app

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.role.RoleManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.content.res.ColorStateList
import android.graphics.RenderEffect
import android.graphics.Shader
import android.graphics.PixelFormat
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.provider.ContactsContract
import android.provider.Settings
import android.telephony.TelephonyCallback
import android.telephony.TelephonyManager
import android.util.Log
import android.graphics.Rect
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewTreeObserver
import android.view.WindowManager
import android.view.inputmethod.InputMethodManager
import android.widget.ImageView
import android.widget.EditText
import android.widget.ProgressBar
import android.widget.TextView
import android.widget.Toast
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
import kotlinx.coroutines.isActive
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
import java.util.Locale

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
    private var adsCarouselAdapter: OverlayBusinessCarouselAdapter? = null

    private var pendingPhone: String = ""
    private var pendingContact: String = ""

    private var launchedByReceiver = false
    private var postCallPopupMode = false
    private var showOnlyAfterEnd = false
    private var outgoingOverlayMode = false

    private var telephonyManager: TelephonyManager? = null
    private var telephonyCallback: TelephonyCallback? = null

    @Suppress("DEPRECATION")
    private var phoneStateListener: android.telephony.PhoneStateListener? = null

    private var isWatchingCallEnd = false
    private var lastState: Int = TelephonyManager.CALL_STATE_IDLE

    private var endConfirmJob: Job? = null
    private var lastNonIdleAt: Long = 0L
    private var incomingAutoHideJob: Job? = null
    private var metaTickerJob: Job? = null
    private var metaReferenceAt: Long = 0L
    private var callEndedAt: Long = 0L
    private var currentCallerName: String = ""
    private var postCallFlowJob: Job? = null

    private var isEditSheetOpen: Boolean = false
    private var editSheetAnimToken: Int = 0
    private var postCallAutoDismissRemainingMs: Long? = null

    private fun isDebuggableApp(): Boolean {
        return try {
            (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
        } catch (_: Exception) {
            false
        }
    }

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
    private var lastOverlayPhone: String = ""

    private fun isUnknownPhone(phone: String): Boolean {
        val p = phone.trim()
        return p.isBlank() || p.equals("UNKNOWN", ignoreCase = true)
    }

    private fun readLastKnownPhone(): String {
        return try {
            getSharedPreferences(PREF, MODE_PRIVATE)
                .getString(KEY_LAST_NUMBER, "")
                ?.trim()
                .orEmpty()
        } catch (_: Throwable) {
            ""
        }
    }

    private var postCallShownOnce = false
    private val INCOMING_SHOW_MS = 10_000L
    private val POST_CALL_SHOW_MS = 15_000L
    private val IDLE_CONFIRM_MS = 650L

    // ==========================================================
    // ✅ CACHE (API only once)
    // ==========================================================
    private val CACHE_VALID_MS = 90_000L
    private var cachePhone: String? = null
    private var cacheAt: Long = 0L

    private var cacheIsShop: Boolean = false
    private var cacheTitle: String = ""
    private var cacheCardSubtitle: String = ""
    private var cacheSubtitleLine: String = ""
    private var cacheImageUrl: String = ""
    private var cacheCanEditName: Boolean = false
    private var cacheShowEditIcon: Boolean = false
    private var cacheRequiresAuthToEdit: Boolean = true

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
        cardSubtitle: String,
        subtitleLine: String,
        imageUrl: String,
        canEditName: Boolean,
        showEditIcon: Boolean,
        requiresAuthToEdit: Boolean,
        adsTitle: String,
        adsCards: List<OverlayAdCard>
    ) {
        cachePhone = phone
        cacheAt = System.currentTimeMillis()
        cacheIsShop = isShop
        cacheTitle = title
        cacheCardSubtitle = cardSubtitle
        cacheSubtitleLine = subtitleLine
        cacheImageUrl = imageUrl
        cacheCanEditName = canEditName
        cacheShowEditIcon = showEditIcon
        cacheRequiresAuthToEdit = requiresAuthToEdit
        cacheAdsTitle = adsTitle
        cacheAdsCards = adsCards
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
            launchedByReceiver: Boolean = false,
            outgoingOverlay: Boolean = false
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
                putExtra("outgoingOverlay", outgoingOverlay)
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
        outgoingOverlayMode = intent?.getBooleanExtra("outgoingOverlay", false) ?: false

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
        // Normalize to a stable format for API and UI (prefer +91xxxxxxxxxx when possible).
        val normalizedIncoming = normalizePhoneForPhoneInfo(pendingPhone)
        if (normalizedIncoming.isNotBlank()) pendingPhone = normalizedIncoming

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
                Log.w(TAG, "showOnlyAfterEnd requested but callState=$callStateNow; will wait briefly for IDLE")
            }
        }

        // Cancel any incoming auto-hide job; post-call flow owns dismissal.
        incomingAutoHideJob?.cancel()
        incomingAutoHideJob = null

        if (!showOnlyAfterEnd) {
            // Incoming overlay: show immediately (caller-id). Post-call overlay will be triggered by receiver.
            Log.d(TAG, "incoming overlay showing phone=$pendingPhone")
            postCallPopupMode = false
            if (!suppressedForThisNumber) {
                safeShowOverlay(pendingPhone, pendingContact, preferCache = true)
                scheduleIncomingAutoHide()
            }
            startWatchingForCallEnd()
            return START_STICKY
        }

        // Post-call overlay: show immediately (receiver already filtered noisy states).
        Log.d(TAG, "postCall overlay showing phone=$pendingPhone")
        if (postCallPopupMode && overlayView != null) return START_STICKY

        postCallFlowJob?.cancel()
        postCallFlowJob = null
        endConfirmJob?.cancel()
        stopWatchingForCallEnd()
        removeOverlay()
        postCallShownOnce = true

        postCallFlowJob = serviceScope.launch {
            val startWaitAt = System.currentTimeMillis()
            while (safeCallState() != TelephonyManager.CALL_STATE_IDLE && isActive) {
                if (System.currentTimeMillis() - startWaitAt >= 1_500L) break
                delay(150)
            }
            if (safeCallState() != TelephonyManager.CALL_STATE_IDLE) {
                Log.w(TAG, "postCall start but device not idle after wait; abort")
                stopSelf()
                return@launch
            }

            callEndedAt = System.currentTimeMillis()
            postCallPopupMode = true
            lastOverlayShownAt = 0L
            showOverlay(pendingPhone, pendingContact, preferCache = true)
            startWatchingForCallEnd()

            delay(POST_CALL_SHOW_MS)
            while (isEditSheetOpen && isActive) delay(250)
            removeOverlay()
            postCallPopupMode = false
            clearUserClosedFlag()
            stopSelf()
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
                // Use phoneCall type ONLY when we are the default dialer; otherwise Android throws SecurityException.
                val isDialerRoleHeld = try {
                    val rm = getSystemService(RoleManager::class.java)
                    rm != null && rm.isRoleHeld(RoleManager.ROLE_DIALER)
                } catch (_: Throwable) {
                    false
                }

                val fgsType =
                    if (isDialerRoleHeld) ServiceInfo.FOREGROUND_SERVICE_TYPE_PHONE_CALL
                    else ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC

                ServiceCompat.startForeground(this, 101, notif, fgsType)
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
        postCallFlowJob?.cancel()
        postCallFlowJob = null
        removeOverlay()

        incomingAutoHideJob?.cancel()
        incomingAutoHideJob = null

        postCallPopupMode = false
        clearUserClosedFlag()
        stopSelf()
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

        // OEMs sometimes emit transient IDLE while the phone is still RINGING.
        // Track the last time we saw a non-idle state and only treat IDLE as "ended"
        // if it stays stable for a short window.
        if (state != TelephonyManager.CALL_STATE_IDLE) {
            lastNonIdleAt = now
            endConfirmJob?.cancel()
            endConfirmJob = null
        }

        if (postCallPopupMode) {
            // If a new call starts while the post-call popup is visible, close it immediately.
            if (state != TelephonyManager.CALL_STATE_IDLE) {
                try {
                    postCallFlowJob?.cancel()
                    postCallFlowJob = null
                } catch (_: Exception) {}
                postCallPopupMode = false
                removeOverlay()
                stopSelf()
            }
            return
        }

        // Incoming overlay mode:
        // - If user answers (OFFHOOK) -> hide overlay
        // - If call ends/rejected (IDLE) -> hide overlay after confirming stable IDLE
        //   (post-call overlay will be started by receiver)
        if (!showOnlyAfterEnd) {
            when (state) {
                TelephonyManager.CALL_STATE_OFFHOOK -> {
                    if (outgoingOverlayMode) return
                    incomingAutoHideJob?.cancel()
                    incomingAutoHideJob = null
                    endConfirmJob?.cancel()
                    endConfirmJob = null
                    removeOverlay()
                    stopSelf()
                }
                TelephonyManager.CALL_STATE_IDLE -> {
                    if (endConfirmJob != null) return

                    endConfirmJob = serviceScope.launch {
                        delay(IDLE_CONFIRM_MS)
                        endConfirmJob = null

                        val stillIdle = safeCallState() == TelephonyManager.CALL_STATE_IDLE
                        val idleFor = System.currentTimeMillis() - lastNonIdleAt
                        if (!stillIdle || idleFor < IDLE_CONFIRM_MS) return@launch

                        incomingAutoHideJob?.cancel()
                        incomingAutoHideJob = null
                        removeOverlay()
                        stopSelf()
                    }
                }
            }
        }
    }

    private fun scheduleIncomingAutoHide() {
        incomingAutoHideJob?.cancel()
        incomingAutoHideJob = serviceScope.launch {
            delay(INCOMING_SHOW_MS)
            if (!postCallPopupMode && !showOnlyAfterEnd) {
                removeOverlay()
                stopSelf()
            }
        }
    }

    // ==========================================================
    // Overlay show (debounced)
    // ==========================================================
    private fun safeShowOverlay(phone: String, contactName: String, preferCache: Boolean) {
        val now = System.currentTimeMillis()
        val trimmed = phone.trim()
        val nowIsKnown = !isUnknownPhone(trimmed)
        val prevWasUnknown = isUnknownPhone(lastOverlayPhone)

        // Allow upgrading UNKNOWN -> real phone immediately (receiver may start before screening provides a number).
        if (!(nowIsKnown && prevWasUnknown)) {
            if (now - lastOverlayShownAt < OVERLAY_DEBOUNCE_MS) return
        }

        lastOverlayShownAt = now
        lastOverlayPhone = trimmed
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
            val rid = System.currentTimeMillis()
            val i = Intent(this, MainActivity::class.java).apply {
                putExtra("overlay_action", "open_shop_details")
                putExtra("shopId", shopId)
                putExtra("tab", tabIndex)
                putExtra("requestId", rid)
                try {
                    data = Uri.parse("tringo://overlay/open_shop_details?shopId=$shopId&tab=$tabIndex&rid=$rid")
                } catch (_: Exception) {}

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

        val nameRaw = contactName.trim()
        val hasName = nameRaw.isNotBlank()
        currentCallerName = if (hasName) nameRaw else ""
        val hasPhone = phone.isNotBlank() && !phone.equals("UNKNOWN", true)
        val formattedPhone = if (hasPhone) formatPhoneForDisplay(phone) else ""
        val showPhoneAsHeading = !hasName && hasPhone
        personTv?.text = if (hasName) nameRaw else if (showPhoneAsHeading) formattedPhone else "Unknown Number"
        personTv?.visibility = View.VISIBLE

        if (hasName && hasPhone) {
            personPhoneTv?.text = formattedPhone
            personPhoneTv?.visibility = View.VISIBLE
        } else {
            personPhoneTv?.visibility = View.GONE
        }

        personMetaTv?.text = buildDynamicMetaText()
        personBadgeTv?.text = "UNKNOWN CALLER"
        personBadgeTv?.visibility = if (hasName) View.GONE else View.VISIBLE

        try {
            logoPerson?.scaleType = ImageView.ScaleType.CENTER_INSIDE
            logoPerson?.imageTintList = ColorStateList.valueOf(0xFFEAF7FF.toInt())
            logoPerson?.setImageResource(R.drawable.ic_avatar_person)
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

        metaReferenceAt = if (postCallPopupMode && callEndedAt > 0L) callEndedAt else System.currentTimeMillis()

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
        val logoPerson = v.findViewById<ImageView>(R.id.logoImagePerson)
        val editIcon = v.findViewById<View>(R.id.personEditIcon)

        // Suggestion block (incoming)
        val suggestionCard = v.findViewById<View>(R.id.suggestionCard)
        val suggestionNameTv = v.findViewById<TextView>(R.id.suggestionNameText)
        val suggestionMetaTv = v.findViewById<TextView>(R.id.suggestionMetaText)
        val suggestedEditBtn = v.findViewById<View>(R.id.suggestedEditBtn)
        val confirmSaveBtnPerson = v.findViewById<View>(R.id.confirmSaveBtnPerson)

        // Premium edit sheet views
        val editSheetRoot = v.findViewById<View>(R.id.editSheetRoot)
        val editSheetScrim = v.findViewById<View>(R.id.editSheetScrim)
        val editSheetCard = v.findViewById<View>(R.id.editSheetCard)
        val editSheetSubtitle = v.findViewById<TextView>(R.id.editSheetSubtitle)
        val editSheetNameInput = v.findViewById<EditText>(R.id.editSheetNameInput)
        val editSheetError = v.findViewById<TextView>(R.id.editSheetError)
        val editSheetLoading = v.findViewById<ProgressBar>(R.id.editSheetLoading)
        val editSheetCancelBtn = v.findViewById<View>(R.id.editSheetCancelBtn)
        val editSheetSaveBtn = v.findViewById<View>(R.id.editSheetSaveBtn)
        val overlayContent = v.findViewById<View>(R.id.overlayContent)

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

        // Incoming overlay position: float slightly below center (not bottom, not perfectly centered).
        // Post-call overlay keeps the existing bottom placement.
        val belowCenterOffsetPx = (72f * resources.displayMetrics.density)
        try {
            val lp = rootCard?.layoutParams as? android.widget.FrameLayout.LayoutParams
            if (lp != null) {
                lp.gravity =
                    if (postCallPopupMode) (Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL)
                    else (Gravity.CENTER)
                rootCard.layoutParams = lp
            }
        } catch (_: Exception) {}

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
	            14f,
	            tintColor = 0xFF39E38C.toInt()
	        )
	        setButtonIconDp(
	            saveContactBtnPerson,
	            R.drawable.ic_person_add_outline,
	            14f,
	            tintColor = 0xFFFFFFFF.toInt()
	        )
	        setButtonIconDp(
	            chatBtnPerson,
	            R.drawable.ic_message_outline,
	            14f,
	            tintColor = 0xFFFFFFFF.toInt()
	        )

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
            val name = currentCallerName.trim()
            openAddContact(name = name, phone = num)
            if (name.isNotBlank()) syncSingleContactBestEffort(name = name, phone = num)
        }

        // Never show business call/whatsapp UI for this design
        headerBusiness?.visibility = View.GONE
        callBtnBusiness?.visibility = View.GONE
        chatBtnBusiness?.visibility = View.GONE
        callBtnPerson?.setOnClickListener(dialClick)
        saveContactBtnPerson?.setOnClickListener(saveContactClick)
        chatBtnPerson?.setOnClickListener(smsClick)

        // Incoming overlay: hide action row. Post-call overlay: show action row.
        val showPostCallActions = postCallPopupMode
        actionRowPerson?.visibility = if (showPostCallActions) View.VISIBLE else View.GONE
        callBtnPerson?.visibility = if (showPostCallActions) View.VISIBLE else View.GONE
        saveContactBtnPerson?.visibility = if (showPostCallActions) View.VISIBLE else View.GONE
        chatBtnPerson?.visibility = if (showPostCallActions) View.VISIBLE else View.GONE

        fun applyEditIconVisibility() {
            // Edit icon should be driven by API "editable" flag.
            // Default hidden until API/cache says editing is allowed.
            val phoneForEdit = (phone.takeIf { it.isNotBlank() } ?: pendingPhone).trim()
            val hasValidPhone = phoneForEdit.isNotBlank() && !phoneForEdit.equals("UNKNOWN", true)
            val allowEdit = hasValidPhone && cacheShowEditIcon
            editIcon?.visibility = if (allowEdit) View.VISIBLE else View.GONE
            suggestedEditBtn?.visibility = if (allowEdit) View.VISIBLE else View.GONE
        }

        applyEditIconVisibility()

        fun applySuggestionNow() {
            val suggestedNameNow = cacheTitle.trim()
            val showSuggestion =
                !postCallPopupMode && currentCallerName.isBlank() && suggestedNameNow.isNotBlank()
            suggestionCard?.visibility = if (showSuggestion) View.VISIBLE else View.GONE
            if (showSuggestion) {
                suggestionNameTv?.text = suggestedNameNow
                suggestionMetaTv?.text = "Suggested by Tringo users"
            }
        }

        applySuggestionNow()

        suggestedEditBtn?.setOnClickListener {
            val num = (cachePhone ?: pendingPhone).trim()
            if (num.isBlank() || num.equals("UNKNOWN", true)) return@setOnClickListener
            val suggestedNameNow = cacheTitle.trim()
            showPremiumEditSheet(
                root = editSheetRoot,
                scrim = editSheetScrim,
                card = editSheetCard,
                backgroundToBlur = overlayContent,
                subtitleTv = editSheetSubtitle,
                nameInput = editSheetNameInput,
                errorTv = editSheetError,
                loading = editSheetLoading,
                cancelBtn = editSheetCancelBtn,
                saveBtn = editSheetSaveBtn,
                initialName = suggestedNameNow.ifBlank { currentCallerName.trim() },
                phone = num
            ) { newName ->
                if (overlayView !== v) return@showPremiumEditSheet
                applyCallerNameToUi(
                    newName = newName,
                    personTv = personTv,
                    personBadgeTv = personBadgeTv,
                    personPhoneTv = personPhoneTv,
                    personAvatarBadge = personAvatarBadge
                )
            }
        }

        confirmSaveBtnPerson?.setOnClickListener {
            val num = (cachePhone ?: pendingPhone).trim()
            if (num.isBlank() || num.equals("UNKNOWN", true)) return@setOnClickListener
            val name = cacheTitle.trim()
            if (name.isBlank()) return@setOnClickListener
            applyCallerNameToUi(
                newName = name,
                personTv = personTv,
                personBadgeTv = personBadgeTv,
                personPhoneTv = personPhoneTv,
                personAvatarBadge = personAvatarBadge
            )
            openAddContact(name = name, phone = num)
            syncSingleContactBestEffort(name = name, phone = num)
            // Don't mark as "user closed" (we still want post-call overlay to show).
            removeOverlay()
        }

        editIcon?.setOnClickListener {
            val num = (cachePhone ?: pendingPhone).trim()
            if (num.isBlank() || num.equals("UNKNOWN", true)) return@setOnClickListener
            showPremiumEditSheet(
                root = editSheetRoot,
                scrim = editSheetScrim,
                card = editSheetCard,
                backgroundToBlur = overlayContent,
                subtitleTv = editSheetSubtitle,
                nameInput = editSheetNameInput,
                errorTv = editSheetError,
                loading = editSheetLoading,
                cancelBtn = editSheetCancelBtn,
                saveBtn = editSheetSaveBtn,
                initialName = currentCallerName.trim(),
                phone = num
            ) { newName ->
                if (overlayView !== v) return@showPremiumEditSheet
                applyCallerNameToUi(
                    newName = newName,
                    personTv = personTv,
                    personBadgeTv = personBadgeTv,
                    personPhoneTv = personPhoneTv,
                    personAvatarBadge = personAvatarBadge
                )
            }
        }

        // Ads
        val divider = v.findViewById<View>(R.id.dividerLine)
        val adsTitleTv = v.findViewById<TextView>(R.id.adsTitle)
        val recycler = v.findViewById<RecyclerView>(R.id.adsRecycler)

        recycler.layoutManager = LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false)
        try {
            recycler.isNestedScrollingEnabled = false
            recycler.overScrollMode = View.OVER_SCROLL_NEVER
        } catch (_: Exception) {}
        clampAdsRecyclerHeight(recycler)

        // ✅ click callback -> open flutter page
        val carouselAdapter = OverlayBusinessCarouselAdapter { ad ->
            val sid = ad.shopId.ifBlank { ad.id } // fallback
            if (isDebuggableApp()) {
                try { Log.d(TAG, "CTA click shopId=$sid title='${ad.title.take(60)}'") } catch (_: Exception) {}
            }
            openFlutterShopDetails(sid, tabIndex = 4)
        }
        recycler.adapter = carouselAdapter
        adsAdapter = null
        adsCarouselAdapter = carouselAdapter

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
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            softInputMode =
                WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE or
                    WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN
        }

        try {
            windowManager?.addView(v, params)
            Log.d(TAG, "addView ok postCall=$postCallPopupMode phone=$phone")
            try {
                val dy = 28f * resources.displayMetrics.density
                val baseOffset = if (postCallPopupMode) 0f else belowCenterOffsetPx
                rootCard?.alpha = 0f
                rootCard?.translationY = baseOffset + dy
                rootCard?.animate()?.alpha(1f)?.translationY(baseOffset)?.setDuration(180)?.start()
            } catch (_: Exception) {}
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
        val nameRaw = contactName.trim()
        val hasName = nameRaw.isNotBlank()
        currentCallerName = if (hasName) nameRaw else ""

        val hasPhone = phone.isNotBlank() && !phone.equals("UNKNOWN", true)
        val formattedPhone = if (hasPhone) formatPhoneForDisplay(phone) else ""
        // If we don't have a name yet, prefer an "Unknown Caller" placeholder (never show raw phone as title).
        personTv.text = if (hasName) nameRaw else if (hasPhone) "Unknown Caller" else "Unknown Number"
        personTv.visibility = View.VISIBLE

        if (!hasName && hasPhone) {
            personPhoneTv?.text = formattedPhone
            personPhoneTv?.visibility = View.VISIBLE
        } else if (hasName && hasPhone) {
            personPhoneTv?.text = formattedPhone
            personPhoneTv?.visibility = View.VISIBLE
        } else {
            personPhoneTv?.visibility = View.GONE
        }

        personMetaTv.text = buildDynamicMetaText()
        personBadgeTv?.text = "UNKNOWN CALLER"
        personBadgeTv?.visibility = if (hasName) View.GONE else View.VISIBLE
        applyDefaultCallerAvatar(logoPerson, personAvatarBadge, showBadge = !hasName)

        // ✅ ads default hidden (only show postCallPopupMode)
        divider.visibility = View.GONE
        adsTitleTv.visibility = View.GONE
        recycler.visibility = View.GONE

        fun applyAdsVisibilityNow() {
            val allowAds = postCallPopupMode
            val items = getCarouselItems()
            val hasAds = items.isNotEmpty()
            if (allowAds && hasAds) {
                divider.visibility = View.VISIBLE
                // Title pill is rendered inside the first ad card to match design.
                adsTitleTv.visibility = View.GONE
                recycler.visibility = View.VISIBLE
                adsCarouselAdapter?.submitList(items)
            } else {
                divider.visibility = View.GONE
                adsTitleTv.visibility = View.GONE
                recycler.visibility = View.GONE
            }
        }

        startMetaTicker(personMetaTv)
        applyAdsVisibilityNow()

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
            applyEditIconVisibility()
            applySuggestionNow()
            applyAdsVisibilityNow()
            return
        }

        // ✅ API fetch
        serviceScope.launch {
            try {
                var phoneForApi = phone.trim()
                phoneForApi = normalizePhoneForPhoneInfo(phoneForApi).ifBlank { phoneForApi }
                if (isUnknownPhone(phoneForApi) || phoneForApi.isBlank()) {
                    // Receiver may start the service before CallScreeningService writes the real number.
                    for (i in 0 until 6) {
                        val last = readLastKnownPhone()
                        val lastNorm = normalizePhoneForPhoneInfo(last).ifBlank { last.trim() }
                        if (!isUnknownPhone(lastNorm) && lastNorm.isNotBlank()) {
                            phoneForApi = lastNorm
                            break
                        }
                        delay(250)
                    }
                }

                val res = withContext(Dispatchers.IO) { ApiClient.api.phoneInfo(phoneForApi) }

                val dataAny = tryRead(res, "data")
                val typeStr = (readAny(dataAny, "type") as? String).orEmpty()
                val cardAny = readAny(dataAny, "card")

                val cardTitle = (readAny(cardAny, "title") as? String)?.trim().orEmpty()
                val cardSubtitle = (readAny(cardAny, "subtitle") as? String)?.trim().orEmpty()
                val cardImageUrl = (readAny(cardAny, "imageUrl") as? String)?.trim().orEmpty()

                val editableRaw = readAny(cardAny, "editable")
                val editableFlag: Boolean? = when (editableRaw) {
                    is Boolean -> editableRaw
                    is String -> {
                        val s = editableRaw.trim().lowercase()
                        when (s) {
                            "true", "1", "yes" -> true
                            "false", "0", "no" -> false
                            else -> null
                        }
                    }
                    is Int -> editableRaw != 0
                    is Long -> editableRaw != 0L
                    else -> null
                }

                val editableAny = editableRaw ?: readAny(cardAny, "actions")
                // Use API editable flag as the only source of truth.
                val canEditName = editableFlag ?: false
                val showEditIcon = editableFlag ?: false
                val requiresAuthToEdit = pickBool(editableAny, "requiresAuthToEdit") ?: true

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
                val adsTitle = (readAny(adsAny, "title") as? String)?.trim()
                    .takeUnless { it.isNullOrBlank() } ?: "Advertisements"

                val listAny = readAny(adsAny, "items") as? List<*>
                val rawItems: List<Any> = listAny?.mapNotNull { it as? Any } ?: emptyList()

                fun parseAppOffer(item: Any?): Triple<String, String, String>? {
                    val typed = item as? AdItem
                    val typedOffer = typed?.appOffer
                    if (typedOffer != null) {
                        val pct = typedOffer.discountPercentage
                        val finalTitle =
                            if (pct != null && pct > 0) "${pct}% DISCOUNT" else typedOffer.title?.trim().orEmpty()
                        val finalSubtitle = typedOffer.description?.trim().orEmpty()
                            .ifBlank { typedOffer.subtitle?.trim().orEmpty() }
                        val finalCta = typedOffer.ctaLabel?.trim().orEmpty()
                            .ifBlank { typedOffer.ctaText?.trim().orEmpty() }
                        if (finalTitle.isBlank() && finalSubtitle.isBlank() && finalCta.isBlank()) return null
                        return Triple(finalTitle, finalSubtitle, finalCta)
                    }

                    val offerAny = readAny(item, "appOffer") ?: return null
                    val pct = pickInt(offerAny, "discountPercentage", "discountPercent", "percentage")
                    val title = pickString(
                        offerAny,
                        "title",
                        "headline",
                        "offerTitle",
                        "discountTitle",
                        "discountText",
                        "primaryText"
                    )?.trim().orEmpty()
                    val subtitle = pickString(
                        offerAny,
                        "subtitle",
                        "subTitle",
                        "description",
                        "details",
                        "secondaryText"
                    )?.trim().orEmpty()
                    val cta = pickString(offerAny, "ctaLabel", "ctaText")?.trim().orEmpty()
                    val finalTitle =
                        if (pct != null && pct > 0) "${pct}% DISCOUNT" else title
                    val finalSubtitle = subtitle
                    if (finalTitle.isBlank() && finalSubtitle.isBlank() && cta.isBlank()) return null
                    return Triple(finalTitle, finalSubtitle, cta)
                }

                val cards = rawItems.mapIndexed { idx, item ->
                    val adId = pickString(item, "id", "_id") ?: "ad_$idx"
                    val shopId = pickString(item, "shopId") ?: adId // ✅ fallback to adId
                    val (offerTitle, offerSubtitle, offerCta) = parseAppOffer(item) ?: Triple("", "", "")
                    if (isDebuggableApp() && (offerTitle.isNotBlank() || offerSubtitle.isNotBlank())) {
                        try { Log.d(TAG, "ad[$idx] offer title='$offerTitle' subtitle='${offerSubtitle.take(120)}'") } catch (_: Exception) {}
                    }

                    val categoryLabel = prettyAdCategory(pickString(item, "category")?.trim().orEmpty())
                    val locationLabel = buildAdLocationLabel(item)
                    val locationParts = locationLabel.split(",").map { it.trim() }.filter { it.isNotBlank() }
                    val locality = pickAdLocality(
                        rawAddress = pickString(item, "addressEn", "addressTa")?.trim().orEmpty(),
                        locationParts = locationParts
                    )
                    val subtitleLine = listOf(categoryLabel, locality).filter { it.isNotBlank() }.joinToString(" • ")

                    OverlayAdCard(
                        id = adId,
                        shopId = shopId,
                        title = pickString(item, "englishName", "title", "name") ?: "Ad ${idx + 1}",
                        subtitle = subtitleLine,
                        categoryLabel = categoryLabel.takeIf { it.isNotBlank() },
                        locality = locality.takeIf { it.isNotBlank() },
                        locationLabel = locationLabel.takeIf { it.isNotBlank() },
                        rating = pickDouble(item, "rating", "avgRating"),
                        ratingCount = pickInt(item, "ratingCount", "totalRatings"),
                        viewsCount = pickInt(item, "viewsCount", "viewCount", "views", "totalViews", "totalViewCount"),
                        viewsLabel = pickString(item, "viewCountLabel", "viewsLabel")?.trim(),
                        offerTitle = offerTitle,
                        offerSubtitle = offerSubtitle,
                        ctaLabel = offerCta.trim().takeIf { it.isNotBlank() },
                        openText = pickString(item, "openLabel", "openText"),
                        isTrusted = pickBool(item, "isTrusted", "trusted") ?: false,
                        imageUrl = pickString(item, "primaryImageUrl", "imageUrl") ?: "",
                        phone = pickString(item, "primaryPhone", "phone")
                    )
                }

                saveCache(
                    phone = phoneForApi,
                    isShop = isShop,
                    title = cardTitle.ifBlank { contactName.trim() },
                    cardSubtitle = cardSubtitle,
                    subtitleLine = subtitleLine,
                    imageUrl = cardImageUrl,
                    canEditName = canEditName,
                    showEditIcon = showEditIcon,
                    requiresAuthToEdit = requiresAuthToEdit,
                    adsTitle = adsTitle,
                    adsCards = cards
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
                applyEditIconVisibility()
                applySuggestionNow()

                applyAdsVisibilityNow()

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

    private fun prettyAdCategory(raw: String): String {
        val t = raw.trim()
        if (t.isBlank()) return ""
        val noPrefix = t.removePrefix("shop-").removePrefix("shop_")
        val base = noPrefix.substringAfterLast('/').substringAfterLast(':')
        val words = base.split('-', '_').mapNotNull { w -> w.trim().takeIf { it.isNotBlank() } }
        if (words.isEmpty()) return ""
        val core = if (words.size >= 2 && words.first().equals("shop", true)) words.drop(1) else words
        return core.joinToString(" ") { w -> w.lowercase().replaceFirstChar { it.titlecase() } }
    }

    private fun buildAdLocationLabel(item: Any?): String {
        val city = pickString(item, "city")?.trim().orEmpty()
        val state = pickString(item, "state")?.trim().orEmpty()
        val country = pickString(item, "country")?.trim().orEmpty()
        return listOf(city, state, country).filter { it.isNotBlank() }.joinToString(", ")
    }

    private fun pickAdLocality(rawAddress: String, locationParts: List<String>): String {
        val addr = rawAddress.trim()
        if (addr.isBlank()) return ""
        val lower = addr.lowercase()
        if (addr.contains(",")) return ""
        if (locationParts.any { it.isNotBlank() && lower.contains(it.lowercase()) }) return ""
        return addr.takeIf { it.length <= 40 } ?: ""
    }

    private fun buildAdSubtitleClean(item: Any?): String {
        val categoryLabel = prettyAdCategory(pickString(item, "category")?.trim().orEmpty())
        val locationLabel = buildAdLocationLabel(item)
        val locationParts = locationLabel.split(",").map { it.trim() }.filter { it.isNotBlank() }
        val locality = pickAdLocality(
            rawAddress = pickString(item, "addressEn", "addressTa")?.trim().orEmpty(),
            locationParts = locationParts
        )
        return listOf(categoryLabel, locality).filter { it.isNotBlank() }.joinToString(" • ")
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
        val confirmed = currentCallerName.trim()
        val apiTitle = cacheTitle.trim()
        val isUnknownCaller = cacheCardSubtitle.trim().equals("Unknown Caller", ignoreCase = true)
        val resolvedName = if (isUnknownCaller) "" else confirmed.ifBlank { apiTitle }
        val hasResolvedName = resolvedName.isNotBlank()
        val nameFromApi = !isUnknownCaller && confirmed.isBlank() && apiTitle.isNotBlank()
        if (nameFromApi) currentCallerName = resolvedName

        val hasPhone = phone.isNotBlank() && !phone.equals("UNKNOWN", true)
        val formattedPhone = if (hasPhone) formatPhoneForDisplay(phone) else ""
        personTv?.text = when {
            isUnknownCaller -> "Unknown Caller"
            hasResolvedName -> resolvedName
            hasPhone -> "Unknown Caller"
            else -> "Unknown Number"
        }
        personTv?.visibility = View.VISIBLE

        // Phone secondary line:
        // - Always show for unknown caller
        // - Show for known names unless we intentionally suppress in shop-name case
        val showPhoneLine =
            (isUnknownCaller && hasPhone) ||
                (hasResolvedName && hasPhone && !(cacheIsShop && nameFromApi))
        if (showPhoneLine) {
            personPhoneTv?.text = formattedPhone
            personPhoneTv?.visibility = View.VISIBLE
        } else {
            personPhoneTv?.visibility = View.GONE
        }

        personMetaTv?.text = buildDynamicMetaText()
        personBadgeTv?.text = "UNKNOWN CALLER"
        personBadgeTv?.visibility = if (hasResolvedName && !isUnknownCaller) View.GONE else View.VISIBLE
        personAvatarBadge?.visibility = if (hasResolvedName && !isUnknownCaller) View.GONE else View.VISIBLE

        val hasPhoto = cacheImageUrl.isNotBlank()
        if (hasPhoto) {
            try {
                logoPerson?.scaleType = ImageView.ScaleType.CENTER_CROP
                logoPerson?.imageTintList = null
            } catch (_: Exception) {}
            logoPerson?.load(cacheImageUrl) {
                allowHardware(false)
                crossfade(true)
                placeholder(R.drawable.ic_avatar_person)
                error(R.drawable.ic_avatar_person)
                listener(
                    onError = { _, _ ->
                        val showBadge = !(hasResolvedName && !isUnknownCaller)
                        applyDefaultCallerAvatar(logoPerson, personAvatarBadge, showBadge)
                    },
                    onSuccess = { _, _ ->
                        personAvatarBadge?.visibility = View.GONE
                    }
                )
            }
            personAvatarBadge?.visibility = View.GONE
        } else {
            val showBadge = !(hasResolvedName && !isUnknownCaller)
            applyDefaultCallerAvatar(logoPerson, personAvatarBadge, showBadge)
        }
    }

    private fun removeOverlay() {
        metaTickerJob?.cancel()
        metaTickerJob = null
        overlayView?.let {
            try { windowManager?.removeView(it) } catch (_: Exception) {}
            Log.d(TAG, "removeOverlay()")
        }
        overlayView = null
    }

    private fun clampAdsRecyclerHeight(recycler: RecyclerView?) {
        if (recycler == null) return
        try {
            recycler.layoutParams = recycler.layoutParams.apply {
                height = android.view.ViewGroup.LayoutParams.WRAP_CONTENT
            }
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

    private fun buildDynamicMetaText(): String {
        val region = resolveRegionLabel()?.trim().orEmpty()
        val rel = formatRelativeTime(fromMs = metaReferenceAt, toMs = System.currentTimeMillis())
        return listOf(region, rel).filter { it.isNotBlank() }.joinToString(" • ")
    }

    private fun resolveRegionLabel(): String? {
        // Prefer device/network region; avoid hardcoded country strings.
        val iso = try {
            telephonyManager?.networkCountryIso?.trim().orEmpty()
        } catch (_: Throwable) {
            ""
        }

        val usableIso = iso.ifBlank {
            try {
                resources.configuration.locales[0]?.country?.trim().orEmpty()
            } catch (_: Throwable) {
                ""
            }
        }

        if (usableIso.isBlank()) return null
        return try {
            val region = usableIso.uppercase(Locale.ROOT)
            Locale.Builder().setRegion(region).build().displayCountry.takeIf { it.isNotBlank() }
        } catch (_: Throwable) {
            null
        }
    }

    private fun formatRelativeTime(fromMs: Long, toMs: Long): String {
        val base = if (fromMs > 0L) fromMs else toMs
        val deltaSec = ((toMs - base) / 1000L).coerceAtLeast(0L)
        if (deltaSec < 10) return "Just now"
        if (deltaSec < 60) return "${deltaSec}s ago"
        val deltaMin = deltaSec / 60L
        if (deltaMin < 60) return if (deltaMin == 1L) "1 min ago" else "$deltaMin min ago"
        val deltaHr = deltaMin / 60L
        if (deltaHr < 24) return if (deltaHr == 1L) "1 hr ago" else "$deltaHr hr ago"
        val deltaDay = deltaHr / 24L
        return if (deltaDay == 1L) "1 day ago" else "$deltaDay days ago"
    }

    private fun startMetaTicker(metaTv: TextView?) {
        metaTickerJob?.cancel()
        if (metaTv == null) return

        metaTickerJob = serviceScope.launch {
            while (overlayView != null && isActive) {
                try {
                    metaTv.text = buildDynamicMetaText()
                } catch (_: Exception) {}
                delay(10_000)
            }
        }
    }

    private fun applyCallerNameToUi(
        newName: String,
        personTv: TextView?,
        personBadgeTv: TextView?,
        personPhoneTv: TextView?,
        personAvatarBadge: View?
    ) {
        val n = newName.trim()
        if (n.isBlank()) return

        currentCallerName = n
        personTv?.text = n
        personBadgeTv?.visibility = View.GONE
        personAvatarBadge?.visibility = View.GONE

        // Keep phone as secondary (if already visible, don't change)
        personPhoneTv?.visibility = personPhoneTv?.visibility ?: View.VISIBLE

        if (!cacheIsShop) {
            val num = (cachePhone ?: pendingPhone).trim()
            if (num.isNotBlank() && !num.equals("UNKNOWN", true)) {
                cachePhone = num
            }
            cacheTitle = n
            cacheAt = System.currentTimeMillis()
        }
    }

    private fun showPremiumEditSheet(
        root: View?,
        scrim: View?,
        card: View?,
        backgroundToBlur: View?,
        subtitleTv: TextView?,
        nameInput: EditText?,
        errorTv: TextView?,
        loading: ProgressBar?,
        cancelBtn: View?,
        saveBtn: View?,
        initialName: String,
        phone: String,
        onSaved: (String) -> Unit
    ) {
        if (root == null || card == null) return
        val token = ++editSheetAnimToken

        // Prevent overlay auto-dismiss while the user is editing.
        isEditSheetOpen = true
        if (postCallPopupMode) {
            val now = System.currentTimeMillis()
            val remaining = (POST_CALL_SHOW_MS - (now - callEndedAt)).coerceAtLeast(2_000L)
            postCallAutoDismissRemainingMs = remaining
            postCallFlowJob?.cancel()
            postCallFlowJob = null
        }

        // Ensure taps don't dismiss the overlay behind the sheet.
        val outsideLayer = overlayView?.findViewById<View>(R.id.outsideCloseLayer)
        outsideLayer?.isClickable = false

        // Cancel any in-flight animations to avoid racey end-actions hiding the sheet.
        try { card.animate()?.cancel() } catch (_: Exception) {}
        try { scrim?.animate()?.cancel() } catch (_: Exception) {}

        fun setLoading(isLoading: Boolean) {
            loading?.visibility = if (isLoading) View.VISIBLE else View.GONE
            cancelBtn?.isEnabled = !isLoading
            saveBtn?.isEnabled = !isLoading
            nameInput?.isEnabled = !isLoading
            (saveBtn as? TextView)?.text = if (isLoading) "Saving..." else "Save"
        }

        fun hide() {
            if (token != editSheetAnimToken) return
            setBlur(backgroundToBlur, enabled = false)
            val listener = root.getTag(R.id.editSheetRoot) as? ViewTreeObserver.OnGlobalLayoutListener
            if (listener != null) {
                try {
                    if (root.viewTreeObserver.isAlive) root.viewTreeObserver.removeOnGlobalLayoutListener(listener)
                } catch (_: Exception) {}
                root.setTag(R.id.editSheetRoot, null)
            }

            card.animate().translationY(card.height.toFloat()).setDuration(160).withEndAction {
                if (token != editSheetAnimToken) return@withEndAction
                root.visibility = View.GONE
                isEditSheetOpen = false
                outsideLayer?.isClickable = true

                if (postCallPopupMode) {
                    val remaining = postCallAutoDismissRemainingMs ?: POST_CALL_SHOW_MS
                    postCallAutoDismissRemainingMs = null
                    postCallFlowJob?.cancel()
                    postCallFlowJob = serviceScope.launch {
                        delay(remaining)
                        while (isEditSheetOpen && isActive) delay(250)
                        removeOverlay()
                        postCallPopupMode = false
                        clearUserClosedFlag()
                        stopSelf()
                    }
                }
            }.start()
            scrim?.animate()?.alpha(0f)?.setDuration(160)?.start()
        }

        val wasAlreadyVisible = root.visibility == View.VISIBLE
        root.visibility = View.VISIBLE
        if (!wasAlreadyVisible) {
            scrim?.alpha = 0f
            card.translationY = 200f
        } else {
            scrim?.alpha = 1f
        }
        errorTv?.visibility = View.GONE
        errorTv?.setTextColor(0xFFFF6B6B.toInt())
        subtitleTv?.text = formatPhoneForDisplay(phone)
        if (!wasAlreadyVisible) {
            nameInput?.setText(initialName)
        }
        nameInput?.setSelection(nameInput?.text?.length ?: 0)
        setLoading(false)

        setBlur(backgroundToBlur, enabled = true)

        if (!wasAlreadyVisible) {
            scrim?.animate()?.alpha(1f)?.setDuration(180)?.start()
            card.animate().translationY(0f).setDuration(180).start()
        } else {
            card.animate().translationY(0f).setDuration(120).start()
        }

        scrim?.setOnClickListener { hide() }
        cancelBtn?.setOnClickListener { hide() }

        // Keyboard-safe: keep the sheet above the IME using a simple global layout heuristic.
        val layoutListener = ViewTreeObserver.OnGlobalLayoutListener {
            if (overlayView == null) return@OnGlobalLayoutListener
            if (root.visibility != View.VISIBLE) return@OnGlobalLayoutListener
            if (token != editSheetAnimToken) return@OnGlobalLayoutListener

            val r = Rect()
            try {
                root.getWindowVisibleDisplayFrame(r)
                val screenHeight = root.rootView.height
                val keyboardHeight = (screenHeight - r.bottom).coerceAtLeast(0)
                val keyboardVisible = keyboardHeight > (screenHeight * 0.15f)
                val targetY = if (keyboardVisible) -keyboardHeight.toFloat() else 0f
                if (card.translationY != targetY) {
                    card.animate().translationY(targetY).setDuration(120).start()
                }
            } catch (_: Exception) {}
        }
        try {
            root.viewTreeObserver.addOnGlobalLayoutListener(layoutListener)
            root.setTag(R.id.editSheetRoot, layoutListener)
        } catch (_: Exception) {}

        // Focus + show keyboard reliably.
        try {
            nameInput?.requestFocus()
            val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
            imm?.showSoftInput(nameInput, InputMethodManager.SHOW_IMPLICIT)
        } catch (_: Exception) {}

        saveBtn?.setOnClickListener {
            val newName = nameInput?.text?.toString()?.trim().orEmpty()
            if (newName.isBlank()) {
                errorTv?.text = "Name cannot be empty"
                errorTv?.visibility = View.VISIBLE
                return@setOnClickListener
            }

            setLoading(true)
            errorTv?.visibility = View.GONE

            serviceScope.launch {
                val result = syncEditedName(newName, phone)
                if (overlayView == null) return@launch
                if (result.isSuccess) {
                    onSaved(newName)
                    try {
                        errorTv?.setTextColor(0xFF39E38C.toInt())
                        errorTv?.text = "Saved"
                        errorTv?.visibility = View.VISIBLE
                        Toast.makeText(this@TringoOverlayService, "Saved", Toast.LENGTH_SHORT).show()
                    } catch (_: Exception) {}

                    setLoading(false)
                    delay(550)
                    hide()
                } else {
                    setLoading(false)
                    val err = result.exceptionOrNull()
                    if (err != null) {
                        Log.e(TAG, "Edit name save failed: ${err.message}", err)
                    } else {
                        Log.e(TAG, "Edit name save failed")
                    }
                    errorTv?.text = result.exceptionOrNull()?.message?.takeIf { it.isNotBlank() }
                        ?: "Failed to save"
                    errorTv?.visibility = View.VISIBLE
                }
            }
        }
    }

    private fun setBlur(target: View?, enabled: Boolean) {
        if (target == null) return
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return
        try {
            target.setRenderEffect(
                if (enabled) RenderEffect.createBlurEffect(22f, 22f, Shader.TileMode.CLAMP)
                else null
            )
        } catch (_: Exception) {}
    }

    private fun getCarouselItems(): List<OverlayAdCard> {
        return cacheAdsCards
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

    private fun normalizePhoneForPhoneInfo(raw: String): String {
        val t = raw.trim()
        if (t.isBlank() || t.equals("UNKNOWN", true)) return ""
        val digits = t.filter { it.isDigit() }
        return when {
            t.startsWith("+") && digits.length >= 10 -> "+$digits"
            digits.length == 10 -> "+91$digits"
            digits.length == 12 && digits.startsWith("91") -> "+$digits"
            digits.isNotBlank() -> digits
            else -> t
        }
    }

    private fun normalizePhoneForNameEdit(raw: String): String {
        val digits = raw.filter { it.isDigit() }
        return if (digits.length >= 10) digits.takeLast(10) else raw.trim()
    }

    private class HttpStatusException(val code: Int, message: String) : RuntimeException(message)

    private fun extractBackendErrorMessage(rawBody: String): String? {
        val body = rawBody.trim()
        if (body.isBlank()) return null
        if (body.startsWith("{") && body.endsWith("}")) {
            try {
                val o = JSONObject(body)
                val candidates = listOf("message", "error", "detail", "msg")
                for (k in candidates) {
                    val v = o.optString(k, "").trim()
                    if (v.isNotBlank()) return v
                }
            } catch (_: Exception) {}
        }
        return body.lineSequence().firstOrNull()?.trim()?.takeIf { it.isNotBlank() }
    }

    private fun friendlyNameEditError(code: Int, backendMsg: String?): String? {
        val k = backendMsg?.trim().orEmpty()
        return when {
            k.equals("PHONE_NAME_EDIT_NOT_ALLOWED", ignoreCase = true) ->
                "Name edit is not allowed for this number"
            k.equals("PHONE_NOT_FOUND", ignoreCase = true) ->
                "This number is not available to edit"
            k.equals("INVALID_PHONE", ignoreCase = true) ->
                "Invalid phone number"
            code == 429 ->
                "Too many requests. Try again shortly"
            else -> null
        }
    }

    private suspend fun submitPhoneInfoNameEdit(name: String, phone: String): Result<Unit> {
        return try {
            val token = getFlutterPref("token")?.trim().orEmpty()
            val sessionToken = getFlutterPref("sessionToken")?.trim().orEmpty()

            val payload = JSONObject().apply {
                put("phone", normalizePhoneForNameEdit(phone))
                put("name", name)
            }
            if (isDebuggableApp()) {
                try { Log.d(TAG, "submitPhoneInfoNameEdit body=$payload") } catch (_: Exception) {}
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
                    val respBody = try { res.body?.string().orEmpty() } catch (_: Exception) { "" }
                    val backendMsg = extractBackendErrorMessage(respBody)
                    if (res.code == 401 || res.code == 403) {
                        if (isDebuggableApp()) {
                            try {
                                Log.e(
                                    TAG,
                                    "submitPhoneInfoNameEdit http=${res.code} unauthorized body=${(backendMsg ?: respBody).take(900)}"
                                )
                            } catch (_: Exception) {}
                        } else {
                            Log.e(TAG, "submitPhoneInfoNameEdit http=${res.code} unauthorized")
                        }
                        throw IllegalStateException("Please login to save edits")
                    }
                    if (!res.isSuccessful) {
                        if (isDebuggableApp()) {
                            try { Log.e(TAG, "submitPhoneInfoNameEdit http=${res.code} body=${(backendMsg ?: respBody).take(900)}") } catch (_: Exception) {}
                        } else {
                            Log.e(TAG, "submitPhoneInfoNameEdit http=${res.code}")
                        }
                        val friendly = friendlyNameEditError(res.code, backendMsg)
                        val msg = friendly ?: buildString {
                            append("Name update failed (${res.code})")
                            if (!backendMsg.isNullOrBlank()) append(": ").append(backendMsg)
                        }
                        throw HttpStatusException(res.code, msg)
                    }
                    if (isDebuggableApp()) {
                        try { Log.d(TAG, "submitPhoneInfoNameEdit http=${res.code} resp=${respBody.take(900)}") } catch (_: Exception) {}
                    } else {
                        Log.d(TAG, "submitPhoneInfoNameEdit http=${res.code}")
                    }
                }
            }

            Result.success(Unit)
        } catch (e: Exception) {
            Log.e(TAG, "submitPhoneInfoNameEdit failed: ${e.message}", e)
            Result.failure(e)
        }
    }

    private suspend fun syncSingleContact(name: String, phone: String): Result<Unit> {
        return try {
            val token = getFlutterPref("token")?.trim().orEmpty()
            val sessionToken = getFlutterPref("sessionToken")?.trim().orEmpty()
            if (token.isBlank()) {
                return Result.failure(IllegalStateException("Please login to save edits"))
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
                    if (!res.isSuccessful) throw RuntimeException("Sync failed (${res.code})")
                    Log.d(TAG, "syncSingleContact http=${res.code}")
                }
            }

            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    private suspend fun syncEditedName(name: String, phone: String): Result<Unit> {
        val r = submitPhoneInfoNameEdit(name, phone)
        if (r.isSuccess) return r

        val e = r.exceptionOrNull()
        if (e is HttpStatusException && (e.code == 404 || e.code == 405)) {
            // Backward compatible fallback for older backends.
            return syncSingleContact(name, phone)
        }
        return r
    }

    private fun syncSingleContactBestEffort(name: String, phone: String) {
        serviceScope.launch {
            val r = syncSingleContact(name, phone)
            if (r.isFailure) Log.e(TAG, "syncSingleContact failed: ${r.exceptionOrNull()?.message}", r.exceptionOrNull())
        }
    }

    private fun normalizePhoneForDial(raw: String): String {
        return raw.trim().replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
    }

    private fun applyDefaultCallerAvatar(logo: ImageView?, badge: View?, showBadge: Boolean) {
        try {
            logo?.scaleType = ImageView.ScaleType.CENTER_INSIDE
            logo?.imageTintList = ColorStateList.valueOf(0xFFEAF7FF.toInt())
            logo?.setImageResource(R.drawable.ic_avatar_person)
        } catch (_: Exception) {}
        badge?.visibility = if (showBadge) View.VISIBLE else View.GONE
    }

    private fun normalizePhoneForWhatsApp(raw: String): String {
        var p = raw.trim().replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
        if (p.startsWith("+")) p = p.substring(1)
        return p
    }

    private fun dialNumber(phone: String) {
        try {
            val p = normalizePhoneForDial(phone)
            if (p.isNotBlank()) {
                try {
                    getSharedPreferences(PREF, MODE_PRIVATE).edit()
                        .putString(KEY_LAST_NUMBER, normalizePhoneForPhoneInfo(p).ifBlank { p })
                        .apply()
                } catch (_: Throwable) {}
            }
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
