# 📝 NOTAS DEL PROYECTO CUBA LINK 23

## 🚨 **IMPORTANTE: DIFERENCIA ENTRE REPOSITORIOS**

### **REPOSITORIO PRINCIPAL (RENDER DEPLOY):**
- **Nombre**: `cubalink23-backend`
- **URL**: `https://github.com/landerlopez1992-cyber/cubalink23-backend.git`
- **Propósito**: **ESTE ES EL REPOSITORIO AL QUE RENDER ESTÁ CONECTADO**
- **Comando**: `git push origin main`
- **⚠️ CRÍTICO**: Todos los cambios para deploy en Render DEBEN ir aquí

### **REPOSITORIO BACKUP:**
- **Nombre**: `Cubalink23`
- **URL**: `https://github.com/landerlopez1992-cyber/Cubalink23.git`
- **Propósito**: Solo es un **backup completo** del proyecto
- **Comando**: `git push backup main`
- **⚠️ IMPORTANTE**: Este NO activa deploys en Render

### **REGLA DE ORO:**
- **Para deploys en Render**: SIEMPRE usar `git push origin main`
- **Para backups**: Usar `git push backup main`
- **NUNCA confundir**: Los cambios van a `cubalink23-backend` para deploy

---

## 📋 ESTADO ACTUAL DEL PROYECTO

### ✅ **FUNCIONALIDADES IMPLEMENTADAS:**
- Sistema de banners con rotación automática
- Panel de administración web
- API de vuelos con Duffel
- Control individual de tiempo de rotación para cada banner
- Deploy automático en Render

### 🔧 **ARCHIVOS PRINCIPALES:**
- `app.py` - Aplicación Flask principal
- `admin_routes.py` - Rutas del panel de administración
- `templates/admin/system.html` - Interfaz del panel admin
- `Procfile` - Configuración para Render
- `requirements.txt` - Dependencias Python

### 🌐 **URLS IMPORTANTES:**
- **Backend**: `https://cubalink23-backend.onrender.com`
- **Panel Admin**: `https://cubalink23-backend.onrender.com/admin/system`
- **API Banners**: `https://cubalink23-backend.onrender.com/admin/api/banners`

### 📱 **FUNCIONALIDADES DEL PANEL ADMIN:**
- Gestión de banners (crear, editar, eliminar)
- Control de tiempo de rotación individual
- Subida de imágenes a Supabase
- Vista previa de banners activos

---

## 🚀 **INSTRUCCIONES PARA AGENTES FUTUROS:**

1. **SIEMPRE verificar** a qué repositorio se están enviando los cambios
2. **Para deploys**: Usar `git push origin main` (cubalink23-backend)
3. **Para backups**: Usar `git push backup main` (Cubalink23)
4. **NUNCA confundir** los dos repositorios
5. **Verificar** que Render esté conectado al repositorio correcto

---

## 📝 **HISTORIAL DE CAMBIOS:**

### **Último commit desplegado:**
- **ID**: `d584482`
- **Mensaje**: "FEATURE: Agregar control individual de tiempo de rotación para cada banner"
- **Repositorio**: `cubalink23-backend` ✅
- **Estado**: Desplegado en Render ✅

### **Funcionalidad agregada:**
- Control individual de tiempo de rotación para cada banner
- Casillas de segundos en el panel admin
- Actualización automática del tiempo de rotación
- Interfaz mejorada para gestión de banners

---

## ⚠️ **NOTAS IMPORTANTES:**

- **NO eliminar** funcionalidades existentes
- **Solo agregar** nuevas características
- **Verificar** que los cambios no rompan el sistema
- **Probar** en el panel admin antes de confirmar
- **Siempre** hacer backup después de cambios importantes

---

*Última actualización: 8 de septiembre de 2025*


