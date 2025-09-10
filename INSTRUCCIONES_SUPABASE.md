# 📋 INSTRUCCIONES PARA AGREGAR A SUPABASE

## 🚨 **IMPORTANTE: EJECUTAR EN ESTE ORDEN EXACTO**

### **📥 PASO 1: Ir a Supabase Dashboard**
1. Ve a tu proyecto en Supabase
2. Click en **"SQL Editor"** (en el menú lateral)
3. Ejecuta cada archivo en el orden indicado abajo

---

### **📋 ORDEN DE EJECUCIÓN (CRÍTICO):**

#### **🔧 1. PRIMERO - Sistema de Mantenimiento:**
```sql
-- Copia y pega todo el contenido de:
SQL_MANTENIMIENTO_TOTAL_SISTEMA.sql
```
**⚠️ Este DEBE ser el primero porque otros sistemas lo necesitan**

#### **⏰ 2. FASE 1 - Timeouts:**
```sql
-- Copia y pega todo el contenido de:
SQL_FASE_1_TIMEOUTS.sql
```

#### **📝 3. FASE 2 - Sanciones:**
```sql
-- Copia y pega todo el contenido de:
SQL_FASE_2_SANCIONES.sql
```

#### **🧠 4. FASE 3 - Asignación Inteligente:**
```sql
-- Copia y pega todo el contenido de:
SQL_FASE_3_ASIGNACION_INTELIGENTE.sql
```

#### **💬 5. FASE 4 - Chat Directo:**
```sql
-- Copia y pega todo el contenido de:
SQL_FASE_4_CHAT_DIRECTO.sql
```

#### **🔍 6. FASE 5 - Detección de Diferencias:**
```sql
-- Copia y pega todo el contenido de:
SQL_FASE_5_DETECCION_DIFERENCIAS.sql
```

#### **⏱️ 7. FASE 6 - Contador Renta Autos:**
```sql
-- Copia y pega todo el contenido de:
SQL_FASE_6_CONTADOR_RENTA_AUTOS.sql
```

#### **🔔 8. FASE 7 - Notificaciones con Sonido:**
```sql
-- Copia y pega todo el contenido de:
SQL_FASE_7_NOTIFICACIONES_SONIDO.sql
```

#### **⚡ 9. FASE 8 - Triggers Master:**
```sql
-- Copia y pega todo el contenido de:
SQL_FASE_8_TRIGGERS_MASTER.sql
```

#### **🤖 10. FASE 9 - Jobs Automáticos:**
```sql
-- Copia y pega todo el contenido de:
SQL_FASE_9_JOBS_AUTOMATICOS.sql
```

---

### **✅ PASO 2: Verificar que Todo Funciona**

Después de ejecutar todos los SQL, verifica con estas consultas:

#### **🔍 Ver todas las nuevas tablas creadas:**
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name LIKE '%timeout%' 
   OR table_name LIKE '%sanction%'
   OR table_name LIKE '%delivery_%'
   OR table_name LIKE '%chat_%'
   OR table_name LIKE '%verification%'
   OR table_name LIKE '%rental%'
   OR table_name LIKE '%notification%'
   OR table_name LIKE '%maintenance%'
   OR table_name LIKE '%job%'
ORDER BY table_name;
```

#### **⚡ Ver todas las funciones creadas:**
```sql
SELECT routine_name, routine_type
FROM information_schema.routines 
WHERE routine_schema = 'public'
  AND routine_name LIKE '%job_%'
   OR routine_name LIKE '%auto_%'
   OR routine_name LIKE '%process_%'
   OR routine_name LIKE '%maintenance_%'
ORDER BY routine_name;
```

#### **🎛️ Ver todos los triggers creados:**
```sql
SELECT trigger_name, table_name, action_timing, event_manipulation
FROM information_schema.triggers 
WHERE trigger_schema = 'public'
ORDER BY table_name, trigger_name;
```

---

### **🚨 PASO 3: Probar el Sistema de Mantenimiento**

#### **Activar Mantenimiento (DETIENE TODO):**
```sql
SELECT * FROM activate_total_maintenance_mode(
    (SELECT id FROM users WHERE role = 'admin' LIMIT 1), -- Tu ID de admin
    'Prueba del sistema de mantenimiento',
    30, -- 30 minutos
    'Sistema en mantenimiento de prueba'
);
```

#### **Ver Estado de Mantenimiento:**
```sql
SELECT * FROM get_maintenance_status();
SELECT * FROM maintenance_dashboard;
```

#### **Desactivar Mantenimiento (RESTAURA TODO):**
```sql
SELECT * FROM deactivate_total_maintenance_mode(
    (SELECT id FROM users WHERE role = 'admin' LIMIT 1)
);
```

---

### **🤖 PASO 4: Probar Jobs Automáticos**

```sql
-- Ejecutar todos los jobs manualmente:
SELECT * FROM execute_scheduled_jobs();

-- Ver estadísticas de jobs:
SELECT * FROM jobs_monitor;
SELECT * FROM get_jobs_statistics(1);
```

---

### **🔔 PASO 5: Probar Notificaciones**

```sql
-- Crear una notificación de prueba:
SELECT * FROM create_smart_notification(
    (SELECT id FROM users WHERE role = 'vendor' LIMIT 1),
    'new_order',
    'Pedido de Prueba',
    'Este es un pedido de prueba del sistema',
    '{"test": true}'::jsonb,
    'high'
);

-- Ver notificaciones:
SELECT * FROM notifications_dashboard;
```

---

### **💬 PASO 6: Probar Chat Directo**

```sql
-- Crear una conversación de prueba:
SELECT create_chat_conversation(
    (SELECT id FROM orders LIMIT 1), -- ID de un pedido
    (SELECT id FROM users WHERE role = 'vendor' LIMIT 1),
    (SELECT id FROM users WHERE role = 'delivery' LIMIT 1)
);

-- Enviar mensaje de prueba:
SELECT * FROM send_chat_message(
    (SELECT id FROM chat_conversations LIMIT 1),
    (SELECT id FROM users WHERE role = 'vendor' LIMIT 1),
    'text',
    'Hola, este es un mensaje de prueba'
);
```

---

## ⚠️ **ERRORES COMUNES:**

### **Si aparece "relation does not exist":**
- Asegúrate de ejecutar los archivos en el orden correcto
- Algunos archivos dependen de tablas creadas en archivos anteriores

### **Si aparece "function does not exist":**
- Verifica que el archivo SQL se ejecutó completamente
- Algunos archivos tienen múltiples funciones

### **Si aparece "permission denied":**
- Asegúrate de tener permisos de admin en Supabase
- Algunos comandos requieren permisos especiales

---

## 🎉 **¡UNA VEZ COMPLETADO, TU SISTEMA ESTARÁ 100% FUNCIONAL!**

### **✅ TENDRÁS:**
- 🔧 **Mantenimiento total** que para todo el sistema
- ⏰ **Timeouts automáticos** con reasignación
- 📝 **Sanciones automáticas** 
- 🧠 **Asignación inteligente** de repartidores
- 💬 **Chat en tiempo real** 
- 🔍 **Detección de diferencias**
- ⏱️ **Sistema de renta de autos**
- 🔔 **Notificaciones con sonido**
- ⚡ **Triggers automáticos**
- 🤖 **Jobs que se ejecutan solos**

---

### 🚀 **¡EJECUTA TODO EN SUPABASE Y TENDRÁS EL SISTEMA COMPLETO!**



