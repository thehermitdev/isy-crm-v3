-- ====================================================
-- RLS VERIFICATION SCRIPT
-- ====================================================

-- 1. CLEANUP (Reset previous tests)
TRUNCATE TABLE auth.users CASCADE; -- This wipes users AND profiles/tasks (because of CASCADE)

-- 2. SETUP DUMMY USERS
-- We manually insert into auth.users. 
-- The "Trigger" we wrote in Task 1-Step 4 will automatically create the Profiles!
INSERT INTO auth.users (id, email, raw_user_meta_data) VALUES
  ('11111111-1111-1111-1111-111111111111', 'alice@test.com', '{"username": "alice", "full_name": "Alice Wonderland"}'),
  ('22222222-2222-2222-2222-222222222222', 'bob@test.com', '{"username": "bob", "full_name": "Bob Builder"}');

-- 3. SETUP TASKS
-- Create a task for Alice
INSERT INTO public.tasks (title, user_id, status) VALUES 
  ('Alice Secret Task', '11111111-1111-1111-1111-111111111111', 'todo');

-- Create a task for Bob
INSERT INTO public.tasks (title, user_id, status) VALUES 
  ('Bob Public Task', '22222222-2222-2222-2222-222222222222', 'in_progress');

-- ====================================================
-- TEST CASE 1: ANONYMOUS ACCESS (The Stranger)
-- ====================================================
-- Switch to "anon" role (like a user who hasn't logged in)
SET ROLE anon;

-- Try to read data
SELECT 'TEST 1: Anon View' as test_name, count(*) as visible_rows FROM public.tasks;
-- EXPECTED RESULT: visible_rows = 0


-- ====================================================
-- TEST CASE 2: ALICE ACCESS (The Owner)
-- ====================================================
-- Switch to "authenticated" role and pretend to be Alice
SET ROLE authenticated;
SET request.jwt.claim.sub = '11111111-1111-1111-1111-111111111111';

-- Try to read data
SELECT 'TEST 2: Alice View' as test_name, title, user_id FROM public.tasks;
-- EXPECTED RESULT: Should see ONLY "Alice Secret Task"

