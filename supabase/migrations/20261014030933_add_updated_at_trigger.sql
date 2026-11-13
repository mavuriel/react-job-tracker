CREATE FUNCTION updated_at_update() 
RETURNS trigger AS $$
    BEGIN
        NEW.updated_at := now();
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER updated_at_trigger
BEFORE UPDATE ON public.job_applications
FOR EACH ROW
EXECUTE FUNCTION updated_at_update();