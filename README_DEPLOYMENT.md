# 🚀 Deployment Automático con Base de Datos

## ✅ **¡SISTEMA AUTOMÁTICO CREADO!**

### **📁 Archivos Creados:**
1. **`setup_database.py`** - Configuración automática de tabla `user_carts`
2. **`deploy_with_database.sh`** - Script de deployment automático
3. **`create_user_carts_table.sql`** - SQL para crear tabla manualmente
4. **`app.py`** - Modificado para configurar DB automáticamente

---

## 🔧 **CÓMO FUNCIONA:**

### **1. Deployment Automático:**
- **Al hacer deploy** en Render.com, se ejecuta automáticamente
- **Configura la tabla** `user_carts` en Supabase
- **Habilita persistencia** del carrito automáticamente

### **2. Endpoint Manual:**
Si la configuración automática falla, puedes usar:
```
https://tu-backend.onrender.com/setup-database
```

### **3. Configuración en Render.com:**
```bash
# Build Command:
pip install -r requirements.txt

# Start Command:
python3 app.py
```

---

## 🎯 **VARIABLES DE ENTORNO REQUERIDAS:**

### **En Render.com Dashboard:**
```
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_SERVICE_KEY=tu_service_role_key
```

**⚠️ IMPORTANTE:** Usar `SUPABASE_SERVICE_KEY` (no `SUPABASE_ANON_KEY`) para crear tablas.

---

## 🚀 **PASOS PARA DEPLOYMENT:**

### **1. Subir Archivos a GitHub:**
```bash
git add .
git commit -m "Agregar configuración automática de DB"
git push origin main
```

### **2. Deploy en Render.com:**
- **Se ejecutará automáticamente** la configuración de DB
- **Verificar logs** para confirmar creación de tabla
- **Probar endpoint** `/setup-database` si es necesario

### **3. Verificar Funcionamiento:**
- **Abrir la app Flutter**
- **Hacer login**
- **Agregar productos al carrito**
- **Verificar notificación** del carrito
- **Cerrar sesión y volver a hacer login**
- **Verificar que productos persisten**

---

## 📊 **LOGS ESPERADOS:**

### **Durante el Deploy:**
```
✅ Configuración automática de DB disponible
🚀 Inicializando configuración de base de datos...
✅ Tabla user_carts creada exitosamente
📋 Características configuradas:
   - Persistencia de carritos por usuario
   - RLS habilitado (seguridad por usuario)
   - Índices para mejor performance
   - Triggers automáticos para updated_at
```

### **Si Hay Error:**
```
⚠️ Error en configuración automática: [detalle del error]
📋 INSTRUCCIONES MANUALES:
1. Ve al dashboard de Supabase
2. Abre SQL Editor
3. Ejecuta el SQL del archivo create_user_carts_table.sql
```

---

## 🔍 **VERIFICACIÓN EN SUPABASE:**

### **1. Verificar Tabla:**
- **Ve a Table Editor** en Supabase
- **Busca `user_carts`**
- **Verifica columnas:** `id`, `user_id`, `items`, `created_at`, `updated_at`

### **2. Verificar RLS:**
- **Ve a Authentication > Policies**
- **Busca política:** "Users can manage their own cart"

### **3. Verificar Funcionamiento:**
- **Agrega productos en la app**
- **Ve a Table Editor > user_carts**
- **Deberías ver registros** con carritos de usuarios

---

## 🐛 **SOLUCIÓN DE PROBLEMAS:**

### **Error: Variables de entorno no encontradas**
- **Verificar** `SUPABASE_URL` y `SUPABASE_SERVICE_KEY` en Render.com
- **Usar Service Role Key** (no Anon Key)

### **Error: Tabla no se crea**
- **Usar endpoint manual:** `/setup-database`
- **Ejecutar SQL manualmente** en Supabase
- **Verificar permisos** del Service Role Key

### **Carrito no se guarda**
- **Verificar tabla** `user_carts` existe
- **Verificar políticas RLS**
- **Verificar autenticación** del usuario

---

## ✅ **RESULTADO FINAL:**

Una vez configurado correctamente:
- ✅ **Carritos persisten** entre sesiones
- ✅ **Notificaciones funcionan** en tiempo real
- ✅ **Configuración automática** en cada deploy
- ✅ **Seguridad por usuario** (RLS habilitado)
- ✅ **Performance optimizada** (índices creados)

---

**¡El sistema ahora configura automáticamente la persistencia del carrito en cada deployment!** 🎉
