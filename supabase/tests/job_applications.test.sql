create extension pgtap with schema extensions;

begin;

select plan(5)
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

SELECT is( job_applications, ROW(1, 'theory', true)::users )
  FROM users
 WHERE nick = 'theory';

SELECT is (company)
SELECT (position)
SELECT (status)
SELECT (applied_at)

rollback;

drop extension if exists pgtap;

-- Empresa vacía	Rechazado
-- Puesto con solo espacios	Rechazado
-- Estado interviewing	Rechazado
-- Estado applied sin fecha	Rechazado
-- Estado saved con fecha	Rechazado
-- CV con nombre pero sin URL	Rechazado
-- CV con nombre y URL válidos	Aceptado