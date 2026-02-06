-- ==========================================
-- 1. TASKS TABLE
-- ==========================================
CREATE TABLE public.tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL CHECK (status IN ('todo', 'in_progress', 'done')) DEFAULT 'todo',
  priority TEXT NOT NULL CHECK (priority IN ('low', 'medium', 'high')) DEFAULT 'medium',
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ -- Nullable. If NULL, task is active.
);

COMMENT ON TABLE public.tasks IS 'Core table for tracking user tasks';
COMMENT ON COLUMN public.tasks.user_id IS 'Links to the Supabase Auth User';

-- ==========================================
-- 2. PROFILES TABLE
-- ==========================================
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'user', 'manager')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

COMMENT ON TABLE public.profiles IS 'Public user profiles linked 1:1 with auth.users';
COMMENT ON COLUMN public.profiles.id IS 'References the internal Supabase Auth User ID';

-- ==========================================
-- 3. UTILITY FUNCTION: Auto-update updated_at
-- ==========================================
-- ===================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- 4. ATTACH TRIGGERS (The "Listeners")
-- ==========================================

-- Trigger for TASKS
CREATE TRIGGER set_timestamp_tasks
BEFORE UPDATE ON public.tasks
FOR EACH ROW
EXECUTE PROCEDURE public.handle_updated_at();

-- Trigger for PROFILES
CREATE TRIGGER set_timestamp_profiles
BEFORE UPDATE ON public.profiles
FOR EACH ROW
EXECUTE PROCEDURE public.handle_updated_at();

-- ==========================================
-- 5. AUTH TRIGGER: Auto-create Profile
-- ==========================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'username',
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Attach the Auth Trigger
-- Note: we attach this to 'auth.users', not a public table.
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE PROCEDURE public.handle_new_user();

-- ==========================================
-- 6. ENABLE ROW LEVEL SECURITY (RLS)
-- ==========================================
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- ==========================================
-- 7. POLICIES (The "Keycards")
-- ==========================================

-- A. POLICIES FOR 'public.profiles'
-- ---------------------------------

-- 1. Read: Users can only see their own profile
CREATE POLICY "Users can view own profile"
ON public.profiles FOR SELECT
TO authenticated
USING ( (select auth.uid()) = id );

-- 2. Update: Users can update their own profile
CREATE POLICY "Users can update own profile"
ON public.profiles FOR UPDATE
TO authenticated
USING ( (select auth.uid()) = id );

-- B. POLICIES FOR 'public.tasks'
-- ------------------------------

-- 1. Read: Users can see only their own tasks
CREATE POLICY "Users can view own tasks"
ON public.tasks FOR SELECT
TO authenticated
USING ( (select auth.uid()) = user_id );

-- 2. Insert: Users can insert tasks (but only if they assign it to themselves)
CREATE POLICY "Users can create tasks"
ON public.tasks FOR INSERT
TO authenticated
WITH CHECK ( (select auth.uid()) = user_id );

-- 3. Update: Users can update only their own tasks
CREATE POLICY "Users can update own tasks"
ON public.tasks FOR UPDATE
TO authenticated
USING ( (select auth.uid()) = user_id );

-- 4. Delete: Users can delete only their own tasks
CREATE POLICY "Users can delete own tasks"
ON public.tasks FOR DELETE
TO authenticated
USING ( (select auth.uid()) = user_id );