-- =============================================================================
-- Complete Database Fix - Run ALL of this in Supabase SQL Editor
-- =============================================================================

-- STEP 1: Fix user_mobile - make it nullable first if it exists
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'yaara_calls' AND column_name = 'user_mobile') THEN
        ALTER TABLE yaara_calls ALTER COLUMN user_mobile DROP NOT NULL;
    END IF;
END $$;

-- STEP 2: Add ALL missing columns to yaara_calls
ALTER TABLE yaara_calls ADD COLUMN IF NOT EXISTS user_id uuid;
ALTER TABLE yaara_calls ADD COLUMN IF NOT EXISTS audio_path text;
ALTER TABLE yaara_calls ADD COLUMN IF NOT EXISTS transcript text;
ALTER TABLE yaara_calls ADD COLUMN IF NOT EXISTS transcript_chat text;
ALTER TABLE yaara_calls ADD COLUMN IF NOT EXISTS transcript_ai text;
ALTER TABLE yaara_calls ADD COLUMN IF NOT EXISTS start_time timestamptz;
ALTER TABLE yaara_calls ADD COLUMN IF NOT EXISTS end_time timestamptz;
ALTER TABLE yaara_calls ADD COLUMN IF NOT EXISTS duration int;
ALTER TABLE yaara_calls ADD COLUMN IF NOT EXISTS status text;
ALTER TABLE yaara_calls ADD COLUMN IF NOT EXISTS created_at timestamptz DEFAULT NOW();
ALTER TABLE yaara_calls ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT NOW();

-- STEP 3: Fix RLS on yaara_calls
ALTER TABLE yaara_calls ENABLE ROW LEVEL SECURITY;

-- Drop any existing policies
DROP POLICY IF EXISTS "Users can read own calls" ON yaara_calls;
DROP POLICY IF EXISTS "Users can insert own calls" ON yaara_calls;
DROP POLICY IF EXISTS "Users can update own calls" ON yaara_calls;
DROP POLICY IF EXISTS "read own calls" ON yaara_calls;
DROP POLICY IF EXISTS "insert own calls" ON yaara_calls;
DROP POLICY IF EXISTS "update own calls" ON yaara_calls;

-- Create permissive policies
CREATE POLICY "Allow all yaara_calls" ON yaara_calls FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- STEP 4: Fix RLS on yaara_messages
ALTER TABLE yaara_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own messages" ON yaara_messages;
DROP POLICY IF EXISTS "Users can insert own messages" ON yaara_messages;
DROP POLICY IF EXISTS "read own messages" ON yaara_messages;
DROP POLICY IF EXISTS "insert own messages" ON yaara_messages;

CREATE POLICY "Allow all yaara_messages" ON yaara_messages FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- STEP 5: Fix Storage RLS for call-recordings bucket
DROP POLICY IF EXISTS "Allow all storage" ON storage.objects;
CREATE POLICY "Allow all storage" ON storage.objects FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- =============================================================================
-- VERIFICATION - Check what columns we now have
-- =============================================================================
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'yaara_calls' 
ORDER BY ordinal_position;

-- Check RLS is enabled
SELECT relname, relrowsecurity 
FROM pg_class 
WHERE relname = 'yaara_calls';

-- Check policies
SELECT policyname, cmd, permissive, roles 
FROM pg_policies 
WHERE tablename IN ('yaara_calls', 'yaara_messages');

SELECT '✅ Database fix complete!' as status;