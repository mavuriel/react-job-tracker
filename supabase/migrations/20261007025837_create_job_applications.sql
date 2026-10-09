CREATE TABLE  public.job_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE RESTRICT,
    company VARCHAR(150) NOT NULL,
    position VARCHAR(200) NOT NULL,
    offer_url TEXT,
    cv_name VARCHAR(100),
    cv_url TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'saved',
    notes TEXT,
    applied_at DATE,
    archived_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
)