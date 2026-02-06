const env = {
  api: {
    baseUrl: import.meta.env.VITE_API_URL || 'http://localhost:3000/api/v1',
  },
  supabase: {
    url: import.meta.env.VITE_SUPABASE_URL as string,
    key: import.meta.env.VITE_SUPABASE_PUBLIC_KEY as string,
  },
};

if (!env.supabase.url || !env.supabase.key) {
  console.error(
    '❌ Critical: Supabase URL or KEY is missing in Environment Variables.'
  );
}

export default env;
