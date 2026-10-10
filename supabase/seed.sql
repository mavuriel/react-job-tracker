-- Empresa y puesto válidos, estado saved, sin fecha	Aceptado
INSERT INTO job_applications 
    (
        company,
        position,
    )
VALUES
    (
        'test company',
        'test position',
    );


-- Empresa vacía	Rechazado
-- Puesto con solo espacios	Rechazado
-- Estado interviewing	Rechazado
-- Estado applied sin fecha	Rechazado
-- Estado saved con fecha	Rechazado
-- CV con nombre pero sin URL	Rechazado
-- CV con nombre y URL válidos	Aceptado