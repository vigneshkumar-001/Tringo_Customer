package com.feni.tringo.tringo_app

private fun String?.clean(): String = this?.trim().orEmpty()
private fun String?.nonEmptyOrNull(): String? = this?.trim()?.takeIf { it.isNotBlank() }

private fun prettyCategorySlug(raw: String): String {
    val t = raw.trim()
    if (t.isBlank()) return ""
    val noPrefix = t.removePrefix("shop-").removePrefix("shop_")
    val base = noPrefix.substringAfterLast('/').substringAfterLast(':')
    val words = base.split('-', '_').mapNotNull { w -> w.trim().takeIf { it.isNotBlank() } }
    if (words.isEmpty()) return ""
    val core = if (words.size >= 2 && words.first().equals("shop", true)) words.drop(1) else words
    return core.joinToString(" ") { w -> w.lowercase().replaceFirstChar { it.titlecase() } }
}

private fun pickLocality(rawAddress: String, locationParts: List<String>): String {
    val addr = rawAddress.trim()
    if (addr.isBlank()) return ""
    val lower = addr.lowercase()
    if (addr.contains(",")) return ""
    if (locationParts.any { it.isNotBlank() && lower.contains(it.lowercase()) }) return ""
    return addr.takeIf { it.length <= 40 } ?: ""
}

fun AdItem.toOverlayCard(preferTamil: Boolean = false): OverlayAdCard {
    val title = if (preferTamil) tamilName.clean() else englishName.clean()
    val finalTitle = title.ifBlank { englishName.clean().ifBlank { "Advertisement" } }

    val address = (if (preferTamil) addressTa.nonEmptyOrNull() else addressEn.nonEmptyOrNull())
        ?: listOf(city.nonEmptyOrNull(), state.nonEmptyOrNull(), country.nonEmptyOrNull())
            .filterNotNull()
            .joinToString(", ")
            .takeIf { it.isNotBlank() }
        ?: ""

    val dist = distanceLabel.clean()
    val subtitle = listOf(address, dist).filter { it.isNotBlank() }.joinToString(" • ")

    val categoryLabel = prettyCategorySlug(category.clean())
    val locationParts = listOf(city.clean(), state.clean(), country.clean()).filter { it.isNotBlank() }
    val locationLabel = locationParts.joinToString(", ")
    val locality = pickLocality(
        rawAddress = if (preferTamil) addressTa.clean() else addressEn.clean(),
        locationParts = locationParts
    )

    val subtitleLine = listOf(categoryLabel, locality).filter { it.isNotBlank() }.joinToString(" • ")

    val offer = appOffer
    val offerTitle = offer?.discountPercentage?.takeIf { it > 0 }?.let { "${it}% DISCOUNT" }
        ?: offer?.title.nonEmptyOrNull()
    val offerSubtitle = offer?.description.nonEmptyOrNull()
        ?: offer?.subtitle.nonEmptyOrNull()
    val ctaLabel = offer?.ctaLabel.nonEmptyOrNull() ?: offer?.ctaText.nonEmptyOrNull()

    return OverlayAdCard(
        id = id.clean(),
        title = finalTitle,
        subtitle = subtitleLine,
        categoryLabel = categoryLabel.takeIf { it.isNotBlank() },
        locality = locality.takeIf { it.isNotBlank() },
        locationLabel = locationLabel.takeIf { it.isNotBlank() },
        rating = rating,
        ratingCount = ratingCount,
        viewsCount = viewsCount,
        viewsLabel = viewCountLabel.nonEmptyOrNull(),
        offerTitle = offerTitle,
        offerSubtitle = offerSubtitle,
        ctaLabel = ctaLabel,
        openText = openLabel.clean(),
        isTrusted = isTrusted == true,
        imageUrl = primaryImageUrl.clean(),   // ✅ primaryImageUrl
        phone = primaryPhone.clean()
    )
}
