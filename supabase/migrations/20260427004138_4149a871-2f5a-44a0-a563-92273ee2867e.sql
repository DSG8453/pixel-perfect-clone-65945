CREATE TABLE public.csx_snapshots (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  file_name TEXT NOT NULL,
  uploaded_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  load_count INTEGER NOT NULL DEFAULT 0,
  loads JSONB NOT NULL,
  diff_summary JSONB
);

ALTER TABLE public.csx_snapshots ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read csx_snapshots"
  ON public.csx_snapshots FOR SELECT
  USING (true);

CREATE POLICY "Public insert csx_snapshots"
  ON public.csx_snapshots FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Public delete csx_snapshots"
  ON public.csx_snapshots FOR DELETE
  USING (true);

CREATE INDEX idx_csx_snapshots_uploaded_at ON public.csx_snapshots(uploaded_at DESC);