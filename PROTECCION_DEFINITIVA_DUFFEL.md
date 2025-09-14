# 🛡️ PROTECCIÓN DEFINITIVA DUFFEL - NUNCA MÁS SE ROMPE

## 🚨 REGLAS ABSOLUTAS - NUNCA VIOLAR:

### ❌ NUNCA CAMBIAR:
- `https://api.duffel.com/air/airports?search={}&limit=20` (endpoint correcto)
- `for airport in data.get('data', []):` (parsing correcto)
- `airport.get('iata_code')` (campos correctos)

### ✅ SIEMPRE VERIFICAR ANTES DE DEPLOY:
```bash
curl "https://api.duffel.com/air/airports?search=denver&limit=5" -H "Authorization: Bearer duffel_live_Rj6u0G0cT2hUeIw53ou2HRTNNf0tXl6oP-pVzcGvI7e" -H "Duffel-Version: v2"
```

### 🔒 CÓDIGO PROTEGIDO:
```python
# ENDPOINT CORRECTO - NO TOCAR
url = 'https://api.duffel.com/air/airports?search={}&limit=20'.format(query)

# PARSING CORRECTO - NO TOCAR  
for airport in data.get('data', []):
    airports.append({
        'iata_code': airport.get('iata_code'),
        'name': airport.get('name'),
        'city': airport.get('city_name'),
        'country': airport.get('iata_country_code')
    })
```

## 🚫 PROHIBIDO:
- Cambiar `/air/airports` por `/places`
- Cambiar `search` por `query` o `name`
- Cambiar `for airport` por `for place`
- Agregar `if place.get('type') == 'airport'`

## ✅ OBLIGATORIO:
- Probar con "denver" antes de deploy
- Verificar que devuelve aeropuertos reales
- NO deploy si devuelve `[]`

---
**FECHA DE CREACIÓN: 2025-09-13**
**ESTADO: FUNCIONANDO AL 100%**
**NUNCA MÁS SE ROMPE**
