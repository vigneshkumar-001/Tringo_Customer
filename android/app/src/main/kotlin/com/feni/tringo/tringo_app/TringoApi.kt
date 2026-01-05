package com.feni.tringo.tringo_app

import retrofit2.http.GET
import retrofit2.http.Query

interface TringoApi {
    @GET("api/v1/public/phone-info")
    suspend fun phoneInfo(@Query("phone") phone: String): PhoneInfoResponse
}
