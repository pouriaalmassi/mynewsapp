import Foundation
import Observation

enum DataState {
    case idle
    case loading
    case loaded([Article])
    case error(Error)
}

@Observable
@MainActor
final class ArticlesViewModel {

    var dataState: DataState = .idle
    
    private let fetchAction: () async throws -> [Article]
    
    init(fetchAction: @escaping () async throws -> [Article]) {
        self.fetchAction = fetchAction
    }
    
    func loadData() async {
        dataState = .loading
        AppLogger.viewModels.debug("Loading articles from server...")
        do {
            let articles = try await fetchAction()
            dataState = .loaded(articles)
            AppLogger.viewModels.info("Successfully fetched \(articles.count) articles")
        } catch {
            dataState = .error(error)
            AppLogger.viewModels.error(public: "Failed to fetch articles", private: error.localizedDescription)
        }
    }
}
