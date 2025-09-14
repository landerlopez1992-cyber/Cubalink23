# 🚀 CUBALINK23 - Panel de Administración

## 📋 **INSTRUCCIONES RÁPIDAS:**

### **Para iniciar TODO automáticamente:**
```bash
./start_all.sh
```

### **Para iniciar solo el backend:**
```bash
./start_backend.sh
```

### **Para ver los logs:**
```bash
tail -f backend.log
```

## 🔐 **CREDENCIALES DEL PANEL:**

**🌐 URL LOCAL:** http://localhost:3005/auth/login  
**🌐 URL ONLINE:** https://backend.cubalink23.com/auth/login  
**👤 Usuario:** landerlopez1992@gmail.com  
**🔑 Contraseña:** Maquina.2055

## 🎯 **FUNCIONALIDADES DEL PANEL:**

### ✅ **Gestión de Productos:**
- Agregar/editar productos
- Configurar precios y descuentos
- Gestionar categorías
- Subir imágenes
- Controlar inventario

### ✅ **Gestión de Usuarios:**
- Ver todos los usuarios
- Bloquear/desbloquear usuarios
- Ver historial de recargas
- Gestionar saldos
- Enviar notificaciones

### ✅ **Gestión de Órdenes:**
- Ver todas las órdenes
- Aprobar/rechazar pagos
- Gestionar carritos
- Ver comprobantes Zelle
- Controlar entregas

### ✅ **Configuración de la App:**
- Cambiar nombre de la app
- Activar/desactivar mantenimiento
- Configurar promociones
- Cambiar URLs de APIs
- Gestionar notificaciones

### ✅ **Analytics y Reportes:**
- Estadísticas de ventas
- Comportamiento de usuarios
- Reportes de ingresos
- Métricas de rendimiento

## 🔧 **CONFIGURACIÓN AUTOMÁTICA:**

El sistema está configurado para iniciarse automáticamente cuando enciendas tu PC.

### **Archivos importantes:**
- `start_all.sh` - Inicia TODO automáticamente
- `start_backend.sh` - Solo el backend
- `start_tunnel.sh` - Solo el túnel de Cloudflare
- `backend.log` - Logs del sistema

## 🌐 **DOMINIO:**

**Dominio principal:** cubalink23.com  
**Subdominio del panel:** backend.cubalink23.com

## 📞 **SOPORTE:**

Si algo no funciona:
1. Ejecuta `./start_all.sh`
2. Revisa los logs: `tail -f backend.log`
3. Verifica que el puerto 3005 esté libre

## 🚀 **DESPLIEGUE:**

El sistema está configurado para funcionar desde tu PC con Cloudflare Tunnel, lo que significa:
- ✅ Control total de los datos
- ✅ Siempre disponible (mientras tu PC esté encendida)
- ✅ Seguro y confiable
- ✅ Sin costos adicionales
