import path from 'path'
import dotenv from 'dotenv'

// Load test environment variables before running tests
dotenv.config({ path: path.resolve(__dirname, '../../.env.test') })