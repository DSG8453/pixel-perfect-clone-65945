-- Clean out unowned legacy snapshots
DELETE FROM public.csx_snapshots;

-- Add owner to csx_snapshots
ALTER TABLE public.csx_snapshots
  ADD COLUMN user_id UUID NOT NULL;

CREATE INDEX idx_csx_snapshots_user ON public.csx_snapshots(user_id, uploaded_at DESC);

-- Replace permissive policies with per-user ones
DROP POLICY IF EXISTS "Public read csx_snapshots"   ON public.csx_snapshots;
DROP POLICY IF EXISTS "Public insert csx_snapshots" ON public.csx_snapshots;
DROP POLICY IF EXISTS "Public delete csx_snapshots" ON public.csx_snapshots;

CREATE POLICY "Users read own csx_snapshots"
  ON public.csx_snapshots FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users insert own csx_snapshots"
  ON public.csx_snapshots FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users delete own csx_snapshots"
  ON public.csx_snapshots FOR DELETE
  USING (auth.uid() = user_id);

-- New table: full dashboard state per user
CREATE TABLE public.app_state (
  user_id UUID NOT NULL PRIMARY KEY,
  state JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.app_state ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own app_state"
  ON public.app_state FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users insert own app_state"
  ON public.app_state FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users update own app_state"
  ON public.app_state FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users delete own app_state"
  ON public.app_state FOR DELETE
  USING (auth.uid() = user_id);