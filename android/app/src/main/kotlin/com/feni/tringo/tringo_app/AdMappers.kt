package com.feni.tringo.tringo_app

private fun String?.clean(): String = this?.trim().orEmpty()
private fun String?.nonEmptyOrNull(): String? = this?.trim()?.takeIf { it.isNotBlank() }

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

    return OverlayAdCard(
        id = id.clean(),
        title = finalTitle,
        subtitle = subtitle,
        rating = rating,
        ratingCount = ratingCount,
        openText = openLabel.clean(),
        isTrusted = isTrusted == true,
        imageUrl = primaryImageUrl.clean(),   // ✅ primaryImageUrl
        phone = primaryPhone.clean()
    )
}
