# ANÁLISIS DEL PROCESO DE COMPRA POR PESO

## 📊 INVESTIGACIÓN DE PLATAFORMAS

### 🛒 **AMAZON**
**Proceso de Compra por Peso:**
1. **Detección Automática**: Amazon extrae automáticamente el peso de los productos de sus especificaciones
2. **Cálculo de Envío**: El peso se usa para calcular costos de envío y tiempo de entrega
3. **Categorización**: Productos se categorizan por peso (ligero, medio, pesado)
4. **Tarifas Variables**: Diferentes tarifas según peso y destino

**Campos de Peso en Amazon:**
- `weight`: String descriptivo (ej: "1.5 kg", "2.2 lbs")
- `weightKg`: Double numérico en kilogramos
- `dimensions`: Información de dimensiones
- `shippingWeight`: Peso para envío (puede incluir empaque)

### 🏪 **WALMART**
**Proceso de Compra por Peso:**
1. **Extracción Inteligente**: Walmart extrae peso de múltiples campos
2. **Conversión Automática**: Convierte automáticamente entre unidades
3. **Estimación**: Si no hay peso, estima basado en categoría
4. **Validación**: Valida peso contra dimensiones del producto

**Campos de Peso en Walmart:**
- `weight`: String descriptivo
- `shippingWeight`: Peso específico para envío
- `itemWeight`: Peso del artículo sin empaque
- `packageWeight`: Peso total con empaque

### 🏠 **HOME DEPOT**
**Proceso de Compra por Peso:**
1. **Productos Pesados**: Enfoque en productos de construcción
2. **Envío Especializado**: Requiere envío especial para productos pesados
3. **Restricciones**: Algunos productos no se pueden enviar por peso
4. **Tarifas Premium**: Costos adicionales por peso y dimensiones

### 🌐 **DIMECUBA.COM**
**Proceso Observado:**
1. **Productos por Peso**: Muestra productos con información de peso
2. **Cálculo de Envío**: Usa peso para calcular costos de envío a Cuba
3. **Categorización**: Separa productos por tipo de envío (express, marítimo)
4. **Logos de Vendedor**: Muestra logos pequeños para identificar origen

### 🦙 **CUBALLAMA.COM**
**Proceso Observado:**
1. **Sistema Similar**: Proceso similar a DimeCuba
2. **Enfoque en Peso**: Énfasis en productos pesados y voluminosos
3. **Cálculo Dinámico**: Precios de envío calculados dinámicamente
4. **Identificación Visual**: Logos de vendedores para transparencia

## 🔧 IMPLEMENTACIÓN ACTUAL EN NUESTRA APP

### ✅ **LO QUE YA TENEMOS:**

#### 1. **Modelos de Producto:**
```dart
// StoreProduct
final double weight; // peso en kg
final String unit; // lb, kg, unidad, etc.

// AmazonProduct
final String? weight; // peso descriptivo
final double? weightKg; // peso numérico en kg

// WalmartProduct
final String? weight; // peso descriptivo
double getEstimatedWeightKg() // conversión automática
```

#### 2. **Funciones de Conversión:**
```dart
// AmazonProduct
double? parseWeightKg(dynamic weightValue) {
  // Convierte "1.5 kg" -> 1.5
  // Convierte "2.2 lbs" -> 1.0 kg
  // Convierte "500g" -> 0.5 kg
}

// WalmartProduct
double getEstimatedWeightKg() {
  // Convierte automáticamente entre unidades
  // Maneja lb, kg, oz, g
  // Retorna peso en kg para cálculos
}
```

#### 3. **Integración en Carrito:**
```dart
// CartItem
final dynamic weight; // peso del producto
// Se agrega al carrito con información de peso
```

### 🚀 **LO QUE NECESITAMOS IMPLEMENTAR:**

#### 1. **Sistema de Cálculo de Envío por Peso:**
```dart
class ShippingCalculator {
  static double calculateShippingCost(double weightKg, String destination) {
    // Tarifas por peso
    if (weightKg <= 0.5) return 5.00; // Hasta 500g
    if (weightKg <= 1.0) return 8.00; // Hasta 1kg
    if (weightKg <= 2.0) return 12.00; // Hasta 2kg
    if (weightKg <= 5.0) return 20.00; // Hasta 5kg
    return 20.00 + ((weightKg - 5.0) * 3.00); // +$3 por kg adicional
  }
}
```

#### 2. **Categorización por Peso:**
```dart
enum WeightCategory {
  light,    // < 1kg
  medium,   // 1-5kg
  heavy,    // 5-20kg
  oversized // > 20kg
}

class WeightCategoryDetector {
  static WeightCategory getCategory(double weightKg) {
    if (weightKg < 1.0) return WeightCategory.light;
    if (weightKg < 5.0) return WeightCategory.medium;
    if (weightKg < 20.0) return WeightCategory.heavy;
    return WeightCategory.oversized;
  }
}
```

#### 3. **Validación de Envío:**
```dart
class ShippingValidator {
  static bool canShipToCuba(double weightKg, String productType) {
    // Reglas de envío a Cuba
    if (weightKg > 50.0) return false; // Límite de peso
    if (productType == 'hazardous') return false; // Productos peligrosos
    return true;
  }
}
```

#### 4. **UI para Mostrar Peso:**
```dart
class WeightDisplay extends StatelessWidget {
  final double weightKg;
  final String? originalWeight;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getWeightColor(weightKg),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.scale, size: 16),
          SizedBox(width: 4),
          Text('${weightKg.toStringAsFixed(1)} kg'),
          if (originalWeight != null)
            Text(' ($originalWeight)', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
```

## 📋 PLAN DE IMPLEMENTACIÓN

### **FASE 1: Sistema de Cálculo de Envío**
1. Crear `ShippingCalculator` con tarifas por peso
2. Integrar con `CartService` para calcular costos totales
3. Mostrar costos de envío en tiempo real

### **FASE 2: Categorización Visual**
1. Implementar `WeightCategoryDetector`
2. Crear `WeightDisplay` widget
3. Mostrar categoría de peso en tarjetas de productos

### **FASE 3: Validación y Restricciones**
1. Implementar `ShippingValidator`
2. Mostrar alertas para productos no enviables
3. Sugerir alternativas para productos pesados

### **FASE 4: Integración con Backend**
1. Actualizar API para manejar peso
2. Implementar cálculos de envío en backend
3. Sincronizar con sistema de órdenes

## 🎯 BENEFICIOS ESPERADOS

1. **Transparencia**: Usuarios ven costos de envío antes de comprar
2. **Precisión**: Cálculos exactos basados en peso real
3. **Eficiencia**: Menos errores en envíos
4. **Competitividad**: Sistema similar a plataformas líderes
5. **Escalabilidad**: Fácil agregar nuevos vendedores y destinos

## 🔍 PRÓXIMOS PASOS

1. **Implementar ShippingCalculator**
2. **Crear WeightDisplay widget**
3. **Integrar con sistema de carrito**
4. **Actualizar backend para cálculos de envío**
5. **Probar con productos reales de Amazon/Walmart**
