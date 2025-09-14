# 📋 Instrucciones para Crear Tabla user_carts en Supabase

## 🎯 **PROBLEMA IDENTIFICADO:**
- Los carritos no se guardan entre sesiones
- La notificación del carrito no se actualiza correctamente

## ✅ **SOLUCIÓN:**
Crear la tabla `user_carts` en Supabase para persistir los carritos de los usuarios.

---

## 🔧 **PASO 1: Crear la Tabla en Supabase**

### **Opción A: SQL Editor (Recomendado)**
1. **Ve a tu dashboard de Supabase**
2. **Abre el SQL Editor** (pestaña "SQL Editor")
3. **Copia y pega** el siguiente SQL:

```sql
-- Crear tabla user_carts para persistir carritos de usuarios
CREATE TABLE IF NOT EXISTS user_carts (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  items JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Crear índice para mejorar performance
CREATE INDEX IF NOT EXISTS idx_user_carts_user_id ON user_carts(user_id);

-- Habilitar RLS (Row Level Security)
ALTER TABLE user_carts ENABLE ROW LEVEL SECURITY;

-- Política para que usuarios solo puedan ver/editar su propio carrito
CREATE POLICY "Users can manage their own cart" ON user_carts
  FOR ALL USING (auth.uid() = user_id);

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para actualizar updated_at automáticamente
DROP TRIGGER IF EXISTS update_user_carts_updated_at ON user_carts;
CREATE TRIGGER update_user_carts_updated_at
  BEFORE UPDATE ON user_carts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

4. **Ejecuta el SQL** (botón "Run")

### **Opción B: Usar el Script Python**
```bash
python3 setup_user_carts_table.py
```

---

## 🎯 **PASO 2: Verificar la Tabla**

1. **Ve a la pestaña "Table Editor"**
2. **Busca la tabla `user_carts`**
3. **Verifica que tenga las columnas:**
   - `id` (Serial, Primary Key)
   - `user_id` (UUID, Foreign Key)
   - `items` (JSONB)
   - `created_at` (Timestamp)
   - `updated_at` (Timestamp)

---

## 🚀 **PASO 3: Probar la Funcionalidad**

1. **Compila y ejecuta la app** en el Motorola
2. **Haz login** con un usuario
3. **Agrega productos al carrito** desde la pantalla Welcome
4. **Verifica que aparezca la notificación** (número en el carrito)
5. **Cierra sesión y vuelve a hacer login**
6. **Verifica que los productos sigan en el carrito**

---

## 🔍 **VERIFICACIÓN EN SUPABASE:**

### **Ver Carritos Guardados:**
1. **Ve a "Table Editor"**
2. **Selecciona la tabla `user_carts`**
3. **Deberías ver registros** con:
   - `user_id`: ID del usuario
   - `items`: Array JSON con los productos del carrito
   - `created_at` y `updated_at`: Timestamps

### **Ejemplo de Registro:**
```json
{
  "id": 1,
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "items": [
    {
      "id": "store_123",
      "name": "Producto de Tienda",
      "price": 25.99,
      "quantity": 2,
      "type": "store_product"
    }
  ],
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

---

## ⚠️ **NOTAS IMPORTANTES:**

- **RLS Habilitado**: Los usuarios solo pueden ver/editar su propio carrito
- **Persistencia Automática**: El carrito se guarda automáticamente al agregar/remover productos
- **Carga Automática**: El carrito se carga automáticamente al hacer login
- **Notificaciones**: El contador del carrito se actualiza en tiempo real

---

## 🐛 **SOLUCIÓN DE PROBLEMAS:**

### **Si la notificación no aparece:**
1. Verifica que la tabla `user_carts` existe
2. Revisa los logs de la app para errores
3. Asegúrate de que el usuario esté autenticado

### **Si los productos no se guardan:**
1. Verifica las políticas RLS
2. Revisa que el `user_id` sea correcto
3. Verifica la conexión a Supabase

---

**¡Una vez creada la tabla, los carritos se guardarán automáticamente entre sesiones!** 🎉
