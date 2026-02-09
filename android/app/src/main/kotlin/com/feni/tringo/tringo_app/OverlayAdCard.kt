package com.feni.tringo.tringo_app

data class OverlayAdCard(
    val id: String,
    val shopId: String = "",
    val title: String,
    val subtitle: String = "",
    val rating: Double? = null,
    val ratingCount: Int? = null,
    val openText: String? = null,
    val isTrusted: Boolean = false,
    val imageUrl: String? = null,
    val phone: String? = null
)
