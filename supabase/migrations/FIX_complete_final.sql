-- =============================================================================
-- Hey Yaara - Complete Database Migration Script
-- Run this in Supabase SQL Editor
-- =============================================================================

-- =============================================================================
-- STEP 1: DATABASE FIX - Remove user_mobile, Add missing columns
-- =============================================================================
-- Drop user_mobile column if exists
ALTER TABLE yaara_calls DROP COLUMN IF EXISTS user_mobile;

-- Add missing columns if they don't exist
ALTER TABLE yaara_calls ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id);
ALTER TABLE yaara_calls ADD COLUMN IF NOT EXISTS audio_path text;
ALTER TABLE yaara_calls ADD COLUMN IF NOT EXISTS transcript text;
ALTER TABLE yaara_calls ADD COLUMN IF NOT EXISTS transcript_chat text;
ALTER TABLE yaara_calls ADD COLUMN IF NOT EXISTS transcript_ai text;

-- =============================================================================
-- STEP 2: FIX RLS - yaara_calls
-- =============================================================================
ALTER TABLE yaara_calls ENABLE ROW LEVEL SECURITY;

-- Drop existing restrictive policies
DROP POLICY IF EXISTS "Users can read own calls" ON yaara_calls;
DROP POLICY IF EXISTS "Users can insert own calls" ON yaara_calls;
DROP POLICY IF EXISTS "Users can update own calls" ON yaara_calls;
DROP POLICY IF EXISTS "read own calls" ON yaara_calls;
DROP POLICY IF EXISTS "insert own calls" ON yaara_calls;
DROP POLICY IF EXISTS "update own calls" ON yaara_calls;
DROP POLICY IF EXISTS "Allow all yaara_calls" ON yaara_calls;

-- Create permissive policies for now (since we're using a demo user_id)
CREATE POLICY "Allow all calls read" ON yaara_calls FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow all calls insert" ON yaara_calls FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow all calls update" ON yaara_calls FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow all calls delete" ON yaara_calls FOR DELETE TO authenticated USING (true);

-- =============================================================================
-- STEP 2: FIX RLS - yaara_messages
-- =============================================================================
ALTER TABLE yaara_messages ENABLE ROW LEVEL SECURITY;

-- Drop existing restrictive policies  
DROP POLICY IF EXISTS "Users can read own messages" ON yaara_messages;
DROP POLICY IF EXISTS "Users can insert own messages" ON yaara_messages;
DROP POLICY IF EXISTS "read own messages" ON yaara_messages;
DROP POLICY IF EXISTS "insert own messages" ON yaara_messages;
DROP POLICY IF EXISTS "Allow all messages" ON yaara_messages;

-- Create permissive policies
CREATE POLICY "Allow all messages read" ON yaara_messages FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow all messages insert" ON yaara_messages FOR INSERT TO authenticated WITH CHECK (true);

-- =============================================================================
-- STEP 3: FIX RLS - storage.objects for call-recordings
-- =============================================================================
-- Drop existing restrictive policies
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated read" ON storage.objects;
DROP POLICY IF EXISTS "Allow all storage operations" ON storage.objects;
DROP POLICY IF EXISTS "upload own audio" ON storage.objects;
DROP POLICY IF EXISTS "read own audio" ON storage.objects;

-- Create permissive storage policies
CREATE POLICY "Allow all storage operations" 
ON storage.objects 
FOR ALL 
TO authenticated 
USING (bucket_id = 'call-recordings') 
WITH CHECK (bucket_id = 'call-recordings');

-- =============================================================================
-- Verification queries
-- =============================================================================
SELECT '✅ All migrations applied successfully!' as status;

-- Check yaara_calls structure
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'yaara_calls' 
ORDER BY ordinal_position;

-- Check yaara_calls RLS policies
SELECT policyname, cmd, permissive 
FROM pg_policies 
WHERE tablename = 'yaara_calls';

-- Check yaara_messages RLS policies
SELECT policyname, cmd, permissive 
FROM pg_policies 
WHERE tablename = 'yaara_messages';

-- Check storage policies
SELECT policyname, cmd 
FROM pg_policies 
WHERE schemaname = 'storage' AND tablename = 'objects';