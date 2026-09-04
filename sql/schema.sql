-- =========================================================
-- Monitor Salón 317 - Esquema de base de datos (Supabase)
-- Ejecutar en el SQL Editor de tu proyecto Supabase
-- =========================================================

-- 1. Tabla de Salones
CREATE TABLE salones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL -- Ej: 'Salón 317'
);

-- 2. Tabla de Equipos
CREATE TABLE equipos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo TEXT NOT NULL,           -- Ej: 'PC-317-01'
  estado BOOLEAN DEFAULT true,    -- true = OPERATIVO, false = FALLA
  observacion TEXT,
  salon_id UUID REFERENCES salones(id) ON DELETE CASCADE,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Habilitar Replicación Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE equipos;

-- 4. (Opcional pero recomendado) Políticas RLS para poder leer/escribir
--    mientras pruebas el proyecto (ajusta esto para producción).
ALTER TABLE salones ENABLE ROW LEVEL SECURITY;
ALTER TABLE equipos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir lectura publica salones" ON salones
  FOR SELECT USING (true);

CREATE POLICY "Permitir lectura publica equipos" ON equipos
  FOR SELECT USING (true);

CREATE POLICY "Permitir escritura publica equipos" ON equipos
  FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Permitir insercion publica equipos" ON equipos
  FOR INSERT WITH CHECK (true);

-- 5. Datos de ejemplo: 1 salón con 30 equipos
INSERT INTO salones (nombre) VALUES ('Salón 317');

INSERT INTO equipos (codigo, estado, salon_id)
SELECT
  'PC-317-' || LPAD(n::text, 2, '0'),
  true,
  (SELECT id FROM salones WHERE nombre = 'Salón 317')
FROM generate_series(1, 30) AS n;
