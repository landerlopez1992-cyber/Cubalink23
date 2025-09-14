# Tarjeta de Referencia Rápida - Duffel API

## 🔑 Información Básica
- **URL Base:** `https://api.duffel.com/air`
- **Versión:** `v2`
- **Clave API:** [PROPORCIONAR DESPUÉS]

## 📋 Headers Requeridos
```
Authorization: Bearer [TU_CLAVE_API]
Content-Type: application/json
Duffel-Version: v2
```

## 🚀 Flujo de Implementación

### 1. Búsqueda de Vuelos
```http
POST /offer_requests
```
**Payload:**
```json
{
  "data": {
    "slices": [{
      "origin": "LHR",
      "destination": "JFK", 
      "departure_date": "2024-06-15"
    }],
    "passengers": [{"type": "adult"}],
    "cabin_class": "economy"
  }
}
```

### 2. Obtener Ofertas
```http
GET /offers?offer_request_id={id}
```

### 3. Crear Reserva
```http
POST /orders
```
**Payload:**
```json
{
  "data": {
    "selected_offers": ["off_00009htYpSCXrwaB9DnUm0"],
    "passengers": [{
      "title": "mr",
      "given_name": "John",
      "family_name": "Doe",
      "email": "john@example.com",
      "phone_number": "+1234567890",
      "born_on": "1990-01-01",
      "gender": "m"
    }],
    "payments": [{
      "type": "balance",
      "currency": "GBP",
      "amount": "45.00"
    }]
  }
}
```

### 4. Verificar Estado
```http
GET /orders/{order_id}
```

## 📱 Endpoints Esenciales

| Endpoint | Método | Propósito |
|----------|--------|-----------|
| `/offer_requests` | POST | Crear búsqueda |
| `/offers` | GET | Obtener ofertas |
| `/orders` | POST | Crear reserva |
| `/orders/{id}` | GET | Verificar estado |

## 🎯 Componentes UI Necesarios

1. **Formulario de Búsqueda**
   - Origen y destino (códigos IATA)
   - Fecha de salida
   - Número de pasajeros
   - Clase de cabina

2. **Lista de Ofertas**
   - Precio y moneda
   - Aerolínea
   - Duración del vuelo
   - Detalles de escalas

3. **Formulario de Pasajero**
   - Datos personales
   - Información de contacto
   - Documentos de identidad

4. **Confirmación de Reserva**
   - Resumen de la reserva
   - Información de pago
   - E-ticket

## ⚠️ Puntos Clave

- ✅ Validar códigos de aeropuerto IATA
- ✅ Manejar errores de API
- ✅ Mostrar estados de carga
- ✅ Validar datos de pasajeros
- ✅ Implementar confirmación de reserva
- ✅ Generar documentación de viaje

## 🔧 Configuración Backend

```javascript
// API Route ejemplo
const response = await fetch('https://api.duffel.com/air/offer_requests', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${process.env.DUFFEL_API_KEY}`,
    'Content-Type': 'application/json',
    'Duffel-Version': 'v2'
  },
  body: JSON.stringify(payload)
});
```

## 📝 Tipos de Pasajeros

- `adult` - Adulto (18+ años)
- `child` - Niño (2-17 años)
- `infant_without_seat` - Infante sin asiento (0-1 año)

## 🎨 Clases de Cabina

- `economy` - Económica
- `premium_economy` - Premium Económica
- `business` - Business
- `first` - Primera Clase
