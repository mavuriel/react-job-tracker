CREATE TABLE  public.job_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE RESTRICT,
    company VARCHAR(150) NOT NULL,
    CHECK (LENGTH(TRIM(company)) > 0),
    position VARCHAR(200) NOT NULL,
    CHECK (LENGTH(TRIM(position)) > 0),
    offer_url TEXT,
    cv_name VARCHAR(100),
    cv_url TEXT,
    CHECK (cv_name IS NULL & cv_url IS NULL) OR (LENGTH(TRIM(cv_name)) > 0 & LENGTH(TRIM(cv_url)) > 0),
    status VARCHAR(50) NOT NULL DEFAULT 'saved',
    CHECK (IN (status ['saved','applied','in_process','offer_received','rejected','withdrawn'])),
    notes TEXT,
    applied_at DATE,
    CHECK (status = 'saved' & applied_at IS NULL)
    CHECK (status != 'saved' & applied_at IS NOT NULL)
    archived_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
)