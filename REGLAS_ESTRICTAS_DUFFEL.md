# 🚨 REGLAS ESTRICTAS PARA BACKEND DUFFEL

## ⚠️ ADVERTENCIA CRÍTICA
**NUNCA MODIFICAR** los siguientes archivos sin autorización explícita:
- `backend/app.py` (líneas 88-90)
- `backend/duffel_service.py` (líneas 35-38)

## 🛡️ PROTECCIÓN AUTOMÁTICA

### 1. ANTES DE CUALQUIER MODIFICACIÓN
```bash
# SIEMPRE ejecutar primero:
python3 PROTECCION_BACKEND_DUFFEL.py
```

### 2. ANTES DE CUALQUIER DEPLOY
```bash
# OBLIGATORIO ejecutar:
python3 VALIDACION_DUFFEL_PRE_DEPLOY.py
```

### 3. SI ALGO SE DAÑA
```bash
# Restaurar automáticamente:
python3 ROLLBACK_DUFFEL_AUTOMATICO.py
```

## 🔒 CÓDIGO PROTEGIDO

### app.py - LÍNEAS CRÍTICAS (NO TOCAR)
```python
# LÍNEA 89 - ENDPOINT CORRECTO (NO MODIFICAR)
url = f'https://api.duffel.com/air/airports?search={query}&limit=20'

# LÍNEAS 99-111 - ESTRUCTURA CORRECTA (NO MODIFICAR)
for airport in data['data']:
    airport_data = {
        'city': airport.get('city', {}).get('name', '') if airport.get('city') else '',
        'country': airport.get('city', {}).get('country', {}).get('name', '') if airport.get('city') and airport.get('city', {}).get('country') else '',
    }
```

### duffel_service.py - LÍNEAS CRÍTICAS (NO TOCAR)
```python
# LÍNEAS 35-38 - PARÁMETROS CORRECTOS (NO MODIFICAR)
params = {
    'search': query,  # NO CAMBIAR A 'name'
    'limit': 20
}
```

## 🚫 PATRONES PROHIBIDOS

**NUNCA USAR:**
- `/places?query=` (endpoint incorrecto)
- `'name': query,` (parámetro incorrecto)
- `place.get('city_name', '')` (estructura incorrecta)

## ✅ PATRONES CORRECTOS

**SIEMPRE USAR:**
- `/air/airports?search=` (endpoint correcto)
- `'search': query,` (parámetro correcto)
- `airport.get('city', {}).get('name', '')` (estructura correcta)

## 🔄 FLUJO DE TRABAJO OBLIGATORIO

1. **ANTES DE MODIFICAR CUALQUIER COSA:**
   ```bash
   python3 PROTECCION_BACKEND_DUFFEL.py
   ```

2. **SI NECESITAS MODIFICAR ALGO:**
   - Crear backup manual
   - Modificar SOLO lo necesario
   - NO tocar líneas críticas

3. **ANTES DE DEPLOY:**
   ```bash
   python3 VALIDACION_DUFFEL_PRE_DEPLOY.py
   ```
   - Si falla: NO HACER DEPLOY
   - Corregir errores primero

4. **SI ALGO SE DAÑA:**
   ```bash
   python3 ROLLBACK_DUFFEL_AUTOMATICO.py
   ```

## 📋 CHECKLIST PRE-DEPLOY

- [ ] Ejecutar `PROTECCION_BACKEND_DUFFEL.py`
- [ ] Ejecutar `VALIDACION_DUFFEL_PRE_DEPLOY.py`
- [ ] Verificar que todos los tests pasen
- [ ] Confirmar que endpoint usa `/air/airports?search=`
- [ ] Confirmar que parámetro usa `'search'`
- [ ] NO hay patrones prohibidos en el código

## 🚨 CONSECUENCIAS DE VIOLAR ESTAS REGLAS

1. **Búsqueda de aeropuertos se rompe**
2. **Usuarios no pueden buscar vuelos**
3. **Sistema de vuelos queda inutilizable**
4. **Pérdida de funcionalidad crítica**

## 📞 CONTACTO DE EMERGENCIA

Si necesitas modificar algo relacionado con Duffel:
1. **LEER ESTE ARCHIVO COMPLETO**
2. **EJECUTAR SCRIPTS DE PROTECCIÓN**
3. **VALIDAR ANTES DE DEPLOY**
4. **TENER PLAN DE ROLLBACK**

---
**Última actualización**: 13 de Septiembre 2025  
**Estado**: 🛡️ PROTEGIDO  
**Versión**: 1.0
