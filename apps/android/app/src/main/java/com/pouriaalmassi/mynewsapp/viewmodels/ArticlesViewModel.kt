package com.pouriaalmassi.mynewsapp.viewmodels

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.pouriaalmassi.mynewsapp.models.Article
import kotlinx.coroutines.launch

sealed class DataState {
    object Idle : DataState()
    object Loading : DataState()
    data class Loaded(val articles: List<Article>) : DataState()
    data class Error(val error: Throwable) : DataState()
}

class ArticlesViewModel(
    private val fetchAction: suspend () -> List<Article>
) : ViewModel() {

    var dataState by mutableStateOf<DataState>(DataState.Idle)
        private set

    fun loadData() {
        viewModelScope.launch {
            dataState = DataState.Loading
            try {
                val articles = fetchAction()
                dataState = DataState.Loaded(articles)
            } catch (e: Exception) {
                dataState = DataState.Error(e)
            }
        }
    }
}
