package com.feni.tringo.tringo_app

import android.util.Log
import com.google.gson.GsonBuilder
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okhttp3.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.io.IOException
import java.util.concurrent.TimeUnit

object ApiClient {

    private const val BASE_URL = "https://bknd.tringobiz.com/"
    private const val TAG = "TRINGO_HTTP"

    private val rawBodyLogger: Interceptor = Interceptor { chain ->
        val req = chain.request()
        Log.d(TAG, "→ ${req.method} ${req.url}")

        val res: Response = chain.proceed(req)
        Log.d(TAG, "← ${res.code} ${res.request.url}")

        try {
            val peek = res.peekBody(1024 * 1024)
            val bodyStr = peek.string()
            Log.d(TAG, "BODY: ${if (bodyStr.isNotBlank()) bodyStr else "<empty>"}")
        } catch (e: Exception) {
            Log.e(TAG, "peekBody failed: ${e.message}")
        }

        res
    }

    // ✅ Retry only for temp network/proxy errors
    private val retryInterceptor = Interceptor { chain ->
        var res = chain.proceed(chain.request())

        val retryCodes = setOf(522, 524, 502, 503, 504)
        var tryCount = 0

        while (res.code in retryCodes && tryCount < 2) {
            tryCount++
            Log.w(TAG, "Retrying request due to HTTP ${res.code} (try $tryCount) ...")
            res.close()

            // small backoff
            try {
                Thread.sleep((600L * tryCount))
            } catch (_: Exception) {}

            res = chain.proceed(chain.request())
        }

        res
    }

    private val gson = GsonBuilder()
        .setLenient()
        .serializeNulls()
        .create()

    private val okHttp: OkHttpClient by lazy {
        OkHttpClient.Builder()
            // ✅ more generous timeouts (Cloudflare/origin delays)
            .connectTimeout(25, TimeUnit.SECONDS)
            .readTimeout(25, TimeUnit.SECONDS)
            .writeTimeout(25, TimeUnit.SECONDS)
            .callTimeout(30, TimeUnit.SECONDS)
            .retryOnConnectionFailure(true)
            .addInterceptor(retryInterceptor)
            .addInterceptor(rawBodyLogger)
            .build()
    }

    val api: TringoApi by lazy {
        Retrofit.Builder()
            .baseUrl(BASE_URL)
            .client(okHttp)
            .addConverterFactory(GsonConverterFactory.create(gson))
            .build()
            .create(TringoApi::class.java)
    }
}
