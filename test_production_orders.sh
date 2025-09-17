#!/bin/bash
# 🧪 TEST DE ÓRDENES EN PRODUCCIÓN

echo "🧪 ===== TESTING ÓRDENES EN PRODUCCIÓN ====="
echo ""

# 1. Verificar backend
echo "🔍 1. Verificando backend sistema..."
curl -s https://cubalink23-system.onrender.com/api/health | jq '.'
echo ""

# 2. Crear orden de prueba
echo "🛒 2. Creando orden de prueba..."
RESPONSE=$(curl -s -X POST https://cubalink23-system.onrender.com/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "0b802a1e-8651-4fcf-b2d7-0442db89f4d7",
    "order_number": "PROD-FINAL-TEST-001",
    "shipping_method": "express",
    "subtotal": 10.99,
    "shipping_cost": 2.00,
    "total": 12.99,
    "payment_method": "wallet",
    "payment_status": "completed",
    "order_status": "payment_confirmed",
    "shipping_address": {
      "recipient": "Lander Lopez",
      "phone": "+1234567890",
      "address": "Calle Producción 123",
      "city": "Havana",
      "province": "La Habana"
    },
    "items": [],
    "cart_items": [
      {
        "product_id": "final-test-1",
        "product_name": "Producto Final Test",
        "product_price": 10.99,
        "quantity": 1,
        "product_type": "store",
        "weight_lb": 0.3
      }
    ]
  }')

echo "$RESPONSE" | jq '.'
echo ""

# 3. Verificar órdenes del usuario
echo "📋 3. Verificando órdenes del usuario..."
curl -s https://cubalink23-system.onrender.com/api/orders/user/0b802a1e-8651-4fcf-b2d7-0442db89f4d7 | jq '.orders | length'
echo ""

echo "✅ ===== TEST COMPLETADO ====="
