# Duffel API Backend

Backend para manejar la API de Duffel para reservas de vuelos en la aplicación TuRecarga.

## 🚀 Características

- **Búsqueda de vuelos**: Buscar ofertas de vuelos disponibles
- **Gestión de ofertas**: Obtener detalles de ofertas específicas
- **Creación de órdenes**: Crear reservas de vuelos
- **Gestión de órdenes**: Ver y cancelar órdenes existentes
- **Búsqueda de aeropuertos**: Buscar aeropuertos por nombre o código
- **Información de aerolíneas**: Obtener lista de aerolíneas disponibles

## 📋 Requisitos

- Node.js (v14 o superior)
- npm o yarn
- Token de API de Duffel

## 🔧 Instalación

1. **Clonar el repositorio**:
   ```bash
   cd backend-duffel
   ```

2. **Instalar dependencias**:
   ```bash
   npm install
   ```

3. **Configurar variables de entorno**:
   ```bash
   cp .env.example .env
   ```
   
   Editar `.env` y agregar tu token de Duffel:
   ```
   DUFFEL_API_TOKEN=tu_token_aqui
   ```

4. **Ejecutar el servidor**:
   ```bash
   # Desarrollo
   npm run dev
   
   # Producción
   npm start
   ```

## 🌐 Endpoints

### Búsqueda de Vuelos
- `POST /api/duffel/search-offers` - Buscar ofertas de vuelos

### Gestión de Ofertas
- `GET /api/duffel/offers/:offerRequestId` - Obtener ofertas
- `GET /api/duffel/offer/:offerId` - Obtener detalles de una oferta

### Gestión de Órdenes
- `POST /api/duffel/create-order` - Crear una orden
- `GET /api/duffel/order/:orderId` - Obtener detalles de una orden
- `POST /api/duffel/cancel-order/:orderId` - Cancelar una orden

### Información Adicional
- `GET /api/duffel/airports?search=query` - Buscar aeropuertos
- `GET /api/duffel/airlines` - Obtener aerolíneas

### Health Check
- `GET /health` - Verificar estado del servidor

## 📝 Ejemplo de Uso

### Buscar Vuelos
```bash
curl -X POST http://localhost:3001/api/duffel/search-offers \
  -H "Content-Type: application/json" \
  -d '{
    "slices": [
      {
        "origin": "MIA",
        "destination": "LAX",
        "departure_date": "2024-01-15"
      }
    ],
    "passengers": [
      {
        "type": "adult"
      }
    ],
    "cabin_class": "economy"
  }'
```

### Buscar Aeropuertos
```bash
curl "http://localhost:3001/api/duffel/airports?search=miami"
```

## 🔒 Seguridad

- **Rate Limiting**: Límite de 100 requests por 15 minutos por IP
- **CORS**: Configurado para permitir solo orígenes específicos
- **Helmet**: Headers de seguridad HTTP
- **Validación**: Validación de entrada con Joi
- **Error Handling**: Manejo centralizado de errores

## 🛠️ Desarrollo

### Estructura del Proyecto
```
backend-duffel/
├── middleware/
│   └── errorHandler.js
├── routes/
│   └── duffel.js
├── services/
│   └── duffelService.js
├── utils/
│   └── validators.js
├── .env
├── package.json
├── server.js
└── README.md
```

### Scripts Disponibles
- `npm start` - Ejecutar en producción
- `npm run dev` - Ejecutar en desarrollo con nodemon
- `npm test` - Ejecutar tests (pendiente)

## 📞 Soporte

Para soporte técnico, contactar al equipo de desarrollo de TuRecarga.

## 📄 Licencia

MIT License
