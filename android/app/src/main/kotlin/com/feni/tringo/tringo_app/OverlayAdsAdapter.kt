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

class OverlayAdsAdapter(
    private val onClick: ((OverlayAdCard) -> Unit)? = null
) : ListAdapter<OverlayAdCard, OverlayAdsAdapter.VH>(DIFF) {

    companion object {
        private val DIFF = object : DiffUtil.ItemCallback<OverlayAdCard>() {
            override fun areItemsTheSame(oldItem: OverlayAdCard, newItem: OverlayAdCard) =
                oldItem.id == newItem.id

            override fun areContentsTheSame(oldItem: OverlayAdCard, newItem: OverlayAdCard) =
                oldItem == newItem
        }
    }

    inner class VH(v: View) : RecyclerView.ViewHolder(v) {
        private val adImage: ImageView = v.findViewById(R.id.adImage)
        private val trustedBadge: TextView? = v.findViewById(R.id.trustedBadge)
        private val adTitle: TextView = v.findViewById(R.id.adTitle)
        private val adSubtitle: TextView = v.findViewById(R.id.adSubtitle)
        private val adRating: TextView? = v.findViewById(R.id.adRating)
        private val adOpenText: TextView? = v.findViewById(R.id.adOpenText)

        fun bind(item: OverlayAdCard) {
            adTitle.text = item.title
            adSubtitle.text = item.subtitle

            // image
            adImage.load(item.imageUrl) {
                crossfade(true)
                placeholder(android.R.drawable.ic_menu_gallery)
                error(android.R.drawable.ic_menu_gallery)
            }

            // trusted
            trustedBadge?.visibility = if (item.isTrusted) View.VISIBLE else View.GONE

            // rating chip (optional)
            if (adRating != null) {
                val r = item.rating
                val c = item.ratingCount
                if (r != null && c != null && c > 0) {
                    adRating.visibility = View.VISIBLE
                    adRating.text = String.format("%.1f ★  %d", r, c)
                } else {
                    adRating.visibility = View.GONE
                }
            }

            // open text
            adOpenText?.text = item.openText ?: ""

            itemView.setOnClickListener {
                onClick?.invoke(item)
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        // ✅ FIX: item_ad_card இல்ல -> item_ad பயன்படுத்தணும்
        val v = LayoutInflater.from(parent.context).inflate(R.layout.item_ad, parent, false)
        return VH(v)
    }

    override fun onBindViewHolder(holder: VH, position: Int) {
        holder.bind(getItem(position))
    }
}



//package com.feni.tringo.tringo_app
//
//import android.view.LayoutInflater
//import android.view.View
//import android.view.ViewGroup
//import android.widget.ImageView
//import android.widget.TextView
//import androidx.recyclerview.widget.DiffUtil
//import androidx.recyclerview.widget.ListAdapter
//import androidx.recyclerview.widget.RecyclerView
//import coil.load
//
//class OverlayAdsAdapter :
//    ListAdapter<OverlayAdCard, OverlayAdsAdapter.VH>(Diff) {
//
//    object Diff : DiffUtil.ItemCallback<OverlayAdCard>() {
//        override fun areItemsTheSame(old: OverlayAdCard, new: OverlayAdCard) = old.id == new.id
//        override fun areContentsTheSame(old: OverlayAdCard, new: OverlayAdCard) = old == new
//    }
//
//    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
//        val v = LayoutInflater.from(parent.context).inflate(R.layout.item_overlay_ad, parent, false)
//        return VH(v)
//    }
//
//    override fun onBindViewHolder(holder: VH, position: Int) {
//        holder.bind(getItem(position))
//    }
//
//    class VH(itemView: View) : RecyclerView.ViewHolder(itemView) {
//        private val adImage = itemView.findViewById<ImageView>(R.id.adImage)
//        private val trustedBadge = itemView.findViewById<View>(R.id.trustedBadge)
//        private val adTitle = itemView.findViewById<TextView>(R.id.adTitle)
//        private val adSubtitle = itemView.findViewById<TextView>(R.id.adSubtitle)
//        private val adRating = itemView.findViewById<TextView>(R.id.adRating)
//        private val adOpenText = itemView.findViewById<TextView>(R.id.adOpenText)
//
//        fun bind(m: OverlayAdCard) {
//            adTitle.text = m.title
//            adSubtitle.text = m.subtitle
//
//            trustedBadge.visibility = if (m.isTrusted) View.VISIBLE else View.GONE
//
//            val hasRating = (m.rating != null && m.rating!! > 0)
//            if (hasRating) {
//                val count = m.ratingCount ?: 0
//                adRating.visibility = View.VISIBLE
//                adRating.text = "${m.rating} ★  $count"
//            } else {
//                adRating.visibility = View.GONE
//            }
//
//            adOpenText.text = m.openText
//
//            // Image
//            adImage.load(m.imageUrl) {
//                crossfade(true)
//                placeholder(android.R.drawable.ic_menu_gallery)
//                error(android.R.drawable.ic_menu_gallery)
//            }
//        }
//    }
//}
