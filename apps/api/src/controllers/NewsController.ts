import { Request, Response } from 'express';
import { NewsApiService } from '../services/NewsApiService';
import { NewsQueryParams } from '../types';

export class NewsController {
  private newsService: NewsApiService;

  constructor() {
    this.newsService = new NewsApiService();
  }

  public async getTopHeadlines(req: Request, res: Response): Promise<void> {
    try {
      const params: NewsQueryParams = {
        country: req.query.country as string || 'us',
        category: req.query.category as string,
        pageSize: req.query.pageSize ? parseInt(req.query.pageSize as string, 10) : undefined,
        page: req.query.page ? parseInt(req.query.page as string, 10) : undefined
      };

      const news = await this.newsService.getTopHeadlines(params);

      res.status(200).json({
        success: true,
        data: news
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Internal server error'
      });
    }
  }

  public async searchNews(req: Request, res: Response): Promise<void> {
    try {
      const { q } = req.query;

      if (!q || typeof q !== 'string') {
        res.status(400).json({
          success: false,
          error: 'Query parameter "q" is required and must be a string'
        });
        return;
      }

      const params: NewsQueryParams = {
        pageSize: req.query.pageSize ? parseInt(req.query.pageSize as string, 10) : undefined,
        page: req.query.page ? parseInt(req.query.page as string, 10) : undefined,
        fetchFullContent: req.query.fetchFullContent === 'true'
      };

      const news = await this.newsService.searchNews(q, params);

      res.status(200).json({
        success: true,
        data: news
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Internal server error'
      });
    }
  }

  public async healthCheck(req: Request, res: Response): Promise<void> {
    res.status(200).json({
      success: true,
      message: 'News API service is running',
      timestamp: new Date().toISOString()
    });
  }
}