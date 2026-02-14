import { Request, Response, NextFunction } from "express"
import { Config } from "../../config/config"

// Constants
const BEARER_PREFIX = "Bearer "

/**
 * Interface extending Express Request to include potential user data
 */
interface AuthenticatedRequest extends Request {
  user?: {
    isAuthenticated: boolean
    // Add any additional user properties as needed
  }
}

/**
 * Extracts the token from the Authorization header
 * @param authHeader The Authorization header value
 * @returns The token or null if not found/invalid
 */
const extractBearerToken = (authHeader?: string): string | null => {
  if (!authHeader || !authHeader.startsWith(BEARER_PREFIX)) {
    return null
  }

  return authHeader.slice(BEARER_PREFIX.length)
}

/**
 * Middleware to validate API key from Bearer token in Authorization header
 */
export const bearerAuth = (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): void => {
  const authHeader = req.header("Authorization")
  const token = extractBearerToken(authHeader)

  // If token is missing, return 401 Unauthorized
  if (!token) {
    res.status(401).json({
      success: false,
      message:
        "Authentication token is missing. Please provide a valid token using Bearer authentication.",
    })
    return
  }

  // If token doesn't match our API key, return 403 Forbidden
  if (token !== Config.API_KEY) {
    res.status(403).json({
      success: false,
      message: "Invalid authentication token. Access denied.",
    })
    return
  }

  // Set authenticated user information on request object
  req.user = {
    isAuthenticated: true,
  }

  // Continue to the next middleware or route handler
  next()
}

/**
 * Optional middleware for routes that don't require authentication
 * but can use it if provided
 */
export const optionalBearerAuth = (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): void => {
  const authHeader = req.header("Authorization")
  const token = extractBearerToken(authHeader)

  if (token && token === Config.API_KEY) {
    req.user = {
      isAuthenticated: true,
    }
  }

  next()
}
