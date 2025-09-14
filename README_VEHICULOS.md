# Sistema de Gestión de Vehículos - Renta Car

## 📋 Descripción General

El sistema de gestión de vehículos permite administrar una flota de automóviles para renta, incluyendo la gestión de vehículos, rentas, conductores adicionales, servicios adicionales y un sistema completo de categorías con subida de imágenes.

## 🗄️ Esquema de Base de Datos

### Tabla `vehicles`
```sql
CREATE TABLE vehicles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    license_plate TEXT UNIQUE NOT NULL,
    brand TEXT NOT NULL,
    model TEXT NOT NULL,
    year INTEGER NOT NULL,
    color TEXT NOT NULL,
    vehicle_type TEXT NOT NULL,
    transmission TEXT NOT NULL,
    fuel_type TEXT NOT NULL,
    seats INTEGER NOT NULL,
    daily_rate REAL NOT NULL,
    location TEXT NOT NULL,
    status TEXT DEFAULT 'available',
    category_id TEXT,
    description TEXT,
    features TEXT,
    images TEXT,
    insurance_cost REAL NOT NULL,
    deposit_amount REAL NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Tabla `vehicle_rentals`
```sql
CREATE TABLE vehicle_rentals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    rental_code TEXT UNIQUE NOT NULL,
    user_id INTEGER NOT NULL,
    vehicle_id INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    pickup_location TEXT NOT NULL,
    return_location TEXT NOT NULL,
    rental_type TEXT NOT NULL,
    total_days INTEGER NOT NULL,
    daily_rate REAL NOT NULL,
    total_amount REAL NOT NULL,
    deposit_amount REAL NOT NULL,
    insurance_amount REAL NOT NULL,
    taxes_amount REAL NOT NULL,
    final_amount REAL NOT NULL,
    payment_method TEXT NOT NULL,
    rental_status TEXT DEFAULT 'pending',
    payment_status TEXT DEFAULT 'pending',
    pickup_notes TEXT,
    return_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Tabla `rental_drivers`
```sql
CREATE TABLE rental_drivers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    rental_id INTEGER NOT NULL,
    driver_name TEXT NOT NULL,
    driver_license TEXT NOT NULL,
    driver_phone TEXT NOT NULL,
    driver_age INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Tabla `rental_services`
```sql
CREATE TABLE rental_services (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    rental_id INTEGER NOT NULL,
    service_name TEXT NOT NULL,
    service_type TEXT NOT NULL,
    service_cost REAL NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🚗 Categorías de Vehículos

El sistema incluye 8 categorías predefinidas basadas en las prácticas de Rent Cuba Car:

### 1. Económico Mecánico
- **Descripción**: Vehículos compactos con transmisión manual
- **Precio**: 25-35 USD/día
- **Asientos**: 4-5
- **Ejemplos**: Peugeot 208, Renault Sandero, Hyundai i10

### 2. Económico Automático
- **Descripción**: Vehículos compactos con transmisión automática
- **Precio**: 30-40 USD/día
- **Asientos**: 4-5
- **Ejemplos**: Toyota Yaris, Honda Fit, Nissan March

### 3. Medio Mecánico
- **Descripción**: Vehículos de tamaño mediano con transmisión manual
- **Precio**: 35-45 USD/día
- **Asientos**: 5
- **Ejemplos**: Peugeot 301, Renault Logan, Hyundai Accent

### 4. Medio Automático
- **Descripción**: Vehículos de tamaño mediano con transmisión automática
- **Precio**: 40-50 USD/día
- **Asientos**: 5
- **Ejemplos**: Toyota Corolla, Honda Civic, Nissan Sentra

### 5. Alto Estándar
- **Descripción**: Vehículos de gama alta con características avanzadas
- **Precio**: 50-70 USD/día
- **Asientos**: 5
- **Ejemplos**: Toyota Camry, Honda Accord, Nissan Altima

### 6. Premium
- **Descripción**: Vehículos de lujo con prestaciones superiores
- **Precio**: 80-120 USD/día
- **Asientos**: 5
- **Ejemplos**: Mercedes-Benz C-Class, BMW 3 Series, Audi A4

### 7. Jeep
- **Descripción**: Vehículos todoterreno para terrenos difíciles
- **Precio**: 60-90 USD/día
- **Asientos**: 5-7
- **Ejemplos**: Jeep Wrangler, Toyota 4Runner, Nissan X-Trail

### 8. Minivan
- **Descripción**: Vehículos con gran capacidad para grupos
- **Precio**: 70-100 USD/día
- **Asientos**: 8-15
- **Ejemplos**: Toyota Hiace, Ford Transit, Mercedes-Benz Sprinter

## 📸 Sistema de Imágenes

### Características
- **Subida múltiple**: Permite subir varias imágenes por vehículo
- **Formatos soportados**: PNG, JPG, JPEG, GIF, WEBP
- **Almacenamiento**: Archivos guardados en `static/img/vehicles/`
- **Nombres únicos**: Generación automática de nombres únicos
- **Gestión**: Posibilidad de eliminar imágenes individuales

### Estructura de archivos
```
static/
└── img/
    └── vehicles/
        ├── vehicle_1_a1b2c3d4.jpg
        ├── vehicle_1_e5f6g7h8.png
        └── vehicle_2_i9j0k1l2.webp
```

## 🔧 Funcionalidades Implementadas

### Para Administradores

#### Gestión de Vehículos
- ✅ **Listar vehículos** - Obtener todos los vehículos con filtros
- ✅ **Crear vehículo** - Agregar nuevo vehículo con categoría
- ✅ **Editar vehículo** - Modificar información del vehículo
- ✅ **Eliminar vehículo** - Remover vehículo del sistema
- ✅ **Cambiar estado** - Marcar como disponible/mantenimiento/rentado
- ✅ **Subir imágenes** - Agregar múltiples fotos del vehículo
- ✅ **Eliminar imágenes** - Remover fotos específicas
- ✅ **Asignar categoría** - Seleccionar categoría al crear vehículo

#### Gestión de Rentas
- ✅ **Listar rentas** - Ver todas las rentas con filtros
- ✅ **Crear renta** - Generar nueva renta con código único
- ✅ **Editar renta** - Modificar detalles de la renta
- ✅ **Cambiar estado** - Actualizar estado de renta y pago
- ✅ **Completar renta** - Finalizar renta con notas
- ✅ **Estadísticas** - Ver métricas de rentas

#### Gestión de Conductores
- ✅ **Listar conductores** - Ver conductores de una renta
- ✅ **Agregar conductor** - Incluir conductor adicional

#### Gestión de Servicios
- ✅ **Listar servicios** - Ver servicios de una renta
- ✅ **Agregar servicio** - Incluir servicio adicional

#### Categorías de Vehículos
- ✅ **Listar categorías** - Ver todas las categorías disponibles
- ✅ **Detalles de categoría** - Información específica de cada categoría
- ✅ **Crear con categoría** - Asignar categoría al crear vehículo

### Para la App Flutter

#### Vehículos
- ✅ **Vehículos disponibles** - Listar vehículos disponibles
- ✅ **Verificar disponibilidad** - Comprobar fechas disponibles
- ✅ **Información detallada** - Datos completos del vehículo

#### Rentas
- ✅ **Rentas del usuario** - Ver rentas de un usuario específico
- ✅ **Información de usuario** - Datos del usuario de una renta

## 🌐 Endpoints API

### Categorías de Vehículos

#### Obtener todas las categorías
```http
GET /admin/api/vehicles/categories
Authorization: Bearer {token}
```

#### Obtener categoría específica
```http
GET /admin/api/vehicles/categories/{category_id}
Authorization: Bearer {token}
```

### Subida de Imágenes

#### Subir imágenes de vehículo
```http
POST /admin/api/vehicles/upload-images
Authorization: Bearer {token}
Content-Type: multipart/form-data

vehicle_id: {vehicle_id}
images: [archivos de imagen]
```

#### Eliminar imagen de vehículo
```http
DELETE /admin/api/vehicles/{vehicle_id}/images
Authorization: Bearer {token}
Content-Type: application/json

{
    "image_url": "/static/img/vehicles/filename.jpg"
}
```

### Creación de Vehículos con Categoría

#### Crear vehículo con categoría
```http
POST /admin/api/vehicles/create-with-category
Authorization: Bearer {token}
Content-Type: application/json

{
    "license_plate": "ABC123",
    "brand": "Toyota",
    "model": "Corolla",
    "year": 2022,
    "color": "Blanco",
    "vehicle_type": "sedan",
    "transmission": "automático",
    "fuel_type": "gasolina",
    "seats": 5,
    "daily_rate": 45.00,
    "location": "La Habana",
    "category_id": "medio_automatico",
    "description": "Vehículo en excelente estado",
    "features": ["Aire acondicionado", "GPS"],
    "insurance_cost": 15.00,
    "deposit_amount": 200.00
}
```

### Vehículos (CRUD)

#### Listar vehículos
```http
GET /admin/api/vehicles?status=available&vehicle_type=sedan&location=La Habana
Authorization: Bearer {token}
```

#### Obtener vehículo específico
```http
GET /admin/api/vehicles/{vehicle_id}
Authorization: Bearer {token}
```

#### Crear vehículo
```http
POST /admin/api/vehicles
Authorization: Bearer {token}
Content-Type: application/json

{
    "license_plate": "ABC123",
    "brand": "Toyota",
    "model": "Corolla",
    "year": 2022,
    "color": "Blanco",
    "vehicle_type": "sedan",
    "transmission": "automático",
    "fuel_type": "gasolina",
    "seats": 5,
    "daily_rate": 45.00,
    "location": "La Habana"
}
```

#### Actualizar vehículo
```http
PUT /admin/api/vehicles/{vehicle_id}
Authorization: Bearer {token}
Content-Type: application/json

{
    "daily_rate": 50.00,
    "status": "maintenance"
}
```

#### Eliminar vehículo
```http
DELETE /admin/api/vehicles/{vehicle_id}
Authorization: Bearer {token}
```

#### Cambiar estado del vehículo
```http
PUT /admin/api/vehicles/{vehicle_id}/status
Authorization: Bearer {token}
Content-Type: application/json

{
    "status": "available"
}
```

### Rentas (CRUD)

#### Listar rentas
```http
GET /admin/api/rentals?user_id=1&status=active&payment_status=paid
Authorization: Bearer {token}
```

#### Obtener renta específica
```http
GET /admin/api/rentals/{rental_id}
Authorization: Bearer {token}
```

#### Crear renta
```http
POST /admin/api/rentals
Authorization: Bearer {token}
Content-Type: application/json

{
    "user_id": 1,
    "vehicle_id": 1,
    "start_date": "2024-01-15",
    "end_date": "2024-01-20",
    "pickup_location": "Aeropuerto José Martí",
    "return_location": "Aeropuerto José Martí",
    "rental_type": "daily",
    "total_days": 5,
    "daily_rate": 45.00,
    "total_amount": 225.00,
    "deposit_amount": 200.00,
    "insurance_amount": 75.00,
    "taxes_amount": 22.50,
    "final_amount": 322.50,
    "payment_method": "credit_card"
}
```

#### Cambiar estado de renta
```http
PUT /admin/api/rentals/{rental_id}/status
Authorization: Bearer {token}
Content-Type: application/json

{
    "rental_status": "active",
    "payment_status": "paid"
}
```

#### Completar renta
```http
PUT /admin/api/rentals/{rental_id}/complete
Authorization: Bearer {token}
Content-Type: application/json

{
    "return_notes": "Vehículo devuelto en buen estado",
    "final_odometer": 12500
}
```

#### Estadísticas de rentas
```http
GET /admin/api/rentals/statistics
Authorization: Bearer {token}
```

### Conductores

#### Listar conductores de una renta
```http
GET /admin/api/rentals/{rental_id}/drivers
Authorization: Bearer {token}
```

#### Agregar conductor a una renta
```http
POST /admin/api/rentals/{rental_id}/drivers
Authorization: Bearer {token}
Content-Type: application/json

{
    "driver_name": "Juan Pérez",
    "driver_license": "123456789",
    "driver_phone": "+53 5 123 4567",
    "driver_age": 25
}
```

### Servicios

#### Listar servicios de una renta
```http
GET /admin/api/rentals/{rental_id}/services
Authorization: Bearer {token}
```

#### Agregar servicio a una renta
```http
POST /admin/api/rentals/{rental_id}/services
Authorization: Bearer {token}
Content-Type: application/json

{
    "service_name": "GPS",
    "service_type": "equipment",
    "service_cost": 10.00
}
```

### APIs Públicas para Flutter

#### Vehículos disponibles
```http
GET /admin/api/vehicles/available?vehicle_type=sedan&location=La Habana&start_date=2024-01-15&end_date=2024-01-20
```

#### Verificar disponibilidad
```http
GET /admin/api/vehicles/{vehicle_id}/check-availability?start_date=2024-01-15&end_date=2024-01-20
```

#### Rentas de un usuario
```http
GET /admin/api/rentals/user/{user_id}
```

#### Información de usuario de una renta
```http
GET /admin/api/rentals/{rental_id}/user-info
```

## 📊 Estados del Sistema

### Estados de Vehículos
- `available` - Disponible para renta
- `rented` - Actualmente rentado
- `maintenance` - En mantenimiento
- `out_of_service` - Fuera de servicio

### Estados de Rentas
- `pending` - Pendiente de confirmación
- `confirmed` - Confirmada
- `active` - Activa (vehículo rentado)
- `completed` - Completada
- `cancelled` - Cancelada

### Estados de Pago
- `pending` - Pendiente de pago
- `paid` - Pagado
- `partial` - Pago parcial
- `refunded` - Reembolsado

## 🧪 Pruebas

### Script de Pruebas
```bash
python test_vehicle_upload.py
```

### Funcionalidades Probadas
- ✅ Login de administrador
- ✅ Obtención de categorías
- ✅ Detalles de categorías
- ✅ Creación de vehículos con categoría
- ✅ Subida de imágenes
- ✅ Eliminación de imágenes
- ✅ Listado de vehículos

## 🔧 Configuración

### Variables de Entorno
```env
# Base de datos
DATABASE_URL=sqlite:///vehicles.db

# Supabase (opcional)
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_key

# Configuración de archivos
UPLOAD_FOLDER=static/img/vehicles
MAX_FILE_SIZE=10485760  # 10MB
ALLOWED_EXTENSIONS=png,jpg,jpeg,gif,webp
```

### Configuraciones del Sistema
El sistema incluye **25+ configuraciones** relacionadas con vehículos:
- Precios base por categoría
- Límites de días de renta
- Porcentajes de seguro y depósito
- Configuraciones de ubicaciones
- Límites de conductores adicionales

### Reglas de Negocio
El sistema incluye **8 reglas de negocio** específicas para vehículos:
- Validación de fechas de renta
- Cálculo automático de precios
- Verificación de disponibilidad
- Gestión de depósitos y seguros
- Validación de conductores
- Control de servicios adicionales

### Límites del Sistema
El sistema incluye **7 límites** para vehículos:
- Máximo número de vehículos por categoría
- Límite de días de renta
- Máximo número de conductores por renta
- Límite de servicios adicionales
- Restricciones de ubicación
- Límites de precio por categoría

## 📱 Integración con Flutter

### Ejemplo de Uso en Flutter

#### Obtener categorías
```dart
final response = await http.get(
  Uri.parse('$baseUrl/admin/api/vehicles/categories'),
  headers: {'Authorization': 'Bearer $token'},
);

if (response.statusCode == 200) {
  final data = json.decode(response.body);
  final categories = data['categories'] as List;
  // Procesar categorías
}
```

#### Crear vehículo con categoría
```dart
final vehicleData = {
  'license_plate': 'ABC123',
  'brand': 'Toyota',
  'model': 'Corolla',
  'year': 2022,
  'color': 'Blanco',
  'vehicle_type': 'sedan',
  'transmission': 'automático',
  'fuel_type': 'gasolina',
  'seats': 5,
  'daily_rate': 45.00,
  'location': 'La Habana',
  'category_id': 'medio_automatico',
};

final response = await http.post(
  Uri.parse('$baseUrl/admin/api/vehicles/create-with-category'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
  body: json.encode(vehicleData),
);
```

#### Subir imágenes
```dart
var request = http.MultipartRequest(
  'POST',
  Uri.parse('$baseUrl/admin/api/vehicles/upload-images'),
);

request.headers['Authorization'] = 'Bearer $token';
request.fields['vehicle_id'] = vehicleId.toString();

for (var imageFile in imageFiles) {
  request.files.add(await http.MultipartFile.fromPath(
    'images',
    imageFile.path,
  ));
}

final response = await request.send();
```

## 🚀 Despliegue

### Requisitos
- Python 3.8+
- Flask
- SQLite o PostgreSQL
- Espacio en disco para imágenes

### Instalación
```bash
# Instalar dependencias
pip install -r requirements.txt

# Inicializar base de datos
python -c "from database import local_db; local_db.init_database()"

# Ejecutar servidor
python app.py
```

### Estructura de Directorios
```
backend-duffel/
├── static/
│   └── img/
│       └── vehicles/          # Imágenes de vehículos
├── templates/
│   └── admin/
│       ├── vehicles.html      # Panel de vehículos
│       └── rentals.html       # Panel de rentas
├── admin_routes.py            # Rutas de administración
├── database.py               # Base de datos local
├── supabase_service.py       # Servicio de Supabase
├── test_vehicle_upload.py    # Script de pruebas
└── README_VEHICULOS.md       # Esta documentación
```

## 📝 Notas Importantes

1. **Categorías**: Cada vehículo debe pertenecer a una categoría específica
2. **Imágenes**: Se recomienda subir al menos 3-5 imágenes por vehículo
3. **Precios**: Los precios se establecen por día de renta
4. **Disponibilidad**: El sistema verifica automáticamente la disponibilidad
5. **Backup**: Las imágenes se almacenan localmente, considerar backup
6. **Validaciones**: El sistema valida todos los datos antes de guardar
7. **Seguridad**: Solo administradores pueden gestionar vehículos
8. **Escalabilidad**: El sistema soporta múltiples ubicaciones

## 🔄 Actualizaciones Futuras

- [ ] Sistema de reseñas y calificaciones
- [ ] Integración con GPS para tracking
- [ ] Sistema de notificaciones
- [ ] Reportes avanzados
- [ ] Integración con sistemas de pago
- [ ] App móvil para conductores
- [ ] Sistema de mantenimiento programado
- [ ] Integración con proveedores de seguros
