import { Router } from 'express'
import { NewsController } from '../controllers/NewsController'
import { bearerAuth } from '../middleware/auth'
import {
  generalRateLimiter,
} from '../middleware/rateLimiter'

const router = Router()
const newsController = new NewsController()

// Health check endpoint - publicly accessible but rate limited
router.get(
  '/health',
  generalRateLimiter,
  bearerAuth,
  newsController.healthCheck.bind(newsController)
)

// Protected routes - require Bearer token authentication and rate limiting
router.get(
  '/top-headlines',
  generalRateLimiter,
  bearerAuth,
  newsController.getTopHeadlines.bind(newsController)
)

// Search news - requires Bearer token authentication and rate limiting
router.get(
  '/search',
  generalRateLimiter,
  bearerAuth,
  newsController.searchNews.bind(newsController)
)

export default router
