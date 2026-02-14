import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { Config } from './config/config';
import newsRoutes from './routes/newsRoutes';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';

export class App {
  public app: express.Application;

  constructor() {
    this.app = express();
    this.initializeMiddlewares();
    this.initializeRoutes();
    this.initializeErrorHandling();
  }

  private initializeMiddlewares(): void {
    // Security middleware
    this.app.use(helmet());

    // CORS middleware
    this.app.use(cors({
      origin: Config.isDevelopment() ? '*' : process.env.ALLOWED_ORIGINS?.split(',') || [],
      credentials: true
    }));

    // Body parsing middleware
    this.app.use(express.json({ limit: '10mb' }));
    this.app.use(express.urlencoded({ extended: true, limit: '10mb' }));

    // Request logging in development
    if (Config.isDevelopment()) {
      this.app.use((req, res, next) => {
        console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
        next();
      });
    }
  }

  private initializeRoutes(): void {
    // API routes
    this.app.use('/api/news', newsRoutes);

    // Root endpoint
    this.app.get('/', (req, res) => {
      res.json({
        message: 'News API Service',
        version: '1.0.0',
        endpoints: {
          health: '/api/news/health',
          topHeadlines: '/api/news/top-headlines',
          search: '/api/news/search'
        }
      });
    });
  }

  private initializeErrorHandling(): void {
    // 404 handler
    this.app.use(notFoundHandler);

    // Global error handler
    this.app.use(errorHandler);
  }

  public listen(): void {
    this.app.listen(Config.PORT, () => {
      console.log(`🚀 Server is running on port ${Config.PORT}`);
      console.log(`📰 News API Service started`);
      console.log(`🌍 Environment: ${Config.NODE_ENV}`);
      console.log(`🔗 Health check: http://localhost:${Config.PORT}/api/news/health`);
    });
  }
}