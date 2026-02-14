import Foundation

final class NewsClient: NewsService {
    
    private enum Constant {
        static let baseURL = "http://localhost:3000/api/news"
        
        static let cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        static let timeoutInterval: TimeInterval = 30.0
        
        static let apiKey: String? = {
            guard let key = Bundle.main.infoDictionary?["API_KEY"] as? String, !key.isEmpty else {
                assertionFailure("API_KEY not found in Info.plist. Ensure Secrets.xcconfig is configured.")
                return nil
            }
            return key
        }()
    }
    
    enum NewsEndpoint {
        case search(query: String, pageSize: Int, fetchFullContent: Bool, sortBy: SortBy)
        case topHeadlines(country: Country, category: Category, pageSize: Int, fetchFullContent: Bool, sortBy: SortBy)

        private enum QueryParamName {
            static let query = "q"
            static let country = "country"
            static let category = "category"
            static let pageSize = "pageSize"
            static let fetchFullContent = "fetchFullContent"
            static let sortBy = "sortBy"
        }
        
        var path: String {
            switch self {
            case .search:
                return "/search"
            case .topHeadlines:
                return "/top-headlines"
            }
        }
        
        var queryItems: [URLQueryItem] {
            switch self {
            case .search(let query, let pageSize, let fetchFullContent, let sortBy):
                return [
                    URLQueryItem(name: QueryParamName.query, value: query),
                    URLQueryItem(name: QueryParamName.pageSize, value: String(pageSize)),
                    URLQueryItem(name: QueryParamName.fetchFullContent, value: String(fetchFullContent)),
                    URLQueryItem(name: QueryParamName.sortBy, value: sortBy.rawValue),
                ]
            case .topHeadlines(let country, let category, let pageSize, let fetchFullContent, let sortBy):
                return [
                    URLQueryItem(name: QueryParamName.country, value: country.rawValue),
                    URLQueryItem(name: QueryParamName.category, value: category.rawValue),
                    URLQueryItem(name: QueryParamName.pageSize, value: String(pageSize)),
                    URLQueryItem(name: QueryParamName.fetchFullContent, value: String(fetchFullContent)),
                    URLQueryItem(name: QueryParamName.sortBy, value: sortBy.rawValue),
                ]
            }
        }
    }
    
    func search(query: String, sortBy: SortBy, pageSize: Int = 20, fetchFullContent: Bool = false) async throws -> [Article] {
        let endpoint = NewsEndpoint.search(query: query, pageSize: pageSize, fetchFullContent: fetchFullContent, sortBy: sortBy)
        let response = try await fetch(from: endpoint)
        return response.data.articles
    }
    
    
    func topHeadlines(sortBy: SortBy, country: Country = .us, category: Category = .business, pageSize: Int = 20, fetchFullContent: Bool = false) async throws -> [Article] {
        let endpoint = NewsEndpoint.topHeadlines(country: country, category: category, pageSize: pageSize, fetchFullContent: fetchFullContent, sortBy: sortBy)
        let response = try await fetch(from: endpoint)
        return response.data.articles
    }
    
    private func fetch(from endpoint: NewsEndpoint) async throws -> NewsResponse {
        let session = URLSession.shared
        
        let constructedUrlString = Constant.baseURL + endpoint.path
        
        guard var components = URLComponents(string: constructedUrlString) else {
            throw URLError(.badURL)
        }
        
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        var urlRequest = URLRequest(
            url: url,
            cachePolicy: Constant.cachePolicy,
            timeoutInterval: Constant.timeoutInterval
        )
        
        guard let apiKey = Constant.apiKey else {
            throw URLError(.userAuthenticationRequired)
        }
        
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await session.data(for: urlRequest)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(NewsResponse.self, from: data)
    }
}

