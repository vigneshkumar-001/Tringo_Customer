package com.feni.tringo.tringo_app

data class OverlayAdCard(
    val id: String,
    val shopId: String = "",
    val title: String,
    val subtitle: String = "",
    val categoryLabel: String? = null,
    val locality: String? = null,
    val locationLabel: String? = null,
    val rating: Double? = null,
    val ratingCount: Int? = null,
    val viewsCount: Int? = null,
    val viewsLabel: String? = null,
    val offerTitle: String? = null,
    val offerSubtitle: String? = null,
    val ctaLabel: String? = null,
    val openText: String? = null,
    val isTrusted: Boolean = false,
    val imageUrl: String? = null,
    val phone: String? = null
)
