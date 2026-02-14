import Foundation

protocol NewsService {
    func search(query: String, sortBy: SortBy, pageSize: Int, fetchFullContent: Bool) async throws -> [Article]
    func topHeadlines(sortBy: SortBy, country: Country, category: Category, pageSize: Int, fetchFullContent: Bool) async throws -> [Article]
}

enum SortBy: String {
    case popularity = "popularity"
    case publishedAt = "publishedAt"
    case relevancy = "relevancy"
}

enum Country: String {
    case ae = "ae"
    case ar = "ar"
    case at = "at"
    case au = "au"
    case be = "be"
    case bg = "bg"
    case br = "br"
    case ca = "ca"
    case ch = "ch"
    case cn = "cn"
    case co = "co"
    case cu = "cu"
    case cz = "cz"
    case de = "de"
    case eg = "eg"
    case fr = "fr"
    case gb = "gb"
    case gr = "gr"
    case hk = "hk"
    case hu = "hu"
    case id = "id"
    case ie = "ie"
    case il = "il"
    case `in` = "in"
    case it = "it"
    case jp = "jp"
    case kr = "kr"
    case lt = "lt"
    case lv = "lv"
    case ma = "ma"
    case mx = "mx"
    case my = "my"
    case ng = "ng"
    case nl = "nl"
    case no = "no"
    case nz = "nz"
    case ph = "ph"
    case pl = "pl"
    case pt = "pt"
    case ro = "ro"
    case rs = "rs"
    case ru = "ru"
    case sa = "sa"
    case se = "se"
    case sg = "sg"
    case si = "si"
    case sk = "sk"
    case th = "th"
    case tr = "tr"
    case tw = "tw"
    case ua = "ua"
    case us = "us"
    case ve = "ve"
    case za = "za"
}

enum Category: String {
    case business = "business"
    case entertainment = "entertainment"
    case general = "general"
    case health = "health"
    case science = "science"
    case sports = "sports"
    case technology = "technology"
    
    var displayName: String {
        rawValue.capitalized
    }
}
