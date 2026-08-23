package com.pouriaalmassi.mynewsapp.viewmodels

import com.pouriaalmassi.mynewsapp.MainDispatcherRule
import com.pouriaalmassi.mynewsapp.networking.Category
import com.pouriaalmassi.mynewsapp.networking.MockNewsClient
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.runTest
import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test
import java.io.IOException

@OptIn(ExperimentalCoroutinesApi::class)
class ArticlesViewModelTest {

    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    @Test
    fun loadData_success_transitionsToLoadedStateWithArticles() = runTest {
        // Arrange
        val mockClient = MockNewsClient()
        val contentViewModel = ContentViewModel(mockClient)
        val viewModel = contentViewModel.makeTopHeadlinesViewModel(Category.BUSINESS)

        // Assert initial state
        assertEquals(DataState.Idle, viewModel.dataState)

        // Act
        viewModel.loadData()
        advanceUntilIdle() // Advance virtual clock past the mock client's delay

        // Assert final state contains the mock articles
        val state = viewModel.dataState
        assertTrue(state is DataState.Loaded)
        val articles = (state as DataState.Loaded).articles
        assertEquals(3, articles.size)
        assertEquals("The Future of Generative AI in Mobile Ecosystems", articles[0].title)
    }

    @Test
    fun loadData_failure_transitionsToErrorStateWithCaughtException() = runTest {
        // Arrange
        val mockClient = MockNewsClient()
        val expectedException = IOException("Network server down")
        mockClient.mockError = expectedException

        val contentViewModel = ContentViewModel(mockClient)
        val viewModel = contentViewModel.makeTopHeadlinesViewModel(Category.BUSINESS)

        // Assert initial state
        assertEquals(DataState.Idle, viewModel.dataState)

        // Act
        viewModel.loadData()
        advanceUntilIdle() // Advance virtual clock past the mock client's delay

        // Assert state transitions to Error and holds the correct exception
        val state = viewModel.dataState
        assertTrue(state is DataState.Error)
        assertEquals(expectedException, (state as DataState.Error).error)
    }

    @Test
    fun searchArticles_filtersMockResultsBasedOnQuery() = runTest {
        // Arrange
        val mockClient = MockNewsClient()
        val contentViewModel = ContentViewModel(mockClient)
        // Search query specifically matches article 1's title
        val viewModel = contentViewModel.makeSearchViewModel("Generative AI")

        // Act
        viewModel.loadData()
        advanceUntilIdle() // Advance virtual clock past the mock client's delay

        // Assert search results contain only the filtered match
        val state = viewModel.dataState
        assertTrue(state is DataState.Loaded)
        val articles = (state as DataState.Loaded).articles
        assertEquals(1, articles.size)
        assertEquals("The Future of Generative AI in Mobile Ecosystems", articles[0].title)
    }
}
