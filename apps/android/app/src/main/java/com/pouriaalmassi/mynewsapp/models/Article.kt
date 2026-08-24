package com.pouriaalmassi.mynewsapp.models

import com.google.gson.annotations.SerializedName
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.UUID

data class Article(
    val id: String = UUID.randomUUID().toString(),
    @SerializedName("source") val source: Source,
    @SerializedName("author") val author: String?,
    @SerializedName("title") val title: String,
    @SerializedName("description") val description: String?,
    @SerializedName("url") val url: String,
    @SerializedName("urlToImage") val urlToImage: String?,
    @SerializedName("publishedAt") val publishedAt: Date,
    @SerializedName("content") val content: String?
) {
    val publishedAtString: String
        get() {
            return try {
                val formatter = SimpleDateFormat("MMM d, yyyy, h:mm a", Locale.getDefault())
                formatter.format(publishedAt)
            } catch (e: Exception) {
                publishedAt.toString()
            }
        }
}
