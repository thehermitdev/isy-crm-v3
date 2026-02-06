/**
 * File: server/src/config/index.ts
 */

const env = process.env.NODE_ENV || 'development';

const config = {
  env,
  isProduction: env === 'production',
  isDevelopment: env === 'development',
  isTest: env === 'test',

  app: {
    port: parseInt(process.env.PORT || '3000', 10),
    apiPrefix: process.env.API_PREFIX || '/api/v1',
  },

  supabase: {
    url: process.env.SUPABASE_PUBLIC_KEY || '',
    // Using the naming convention we agree on:
    publicKey: process.env.SUPABASE_PUBLIC_KEY || '',
    secretKey: process.env.SUPABASE_SECRET_KEY || '',
  },
};

// Simple validation to ensure we don't start the app without keys
// (In production, we would want this to crash the build if missing)
if (!config.supabase.url && config.isProduction) {
  throw new Error(
    'FATAL ERROR: SUPABASE_URL is mission in production environment'
  );
}

export default config;
