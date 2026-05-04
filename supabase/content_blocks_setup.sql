-- ──────────────────────────────────────────────────────────────────────────────
-- SETUP: Columna updated_at y políticas RLS para contenido editable
-- Ejecuta este script en Supabase SQL Editor (una sola vez)
-- ──────────────────────────────────────────────────────────────────────────────

-- 1. Agregar columna updated_at si no existe
ALTER TABLE museum_config
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();

-- 2. Eliminar políticas viejas (para evitar conflictos)
DROP POLICY IF EXISTS "Public read museum_config"  ON museum_config;
DROP POLICY IF EXISTS "Admin write museum_config"   ON museum_config;

-- 3. Habilitar RLS
ALTER TABLE museum_config ENABLE ROW LEVEL SECURITY;

-- 4. Lectura pública (todos los usuarios, incluso sin sesión)
CREATE POLICY "Public read museum_config"
  ON museum_config
  FOR SELECT
  USING (true);

-- 5. Escritura solo para administradores
CREATE POLICY "Admin write museum_config"
  ON museum_config
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
        AND profiles.role IN ('admin', 'superadmin')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
        AND profiles.role IN ('admin', 'superadmin')
    )
  );
