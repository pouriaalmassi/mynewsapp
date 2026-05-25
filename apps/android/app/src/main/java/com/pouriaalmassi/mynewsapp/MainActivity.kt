package com.pouriaalmassi.mynewsapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.pouriaalmassi.mynewsapp.networking.Category
import com.pouriaalmassi.mynewsapp.ui.ArticleDetailView
import com.pouriaalmassi.mynewsapp.ui.ArticlesView
import com.pouriaalmassi.mynewsapp.ui.ContentView
import com.pouriaalmassi.mynewsapp.ui.SafariView
import com.pouriaalmassi.mynewsapp.ui.theme.MyNewsAppTheme
import com.pouriaalmassi.mynewsapp.viewmodels.ContentViewModel
import java.net.URLEncoder
import java.nio.charset.StandardCharsets

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val app = application as MainApplication
        val contentViewModel = ContentViewModel(app.newsService)
        
        setContent {
            MyNewsAppTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    AppNavigation(contentViewModel)
                }
            }
        }
    }
}

@Composable
fun AppNavigation(contentViewModel: ContentViewModel) {
    val navController = rememberNavController()

    NavHost(
        navController = navController,
        startDestination = "content_view"
    ) {
        // 1. ContentView: Home category selector
        composable("content_view") {
            ContentView(
                contentViewModel = contentViewModel,
                onCategoryClick = { category ->
                    navController.navigate("articles_view/${category.name}")
                }
            )
        }
        
        // 2. ArticlesView: Headline list for a selected category
        composable(
            route = "articles_view/{categoryName}",
            arguments = listOf(navArgument("categoryName") { type = NavType.StringType })
        ) { backStackEntry ->
            val categoryName = backStackEntry.arguments?.getString("categoryName") ?: Category.GENERAL.name
            val category = try {
                Category.valueOf(categoryName)
            } catch (e: Exception) {
                Category.GENERAL
            }
            
            val articlesViewModel = remember(category) {
                contentViewModel.makeTopHeadlinesViewModel(category)
            }
            
            ArticlesView(
                title = category.displayName,
                viewModel = articlesViewModel,
                onArticleClick = { article ->
                    contentViewModel.selectedArticle = article
                    navController.navigate("article_detail_view")
                },
                onBackClick = {
                    navController.popBackStack()
                }
            )
        }
        
        // 3. ArticleDetailView: Visual summary of article, description, content and full-article CTA
        composable("article_detail_view") {
            val article = contentViewModel.selectedArticle
            if (article != null) {
                ArticleDetailView(
                    article = article,
                    onReadFullArticleClick = { url ->
                        val encodedUrl = URLEncoder.encode(url, StandardCharsets.UTF_8.toString())
                        navController.navigate("safari_view/$encodedUrl")
                    },
                    onBackClick = {
                        navController.popBackStack()
                    }
                )
            } else {
                LaunchedEffect(Unit) {
                    navController.popBackStack()
                }
            }
        }
        
        // 4. SafariView: Beautiful in-app custom browser web rendering
        composable(
            route = "safari_view/{url}",
            arguments = listOf(navArgument("url") { type = NavType.StringType })
        ) { backStackEntry ->
            val url = backStackEntry.arguments?.getString("url") ?: ""
            SafariView(
                url = url,
                onBackClick = {
                    navController.popBackStack()
                }
            )
        }
    }
}
