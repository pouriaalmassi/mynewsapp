import Foundation
import Observation

@Observable
class ContentViewModel {
    
    private let newsService: NewsService
    
    init(newsService: NewsService) {
        self.newsService = newsService
    }

    func makeTopHeadlinesViewModel(category: Category) -> ArticlesViewModel {
        ArticlesViewModel {
            try await self.newsService
                .topHeadlines(
                    sortBy: .popularity,
                    country: .us,
                    category: category,
                    pageSize: 20,
                    fetchFullContent: true
                )
        }
    }
    
    func makeSearchViewModel(query: String) -> ArticlesViewModel {
        ArticlesViewModel {
            try await self.newsService.search(
                query: query,
                sortBy: .popularity,
                pageSize: 20,
                fetchFullContent: true
            )
        }
    }
}
