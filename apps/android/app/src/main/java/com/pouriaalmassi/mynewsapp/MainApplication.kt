package com.pouriaalmassi.mynewsapp

import android.app.Application
import androidx.annotation.VisibleForTesting
import com.pouriaalmassi.mynewsapp.networking.MockNewsClient
import com.pouriaalmassi.mynewsapp.networking.NewsClient
import com.pouriaalmassi.mynewsapp.networking.NewsService

class MainApplication : Application() {
    
    // Expose setter for unit/UI testing dependency injection
    @set:VisibleForTesting
    lateinit var newsService: NewsService

    override fun onCreate() {
        super.onCreate()
        
        // Toggle offline mock here (only active in DEBUG builds)
        // Change to true to run the app offline on mock data during local development
        val useOfflineMock = BuildConfig.DEBUG && true
        
        newsService = if (useOfflineMock) {
            MockNewsClient()
        } else {
            NewsClient()
        }
    }
}
