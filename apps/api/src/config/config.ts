import dotenv from 'dotenv';

dotenv.config();

export class Config {
  public static readonly PORT: number = parseInt(process.env.PORT || '3000', 10);

  public static readonly API_KEY: string = (() => {
    const key = process.env.API_KEY;
    if (!key) throw new Error('API_KEY is required');
    return key;
  })();

  public static readonly NEWS_API_KEY: string = (() => {
    const key = process.env.NEWS_API_KEY;
    if (!key) throw new Error('NEWS_API_KEY is required');
    return key;
  })();

  public static readonly NEWS_API_BASE_URL: string = process.env.NEWS_API_BASE_URL || 'https://newsapi.org/v2';

  public static readonly NODE_ENV: string = process.env.NODE_ENV || 'development';

  public static isDevelopment(): boolean {
    return this.NODE_ENV === 'development';
  }

  public static isProduction(): boolean {
    return this.NODE_ENV === 'production';
  }
}
