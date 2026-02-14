import Foundation

class MockNewsClient: NewsService {
    
    var mockArticles: [Article] = []
    var mockError: Error?
    
    func search(query: String, sortBy: SortBy, pageSize: Int = 20, fetchFullContent: Bool = true) async throws -> [Article] {
        if let error = mockError {
            throw error
        }
        return mockArticles
    }
    
    func topHeadlines(sortBy: SortBy, country: Country = .us, category: Category = .business, pageSize: Int = 20, fetchFullContent: Bool = true) async throws -> [Article] {
        if let error = mockError {
            throw error
        }
        return mockArticles
    }
}
