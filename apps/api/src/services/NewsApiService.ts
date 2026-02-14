import axios, { AxiosResponse } from "axios"
import { Config } from "../config/config"
import {
  NewsApiResponse,
  NewsApiError,
  NewsQueryParams,
  NewsArticle,
} from "../types"
import { JSDOM } from "jsdom"

export class NewsApiService {
  private readonly baseUrl: string
  private readonly apiKey: string

  constructor() {
    this.baseUrl = Config.NEWS_API_BASE_URL
    this.apiKey = Config.NEWS_API_KEY
  }

  public async getTopHeadlines(
    params: NewsQueryParams = {}
  ): Promise<NewsApiResponse> {
    try {
      const queryParams = new URLSearchParams({
        apiKey: this.apiKey,
        ...this.sanitizeParams(params),
      })

      const response: AxiosResponse<NewsApiResponse> = await axios.get(
        `${this.baseUrl}/top-headlines?${queryParams.toString()}`
      )

      return response.data
    } catch (error) {
      if (axios.isAxiosError(error) && error.response) {
        const errorData = error.response.data as NewsApiError
        throw new Error(`News API Error: ${errorData.message || error.message}`)
      }
      throw new Error(
        `Failed to fetch news: ${error instanceof Error ? error.message : "Unknown error"}`
      )
    }
  }

  public async searchNews(
    query: string,
    params: NewsQueryParams = {}
  ): Promise<NewsApiResponse> {
    try {
      const queryParams = new URLSearchParams({
        apiKey: this.apiKey,
        q: query,
        ...this.sanitizeParams(params),
      })

      const response: AxiosResponse<NewsApiResponse> = await axios.get(
        `${this.baseUrl}/everything?${queryParams.toString()}`
      )

      // Enhance articles with full content from their URLs if requested
      const enhancedArticles = params.fetchFullContent
        ? await this.enhanceArticlesWithFullContent(response.data.articles)
        : response.data.articles

      return {
        ...response.data,
        articles: enhancedArticles,
      }
    } catch (error) {
      if (axios.isAxiosError(error) && error.response) {
        const errorData = error.response.data as NewsApiError
        throw new Error(`News API Error: ${errorData.message || error.message}`)
      }
      throw new Error(
        `Failed to search news: ${error instanceof Error ? error.message : "Unknown error"}`
      )
    }
  }

  private async enhanceArticlesWithFullContent(
    articles: NewsArticle[]
  ): Promise<NewsArticle[]> {
    const enhancedArticles: NewsArticle[] = []

    // Process articles in parallel with a limit to avoid overwhelming servers
    const batchSize = 5 // Process 5 articles at a time
    for (let i = 0; i < articles.length; i += batchSize) {
      const batch = articles.slice(i, i + batchSize)
      const batchPromises = batch.map(async (article) => {
        try {
          const fullContent = await this.fetchArticleContent(article.url)
          return {
            ...article,
            content: fullContent || article.content, // Fallback to original content if fetch fails
          }
        } catch (error) {
          console.warn(`Failed to fetch content for ${article.url}: ${error}`)
          return article // Return original article if content fetch fails
        }
      })

      const batchResults = await Promise.all(batchPromises)
      enhancedArticles.push(...batchResults)
    }

    return enhancedArticles
  }

  private async fetchArticleContent(url: string): Promise<string | null> {
    try {
      const response = await axios.get(url, {
        timeout: 10000, // 10 second timeout
        headers: {
          "User-Agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        },
      })

      const html = response.data
      return this.extractTextContent(html)
    } catch (error) {
      console.warn(`Failed to fetch content from ${url}: ${error}`)
      return null
    }
  }

  private extractTextContent(html: string): string {
    try {
      // Simple text extraction - remove HTML tags and decode entities
      let text = html
        // Remove script and style tags and their content
        .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, "")
        .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, "")
        // Remove HTML tags
        .replace(/<[^>]*>/g, "")
        // Decode common HTML entities
        .replace(/&amp;/g, "&")
        .replace(/&lt;/g, "<")
        .replace(/&gt;/g, ">")
        .replace(/&quot;/g, '"')
        .replace(/&#39;/g, "'")
        .replace(/&nbsp;/g, " ")
        // Remove extra whitespace
        .replace(/\s+/g, " ")
        .trim()

      // Limit content length to avoid extremely long responses
      const maxLength = 5000
      if (text.length > maxLength) {
        text = text.substring(0, maxLength) + "..."
      }

      return text
    } catch (error) {
      console.warn("Failed to extract text content:", error)
      return ""
    }
  }

  private sanitizeParams(params: NewsQueryParams): Record<string, string> {
    const sanitized: Record<string, string> = {}

    if (params.country) sanitized.country = params.country
    if (params.category) sanitized.category = params.category
    if (params.pageSize) sanitized.pageSize = params.pageSize.toString()
    if (params.page) sanitized.page = params.page.toString()
    // Note: fetchFullContent is not sent to NewsAPI, it's used internally

    return sanitized
  }

  /**
   * Fetches HTML from a URL and extracts URLs from href attributes of elements
   * that contain a span with data-cy="top-table-list-content-headline-span"
   */
  private async extractUrlsFromHeadlineSpans(url: string): Promise<string[]> {
    try {
      const html = await this.fetchArticleContent(url)

      if (!html) {
        throw new Error(`Error getting page content!`)
      }

      // const html = await response.text();

      // Create a JSDOM instance to parse the HTML
      const dom = new JSDOM(html)
      const doc = dom.window.document

      // Find all spans with the specific data-cy attribute
      const targetSpans = doc.querySelectorAll(
        'span[data-cy="top-table-list-content-headline-span"]'
      )

      const extractedUrls: string[] = []

      // For each span, find its parent anchor tag and extract the href
      targetSpans.forEach((span) => {
        // Look for the closest parent anchor tag
        const parentAnchor = span.closest("a[href]") as HTMLAnchorElement

        if (parentAnchor && parentAnchor.href) {
          extractedUrls.push(parentAnchor.href)
        }
      })

      return extractedUrls
    } catch (error) {
      console.error("Error fetching or parsing HTML:", error)
      throw error
    }
  }

  /**
   * Alternative version that returns a single URL (the first match)
   * if you only expect one result
   */
  private async extractFirstUrlFromHeadlineSpan(
    url: string
  ): Promise<string | null> {
    try {
      const urls = await this.extractUrlsFromHeadlineSpans(url)
      return urls.length > 0 ? urls[0] : null
    } catch (error) {
      console.error("Error extracting URL:", error)
      return null
    }
  }
}
