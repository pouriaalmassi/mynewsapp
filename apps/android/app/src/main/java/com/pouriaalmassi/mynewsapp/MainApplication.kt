package com.pouriaalmassi.mynewsapp

import android.app.Application
import com.pouriaalmassi.mynewsapp.networking.MockNewsClient
import com.pouriaalmassi.mynewsapp.networking.NewsClient
import com.pouriaalmassi.mynewsapp.networking.NewsService

class MainApplication : Application() {
    
    lateinit var newsService: NewsService
        private set

    override fun onCreate() {
        super.onCreate()
        
        // Set this to true to run in high-fidelity offline mode without requiring the backend server!
        val useOfflineMock = false
        
        newsService = if (useOfflineMock) {
            MockNewsClient()
        } else {
            NewsClient()
        }
    }
}
