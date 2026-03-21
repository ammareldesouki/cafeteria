import { config } from 'dotenv';
import { existsSync } from 'fs';
import { resolve } from 'path';

/**
 * 1) dotenv loading order
 *    - .env (common)
 *    - .env.{NODE_ENV}.local (environment-specific overrides, if present)
 */
config(); // load .env
const nodeEnv = process.env.NODE_ENV || 'development';
const layerPath = resolve(process.cwd(), `.env.${nodeEnv}.local`);
if (existsSync(layerPath)) {
  config({ path: layerPath });
}

// Simple environment variable wrapper (minimal processing, no zod)

const rawEnv = process.env;

export const NODE_ENV = (rawEnv.NODE_ENV as 'development' | 'production' | 'test') || 'development';
export const PORT = rawEnv.PORT ? Number(rawEnv.PORT) : undefined; // app.ts falls back to 3000
export const SECRET_KEY = rawEnv.SECRET_KEY || 'secret';

export const LOG_FORMAT = rawEnv.LOG_FORMAT; // app.ts falls back to 'dev'
export const LOG_DIR = rawEnv.LOG_DIR || 'logs';
export const LOG_LEVEL = rawEnv.LOG_LEVEL || 'info';

export const ORIGIN = rawEnv.ORIGIN || '*';
export const CREDENTIALS = rawEnv.CREDENTIALS === 'true';

export const SENTRY_DSN = rawEnv.SENTRY_DSN || '';
export const REDIS_URL = rawEnv.REDIS_URL || 'redis://localhost:6379';
export const API_SERVER_URL = rawEnv.API_SERVER_URL;

// Database - single connection for app and better-auth
export const DATABASE_URL = rawEnv.DATABASE_URL || 'mongodb://localhost:27017/cic_main';

// Better Auth
export const BETTER_AUTH_URL = rawEnv.BETTER_AUTH_URL || 'http://localhost:3001';
export const BETTER_AUTH_SECRET = rawEnv.BETTER_AUTH_SECRET || 'secret';

// Provide CORS origins as an array (empty if not set)
export const CORS_ORIGIN_LIST =
  rawEnv.CORS_ORIGINS?.split(',')
    .map((s) => s.trim())
    .filter(Boolean) ?? [];
