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

            adImage.load(item.imageUrl) {
                crossfade(true)
                placeholder(android.R.drawable.ic_menu_gallery)
                error(android.R.drawable.ic_menu_gallery)
            }

            trustedBadge?.visibility = if (item.isTrusted) View.VISIBLE else View.GONE

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

            adOpenText?.text = item.openText ?: ""

            itemView.setOnClickListener { onClick?.invoke(item) }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        val v = LayoutInflater.from(parent.context).inflate(R.layout.item_ad, parent, false)
        return VH(v)
    }

    override fun onBindViewHolder(holder: VH, position: Int) {
        holder.bind(getItem(position))
    }
}
