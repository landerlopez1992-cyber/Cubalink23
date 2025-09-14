-- ========================== ARREGLAR TABLA RECHARGE_HISTORY ==========================
-- Script para agregar la columna 'fee' faltante

-- ==================== VERIFICAR TABLA ACTUAL ====================
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'recharge_history' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- ==================== AGREGAR COLUMNA FEE ====================
ALTER TABLE recharge_history 
ADD COLUMN IF NOT EXISTS fee DECIMAL(10,2) DEFAULT 0.0;

-- ==================== VERIFICAR ESTRUCTURA FINAL ====================
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'recharge_history' 
AND table_schema = 'public'
ORDER BY ordinal_position;


