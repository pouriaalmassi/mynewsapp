import request from "supertest"
import express from "express"
import { App } from "../app"

describe("News API Authentication Tests", () => {
  let app: express.Application

  const TEST_API_KEY = "test-api-key-12345"
  const TEST_INVALID_API_KEY = "invalid_key"

  beforeAll(() => {
    const appInstance = new App()
    app = appInstance.app
  })

  describe("Authentication Protected Endpoints - Health", () => {
    describe("GET /api/news/health", () => {
      it("should reject requests without authentication with 401", async () => {
        const response = await request(app)
          .get("/api/news/health")

        expect(response.status).toBe(401)
        expect(response.body).toMatchObject({
          success: false,
          message: expect.stringContaining("Authentication token is missing"),
        })
      })
      
      it("should reject requests with invalid authentication with 403", async () => {
        const response = await request(app)
          .get("/api/news/health")
          .set("Authorization", `Bearer ${TEST_INVALID_API_KEY}`)

        expect(response.status).toBe(403)
        expect(response.body).toMatchObject({
          success: false,
          message: expect.stringContaining("Invalid authentication token"),
        })
      })

      it("should accept requests with valid authentication", async () => {
        const response = await request(app)
          .get("/api/news/health")
          .set("Authorization", `Bearer ${TEST_API_KEY}`)

        // May be 200 or 500 depending on News API availability,
        // but should not be 401 or 403
        expect(response.status).not.toBe(401)
        expect(response.status).not.toBe(403)
      })
    })
  })

  describe("Authentication Protected Endpoints - Content", () => {
    describe("GET /api/news/top-headlines", () => {
      it("should reject requests without authentication with 401", async () => {
        const response = await request(app).get("/api/news/top-headlines")

        expect(response.status).toBe(401)
        expect(response.body).toMatchObject({
          success: false,
          message: expect.stringContaining("Authentication token is missing"),
        })
      })

      it("should reject requests with invalid authentication with 403", async () => {
        const response = await request(app)
          .get("/api/news/top-headlines")
          .set("Authorization", `Bearer ${TEST_INVALID_API_KEY}`)

        expect(response.status).toBe(403)
        expect(response.body).toMatchObject({
          success: false,
          message: expect.stringContaining("Invalid authentication token"),
        })
      })

      it("should accept requests with valid authentication", async () => {
        const response = await request(app)
          .get("/api/news/top-headlines")
          .set("Authorization", `Bearer ${TEST_API_KEY}`)

        // May be 200 or 500 depending on News API availability,
        // but should not be 401 or 403
        expect(response.status).not.toBe(401)
        expect(response.status).not.toBe(403)
      })
    })

    describe("GET /api/news/search", () => {
      it("should reject requests without authentication with 401", async () => {
        const response = await request(app).get("/api/news/search?q=test")

        expect(response.status).toBe(401)
        expect(response.body).toMatchObject({
          success: false,
          message: expect.stringContaining("Authentication token is missing"),
        })
      })

      it("should reject requests with invalid authentication with 403", async () => {
        const response = await request(app)
          .get("/api/news/search?q=test")
          .set("Authorization", `Bearer ${TEST_INVALID_API_KEY}`)

        expect(response.status).toBe(403)
        expect(response.body).toMatchObject({
          success: false,
          message: expect.stringContaining("Invalid authentication token"),
        })
      })

      it("should accept requests with valid authentication", async () => {
        const response = await request(app)
          .get("/api/news/search?q=test")
          .set("Authorization", `Bearer ${TEST_API_KEY}`)

        // May be 200 or 500 depending on News API availability,
        // but should not be 401 or 403
        expect(response.status).not.toBe(401)
        expect(response.status).not.toBe(403)
      })
    })
  })

  describe("Bearer Token Format Validation", () => {
    it("should reject requests with malformed Authorization header (no Bearer prefix)", async () => {
      const response = await request(app)
        .get("/api/news/top-headlines")
        .set("Authorization", TEST_API_KEY)

      expect(response.status).toBe(401)
    })

    it("should reject requests with empty Bearer token", async () => {
      const response = await request(app)
        .get("/api/news/top-headlines")
        .set("Authorization", "Bearer ")

      expect(response.status).toBe(401)
    })

    it("should reject requests with Basic auth instead of Bearer", async () => {
      const response = await request(app)
        .get("/api/news/top-headlines")
        .set("Authorization", `Basic ${TEST_API_KEY}`)

      expect(response.status).toBe(401)
    })
  })
})
