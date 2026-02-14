import SwiftUI

struct ArticlesView: View {
    let title: String
    @State private var viewModel: ArticlesViewModel
    
    init(title: String, viewModel: ArticlesViewModel) {
        self.title = title
        _viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            switch viewModel.dataState {
            case .idle:
                Color.clear.onAppear {
                    Task { await viewModel.loadData() }
                }
            case .loading:
                ProgressView()
            case .loaded(let articles):
                List(articles) { article in
                    NavigationLink(destination: ArticleDetailView(viewModel: ArticleDetailViewModel(article: article))) {
                        VStack(alignment: .leading) {

                            Text(article.title)
                                .font(.headline)

                            Text(article.publishedAtString)
                                .font(.subheadline)

                            if let description = article.description {
                                Text(description)
                                    .font(.subheadline)
                                    .lineLimit(2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .refreshable {
                    await viewModel.loadData()
                }
            case .error(let error):
                VStack {
                    Text(String(format: NSLocalizedString("error_prefix", comment: "Error prefix"), error.localizedDescription))
                    Button(NSLocalizedString("retry_button", comment: "Retry")) {
                        Task { await viewModel.loadData() }
                    }
                }
            }
        }
        .navigationTitle(title)
    }
}
