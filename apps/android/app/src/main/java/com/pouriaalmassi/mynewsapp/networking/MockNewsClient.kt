package com.pouriaalmassi.mynewsapp.networking

import com.pouriaalmassi.mynewsapp.models.Article
import com.pouriaalmassi.mynewsapp.models.Source
import kotlinx.coroutines.delay
import java.util.*

class MockNewsClient : NewsService {

    var mockError: Exception? = null
    var mockArticles: List<Article> = createMockArticles()

    override suspend fun search(
        query: String,
        sortBy: SortBy,
        pageSize: Int,
        fetchFullContent: Boolean
    ): List<Article> {
        delay(1000) // Simulate network delay
        mockError?.let { throw it }
        return mockArticles.filter {
            it.title.contains(query, ignoreCase = true) ||
                    (it.description?.contains(query, ignoreCase = true) == true)
        }
    }

    override suspend fun topHeadlines(
        sortBy: SortBy,
        country: Country,
        category: Category,
        pageSize: Int,
        fetchFullContent: Boolean
    ): List<Article> {
        delay(1000) // Simulate network delay
        mockError?.let { throw it }
        return mockArticles
    }

    companion object {
        fun createMockArticles(): List<Article> {
            val sourceTech = Source("techcrunch", "TechCrunch")
            val sourceWSJ = Source("wsj", "The Wall Street Journal")
            val sourceVerge = Source("the-verge", "The Verge")
            
            return listOf(
                Article(
                    id = "1",
                    source = sourceTech,
                    author = "Sarah Perez",
                    title = "The Future of Generative AI in Mobile Ecosystems",
                    description = "Mobile operating systems are evolving at a breakneck speed, integrating context-aware AI models directly on-device. Here is what is coming next in Android and iOS developments.",
                    url = "https://techcrunch.com",
                    urlToImage = "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=80",
                    publishedAt = Date(),
                    content = "Generative AI is moving rapidly from cloud-based APIs to on-device hardware. Both Google and Apple are heavily optimizing their silicon to handle large language models locally. This allows users to experience immediate, private, and offline-capable natural language processing directly from their pockets. As NPUs become faster and more energy-efficient, we expect the entire paradigm of mobile app interaction to shift away from standard forms to conversational and highly adaptive dynamic systems. Developers should begin designing their architectures around local context caches to leverage these state-of-the-art developments."
                ),
                Article(
                    id = "2",
                    source = sourceWSJ,
                    author = "Gregory Ip",
                    title = "Global Inflation Stabilizes as Supply Chains Optimize",
                    description = "Key economic indicators suggest global inflation is finally returning to historical averages. Central banks are preparing interest rate cuts.",
                    url = "https://wsj.com",
                    urlToImage = "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?auto=format&fit=crop&w=800&q=80",
                    publishedAt = Date(System.currentTimeMillis() - 3600000 * 4), // 4 hours ago
                    content = "Supply chains around the world have fully recovered from pandemic-era disruptions, helping decrease manufacturing costs and logistics backlogs. According to the latest figures from the International Monetary Fund, inflation rates in major developed economies have cooled down to approximately 2.1 percent, matching long-term targets. Economists predict that the Federal Reserve and European Central Bank will initiate a series of rate cuts beginning next quarter, sparking a surge of investment in technology, housing, and sustainable infrastructure developments."
                ),
                Article(
                    id = "3",
                    source = sourceVerge,
                    author = "Andrew Webster",
                    title = "Next-Gen Consoles and the Rise of Cloud Gaming Platforms",
                    description = "With high-speed 5G and fiber optic networks expanding globally, cloud streaming is becoming a viable rival to physical hardware.",
                    url = "https://theverge.com",
                    urlToImage = "https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?auto=format&fit=crop&w=800&q=80",
                    publishedAt = Date(System.currentTimeMillis() - 3600000 * 12), // 12 hours ago
                    content = "For decades, console generations have been defined by local processing leaps. However, massive investments in cloud distribution servers are leveling the playing field. Gamers can now stream AAA titles at 4K resolution and 120 frames per second with minimal input latency directly onto low-powered smart televisions, smartphones, and laptops. While major hardware manufacturers are still releasing local media centers, the trend points toward a highly subscription-focused ecosystem where the screen itself is merely a gateway to an elastic cloud computing powerhouse."
                )
            )
        }
    }
}
