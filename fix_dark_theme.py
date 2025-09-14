#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os

def apply_dark_theme_to_file(file_path):
    """Aplica el tema oscuro a un archivo HTML del admin panel"""
    
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Reemplazar estilos CSS
    old_css = """        .sidebar {
            min-height: 100vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .card-stats {
            border: none;
            border-radius: 15px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .nav-link {
            color: rgba(255,255,255,0.8);
            border-radius: 10px;
            margin: 5px 0;
        }
        .nav-link:hover, .nav-link.active {
            background: rgba(255,255,255,0.1);
            color: white;
        }"""
    
    new_css = """        body {
            background-color: #1a1a2e;
            color: white;
        }
        .sidebar {
            min-height: 100vh;
            background-color: #16213e;
        }
        .card-stats {
            background-color: #16213e;
            border: 1px solid #0f3460;
            border-radius: 15px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
            color: white;
        }
        .nav-link {
            color: white;
            border-radius: 10px;
            margin: 5px 0;
        }
        .nav-link:hover, .nav-link.active {
            background-color: #0f3460;
            color: white;
        }
        .table {
            background-color: #16213e;
            color: white;
        }
        .table th {
            background-color: #0f3460;
            color: white;
            border-color: #0f3460;
        }
        .table td {
            color: white;
            border-color: #0f3460;
        }
        .btn-outline-primary {
            color: white;
            border-color: #0f3460;
        }
        .btn-outline-primary:hover {
            background-color: #0f3460;
            color: white;
        }
        .btn-success {
            background-color: #0f3460;
            border-color: #0f3460;
            color: white;
        }
        .btn-success:hover {
            background-color: #0f3460;
            border-color: #0f3460;
            color: white;
        }
        .modal-content {
            background-color: #16213e;
            color: white;
        }
        .modal-header {
            background-color: #0f3460;
            color: white;
        }
        .modal-footer {
            background-color: #16213e;
            color: white;
        }"""
    
    content = content.replace(old_css, new_css)
    
    # Reemplazar Main Content background
    content = content.replace(
        '<!-- Main Content -->\n            <div class="col-md-9 col-lg-10 p-4">',
        '<!-- Main Content -->\n            <div class="col-md-9 col-lg-10 p-4" style="background-color: #1a1a2e;">'
    )
    
    # Reemplazar iconos de colores por blancos
    content = content.replace('text-primary', 'text-white')
    content = content.replace('text-warning', 'text-white')
    content = content.replace('text-success', 'text-white')
    content = content.replace('text-info', 'text-white')
    content = content.replace('text-danger', 'text-white')
    
    # Reemplazar números y texto por blancos
    content = content.replace('<h3 id="total-', '<h3 id="total-')
    content = content.replace('<h3 id="pending-', '<h3 id="pending-')
    content = content.replace('<h3 id="completed-', '<h3 id="completed-')
    content = content.replace('<h3 id="active-', '<h3 id="active-')
    content = content.replace('<h3 id="total-revenue">', '<h3 id="total-revenue" class="text-white">')
    content = content.replace('<h3 id="total-orders">', '<h3 id="total-orders" class="text-white">')
    content = content.replace('<h3 id="pending-orders">', '<h3 id="pending-orders" class="text-white">')
    content = content.replace('<h3 id="completed-orders">', '<h3 id="completed-orders" class="text-white">')
    content = content.replace('<h3 id="active-drivers">', '<h3 id="active-drivers" class="text-white">')
    content = content.replace('<h3 id="active-vendors">', '<h3 id="active-vendors" class="text-white">')
    content = content.replace('<h3 id="total-alerts">', '<h3 id="total-alerts" class="text-white">')
    content = content.replace('<h3 id="total-wallet">', '<h3 id="total-wallet" class="text-white">')
    content = content.replace('<h3 id="total-payments">', '<h3 id="total-payments" class="text-white">')
    content = content.replace('<h3 id="total-payroll">', '<h3 id="total-payroll" class="text-white">')
    
    # Reemplazar texto de las tarjetas
    content = content.replace('<p class="mb-0">Órdenes Totales</p>', '<p class="mb-0 text-white">Órdenes Totales</p>')
    content = content.replace('<p class="mb-0">Pendientes</p>', '<p class="mb-0 text-white">Pendientes</p>')
    content = content.replace('<p class="mb-0">Completadas</p>', '<p class="mb-0 text-white">Completadas</p>')
    content = content.replace('<p class="mb-0">Ingresos Totales</p>', '<p class="mb-0 text-white">Ingresos Totales</p>')
    content = content.replace('<p class="mb-0">Repartidores Totales</p>', '<p class="mb-0 text-white">Repartidores Totales</p>')
    content = content.replace('<p class="mb-0">Pendientes de Aprobación</p>', '<p class="mb-0 text-white">Pendientes de Aprobación</p>')
    content = content.replace('<p class="mb-0">Repartidores Activos</p>', '<p class="mb-0 text-white">Repartidores Activos</p>')
    content = content.replace('<p class="mb-0">Ganancias Totales</p>', '<p class="mb-0 text-white">Ganancias Totales</p>')
    content = content.replace('<p class="mb-0">Vendedores Totales</p>', '<p class="mb-0 text-white">Vendedores Totales</p>')
    content = content.replace('<p class="mb-0">Vendedores Activos</p>', '<p class="mb-0 text-white">Vendedores Activos</p>')
    content = content.replace('<p class="mb-0">Comisiones Totales</p>', '<p class="mb-0 text-white">Comisiones Totales</p>')
    content = content.replace('<p class="mb-0">Alertas Totales</p>', '<p class="mb-0 text-white">Alertas Totales</p>')
    content = content.replace('<p class="mb-0">Usuarios Activos</p>', '<p class="mb-0 text-white">Usuarios Activos</p>')
    content = content.replace('<p class="mb-0">Mensajes Hoy</p>', '<p class="mb-0 text-white">Mensajes Hoy</p>')
    content = content.replace('<p class="mb-0">Tiempo Respuesta</p>', '<p class="mb-0 text-white">Tiempo Respuesta</p>')
    content = content.replace('<p class="mb-0">Problemas Pendientes</p>', '<p class="mb-0 text-white">Problemas Pendientes</p>')
    content = content.replace('<p class="mb-0">Saldo Total del Sistema</p>', '<p class="mb-0 text-white">Saldo Total del Sistema</p>')
    content = content.replace('<p class="mb-0">Transferencias Hoy</p>', '<p class="mb-0 text-white">Transferencias Hoy</p>')
    content = content.replace('<p class="mb-0">Billeteras Activas</p>', '<p class="mb-0 text-white">Billeteras Activas</p>')
    content = content.replace('<p class="mb-0">Promedio por Transacción</p>', '<p class="mb-0 text-white">Promedio por Transacción</p>')
    content = content.replace('<p class="mb-0">Métodos Activos</p>', '<p class="mb-0 text-white">Métodos Activos</p>')
    content = content.replace('<p class="mb-0">Pagos en Efectivo</p>', '<p class="mb-0 text-white">Pagos en Efectivo</p>')
    content = content.replace('<p class="mb-0">Pagos con Tarjeta</p>', '<p class="mb-0 text-white">Pagos con Tarjeta</p>')
    content = content.replace('<p class="mb-0">Usuarios con Efectivo</p>', '<p class="mb-0 text-white">Usuarios con Efectivo</p>')
    content = content.replace('<p class="mb-0">Empleados Activos</p>', '<p class="mb-0 text-white">Empleados Activos</p>')
    content = content.replace('<p class="mb-0">Total Nómina</p>', '<p class="mb-0 text-white">Total Nómina</p>')
    content = content.replace('<p class="mb-0">Pagos Pendientes</p>', '<p class="mb-0 text-white">Pagos Pendientes</p>')
    content = content.replace('<p class="mb-0">Pagos Completados</p>', '<p class="mb-0 text-white">Pagos Completados</p>')
    
    # Reemplazar títulos por blancos
    content = content.replace('<h2><i class="fas fa-', '<h2 class="text-white"><i class="fas fa-')
    content = content.replace('<h5><i class="fas fa-', '<h5 class="text-white"><i class="fas fa-')
    
    # Reemplazar texto de tabla por blanco
    content = content.replace('class="text-center">', 'class="text-center text-white">')
    content = content.replace('No hay órdenes registradas', '<span class="text-white">No hay órdenes registradas</span>')
    content = content.replace('No hay vuelos registrados', '<span class="text-white">No hay vuelos registrados</span>')
    content = content.replace('No hay repartidores registrados', '<span class="text-white">No hay repartidores registrados</span>')
    content = content.replace('No hay vendedores registrados', '<span class="text-white">No hay vendedores registrados</span>')
    content = content.replace('No hay alertas registradas', '<span class="text-white">No hay alertas registradas</span>')
    content = content.replace('No hay empleados registrados', '<span class="text-white">No hay empleados registrados</span>')
    
    with open(file_path, 'w') as f:
        f.write(content)
    
    print("✅ Tema oscuro aplicado a: {}".format(file_path))

def main():
    """Aplica el tema oscuro a todas las pantallas del admin panel"""
    
    admin_templates_dir = "templates/admin"
    
    # Lista de archivos a corregir
    files_to_fix = [
        "flights.html",
        "drivers.html", 
        "vendors.html",
        "alerts.html",
        "support_chat.html",
        "wallet.html",
        "payment_methods.html",
        "payroll.html",
        "system.html",
        "vehicles.html"
    ]
    
    for filename in files_to_fix:
        file_path = os.path.join(admin_templates_dir, filename)
        if os.path.exists(file_path):
            apply_dark_theme_to_file(file_path)
        else:
            print("❌ Archivo no encontrado: {}".format(file_path))

if __name__ == "__main__":
    main()
