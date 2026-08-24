package com.pouriaalmassi.mynewsapp.models

import com.google.gson.annotations.SerializedName

data class NewsData(
    @SerializedName("status") val status: String,
    @SerializedName("totalResults") val totalResults: Int,
    @SerializedName("articles") val articles: List<Article>
)
