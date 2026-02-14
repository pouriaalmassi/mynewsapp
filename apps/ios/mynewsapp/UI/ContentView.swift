import SwiftUI

struct ContentView: View {
    private let viewModel: ContentViewModel

    private let categories: [Category] = [
        .general,
        .business,
        .entertainment,
        .health,
        .science,
        .sports,
        .technology
    ]

    init(viewModel: ContentViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(categories, id: \.self) { category in
                    NavigationLink(category.displayName) {
                        ArticlesView(
                            title: category.displayName,
                            viewModel: viewModel.makeTopHeadlinesViewModel(category: category)
                        )
                    }
                }
            }
            .navigationTitle(NSLocalizedString("my_news_title", comment: "My News"))
        }
    }
}
