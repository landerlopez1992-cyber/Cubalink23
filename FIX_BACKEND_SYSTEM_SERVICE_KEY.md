# 🔧 ARREGLO URGENTE - BACKEND SISTEMA

## 🚨 **PROBLEMA IDENTIFICADO:**
El backend sistema está usando la **anon key** de Supabase, pero necesita la **service key** para poder insertar órdenes sin restricciones RLS.

## ✅ **SOLUCIÓN:**

### **1. CAMBIAR VARIABLE DE ENTORNO EN RENDER:**

**En Render.com → cubalink23-system → Environment:**

**CAMBIAR:**
```
SUPABASE_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU3OTI3OTgsImV4cCI6MjA3MTM2ODc5OH0.lUVK99zmOYD7bNTxilJZWHTmYPfZF5YeMJDVUaJ-FsQ
```

**POR:**
```
SUPABASE_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpncXJoenVocnd1ZGNrd2VzeWJnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyNjY2NDgyOSwiZXhwIjoyMDQyMjQwODI5fQ.nMhOYDNNfq8NMqXvJKJT8SjLFjZJmVP9gDGGfcE8xhQ
```

### **2. REDEPLOY AUTOMÁTICO:**
Render detectará el cambio y hará redeploy automáticamente.

### **3. DIFERENCIA:**
- **anon key**: Solo puede leer/escribir sus propios datos (RLS activo)
- **service key**: Puede hacer cualquier operación (bypass RLS)

## 🎯 **DESPUÉS DEL REDEPLOY:**
Las órdenes se crearán correctamente y aparecerán en "Rastreo de Mi Orden".
