# 🧪 TARJETAS DE PRUEBA DE SQUARE SANDBOX

## ✅ TARJETAS QUE FUNCIONAN (Pago Exitoso)

### Visa
- **Número**: 4111 1111 1111 1111
- **CVV**: 123
- **Vencimiento**: 12/25
- **Nombre**: Test User

### Mastercard
- **Número**: 5555 5555 5555 4444
- **CVV**: 123
- **Vencimiento**: 12/25
- **Nombre**: Test User

### American Express
- **Número**: 3782 822463 10005
- **CVV**: 1234
- **Vencimiento**: 12/25
- **Nombre**: Test User

---

## ❌ TARJETAS QUE FALLAN (Para probar errores)

### 1. Tarjeta Declinada
- **Número**: 4000 0000 0000 0002
- **CVV**: 123
- **Vencimiento**: 12/25
- **Nombre**: Test User
- **Error**: "Your card was declined"

### 2. Fondo Insuficiente
- **Número**: 4000 0000 0000 9995
- **CVV**: 123
- **Vencimiento**: 12/25
- **Nombre**: Test User
- **Error**: "Insufficient funds"

### 3. Tarjeta Expirada
- **Número**: 4000 0000 0000 0069
- **CVV**: 123
- **Vencimiento**: 01/20
- **Nombre**: Test User
- **Error**: "Your card has expired"

### 4. CVV Incorrecto
- **Número**: 4111 1111 1111 1111
- **CVV**: 999
- **Vencimiento**: 12/25
- **Nombre**: Test User
- **Error**: "The security code is incorrect"

### 5. Problema de Procesamiento
- **Número**: 4000 0000 0000 0119
- **CVV**: 123
- **Vencimiento**: 12/25
- **Nombre**: Test User
- **Error**: "Processing error"

### 6. Tarjeta Robada/Perdida
- **Número**: 4000 0000 0000 9987
- **CVV**: 123
- **Vencimiento**: 12/25
- **Nombre**: Test User
- **Error**: "Your card was declined"

### 7. Límite de Transacción Excedido
- **Número**: 4000 0000 0000 0069
- **CVV**: 123
- **Vencimiento**: 12/25
- **Nombre**: Test User
- **Error**: "Transaction limit exceeded"

---

## 🎯 CÓMO USAR ESTAS TARJETAS

### Para Probar ÉXITO:
1. Agregar Balance → Seleccionar $50
2. Usar tarjeta: `4111 1111 1111 1111`
3. CVV: `123`, Vencimiento: `12/25`
4. Resultado: Pantalla verde de éxito

### Para Probar ERROR:
1. Agregar Balance → Seleccionar $50
2. Usar tarjeta: `4000 0000 0000 0002`
3. CVV: `123`, Vencimiento: `12/25`
4. Resultado: Pantalla roja de error

---

## 📝 NOTAS IMPORTANTES

- **Todas estas tarjetas son de PRUEBA** - no son reales
- **Solo funcionan en el entorno Sandbox** de Square
- **No se procesan pagos reales** con estas tarjetas
- **Los errores son simulados** por Square para testing
- **Puedes usar cualquier nombre** para el titular de la tarjeta
- **Las fechas de vencimiento** pueden ser futuras (excepto las que están diseñadas para fallar)


