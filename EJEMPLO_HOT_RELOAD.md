# 🔥 Ejemplo Práctico de Hot Reload

## 🎯 **Prueba esto AHORA:**

### 1. **Abre el archivo:** `lib/screens/welcome/welcome_screen.dart`

### 2. **Busca esta línea (aproximadamente línea 200):**
```dart
Text(
  'Inicio',
  style: TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),
```

### 3. **Cambia el color:**
```dart
Text(
  'Inicio',
  style: TextStyle(
    color: Colors.yellow,  // ← Cambia de white a yellow
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),
```

### 4. **Guarda el archivo** (Ctrl+S)

### 5. **¡MIRA EL NAVEGADOR!** 
El texto "Inicio" debería cambiar a amarillo INMEDIATAMENTE

## 🎨 **Más cambios que puedes probar:**

### **Cambiar el saldo:**
Busca: `'\$50.00 +'`
Cambia a: `'\$999.99 +'`

### **Cambiar el título del banner:**
Busca: `'Artemisa'`
Cambia a: `'¡Nueva Provincia!'`

### **Cambiar colores de botones:**
Busca: `Colors.blue`
Cambia a: `Colors.green`

## ⚡ **Resultado:**
- **Cambios instantáneos** al guardar
- **NO necesitas recompilar**
- **NO necesitas reiniciar la app**
- **Solo guarda y ve la magia**

## 🚀 **¡Pruébalo ahora!**
