package com.feni.tringo.tringo_app

import androidx.annotation.Keep
import com.google.gson.annotations.SerializedName

@Keep
data class PhoneInfoResponse(
    @SerializedName("status") val status: Boolean? = null,
    @SerializedName("data") val data: PhoneInfoData? = null
)

@Keep
data class PhoneInfoData(
    @SerializedName("query") val query: String? = null,
    @SerializedName("type") val type: String? = null, // OWNER_SHOP, PERSON
    @SerializedName("card") val card: PhoneInfoCard? = null
)

@Keep
data class PhoneInfoCard(
    @SerializedName("title") val title: String? = null,
    @SerializedName("subtitle") val subtitle: String? = null,
    @SerializedName("phone") val phone: String? = null,
    @SerializedName("imageUrl") val imageUrl: String? = null,
    @SerializedName("details") val details: PhoneInfoDetails? = null,

    // some APIs send rating/reviewCount at card level
    @SerializedName("rating") val rating: Double? = null,
    @SerializedName("reviewCount") val reviewCount: Int? = null
)

@Keep
data class PhoneInfoDetails(
    @SerializedName("shopId") val shopId: String? = null,
    @SerializedName("rating") val rating: Double? = null,
    @SerializedName("reviewCount") val reviewCount: Int? = null,
    @SerializedName("category") val category: String? = null,
    @SerializedName("opensAt") val opensAt: String? = null,
    @SerializedName("closesAt") val closesAt: String? = null,
    @SerializedName("distanceKm") val distanceKm: Double? = null,
    @SerializedName("address") val address: String? = null
)



//package com.feni.tringo.tringo_app
//
//data class PhoneInfoResponse(
//    val status: Boolean?,
//    val data: PhoneInfoData?
//)
//
//data class PhoneInfoData(
//    val query: String?,
//    val type: String?, // OWNER_SHOP, PERSON
//    val card: PhoneInfoCard?
//)
//
//data class PhoneInfoCard(
//    val title: String?,     // Shop / Person name
//    val subtitle: String?,  // Category like "Electronics"
//    val phone: String?,
//    val imageUrl: String?,
//    val details: PhoneInfoDetails?,
//    val rating: Double? = null,
//    val reviewCount: Int? = null
//)
//
//data class PhoneInfoDetails(
//    val shopId: String?,
//    val rating: Double?,
//    val reviewCount: Int?,
//    val category: String?,
//    val opensAt: String?,
//    val closesAt: String?,
//    val distanceKm: Double?,
//    val address: String?
//)
