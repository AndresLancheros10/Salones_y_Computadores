-- =========================================================
-- Migración: 4 estados de equipo + piso/bloque/marca/serie
-- Ejecutar en el SQL Editor de Supabase (además de schema.sql
-- y migracion_salones.sql, que ya deberías tener aplicados).
-- =========================================================

-- 1. Piso y bloque del salón (opcionales, se editan directo en la BD
--    o los agregamos después desde la app si se necesita).
ALTER TABLE salones ADD COLUMN IF NOT EXISTS piso TEXT;
ALTER TABLE salones ADD COLUMN IF NOT EXISTS bloque TEXT;

-- 2. Marca y número de serie del equipo (opcionales, editables desde
--    el detalle de cada computador).
ALTER TABLE equipos ADD COLUMN IF NOT EXISTS marca TEXT;
ALTER TABLE equipos ADD COLUMN IF NOT EXISTS numero_serie TEXT;

-- 3. Nuevo estado de texto con 4 valores posibles (reemplaza el
--    booleano true/false que solo permitía Operativo/Falla).
ALTER TABLE equipos ADD COLUMN IF NOT EXISTS estado_texto TEXT;

-- Migra los datos existentes: true -> disponible, false -> danado
UPDATE equipos
SET estado_texto = CASE WHEN estado THEN 'disponible' ELSE 'danado' END
WHERE estado_texto IS NULL;

ALTER TABLE equipos ALTER COLUMN estado_texto SET DEFAULT 'disponible';
ALTER TABLE equipos ALTER COLUMN estado_texto SET NOT NULL;

-- Solo válido para estos 4 valores (evita datos corruptos)
ALTER TABLE equipos DROP CONSTRAINT IF EXISTS equipos_estado_valido;
ALTER TABLE equipos ADD CONSTRAINT equipos_estado_valido
  CHECK (estado_texto IN ('disponible', 'en_uso', 'danado', 'mantenimiento'));

-- Nota: la columna vieja "estado" (boolean) se deja sin usar por ahora,
-- por si necesitas volver atrás. La app ya no la lee ni la escribe.
-- Si en el futuro quieres eliminarla: ALTER TABLE equipos DROP COLUMN estado;
