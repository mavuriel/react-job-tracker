CREATE TABLE  public.job_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- CHECKS
    CONSTRAINT company_not_empty CHECK (LENGTH(TRIM(company)) > 0),
    CONSTRAINT position_not_empty CHECK (LENGTH(TRIM(position)) > 0),
    CONSTRAINT cv_data_valid CHECK (
        (cv_name IS NULL AND cv_url IS NULL)
        OR 
        (
            cv_name IS NOT NULL 
            AND cv_url IS NOT NULL
            AND LENGTH(TRIM(cv_name)) > 0 
            AND LENGTH(TRIM(cv_url)) > 0
        )
    ),
    CONSTRAINT status_valid CHECK (status IN ('saved','applied','in_process','offer_received','rejected','withdrawn')),
    CONSTRAINT status_applied_at_consistent CHECK (
        (status = 'saved' AND applied_at IS NULL) 
        OR 
        (status != 'saved' AND applied_at IS NOT NULL)
    )
)
