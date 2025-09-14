# 🚀 GUÍA COMPLETA DE DESPLIEGUE A RENDER.COM

## ✅ ESTADO ACTUAL: LISTO PARA DESPLEGAR

### 📋 ARCHIVOS PREPARADOS:
- ✅ `requirements.txt` - Dependencias de Python
- ✅ `Procfile` - Configuración de Render.com
- ✅ `runtime.txt` - Versión de Python 3.9.18
- ✅ `app.py` - Aplicación Flask principal
- ✅ `charter_scraper.py` - Web Scraping Real
- ✅ `charter_routes.py` - API de aerolíneas charter
- ✅ `database.py` - Base de datos SQLite
- ✅ `README.md` - Documentación completa
- ✅ `deploy.sh` - Script de despliegue

---

## 🔧 PASOS PARA DESPLEGAR

### 1️⃣ CREAR REPOSITORIO EN GITHUB

1. Ve a [GitHub.com](https://github.com)
2. Click en "New repository"
3. Nombre: `cubalink23-backend`
4. Descripción: "Backend API para aerolíneas charter con web scraping"
5. **NO** inicializar con README (ya existe)
6. Click "Create repository"

### 2️⃣ SUBIR CÓDIGO A GITHUB

```bash
# En tu terminal (backend-duffel):
git remote add origin https://github.com/TU_USUARIO/cubalink23-backend.git
git branch -M main
git push -u origin main
```

### 3️⃣ CREAR SERVICIO EN RENDER.COM

1. Ve a [Render.com](https://render.com)
2. Click en "New +" → "Web Service"
3. Conectar con GitHub
4. Seleccionar repositorio: `cubalink23-backend`

### 4️⃣ CONFIGURAR SERVICIO

**Configuración básica:**
- **Name**: `cubalink23-backend`
- **Environment**: `Python 3`
- **Region**: `Oregon (US West)` (o más cercana)
- **Branch**: `main`

**Build & Deploy:**
- **Build Command**: `pip install -r requirements.txt`
- **Start Command**: `gunicorn app:app --bind 0.0.0.0:$PORT`

### 5️⃣ CONFIGURAR VARIABLES DE ENTORNO

En Render.com → Environment Variables:

```
DUFFEL_API_TOKEN=tu_token_aqui
FLASK_ENV=production
SECRET_KEY=cubalink23-secret-key-2023
```

### 6️⃣ DESPLEGAR

Click en "Create Web Service"

---

## 🌐 URL FINAL

Tu API estará disponible en:
```
https://cubalink23-backend.onrender.com
```

---

## 🔍 PRUEBAS POST-DESPLIEGUE

### 1. Verificar Estado del Servidor:
```bash
curl https://cubalink23-backend.onrender.com/
```

### 2. Probar Búsqueda de Charter:
```bash
curl -X POST https://cubalink23-backend.onrender.com/api/charter/search \
  -H "Content-Type: application/json" \
  -d '{
    "origin": "Miami",
    "destination": "Havana",
    "departure_date": "2025-09-06",
    "passengers": 2
  }'
```

### 3. Probar Lista de Aerolíneas:
```bash
curl https://cubalink23-backend.onrender.com/api/charter/airlines
```

---

## 📊 FUNCIONALIDADES IMPLEMENTADAS

### ✅ WEB SCRAPING REAL:
- **Xael Charter** - Scraping de widget de vuelos
- **Cubazul Air Charter** - Scraping con Selenium
- **Havana Air Charter** - Scraping con BeautifulSoup
- **Fallback automático** si falla el scraping

### ✅ API ENDPOINTS:
- `POST /api/charter/search` - Búsqueda de vuelos
- `GET /api/charter/airlines` - Lista de aerolíneas
- `POST /api/charter/booking` - Crear reserva
- `POST /api/charter/booking/{id}/confirm` - Confirmar reserva

### ✅ BASE DE DATOS:
- **SQLite** para desarrollo
- **Tablas**: charter_airlines, charter_bookings, scraping_logs
- **Persistencia** de datos

### ✅ SISTEMA DE RESERVAS:
- **Estados**: PENDIENTE, CONFIRMADO, CANCELADO
- **Markup configurable** por aerolínea
- **Restricciones** de modificación/cancelación

---

## 🔗 CONECTAR CON FLUTTER

Una vez desplegado, actualizar en Flutter:

```dart
// En charter_service.dart
static const String baseUrl = 'https://cubalink23-backend.onrender.com';
```

---

## 🎯 RESULTADO FINAL

✅ **Backend funcionando 24/7**
✅ **Web scraping real de 3 aerolíneas**
✅ **API RESTful completa**
✅ **Base de datos persistente**
✅ **Sistema de reservas**
✅ **Listo para producción**

---

## 🆘 SOLUCIÓN DE PROBLEMAS

### Error de Build:
- Verificar `requirements.txt`
- Revisar logs en Render.com

### Error de Runtime:
- Verificar variables de entorno
- Revisar `Procfile`

### Error de CORS:
- CORS ya está configurado en `app.py`

---

## 📞 SOPORTE

Si tienes problemas:
1. Revisar logs en Render.com
2. Verificar configuración
3. Probar endpoints localmente primero

**¡TU BACKEND ESTÁ LISTO PARA PRODUCCIÓN!** 🚀

