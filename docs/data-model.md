# Modelo de datos — Job Application Tracker

**Versión:** 0.1 (MVP)
**Base de datos:** PostgreSQL (Supabase)
**Estado:** Definición inicial aprobada.

## 1. Objetivo

El modelo de datos tiene como propósito almacenar y administrar ofertas laborales de interés y candidaturas realizadas durante una búsqueda activa de empleo.

Debe permitir:

- Registrar ofertas pendientes de aplicación.
- Dar seguimiento al estado de las candidaturas.
- Identificar qué versión del CV se utilizó en cada aplicación.
- Conservar el historial de ofertas y candidaturas.
- Archivar o eliminar lógicamente registros sin perder su información.
- Garantizar que cada usuario únicamente pueda acceder a sus propios registros.

Se prioriza un modelo sencillo que cubra las necesidades del MVP sin introducir entidades o relaciones innecesarias.

## 2. Entidad principal: `job_applications`

El MVP utilizará una única tabla de negocio, relacionada con `auth.users` de Supabase.

### Estructura

| Campo         | Tipo         | Restricción  | Descripción                                              |
| ------------- | ------------ | ------------ | -------------------------------------------------------- |
| `id`          | UUID         | PK           | Identificador único del registro.                        |
| `user_id`     | UUID         | FK, NOT NULL | Propietario del registro. Referencia a `auth.users(id)`. |
| `company`     | VARCHAR(150) | NOT NULL     | Nombre de la empresa.                                    |
| `position`    | VARCHAR(200) | NOT NULL     | Nombre de la vacante.                                    |
| `offer_url`   | TEXT         | NULL         | URL de la publicación original.                          |
| `cv_name`     | VARCHAR(100) | NULL         | Nombre o versión del CV enviado.                         |
| `cv_url`      | TEXT         | NULL         | URL del CV enviado.                                      |
| `status`      | TEXT         | NOT NULL     | Estado actual de la candidatura.                         |
| `applied_at`  | DATE         | NULL         | Fecha en que se realizó la aplicación.                   |
| `notes`       | TEXT         | NULL         | Información adicional de la oferta o proceso.            |
| `archived_at` | TIMESTAMPTZ  | NULL         | Fecha de archivado.                                      |
| `deleted_at`  | TIMESTAMPTZ  | NULL         | Fecha de eliminación lógica.                             |
| `created_at`  | TIMESTAMPTZ  | NOT NULL     | Fecha de creación del registro.                          |
| `updated_at`  | TIMESTAMPTZ  | NOT NULL     | Fecha de última modificación.                            |

### Relación con usuarios

Un usuario puede tener múltiples candidaturas, pero cada candidatura pertenece a un único usuario.

`auth.users (1) → (N) job_applications`

La relación permite implementar políticas RLS para restringir el acceso a los registros según su propietario.

## 3. Estados de candidatura

El campo `status` representa exclusivamente la etapa del proceso de selección.

| Valor almacenado | Representación  | Descripción                                           |
| ---------------- | --------------- | ----------------------------------------------------- |
| `saved`          | Guardada        | Oferta de interés a la que todavía no se ha aplicado. |
| `applied`        | Aplicada        | Candidatura enviada, pendiente de respuesta.          |
| `in_process`     | En proceso      | Existe contacto o un proceso de selección activo.     |
| `offer_received` | Oferta recibida | La empresa ha presentado una propuesta.               |
| `rejected`       | Rechazada       | La candidatura no continuará.                         |
| `withdrawn`      | Retirada        | Se decidió abandonar el proceso.                      |

**Estado por defecto:** `saved`.

Los estados no tendrán transiciones rígidas durante el MVP. Se permitirá modificar manualmente cualquier estado para corregir errores o reflejar cambios en el proceso.

El archivado y la eliminación lógica no forman parte de `status`, ya que representan acciones de gestión sobre el registro y no etapas del proceso de selección.

## 4. Reglas de negocio

| ID    | Regla               | Descripción                                                                 |
| ----- | ------------------- | --------------------------------------------------------------------------- |
| RN-01 | Empresa obligatoria | No se permiten valores vacíos o compuestos únicamente por espacios.         |
| RN-02 | Puesto obligatorio  | No se permiten valores vacíos o compuestos únicamente por espacios.         |
| RN-03 | Estado inicial      | Una nueva oferta tendrá el estado `saved` por defecto.                      |
| RN-04 | Fecha de aplicación | Es obligatoria para cualquier estado diferente de `saved`.                  |
| RN-05 | Fecha futura        | `applied_at` no puede ser posterior a la fecha actual.                      |
| RN-06 | Oferta guardada     | Si `status = saved`, `applied_at` debe ser NULL.                            |
| RN-07 | URL de oferta       | Es opcional, pero debe ser una URL HTTP/HTTPS válida cuando se proporcione. |
| RN-08 | Datos del CV        | `cv_name` y `cv_url` son opcionales, pero deben completarse conjuntamente.  |
| RN-09 | Archivado           | Archivar un registro no modifica su estado ni elimina información.          |
| RN-10 | Eliminación         | La eliminación será lógica mediante `deleted_at`.                           |
| RN-11 | Restauración        | Un registro eliminado podrá restaurarse conservando sus datos anteriores.   |
| RN-12 | Privacidad          | Cada usuario únicamente puede consultar y modificar sus propios registros.  |

### Consideraciones sobre la fecha de aplicación

- Al cambiar una oferta de `saved` a `applied`, se solicitará la fecha de aplicación, sugiriendo el día actual.
- Al avanzar a otros estados, se conservará la fecha original de aplicación.
- Si una candidatura regresa a `saved`, se limpiará `applied_at`, previa confirmación en la interfaz.

### Consideraciones sobre el CV

El formulario tendrá dos campos independientes:

- Nombre o versión del CV.
- URL del documento.

La información se almacenará de manera estructurada, evitando guardar directamente cadenas Markdown.

Cuando sea necesario mostrar o exportar el documento, podrá generarse dinámicamente la representación:

`[Nombre del CV](URL)`

No se implementará almacenamiento de archivos ni administración de versiones de CV durante el MVP.

## 5. Archivado y eliminación lógica

Se utilizarán dos campos independientes:

- `archived_at`: indica que el registro fue archivado.
- `deleted_at`: indica que el registro fue eliminado lógicamente.

Ninguna de estas operaciones modifica el estado de la candidatura.

### Vistas lógicas

| Vista      | Condición                                        |
| ---------- | ------------------------------------------------ |
| Principal  | `archived_at IS NULL AND deleted_at IS NULL`     |
| Archivadas | `archived_at IS NOT NULL AND deleted_at IS NULL` |
| Eliminadas | `deleted_at IS NOT NULL`                         |

### Comportamiento

- Archivar: establece `archived_at` con la fecha actual.
- Desarchivar: establece `archived_at = NULL`.
- Eliminar: establece `deleted_at` con la fecha actual.
- Restaurar: establece `deleted_at = NULL`.

Si un registro estaba archivado antes de eliminarse, conservará `archived_at`. Al restaurarlo regresará a la vista de Archivadas.

No se implementará eliminación física desde la interfaz durante el MVP.

Los registros eliminados lógicamente quedarán excluidos de las estadísticas habituales de candidaturas.

## 6. Seguridad y acceso a los datos

Se utilizará Supabase Auth para la autenticación y Row Level Security (RLS) de PostgreSQL para la autorización.

Las políticas deberán garantizar que:

| Operación | Restricción                                                          |
| --------- | -------------------------------------------------------------------- |
| SELECT    | Consultar únicamente registros propios.                              |
| INSERT    | Crear registros asociados al usuario autenticado.                    |
| UPDATE    | Modificar únicamente registros propios, sin transferir su propiedad. |
| DELETE    | No permitir eliminación física desde el cliente.                     |

Se mantendrá habilitada la opción **Enable automatic RLS** del proyecto Supabase.

Las políticas de acceso se definirán explícitamente mediante migraciones SQL versionadas.

El frontend utilizará la clave pública de Supabase y la sesión del usuario autenticado. No se expondrán claves privilegiadas como `service_role`.

## 7. Decisiones de diseño

Para mantener reducido el alcance del MVP se establecieron las siguientes decisiones:

1. Utilizar UUID como identificador primario.
2. Almacenar `status` como TEXT con una restricción CHECK para los valores permitidos.
3. No crear una tabla independiente de empresas.
4. No crear una tabla de versiones de CV.
5. No implementar un historial de cambios de estado.
6. No implementar eliminación física desde la aplicación.
7. Mantener el archivado independiente del estado de candidatura.
8. Utilizar migraciones SQL versionadas.
9. Incorporar únicamente los índices iniciales necesarios, evaluando futuras optimizaciones según el comportamiento real de las consultas.

El modelo podrá evolucionar posteriormente si aparecen necesidades reales que justifiquen nuevas entidades, relaciones o funcionalidades.
