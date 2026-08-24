package com.pouriaalmassi.mynewsapp.models

import com.google.gson.annotations.SerializedName

data class NewsResponse(
    @SerializedName("success") val success: Boolean,
    @SerializedName("data") val data: NewsData
)
