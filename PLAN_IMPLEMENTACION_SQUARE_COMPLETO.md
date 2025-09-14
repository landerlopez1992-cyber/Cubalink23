# 🚀 Plan de Implementación Completo - Square Payments

## 🔍 **DIAGNÓSTICO ACTUAL**

### ✅ **LO QUE TENEMOS**
- Backend Python completo (`square_service.py`) con todas las funcionalidades
- Estructura de datos y endpoints definidos
- Documentación completa (`README_PAGOS.md`)
- Servicio Flutter desactivado pero con estructura lista
- Variables de entorno configuradas (pero credenciales inválidas)

### ❌ **PROBLEMAS IDENTIFICADOS**
1. **Credenciales Square inválidas** - Error 401 UNAUTHORIZED
2. **Servicio Flutter desactivado** - Solo modo simulación
3. **Falta integración real** entre app y backend
4. **No hay reembolsos desde la app**
5. **No hay dashboard de administración**

## 🎯 **PLAN DE IMPLEMENTACIÓN**

### **FASE 1: OBTENER CREDENCIALES VÁLIDAS DE SQUARE** 🔑
**Prioridad: CRÍTICA**

#### 1.1 Crear Cuenta Square Developer
- Ir a: https://developer.squareup.com/
- Crear cuenta de desarrollador
- Verificar email y completar perfil

#### 1.2 Crear Aplicación
- Crear nueva aplicación en Square Dashboard
- Configurar permisos necesarios:
  - `PAYMENTS_WRITE` - Procesar pagos
  - `PAYMENTS_READ` - Leer pagos
  - `CUSTOMERS_WRITE` - Crear clientes
  - `CUSTOMERS_READ` - Leer clientes
  - `ORDERS_WRITE` - Crear órdenes
  - `ORDERS_READ` - Leer órdenes

#### 1.3 Obtener Credenciales Sandbox
```env
SQUARE_ACCESS_TOKEN=sandbox-sq0atb-[TOKEN_REAL]
SQUARE_APPLICATION_ID=sandbox-sq0idb-[APP_ID_REAL]
SQUARE_LOCATION_ID=[LOCATION_ID_REAL]
SQUARE_ENVIRONMENT=sandbox
```

#### 1.4 Configurar Webhook (Opcional)
- URL: `https://tu-dominio.com/webhooks/square`
- Eventos: `payment.created`, `payment.updated`, `refund.created`

### **FASE 2: REACTIVAR SERVICIO FLUTTER** 📱
**Prioridad: ALTA**

#### 2.1 Modificar `square_payment_service.dart`
```dart
class SquarePaymentService {
  // Configuración real
  static const String _applicationId = 'sandbox-sq0idb-[APP_ID_REAL]';
  static const String _locationId = '[LOCATION_ID_REAL]';
  static const String _environment = 'sandbox';
  
  /// Initialize Square Payment Service
  static Future<void> initialize() async {
    try {
      // Inicializar Square con credenciales reales
      await SquarePayment.initialize(
        applicationId: _applicationId,
        locationId: _locationId,
      );
      print('✅ Square inicializado correctamente');
    } catch (e) {
      print('❌ Error inicializando Square: $e');
      throw e;
    }
  }
  
  /// Procesar pago REAL
  static Future<SquarePaymentResult> processPayment({
    required double amount,
    required String description,
    required String cardLast4,
    required String cardType,
    required String cardHolderName,
  }) async {
    try {
      // Procesar pago real con Square
      final result = await SquarePayment.processPayment(
        amount: amount,
        description: description,
      );
      
      return SquarePaymentResult(
        success: result.success,
        transactionId: result.transactionId,
        message: result.message,
        amount: amount,
      );
    } catch (e) {
      return SquarePaymentResult(
        success: false,
        transactionId: null,
        message: 'Error procesando pago: $e',
        amount: amount,
      );
    }
  }
}
```

#### 2.2 Agregar Dependencias Flutter
```yaml
dependencies:
  square_payment: ^1.0.0  # O la versión más reciente
  http: ^1.1.0
```

### **FASE 3: CREAR ENDPOINTS DE PAGO EN BACKEND** 🔌
**Prioridad: ALTA**

#### 3.1 Endpoints Necesarios
```python
# En app.py o admin_routes.py

@app.route('/api/payments/process', methods=['POST'])
def process_payment():
    """Procesar pago desde la app"""
    data = request.get_json()
    
    # Validar datos
    if not data.get('amount') or not data.get('source_id'):
        return jsonify({'success': False, 'error': 'Datos incompletos'}), 400
    
    # Procesar con Square
    result = square_service.process_payment(data)
    
    if result['success']:
        # Guardar en base de datos
        save_payment_to_db(result)
        
        # Enviar notificación
        send_payment_notification(result)
    
    return jsonify(result)

@app.route('/api/payments/refund', methods=['POST'])
def refund_payment():
    """Reembolsar pago"""
    data = request.get_json()
    
    result = square_service.refund_payment(
        payment_id=data['payment_id'],
        amount=data.get('amount'),
        reason=data.get('reason', 'Customer request')
    )
    
    if result['success']:
        # Actualizar en base de datos
        update_refund_in_db(result)
    
    return jsonify(result)

@app.route('/api/payments/history', methods=['GET'])
def get_payment_history():
    """Obtener historial de pagos"""
    user_id = request.args.get('user_id')
    
    # Obtener de base de datos local
    payments = get_payments_from_db(user_id)
    
    return jsonify({
        'success': True,
        'payments': payments
    })
```

#### 3.2 Base de Datos para Pagos
```sql
-- Tabla para almacenar pagos
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    square_payment_id VARCHAR(255) UNIQUE,
    amount DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla para reembolsos
CREATE TABLE refunds (
    id SERIAL PRIMARY KEY,
    payment_id INTEGER REFERENCES payments(id),
    square_refund_id VARCHAR(255) UNIQUE,
    amount DECIMAL(10,2),
    reason TEXT,
    status VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);
```

### **FASE 4: IMPLEMENTAR REEMBOLSOS** 💰
**Prioridad: MEDIA**

#### 4.1 Pantalla de Reembolsos en Flutter
```dart
class RefundScreen extends StatefulWidget {
  final String paymentId;
  final double amount;
  
  const RefundScreen({
    Key? key,
    required this.paymentId,
    required this.amount,
  }) : super(key: key);

  @override
  _RefundScreenState createState() => _RefundScreenState();
}

class _RefundScreenState extends State<RefundScreen> {
  final _reasonController = TextEditingController();
  double _refundAmount = 0.0;
  bool _isFullRefund = true;

  Future<void> _processRefund() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/refund'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'payment_id': widget.paymentId,
          'amount': _isFullRefund ? null : _refundAmount,
          'reason': _reasonController.text,
        }),
      );

      final result = json.decode(response.body);
      
      if (result['success']) {
        _showSuccessDialog(result);
      } else {
        _showErrorDialog(result['error']);
      }
    } catch (e) {
      _showErrorDialog('Error de conexión: $e');
    }
  }
}
```

#### 4.2 Panel de Administración
```html
<!-- templates/admin/refunds.html -->
<div class="refund-panel">
    <h3>Gestionar Reembolsos</h3>
    
    <div class="payment-search">
        <input type="text" id="payment-search" placeholder="Buscar por ID de pago">
        <button onclick="searchPayment()">Buscar</button>
    </div>
    
    <div id="payment-details" style="display: none;">
        <div class="payment-info">
            <p>ID: <span id="payment-id"></span></p>
            <p>Monto: $<span id="payment-amount"></span></p>
            <p>Estado: <span id="payment-status"></span></p>
        </div>
        
        <div class="refund-form">
            <label>
                <input type="radio" name="refund-type" value="full" checked>
                Reembolso completo
            </label>
            <label>
                <input type="radio" name="refund-type" value="partial">
                Reembolso parcial: $<input type="number" id="partial-amount" step="0.01">
            </label>
            
            <textarea id="refund-reason" placeholder="Razón del reembolso"></textarea>
            
            <button onclick="processRefund()">Procesar Reembolso</button>
        </div>
    </div>
</div>
```

### **FASE 5: DASHBOARD DE ADMINISTRACIÓN** 📊
**Prioridad: MEDIA**

#### 5.1 Panel de Pagos
```html
<!-- templates/admin/payments.html -->
<div class="payments-dashboard">
    <div class="stats-cards">
        <div class="stat-card">
            <h4>Pagos Hoy</h4>
            <span id="today-payments">$0.00</span>
        </div>
        <div class="stat-card">
            <h4>Pagos Este Mes</h4>
            <span id="month-payments">$0.00</span>
        </div>
        <div class="stat-card">
            <h4>Reembolsos Pendientes</h4>
            <span id="pending-refunds">0</span>
        </div>
    </div>
    
    <div class="payments-table">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Usuario</th>
                    <th>Monto</th>
                    <th>Estado</th>
                    <th>Fecha</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody id="payments-list">
                <!-- Llenar dinámicamente -->
            </tbody>
        </table>
    </div>
</div>
```

#### 5.2 Estadísticas en Tiempo Real
```javascript
// Actualizar estadísticas cada 30 segundos
setInterval(async () => {
    try {
        const response = await fetch('/admin/api/payments/stats');
        const stats = await response.json();
        
        document.getElementById('today-payments').textContent = 
            '$' + stats.today_total.toFixed(2);
        document.getElementById('month-payments').textContent = 
            '$' + stats.month_total.toFixed(2);
        document.getElementById('pending-refunds').textContent = 
            stats.pending_refunds;
    } catch (error) {
        console.error('Error actualizando estadísticas:', error);
    }
}, 30000);
```

### **FASE 6: NOTIFICACIONES Y WEBHOOKS** 🔔
**Prioridad: BAJA**

#### 6.1 Webhooks de Square
```python
@app.route('/webhooks/square', methods=['POST'])
def square_webhook():
    """Procesar webhooks de Square"""
    signature = request.headers.get('X-Square-Signature')
    payload = request.get_data()
    
    # Verificar firma (importante para seguridad)
    if not verify_webhook_signature(payload, signature):
        return jsonify({'error': 'Invalid signature'}), 401
    
    data = request.get_json()
    event_type = data.get('type')
    
    if event_type == 'payment.created':
        handle_payment_created(data)
    elif event_type == 'payment.updated':
        handle_payment_updated(data)
    elif event_type == 'refund.created':
        handle_refund_created(data)
    
    return jsonify({'success': True})
```

#### 6.2 Notificaciones Push
```dart
// En Flutter
class PaymentNotificationService {
  static Future<void> sendPaymentNotification({
    required String userId,
    required String message,
    required Map<String, dynamic> data,
  }) async {
    try {
      await FirebaseMessaging.instance.sendMessage(
        to: userId,
        notification: FirebaseNotification(
          title: 'Pago Procesado',
          body: message,
        ),
        data: data,
      );
    } catch (e) {
      print('Error enviando notificación: $e');
    }
  }
}
```

## 🧪 **TARJETAS DE PRUEBA SANDBOX**

### Tarjetas Válidas
- **Visa**: 4111 1111 1111 1111
- **MasterCard**: 5555 5555 5555 4444
- **American Express**: 3782 822463 10005
- **Discover**: 6011 1111 1111 1117

### Datos de Prueba
- **CVV**: Cualquier número de 3-4 dígitos
- **Fecha**: Cualquier fecha futura
- **Código Postal**: 10003

### Tarjetas de Error (Para Testing)
- **Tarjeta Declinada**: 4000 0000 0000 0002
- **Fondos Insuficientes**: 4000 0000 0000 9995
- **CVV Incorrecto**: 4000 0000 0000 0127

## 📋 **CHECKLIST DE IMPLEMENTACIÓN**

### ✅ **FASE 1: Credenciales**
- [ ] Crear cuenta Square Developer
- [ ] Crear aplicación en Square
- [ ] Obtener Access Token
- [ ] Obtener Application ID
- [ ] Obtener Location ID
- [ ] Actualizar variables de entorno
- [ ] Probar conexión con API

### ✅ **FASE 2: Flutter**
- [ ] Reactivar square_payment_service.dart
- [ ] Agregar dependencias Flutter
- [ ] Implementar inicialización real
- [ ] Implementar procesamiento de pagos
- [ ] Probar pagos desde la app

### ✅ **FASE 3: Backend**
- [ ] Crear endpoint /api/payments/process
- [ ] Crear endpoint /api/payments/refund
- [ ] Crear endpoint /api/payments/history
- [ ] Crear tablas de base de datos
- [ ] Integrar con Square service

### ✅ **FASE 4: Reembolsos**
- [ ] Crear pantalla de reembolsos Flutter
- [ ] Crear panel de reembolsos admin
- [ ] Implementar lógica de reembolsos
- [ ] Probar reembolsos completos y parciales

### ✅ **FASE 5: Dashboard**
- [ ] Crear panel de administración
- [ ] Implementar estadísticas
- [ ] Crear tabla de pagos
- [ ] Implementar filtros y búsqueda

### ✅ **FASE 6: Notificaciones**
- [ ] Configurar webhooks
- [ ] Implementar notificaciones push
- [ ] Crear sistema de alertas
- [ ] Probar notificaciones

## 🚀 **PRÓXIMOS PASOS INMEDIATOS**

1. **OBTENER CREDENCIALES VÁLIDAS** (Prioridad #1)
   - Ir a https://developer.squareup.com/
   - Crear cuenta y aplicación
   - Obtener tokens de sandbox

2. **ACTUALIZAR CONFIGURACIÓN**
   ```bash
   # Actualizar config.env.backup con credenciales reales
   SQUARE_ACCESS_TOKEN=sandbox-sq0atb-[TOKEN_REAL]
   SQUARE_APPLICATION_ID=sandbox-sq0idb-[APP_ID_REAL]
   SQUARE_LOCATION_ID=[LOCATION_ID_REAL]
   ```

3. **PROBAR CONEXIÓN**
   ```bash
   python test_square_connection.py
   ```

4. **REACTIVAR FLUTTER**
   - Modificar square_payment_service.dart
   - Agregar dependencias
   - Probar pagos

---

**Estado**: 🔴 **REQUIERE CREDENCIALES VÁLIDAS**  
**Tiempo estimado**: 1-2 días para obtener credenciales + 3-4 días desarrollo  
**Dependencias**: Cuenta Square Developer activa



