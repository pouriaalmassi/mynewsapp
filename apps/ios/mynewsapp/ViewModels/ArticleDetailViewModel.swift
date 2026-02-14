import Foundation
import Observation

@Observable
final class ArticleDetailViewModel {

    let article: Article
    
    init(article: Article) {
        self.article = article
    }
}
