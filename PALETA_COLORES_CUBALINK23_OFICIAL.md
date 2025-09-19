# 🎨 PALETA DE COLORES OFICIAL - CUBALINK23

## 📋 **REGLA OBLIGATORIA PARA TODOS LOS AGENTES**

**⚠️ IMPORTANTE**: Todos los agentes **DEBEN** usar esta paleta de colores al crear nuevas pantallas en Cubalink23, **a menos que el usuario solicite explícitamente colores diferentes**.

Esta regla existe para mantener **consistencia visual** y evitar que la app parezca **"un carrusel de colores diferentes"**.

---

## 🎨 **COLORES OFICIALES**

### **🟢 VERDES (Identidad Principal)**
```dart
// Verde Principal - Secciones principales, fondos destacados
static const Color primaryGreen = Color(0xFF2E7D32);

// Verde Claro - Botones seleccionados, elementos activos
static const Color lightGreen = Color(0xFF4CAF50);

// Verde Check - Elementos seleccionados, checkboxes
static const Color checkGreen = Color(0xFF4CAF50);
```

### **🔵 AZULES (Headers y Navegación)**
```dart
// Azul Oscuro - Headers, barras superiores, navegación
static const Color darkBlue = Color(0xFF1A237E);
```

### **🟠 NARANJAS (Acciones Principales)**
```dart
// Naranja - Botones de acción principales ("Proceder al Pago", "Confirmar")
static const Color primaryOrange = Color(0xFF FF9800);
```

### **⚪ NEUTROS (Fondos y Texto)**
```dart
// Blanco - Fondos de tarjetas, contenido principal
static const Color cardWhite = Color(0xFFFFFFFF);

// Gris Texto - Texto secundario, subtítulos
static const Color secondaryText = Color(0xFF757575);
```

---

## 🖼️ **EJEMPLO DE REFERENCIA**

La pantalla **"Información de Envío"** es el **modelo perfecto** de esta paleta:

- ✅ **Header azul oscuro** (#1A237E)
- ✅ **Sección verde principal** (#2E7D32) 
- ✅ **Botones seleccionados verde claro** (#4CAF50)
- ✅ **Botón naranja de acción** (#FF9800)
- ✅ **Tarjetas blancas** (#FFFFFF)
- ✅ **Texto gris secundario** (#757575)

---

## 🚫 **PROHIBIDO**

- ❌ Usar colores aleatorios o inventados
- ❌ Mezclar paletas de otras apps
- ❌ Crear pantallas con colores inconsistentes
- ❌ Ignorar esta paleta sin autorización explícita del usuario

---

## ✅ **CUÁNDO USAR CADA COLOR**

| Color | Uso Principal | Ejemplos |
|-------|---------------|----------|
| **Verde Principal** | Secciones importantes | Headers de secciones, fondos destacados |
| **Verde Claro** | Elementos activos | Botones seleccionados, switches ON |
| **Azul Oscuro** | Navegación | AppBar, headers de pantalla |
| **Naranja** | Acciones críticas | "Proceder al Pago", "Confirmar Orden" |
| **Blanco** | Contenido | Fondos de tarjetas, formularios |
| **Gris Texto** | Información secundaria | Subtítulos, descripciones |

---

**📅 Creado**: ${DateTime.now().toString().split(' ')[0]}  
**👤 Autorizado por**: Usuario Cubalink23  
**🎯 Objetivo**: Consistencia visual en toda la aplicación
