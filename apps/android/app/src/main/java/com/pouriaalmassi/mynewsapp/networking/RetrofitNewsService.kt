package com.pouriaalmassi.mynewsapp.networking

import com.pouriaalmassi.mynewsapp.models.NewsResponse
import retrofit2.http.GET
import retrofit2.http.Query

interface RetrofitNewsService {
    @GET("search")
    suspend fun search(
        @Query("q") query: String,
        @Query("sortBy") sortBy: String,
        @Query("pageSize") pageSize: Int,
        @Query("fetchFullContent") fetchFullContent: Boolean
    ): NewsResponse

    @GET("top-headlines")
    suspend fun topHeadlines(
        @Query("country") country: String,
        @Query("category") category: String,
        @Query("sortBy") sortBy: String,
        @Query("pageSize") pageSize: Int,
        @Query("fetchFullContent") fetchFullContent: Boolean
    ): NewsResponse
}
