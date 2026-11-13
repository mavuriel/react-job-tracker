ALTER TABLE public.job_applications ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON public.job_applications FROM anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON public.job_applications TO authenticated;

CREATE POLICY "Allow users to get their own job applications" 
    ON public.job_applications FOR SELECT
    TO authenticated
    USING ((select auth.uid()) = user_id);

CREATE POLICY "Allow users to insert their own job applications"
    ON public.job_applications FOR INSERT
    TO authenticated
    WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY "Allow users to update their own job applications"
    ON public.job_applications FOR UPDATE
    TO authenticated
    USING ((select auth.uid()) = user_id)
    WITH CHECK ((select auth.uid()) = user_id);

