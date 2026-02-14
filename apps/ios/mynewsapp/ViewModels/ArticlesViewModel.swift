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
        do {
            let articles = try await fetchAction()
            dataState = .loaded(articles)
        } catch {
            dataState = .error(error)
            print("Error fetching articles: \(error)")
        }
    }
}
