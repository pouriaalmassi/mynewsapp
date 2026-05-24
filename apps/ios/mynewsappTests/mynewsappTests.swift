//
//  mynewsappTests.swift
//  mynewsappTests
//
//  Created by Pouria Almassi on 2025-12-07.
//

import Testing
import Foundation
@testable import mynewsapp

@MainActor
struct mynewsappTests {

    @Test func testJSONDecoding() async throws {
        let json = """
        {
          "success": true,
          "data": {
            "status": "ok",
            "totalResults": 14512,
            "articles": [
              {
                "source": {
                  "id": "wired",
                  "name": "Wired"
                },
                "author": "Article author",
                "title": "Article title",
                "description": "Article description",
                "url": "https://www.wired.com/story/bitcoin-scam-mining-as-service/",
                "urlToImage": "https://media.wired.com/photos/6913b909f757bec53ccf7811/191:100/w_1280,c_limit/Bitcoin-Heist-Business-1304706668.jpg",
                "publishedAt": "2025-11-17T10:00:00Z",
                "content": "Article content"
              }
            ]
          }
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let response = try decoder.decode(NewsResponse.self, from: data)
        
        #expect(response.success == true)
        #expect(response.data.status == "ok")
        #expect(response.data.totalResults == 14512)
        #expect(response.data.articles.count == 1)
        
        let article = response.data.articles.first!
        #expect(article.source.id == "wired")
        #expect(article.source.name == "Wired")
        #expect(article.author == "Article author")
        #expect(article.title == "Article title")
    }

    @Test func testNewsEndpointURLs() {
        let searchEndpoint = NewsClient.NewsEndpoint.search(query: "bitcoin", pageSize: 20, fetchFullContent: true, sortBy: .publishedAt)
        let searchPath = searchEndpoint.path
        let searchQueryItems = searchEndpoint.queryItems

        #expect(searchPath == "/search")
        #expect(searchQueryItems.contains(where: { $0.name == "q" && $0.value == "bitcoin" }))
        #expect(searchQueryItems.contains(where: { $0.name == "pageSize" && $0.value == "20" }))

        let headlinesEndpoint = NewsClient.NewsEndpoint.topHeadlines(
            country: Country(rawValue: "us")!,
            category: Category(rawValue: "business")!,
            pageSize: 20,
            fetchFullContent: true,
            sortBy: .publishedAt,
        )
        let headlinesPath = headlinesEndpoint.path
        let headlinesQueryItems = headlinesEndpoint.queryItems

        #expect(headlinesPath == "/top-headlines")
        #expect(headlinesQueryItems.contains(where: { $0.name == "country" && $0.value == "us" }))
        #expect(headlinesQueryItems.contains(where: { $0.name == "category" && $0.value == "business" }))
    }

    @Test func testMockClient() async throws {
        let mockClient = MockNewsClient()
        let mockArticle = Article(
            source: Source(id: "mock", name: "Mock Source"),
            author: "Mock Author",
            title: "Mock Title",
            description: "Mock Description",
            url: "https://mock.com",
            urlToImage: nil,
            publishedAt: Date(),
            content: "Mock Content"
        )

        mockClient.mockArticles = [mockArticle]

        let articles = try await mockClient.search(
            query: "test",
            sortBy: .publishedAt,
            pageSize: 10,
            fetchFullContent: false
        )

        #expect(articles.count == 1)
        #expect(articles.first?.title == "Mock Title")
    }

}
