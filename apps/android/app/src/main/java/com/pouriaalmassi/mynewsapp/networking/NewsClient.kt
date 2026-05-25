package com.pouriaalmassi.mynewsapp.networking

import android.util.Log
import com.google.gson.*
import com.pouriaalmassi.mynewsapp.models.Article
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.lang.reflect.Type
import java.text.SimpleDateFormat
import java.util.*

class NewsClient(
    private val baseUrl: String = "http://10.0.2.2:3000/api/news/",
    private val apiKey: String = "474d4e4699444b8f84c3918deda22e2a"
) : NewsService {

    private val retrofitService: RetrofitNewsService

    init {
        // Logging Interceptor
        val loggingInterceptor = HttpLoggingInterceptor { message ->
            Log.d("NewsClient", message)
        }.apply {
            level = HttpLoggingInterceptor.Level.BODY
        }

        // Header Interceptor for Bearer token auth
        val headerInterceptor = Interceptor { chain ->
            val original = chain.request()
            val requestBuilder = original.newBuilder()
                .header("Authorization", "Bearer $apiKey")
                .method(original.method, original.body)
            chain.proceed(requestBuilder.build())
        }

        val okHttpClient = OkHttpClient.Builder()
            .addInterceptor(headerInterceptor)
            .addInterceptor(loggingInterceptor)
            .build()

        // Gson Date Deserializer to parse various ISO-8601 formats
        val gson = GsonBuilder()
            .registerTypeAdapter(Date::class.java, GsonDateDeserializer())
            .create()

        val retrofit = Retrofit.Builder()
            .baseUrl(baseUrl)
            .client(okHttpClient)
            .addConverterFactory(GsonConverterFactory.create(gson))
            .build()

        retrofitService = retrofit.create(RetrofitNewsService::class.java)
    }

    override suspend fun search(
        query: String,
        sortBy: SortBy,
        pageSize: Int,
        fetchFullContent: Boolean
    ): List<Article> {
        return try {
            val response = retrofitService.search(
                query = query,
                sortBy = sortBy.value,
                pageSize = pageSize,
                fetchFullContent = fetchFullContent
            )
            if (response.success) {
                response.data.articles
            } else {
                emptyList()
            }
        } catch (e: Exception) {
            Log.e("NewsClient", "Search request failed", e)
            throw e
        }
    }

    override suspend fun topHeadlines(
        sortBy: SortBy,
        country: Country,
        category: Category,
        pageSize: Int,
        fetchFullContent: Boolean
    ): List<Article> {
        return try {
            val response = retrofitService.topHeadlines(
                country = country.value,
                category = category.value,
                sortBy = sortBy.value,
                pageSize = pageSize,
                fetchFullContent = fetchFullContent
            )
            if (response.success) {
                response.data.articles
            } else {
                emptyList()
            }
        } catch (e: Exception) {
            Log.e("NewsClient", "Top headlines request failed", e)
            throw e
        }
    }

    // Robust Date parsing helper
    private class GsonDateDeserializer : JsonDeserializer<Date> {
        private val dateFormats = arrayOf(
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd"
        )

        override fun deserialize(
            json: JsonElement?,
            typeOfT: Type?,
            context: JsonDeserializationContext?
        ): Date {
            val dateStr = json?.asString ?: ""
            for (format in dateFormats) {
                try {
                    val sdf = SimpleDateFormat(format, Locale.US)
                    sdf.timeZone = TimeZone.getTimeZone("UTC")
                    return sdf.parse(dateStr) ?: continue
                } catch (e: Exception) {
                    // Try next pattern
                }
            }
            // Fallback to basic date conversion or current date if empty
            try {
                return Date(dateStr.toLong())
            } catch (e: Exception) {
                // Return epoch on total failure to prevent crashing
                return Date(0)
            }
        }
    }
}
