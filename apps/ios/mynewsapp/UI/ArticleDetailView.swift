import SwiftUI

struct ArticleDetailView: View {
    let viewModel: ArticleDetailViewModel
    @State private var isShowingSafari = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let urlToImage = viewModel.article.urlToImage, let url = URL(string: urlToImage) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        case .failure:
                            EmptyView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxHeight: 300)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.article.title)
                        .font(.title)
                        .bold()
                    
                    if let author = viewModel.article.author {
                        Text(String(format: NSLocalizedString("author_prefix", comment: "Author prefix"), author))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(viewModel.article.publishedAtString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Divider()
                    
                    if let description = viewModel.article.description {
                        Text(description)
                            .font(.body)
                    }
                    
                    if let content = viewModel.article.content {
                        Text(content)
                            .font(.body)
                            .padding(.top, 4)
                    }
                    
                    if let url = URL(string: viewModel.article.url) {
                        Button(NSLocalizedString("read_full_article", comment: "Read full article")) {
                            isShowingSafari = true
                        }
                        .font(.headline)
                        .padding(.top)
                        .fullScreenCover(isPresented: $isShowingSafari) {
                            SafariView(url: url)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
