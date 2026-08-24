package com.pouriaalmassi.mynewsapp.networking

import com.pouriaalmassi.mynewsapp.models.Article

interface NewsService {
    suspend fun search(
        query: String,
        sortBy: SortBy = SortBy.POPULARITY,
        pageSize: Int = 20,
        fetchFullContent: Boolean = false
    ): List<Article>

    suspend fun topHeadlines(
        sortBy: SortBy = SortBy.POPULARITY,
        country: Country = Country.US,
        category: Category = Category.BUSINESS,
        pageSize: Int = 20,
        fetchFullContent: Boolean = false
    ): List<Article>
}

enum class SortBy(val value: String) {
    POPULARITY("popularity"),
    PUBLISHED_AT("publishedAt"),
    RELEVANCY("relevancy")
}

enum class Country(val value: String) {
    AE("ae"), AR("ar"), AT("at"), AU("au"), BE("be"), BG("bg"), BR("br"), CA("ca"),
    CH("ch"), CN("cn"), CO("co"), CU("cu"), CZ("cz"), DE("de"), EG("eg"), FR("fr"),
    GB("gb"), GR("gr"), HK("hk"), HU("hu"), ID("id"), IE("ie"), IL("il"), IN("in"),
    IT("it"), JP("jp"), KR("kr"), LT("lt"), LV("lv"), MA("ma"), MX("mx"), MY("my"),
    NG("ng"), NL("nl"), NO("no"), NZ("nz"), PH("ph"), PL("pl"), PT("pt"), RO("ro"),
    RS("rs"), RU("ru"), SA("sa"), SE("se"), SG("sg"), SI("si"), SK("sk"), TH("th"),
    TR("tr"), TW("tw"), UA("ua"), US("us"), VE("ve"), ZA("za")
}

enum class Category(val value: String) {
    BUSINESS("business"),
    ENTERTAINMENT("entertainment"),
    GENERAL("general"),
    HEALTH("health"),
    SCIENCE("science"),
    SPORTS("sports"),
    TECHNOLOGY("technology");

    val displayName: String
        get() = value.replaceFirstChar { it.uppercase() }
}
