package com.feni.tringo.tringo_app

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import coil.load
import java.text.DecimalFormat
import java.util.Locale

class OverlayAdsAdapter(
    private val onClick: ((OverlayAdCard) -> Unit)? = null
) : ListAdapter<OverlayAdCard, OverlayAdsAdapter.VH>(DIFF) {

    companion object {
        private val VIEWS_FMT = DecimalFormat("#,###")

        private val DIFF = object : DiffUtil.ItemCallback<OverlayAdCard>() {
            override fun areItemsTheSame(oldItem: OverlayAdCard, newItem: OverlayAdCard) =
                oldItem.id == newItem.id

            override fun areContentsTheSame(oldItem: OverlayAdCard, newItem: OverlayAdCard) =
                oldItem == newItem
        }
    }

    inner class VH(v: View) : RecyclerView.ViewHolder(v) {
        private val nearLabel: TextView? = v.findViewById(R.id.adNearLabel)
        private val adImage: ImageView = v.findViewById(R.id.adImage)
        private val trustedBadge: ImageView? = v.findViewById(R.id.trustedBadge)
        private val adTitle: TextView = v.findViewById(R.id.adTitle)
        private val adSubtitle: TextView = v.findViewById(R.id.adSubtitle)

        private val adMetaRow: View? = v.findViewById(R.id.adMetaRow)
        private val adCityChip: TextView? = v.findViewById(R.id.adRating)
        private val adViewsBadge: TextView? = v.findViewById(R.id.adOpenText)

        private val adOfferBanner: View? = v.findViewById(R.id.adOfferBanner)
        private val adOfferTitle: TextView? = v.findViewById(R.id.adOfferTitle)
        private val adOfferSubtitle: TextView? = v.findViewById(R.id.adOfferSubtitle)

        private val adStatusText: TextView? = v.findViewById(R.id.adStatusText)
        private val adViewBtn: View? = v.findViewById(R.id.adViewBtn)
        private val adViewBtnText: TextView? = v.findViewById(R.id.adViewBtnText)

        fun bind(item: OverlayAdCard) {
            nearLabel?.visibility = if (bindingAdapterPosition == 0) View.VISIBLE else View.GONE
            adTitle.text = item.title

            // Subtitle rendering:
            // - Line 1: category
            // - Optional line 2: short locality (e.g. addressEn), not full city/state/country (shown in chip)
            val category = item.categoryLabel?.trim().orEmpty()
            val locality = item.locality?.trim().orEmpty()
            val subtitleText = buildString {
                if (category.isNotBlank()) append(category)
                if (locality.isNotBlank()) {
                    if (isNotEmpty()) append("\n")
                    append(locality)
                }
            }.trim()
            adSubtitle.text = subtitleText
            adSubtitle.visibility = if (subtitleText.isNotBlank()) View.VISIBLE else View.GONE

            adImage.load(item.imageUrl) {
                allowHardware(false)
                crossfade(true)
                placeholder(android.R.drawable.ic_menu_gallery)
                error(android.R.drawable.ic_menu_gallery)
            }

            trustedBadge?.visibility = if (item.isTrusted) View.VISIBLE else View.GONE

            // Offer card: show ONLY when API appOffer exists (mapped into offerTitle/offerSubtitle).
            val offerTitle = item.offerTitle?.trim().orEmpty()
            val offerSubtitle = item.offerSubtitle?.trim().orEmpty()
            val hasOffer = offerTitle.isNotBlank() || offerSubtitle.isNotBlank()

            val location = item.locationLabel?.trim().orEmpty()
            if (location.isNotBlank()) {
                adCityChip?.visibility = View.VISIBLE
                adCityChip?.text = location
            } else {
                adCityChip?.visibility = View.GONE
            }

            val viewsLabel = item.viewsLabel?.trim().orEmpty()
            val views = item.viewsCount
            if (viewsLabel.isNotBlank() || (views != null && views > 0)) {
                adViewsBadge?.visibility = View.VISIBLE
                adViewsBadge?.text =
                    if (viewsLabel.isNotBlank()) viewsLabel
                    else "${VIEWS_FMT.format((views ?: 0).toLong())} Views"
            } else {
                adViewsBadge?.visibility = View.GONE
            }

            adOfferBanner?.visibility = if (hasOffer) View.VISIBLE else View.GONE
            adOfferTitle?.visibility = if (offerTitle.isNotBlank()) View.VISIBLE else View.GONE
            adOfferTitle?.text = offerTitle
            adOfferSubtitle?.visibility = if (offerSubtitle.isNotBlank()) View.VISIBLE else View.GONE
            adOfferSubtitle?.text = offerSubtitle

            val hasCity = location.isNotBlank()
            adMetaRow?.visibility = if (hasCity || hasOffer) View.VISIBLE else View.GONE
            if (hasOffer) {
                val lp = adOfferBanner?.layoutParams as? ViewGroup.MarginLayoutParams
                if (lp != null) {
                    lp.marginStart = 0
                    adOfferBanner.layoutParams = lp
                }
            }

            // kept for future API fields
            adStatusText?.visibility = View.GONE

            val apiCta = item.ctaLabel?.trim().orEmpty()
            adViewBtnText?.text = when {
                apiCta.isBlank() -> "View Details"
                apiCta.contains("offer", ignoreCase = true) -> "View Details"
                else -> apiCta
            }

            adViewBtn?.setOnClickListener { onClick?.invoke(item) }
            itemView.setOnClickListener { onClick?.invoke(item) }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        val v = LayoutInflater.from(parent.context).inflate(R.layout.item_overlay_ad, parent, false)
        return VH(v)
    }

    override fun onBindViewHolder(holder: VH, position: Int) {
        holder.bind(getItem(position))
    }

    private fun splitOfferText(offerRaw: String, rating: Double?): Pair<String, String> {
        val raw = offerRaw.trim()
        if (raw.isNotBlank()) {
            val lines = raw.split("\n").map { it.trim() }.filter { it.isNotBlank() }
            if (lines.size >= 2) {
                return lines.first() to lines.drop(1).joinToString("\n")
            }

            val upper = raw.uppercase(Locale.getDefault())

            Regex("""\b\d{1,2}%\s*DISCOUNT\b""", setOf(RegexOption.IGNORE_CASE))
                .find(raw)
                ?.let { match ->
                    val title = match.value.trim().uppercase(Locale.getDefault())
                    val subtitle = raw.replace(match.value, "")
                        .trim()
                        .trimStart('-', ':')
                        .trim()
                    return title to subtitle
                }

            val idx = upper.indexOf(" ON ")
            if (idx > 0) {
                val title = raw.substring(0, idx).trim()
                val subtitle = raw.substring(idx + 1).trim() // keep leading "on"
                return title to subtitle
            }

            return "" to raw
        }

        val r = rating ?: return "" to ""
        if (r <= 0) return "" to ""
        return String.format(Locale.getDefault(), "%.1f ★ Rating", r) to ""
    }

    // Intentionally keep views label as full text (e.g. "1,416 Views") to match overlay reference.
}
