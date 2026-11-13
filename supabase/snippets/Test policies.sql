-- Usuario A consulta sus candidaturas	Las obtiene
SELECT * FROM public.job_applications;
-- Usuario A consulta las candidaturas de B	No obtiene ninguna
SELECT * FROM public.job_applications WHERE user_id = 'a6afce03-92de-45b2-a791-95aed79fe752';
-- Usuario A intenta modificar una candidatura de B	No modifica ninguna fila
UPDATE public.job_applications SET company = 'updated' WHERE id = '0b04c347-a2f9-4e3a-aeed-260acf4cc3c8';
-- Usuario A intenta crear una candidatura asignada a B	PostgreSQL rechaza la operación
INSERT INTO public.job_applications (user_id, company) VALUES ('a6afce03-92de-45b2-a791-95aed79fe752', 'inserted');
-- Usuario A intenta eliminar una candidatura	Operación denegada
DELETE FROM public.job_applications WHERE id = '0b04c347-a2f9-4e3a-aeed-260acf4cc3c8'