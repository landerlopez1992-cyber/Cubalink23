# 🤖 Sistema de Automatización Cuba Transtur

## 📋 Descripción

Sistema completo de automatización para reservas de vehículos en Cuba Transtur. Elimina la necesidad de crear emails manuales y automatiza todo el proceso de reserva.

## ✨ Características Principales

### 🔧 **Automatización Completa**
- **Web Scraping Automático**: Abre Cuba Transtur automáticamente
- **Generación de Emails Temporales**: Crea emails únicos automáticamente
- **Llenado de Formularios**: Completa todos los campos automáticamente
- **Captura de Confirmaciones**: Obtiene números de confirmación
- **Gestión de Base de Datos**: Guarda todas las reservas

### 📊 **Panel de Administración**
- **Dashboard de Reservas**: Vista general de todas las reservas
- **Historial Completo**: Todas las reservas con estados
- **Estadísticas en Tiempo Real**: Métricas de éxito y ingresos
- **Gestión de Clientes**: Datos de clientes centralizados

### 🔄 **Flujo Automatizado**
1. Cliente solicita auto en tu app
2. Sistema genera email temporal automáticamente
3. Sistema navega a Cuba Transtur
4. Llena formulario con datos del cliente
5. Envía reserva automáticamente
6. Captura confirmación
7. Notifica al cliente
8. Guarda en base de datos

## 🚀 Instalación y Configuración

### **Dependencias Requeridas**
```bash
pip3 install selenium webdriver-manager
```

### **Configuración del Navegador**
El sistema usa Chrome WebDriver automáticamente:
- Descarga automática del driver
- Configuración optimizada
- Modo headless disponible

## 📁 Estructura de Archivos

```
backend-duffel/
├── cuba_transtur_automation.py    # Sistema principal de automatización
├── test_cuba_transtur_automation.py  # Script de pruebas
├── admin_routes.py                # Rutas del panel admin
└── README_CUBA_TRANSTUR_AUTOMATION.md  # Esta documentación
```

## 🔌 API Endpoints

### **Panel de Administración**
- `GET /admin/cuba-transtur` - Dashboard principal
- `GET /admin/api/cuba-transtur/bookings` - Listar reservas
- `POST /admin/api/cuba-transtur/bookings` - Crear reserva
- `GET /admin/api/cuba-transtur/bookings/<id>` - Ver reserva específica
- `GET /admin/api/cuba-transtur/statistics` - Estadísticas
- `GET /admin/api/cuba-transtur/test-connection` - Probar conexión

## 💻 Uso del Sistema

### **1. Crear Reserva Automatizada**
```python
from cuba_transtur_automation import create_automated_booking

client_data = {
    'name': 'Juan Pérez',
    'phone': '+53 5 123 4567',
    'pickup_date': '2024-02-15',
    'return_date': '2024-02-20',
    'pickup_location': 'Aeropuerto José Martí',
    'vehicle_type': 'Económico Automático',
    'driver_age': '30',
    'driver_license': 'ABC123456',
    'passport_number': '123456789',
    'flight_number': 'AA123',
    'hotel_name': 'Hotel Nacional'
}

result = create_automated_booking(client_data)
print(f"Reserva creada: {result['reservation_id']}")
```

### **2. Verificar Estado de Reserva**
```python
from cuba_transtur_automation import check_booking_status

status = check_booking_status('CT20240831123456')
print(f"Estado: {status['status']}")
```

### **3. Obtener Historial**
```python
from cuba_transtur_automation import get_booking_history

bookings = get_booking_history()
for booking in bookings:
    print(f"Cliente: {booking['client_data']['name']}")
    print(f"Estado: {booking['status']}")
```

## 🧪 Pruebas del Sistema

### **Ejecutar Pruebas Completas**
```bash
python3 test_cuba_transtur_automation.py
```

### **Pruebas Incluidas**
- ✅ Conexión con Cuba Transtur
- ✅ Creación de reserva automatizada
- ✅ Verificación de estado
- ✅ Historial de reservas
- ✅ Estadísticas del sistema

## 📊 Datos de Salida

### **Estructura de Reserva**
```json
{
    "status": "confirmed",
    "reservation_id": "CT20240831123456",
    "temp_email": "reserva_CT20240831123456_juanperez_20240831_123456_abcd@cubalink.com",
    "confirmation_number": "CT123456",
    "message": "Reserva confirmada exitosamente",
    "client_data": {
        "name": "Juan Pérez",
        "phone": "+53 5 123 4567",
        "pickup_date": "2024-02-15",
        "return_date": "2024-02-20",
        "vehicle_type": "Económico Automático"
    },
    "booking_date": "2024-08-31T12:34:56",
    "automation_success": true
}
```

### **Estadísticas del Sistema**
```json
{
    "total_bookings": 25,
    "confirmed_bookings": 22,
    "pending_bookings": 2,
    "error_bookings": 1,
    "success_rate": 88.0,
    "total_income": 12500.00,
    "average_booking_value": 568.18
}
```

## 🔧 Configuración Avanzada

### **Modo Headless (Sin Interfaz)**
```python
# En cuba_transtur_automation.py, descomenta esta línea:
chrome_options.add_argument("--headless")
```

### **Personalizar Selectores**
```python
# Ajustar selectores según la estructura de Cuba Transtur
field_mappings = {
    'name': ['input[name="name"]', 'input[id="name"]'],
    'email': ['input[name="email"]', 'input[type="email"]'],
    # Agregar más selectores según sea necesario
}
```

### **Configurar Timeouts**
```python
# Ajustar tiempo de espera
self.wait = WebDriverWait(self.driver, 15)  # 15 segundos
```

## 🚨 Solución de Problemas

### **Error: ChromeDriver no encontrado**
```bash
# Instalar webdriver-manager
pip3 install --user webdriver-manager
```

### **Error: Elemento no encontrado**
- Verificar que los selectores coincidan con la página
- Ajustar timeouts si la página carga lento
- Revisar si Cuba Transtur cambió su estructura

### **Error: Conexión fallida**
- Verificar conexión a internet
- Comprobar que Cuba Transtur esté disponible
- Revisar firewall/proxy

## 📈 Ventajas del Sistema

### **Para el Administrador**
- ✅ **No más emails manuales**: Generación automática
- ✅ **Proceso 100% automatizado**: Sin intervención manual
- ✅ **Todas las reservas centralizadas**: Un solo lugar
- ✅ **Notificaciones automáticas**: Sin perder confirmaciones
- ✅ **Historial completo**: Seguimiento de todas las reservas

### **Para los Clientes**
- ✅ **Proceso más rápido**: Reservas instantáneas
- ✅ **Confirmaciones automáticas**: Sin esperar manual
- ✅ **Mejor experiencia**: Proceso transparente
- ✅ **Soporte centralizado**: Un solo punto de contacto

## 🔮 Próximas Mejoras

### **Funcionalidades Planificadas**
- [ ] **Integración con múltiples proveedores**: Cuba Transtur, Havanautos, etc.
- [ ] **Sistema de notificaciones push**: Alertas en tiempo real
- [ ] **Dashboard en tiempo real**: Actualizaciones automáticas
- [ ] **Reportes automáticos**: PDF, Excel, etc.
- [ ] **Integración con WhatsApp**: Notificaciones por WhatsApp
- [ ] **Sistema de comisiones**: Cálculo automático de ganancias

### **Optimizaciones Técnicas**
- [ ] **Cache de formularios**: Respuestas más rápidas
- [ ] **Retry automático**: Reintentos en caso de fallo
- [ ] **Logs detallados**: Mejor debugging
- [ ] **Métricas avanzadas**: Análisis de rendimiento

## 📞 Soporte

Para soporte técnico o preguntas sobre el sistema:
- **Email**: soporte@cubalink.com
- **Documentación**: Este archivo README
- **Logs**: Revisar archivos de log del sistema

---

**¡El sistema de automatización de Cuba Transtur está listo para revolucionar tu proceso de reservas! 🚀**

