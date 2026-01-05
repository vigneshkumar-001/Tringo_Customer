//class TringoCallerPopupActivity : Activity() {
//
//    private val job = SupervisorJob()
//    private val scope = CoroutineScope(Dispatchers.Main + job)
//
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
//            setShowWhenLocked(true)
//            setTurnScreenOn(true)
//        } else {
//            window.addFlags(
//                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
//                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
//            )
//        }
//
//        setContentView(R.layout.tringo_popup_activity)
//
//        val phone = intent?.getStringExtra("phone").orEmpty()
//        val contactName = intent?.getStringExtra("contactName").orEmpty()
//
//        val titleTv = findViewById<TextView>(R.id.popupTitle)
//        val metaTv = findViewById<TextView>(R.id.popupMeta)
//        val logo = findViewById<ImageView>(R.id.popupLogo)
//        val ratingTv = findViewById<TextView>(R.id.popupRating)
//
//        titleTv.text = if (contactName.isNotBlank()) contactName else phone
//        metaTv.text = ""
//        ratingTv.text = ""
//
//        scope.launch {
//            try {
//                withTimeout(2500) {
//                    val res = withContext(Dispatchers.IO) { ApiClient.api.phoneInfo(phone) }
//                    val card = res.data?.card
//                    val details = card?.details
//
//                    if (res.status == true && card != null) {
//                        val title = card.title?.trim().takeUnless { it.isNullOrBlank() }
//                            ?: (if (contactName.isNotBlank()) contactName else phone)
//
//                        val r = (details?.rating ?: card.rating) ?: 0.0
//                        val rc = (details?.reviewCount ?: card.reviewCount) ?: 0
//
//                        titleTv.text = title
//
//                        metaTv.text = listOfNotNull(
//                            card.subtitle?.trim()?.takeUnless { it.isBlank() },
//                            details?.address?.trim()?.takeUnless { it.isBlank() }
//                        ).joinToString(" • ")
//
//                        ratingTv.text = if (r > 0.0 || rc > 0) "${String.format("%.1f", r)} ★  $rc" else ""
//
//                        logo.load(card.imageUrl) {
//                            crossfade(true)
//                            placeholder(android.R.drawable.ic_menu_gallery)
//                            error(android.R.drawable.ic_menu_gallery)
//                        }
//                    }
//                }
//            } catch (_: Exception) { }
//        }
//
//        // ✅ auto close
//        scope.launch {
//            delay(3500)
//            finish()
//        }
//    }
//
//    override fun onDestroy() {
//        job.cancel()
//        super.onDestroy()
//    }
//}
