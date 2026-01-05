package com.feni.tringo.tringo_app

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import coil.load

class AdsAdapter(
    private var items: List<AdItem> = emptyList()
) : RecyclerView.Adapter<AdsAdapter.VH>() {

    fun submit(newItems: List<AdItem>) {
        items = newItems
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        val v = LayoutInflater.from(parent.context).inflate(R.layout.item_ad, parent, false)
        return VH(v)
    }

    override fun onBindViewHolder(holder: VH, position: Int) {
        holder.bind(items[position])
    }

    override fun getItemCount(): Int = items.size

    class VH(itemView: View) : RecyclerView.ViewHolder(itemView) {

        private val image = itemView.findViewById<ImageView>(R.id.adImage)
        private val badge = itemView.findViewById<TextView>(R.id.trustedBadge)

        private val title = itemView.findViewById<TextView>(R.id.adTitle)
        private val subtitle = itemView.findViewById<TextView>(R.id.adSubtitle)
        private val rating = itemView.findViewById<TextView>(R.id.adRating)
        private val openText = itemView.findViewById<TextView>(R.id.adOpenText)

        fun bind(item: AdItem) {
            title.text = item.title
            subtitle.text = item.subtitle.orEmpty()

            // ⭐ Rating
            val r = item.rating ?: 0.0
            rating.visibility = if (r > 0) View.VISIBLE else View.GONE
            if (r > 0) rating.text = "${String.format("%.1f", r)} ★"

            // 🕒 Open Text
            openText.visibility = if (!item.openText.isNullOrBlank()) View.VISIBLE else View.GONE
            openText.text = item.openText.orEmpty()

            // 🖼️ Image
            image.load(item.imageUrl) {
                crossfade(true)
                placeholder(android.R.drawable.ic_menu_gallery)
                error(android.R.drawable.ic_menu_gallery)
            }

            // ✅ Trusted badge (optional rule)
            // If you want always show:
            // badge.visibility = View.VISIBLE
            // If you want only for rating >= 4:
            badge.visibility = if (r >= 4.0) View.VISIBLE else View.GONE
        }
    }
}
