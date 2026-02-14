## News API Service

A Node.js/TypeScript API that wraps the News API (https://newsapi.org/) to provide news headlines and search functionality with Bearer token authentication.

### Features

- 🚀 **Top Headlines**: Get the latest news headlines by country
- 🔍 **News Search**: Search for news articles by keywords
- 🛡️ **Security**: Built with security best practices (Helmet, CORS, Bearer Token Authentication)
- 📝 **TypeScript**: Full TypeScript support with proper type definitions
- 🏗️ **Clean Architecture**: Separated concerns with services, controllers, and middleware
- 🔧 **Development Ready**: Hot reload with nodemon

### Project Structure

```
apps/ios/
├── mynewsapp/
│   ├── mynewsappApp.swift            # App entry point, configures root view with dependencies
│   ├── Info.plist                     # App configuration including API key reference
│   ├── Models/
│   │   ├── Article.swift              # News article model with date formatting
│   │   ├── NewsData.swift             # Wrapper for article list and result metadata
│   │   ├── NewsResponse.swift         # Top-level API response model
│   │   └── Source.swift               # News source model
│   ├── Networking/
│   │   ├── NewsService.swift          # Protocol defining the news API contract, plus SortBy/Country/Category enums
│   │   ├── NewsClient.swift           # URLSession-based implementation that calls the backend API
│   │   └── MockNewsClient.swift       # Mock implementation for testing
│   ├── ViewModels/
│   │   ├── ContentViewModel.swift     # Root view model, factory for child view models
│   │   ├── ArticlesViewModel.swift    # Manages article list loading state (idle/loading/loaded/error)
│   │   └── ArticleDetailViewModel.swift # Holds a single article for the detail screen
│   ├── UI/
│   │   ├── ContentView.swift          # Root view listing news categories
│   │   ├── ArticlesView.swift         # Displays a list of articles with pull-to-refresh
│   │   ├── ArticleDetailView.swift    # Article detail screen with image, content, and full-article link
│   │   └── SafariView.swift           # SFSafariViewController wrapper for in-app browsing
│   ├── Resources/
│   │   └── Localizable.strings        # Localized UI strings
│   └── Assets.xcassets/               # App icons and colors
├── mynewsappTests/
│   └── mynewsappTests.swift           # Unit tests
├── mynewsappUITests/
│   ├── mynewsappUITests.swift         # UI tests
│   └── mynewsappUITestsLaunchTests.swift # Launch UI tests
├── Secrets.xcconfig.example           # Template for API key configuration
└── mynewsapp.xcodeproj/              # Xcode project configuration
```

```
src/
├── config/          # Configuration management
├── controllers/     # HTTP request handlers
├── middleware/      # Express middleware
├── routes/          # API route definitions
├── services/        # Business logic and external API calls
├── types/           # TypeScript type definitions
├── app.ts           # Express application setup
└── index.ts         # Application entry point
```

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd mynewsapi
```

2. Install dependencies:
```bash
npm install
```

3. Create environment file (optional):
```bash
cp .env.example .env
```

### Configuration

The application uses the following environment variables:

- `PORT` (default: 3000) - Server port
- `API_KEY` (required) - Your API key for authenticating requests to this service
- `NEWS_API_KEY` (required) - External News API key
- `NEWS_API_BASE_URL` (default: https://newsapi.org/v2) - News API base URL
- `NODE_ENV` (default: development) - Environment mode

### Usage

#### Development
```bash
npm run dev
```

#### Production
```bash
npm run build
npm start
```

### API Endpoints

#### Authentication

All endpoints (except health check) require authentication using a Bearer token.

Add your API key to requests using the `Authorization` header with the Bearer scheme:

```
Authorization: Bearer your_api_key_here
```

#### Health Check
```
GET /api/news/health
```

#### Samples

curl -H "Authorization: Bearer your_api_key_here" "localhost:3000/api/news/search?q=bitcoin&pageSize=3&fetchFullContent=true&sortBy=publishedAt" | jq

curl -H "Authorization: Bearer your_api_key_here" "localhost:3000/api/news/top-headlines?country=us&category=business&pageSize=10&pageSize=3&fetchFullContent=true" | jq

curl -H "Authorization: Bearer your_api_key_here" http://localhost:3000/api/news/health | jq  

#### Top Headlines
```
GET /api/news/top-headlines?country=us&category=business&pageSize=10&page=1
Authorization: Bearer your_api_key_here
```

**Query Parameters:**
- `country` (optional): Country code (default: us)
- `category` (optional): News category
- `pageSize` (optional): Number of articles per page (default: 20)
- `page` (optional): Page number (default: 1)

#### Search News
```
GET /api/news/search?q=technology&pageSize=10&page=1&fetchFullContent=true
Authorization: Bearer your_api_key_here
```

**Query Parameters:**
- `q` (required): Search query
- `pageSize` (optional): Number of articles per page (default: 20)
- `page` (optional): Page number (default: 1)
- `fetchFullContent` (optional): Fetch full article content from URLs (default: false)

**Note**: When `fetchFullContent=true`, the API will make additional requests to each article's URL to extract the full content, which may increase response time but provides complete article text instead of truncated content.

### Response Format

All endpoints return JSON responses with the following structure:

```json
{
  "success": true,
  "data": {
    "status": "ok",
    "totalResults": 35,
    "articles": [
      {
        "source": {
          "id": "cnn",
          "name": "CNN"
        },
        "author": "Author Name",
        "title": "Article Title",
        "description": "Article description",
        "url": "https://example.com/article",
        "urlToImage": "https://example.com/image.jpg",
        "publishedAt": "2025-07-09T21:59:00Z",
        "content": "Article content..."
      }
    ]
  }
}
```

### Rate Limiting

The API includes in-app rate limiting to protect against abuse and cost spikes from excessive requests.

#### Rate Limits

| Endpoint | Limit | Window | Description |
|----------|-------|--------|-------------|
| `/api/news/health` | 60 requests | 1 minute | Lenient limit for health checks |
| `/api/news/top-headlines` | 100 requests | 15 minutes | Standard API limit |
| `/api/news/search` | 100 requests | 15 minutes | Standard API limit |

#### Rate Limit Response

When a client exceeds the rate limit, the API returns a `429 Too Many Requests` response:

```json
{
  "success": false,
  "message": "Too many requests, please try again later."
}
```

#### Rate Limit Headers

The API returns standard rate limit headers with each response:

- `RateLimit-Limit` - Maximum requests allowed in the window
- `RateLimit-Remaining` - Remaining requests in current window
- `RateLimit-Reset` - Time when the rate limit resets (Unix timestamp)

#### Custom Rate Limiters

The `src/middleware/rateLimiter.ts` module exports a `createRateLimiter` function for custom configurations:

```typescript
import { createRateLimiter } from './middleware/rateLimiter'

const customLimiter = createRateLimiter({
  windowMs: 60 * 1000,  // 1 minute
  max: 30,              // 30 requests
  message: 'Custom rate limit exceeded',
})
```

### Error Handling

The API includes comprehensive error handling:

- **400 Bad Request**: Invalid parameters
- **401 Unauthorized**: Missing authentication token
- **403 Forbidden**: Invalid authentication token
- **404 Not Found**: Route not found
- **500 Internal Server Error**: Server errors

Error responses follow this format:

```json
{
  "success": false,
  "error": "Error message"
}
```

### Development

#### Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build TypeScript to JavaScript
- `npm start` - Start production server
- `npm test` - Run unit tests

#### Unit Testing

The project uses Jest with TypeScript support for unit testing. Tests are located in `src/__tests__/`.

##### Test Environment

A test-specific environment file (`.env.test`) is used to provide isolated configuration:

```
NODE_ENV=test
PORT=3001
API_KEY=test-api-key-12345
NEWS_API_KEY=test-news-api-key-67890
```

##### Running Tests

```bash
npm test
```

##### Test Coverage

The test suite includes 10 tests across 3 categories:

| Category | Test | Description |
|----------|------|-------------|
| **Health Endpoint** | Public access without auth | Verifies health endpoint returns 200 without authentication |
| **Protected Endpoints** | No auth returns 401 | Verifies protected endpoints reject requests without auth |
| | Invalid auth returns 403 | Verifies protected endpoints reject invalid tokens |
| | Valid auth succeeds | Verifies protected endpoints accept valid tokens |
| **Bearer Token Format** | Missing "Bearer" prefix | Rejects auth header without Bearer prefix |
| | Empty token | Rejects empty Bearer token |
| | Basic auth instead of Bearer | Rejects Basic auth scheme |

##### Test Files

- `src/__tests__/setup.ts` - Loads test environment variables
- `src/__tests__/auth.test.ts` - Authentication and health endpoint tests

#### Architecture

The application follows a clean architecture pattern:

1. **Controllers**: Handle HTTP requests and responses
2. **Services**: Contain business logic and external API calls
3. **Routes**: Define API endpoints
4. **Middleware**: Handle cross-cutting concerns
5. **Types**: Define TypeScript interfaces
6. **Config**: Manage application configuration

### Deployment

#### Google Cloud Run

The application includes Docker configuration for deploying to Google Cloud Run with Secret Manager integration.

##### Prerequisites

1. Install the [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)
2. Authenticate: `gcloud auth login`
3. Set your project: `gcloud config set project YOUR_PROJECT_ID`

##### Quick Deploy

Run the deployment script which handles everything automatically:

```bash
./deploy.sh
```

The script will:
- Enable required Google Cloud APIs
- Create secrets in Secret Manager (prompts for values if they don't exist)
- Configure IAM permissions
- Build and deploy the container to Cloud Run

##### Manual Deployment

If you prefer to deploy manually:

```bash
# 1. Enable APIs
gcloud services enable run.googleapis.com secretmanager.googleapis.com cloudbuild.googleapis.com

# 2. Create secrets
echo -n "your-api-key" | gcloud secrets create API_KEY --data-file=-
echo -n "your-news-api-key" | gcloud secrets create NEWS_API_KEY --data-file=-

# 3. Grant Secret Manager access
PROJECT_NUMBER=$(gcloud projects describe $(gcloud config get-value project) --format="value(projectNumber)")
gcloud secrets add-iam-policy-binding API_KEY \
    --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor"
gcloud secrets add-iam-policy-binding NEWS_API_KEY \
    --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor"

# 4. Deploy
gcloud run deploy mynewsapi \
    --source . \
    --region us-central1 \
    --allow-unauthenticated \
    --set-secrets "API_KEY=API_KEY:latest,NEWS_API_KEY=NEWS_API_KEY:latest"
```

##### Deployment Files

- `Dockerfile` - Multi-stage build for production container
- `.dockerignore` - Excludes unnecessary files from Docker build
- `deploy.sh` - Automated deployment script

## News Android App

TBD

## News iOS App

### Features

- **Top Headlines**: Get the latest news headlines by country (currently defaults to US)

### Project Structure
