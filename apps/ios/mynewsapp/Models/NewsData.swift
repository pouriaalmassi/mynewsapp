import Foundation

struct NewsData: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}
