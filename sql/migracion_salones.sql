-- =========================================================
-- Migración: soporte multi-salón desde la app
-- Ejecutar en el SQL Editor de tu proyecto Supabase.
-- Requisito: ya haber corrido sql/schema.sql anteriormente
-- (es decir, las tablas `salones` y `equipos` ya existen).
-- =========================================================

-- 1. Habilitar Realtime también para la tabla `salones`
--    (equipos ya estaba habilitada en schema.sql).
ALTER PUBLICATION supabase_realtime ADD TABLE salones;

-- 2. Permitir crear y eliminar salones desde el formulario de la app.
CREATE POLICY "Permitir insercion publica salones" ON salones
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Permitir eliminacion publica salones" ON salones
  FOR DELETE USING (true);

-- 3. Permitir eliminar equipos individuales, y para que el ON DELETE
--    CASCADE funcione correctamente al borrar un salón bajo RLS.
CREATE POLICY "Permitir eliminacion publica equipos" ON equipos
  FOR DELETE USING (true);

-- Nota de seguridad: estas políticas ("true" para todos) son las mismas
-- que ya usa schema.sql para pruebas/entrega del proyecto. Para producción
-- se recomendaría restringirlas por usuario autenticado (auth.uid()).
