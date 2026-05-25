package com.pouriaalmassi.mynewsapp.viewmodels

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import com.pouriaalmassi.mynewsapp.networking.Category
import com.pouriaalmassi.mynewsapp.networking.Country
import com.pouriaalmassi.mynewsapp.networking.NewsService
import com.pouriaalmassi.mynewsapp.networking.SortBy

class ContentViewModel(
    private val newsService: NewsService
) : ViewModel() {

    var selectedArticle by mutableStateOf<com.pouriaalmassi.mynewsapp.models.Article?>(null)

    fun makeTopHeadlinesViewModel(category: Category): ArticlesViewModel {
        return ArticlesViewModel {
            newsService.topHeadlines(
                sortBy = SortBy.POPULARITY,
                country = Country.US,
                category = category,
                pageSize = 20,
                fetchFullContent = true
            )
        }
    }

    fun makeSearchViewModel(query: String): ArticlesViewModel {
        return ArticlesViewModel {
            newsService.search(
                query = query,
                sortBy = SortBy.POPULARITY,
                pageSize = 20,
                fetchFullContent = true
            )
        }
    }
}
