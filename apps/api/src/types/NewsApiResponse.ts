import { NewsArticle } from './NewsArticle';

export interface NewsApiResponse {
  status: string;
  totalResults: number;
  articles: NewsArticle[];
}