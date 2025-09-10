import 'package:flutter/material.dart';

class DeliveryTermsScreen extends StatelessWidget {
  const DeliveryTermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Términos para Repartidores',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con logo
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.delivery_dining,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'CubaLink23',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Términos y Condiciones para Repartidores',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Última actualización: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Contenido de términos para repartidores
            _buildSection(
              '1. Elegibilidad para Repartidores',
              'Para ser repartidor en CubaLink23, debe:\n\n• Tener al menos 18 años de edad\n• Poseer vehículo válido (bicicleta, moto, auto, camión)\n• Tener licencia de conducir vigente\n• Proporcionar documentos de identidad\n• Tener seguro de vehículo (si aplica)\n• Pasar verificación de antecedentes',
            ),
            
            _buildSection(
              '2. Proceso de Aplicación',
              'El proceso de aplicación incluye:\n\n• Completar formulario de aplicación\n• Verificación de documentos\n• Verificación de vehículo\n• Entrevista de seguridad\n• Aprobación por parte de CubaLink23\n• Configuración de cuenta de repartidor',
            ),
            
            _buildSection(
              '3. Obligaciones del Repartidor',
              'Como repartidor, usted se compromete a:\n\n• Cumplir con tiempos de entrega\n• Mantener vehículo en buenas condiciones\n• Tratar a clientes con respeto\n• Seguir rutas optimizadas\n• Mantener productos seguros\n• Comunicar retrasos inmediatamente',
            ),
            
            _buildSection(
              '4. Tarifas y Pagos',
              '• Tarifa base por entrega: \$2.00 - \$5.00\n• Bonificaciones por entregas rápidas\n• Propinas de clientes (100% para repartidor)\n• Pagos diarios o semanales\n• Comisiones por distancia y peso\n• Bonificaciones por horarios pico',
            ),
            
            _buildSection(
              '5. Horarios y Disponibilidad',
              '• Puede establecer sus propios horarios\n• Debe cumplir con horarios aceptados\n• Debe notificar cambios con anticipación\n• Horarios pico ofrecen mejores tarifas\n• Disponibilidad en fines de semana es valorada',
            ),
            
            _buildSection(
              '6. Seguridad y Seguros',
              '• Debe mantener vehículo asegurado\n• Debe usar equipo de seguridad\n• Debe seguir reglas de tráfico\n• Debe reportar accidentes inmediatamente\n• CubaLink23 proporciona seguro de responsabilidad',
            ),
            
            _buildSection(
              '7. Gestión de Pedidos',
              '• Debe aceptar pedidos asignados\n• Debe confirmar recogida de productos\n• Debe actualizar estado de entrega\n• Debe manejar entregas fallidas apropiadamente\n• Debe obtener confirmación de entrega',
            ),
            
            _buildSection(
              '8. Comunicación con Clientes',
              '• Debe mantener comunicación profesional\n• Debe notificar retrasos\n• Debe confirmar direcciones\n• Debe manejar quejas apropiadamente\n• Debe respetar privacidad del cliente',
            ),
            
            _buildSection(
              '9. Prohibiciones',
              'Está prohibido:\n\n• Consumir alcohol o drogas durante entregas\n• Usar teléfono mientras conduce\n• Abrir o manipular productos\n• Solicitar propinas adicionales\n• Violar privacidad de clientes\n• Participar en actividades fraudulentas',
            ),
            
            _buildSection(
              '10. Suspensión y Terminación',
              'CubaLink23 se reserva el derecho de suspender o terminar cuentas de repartidores que:\n\n• Violen estos términos\n• Reciban múltiples quejas\n• No cumplan con estándares de seguridad\n• Participen en actividades fraudulentas\n• Tengan accidentes por negligencia',
            ),
            
            _buildSection(
              '11. Responsabilidad',
              '• El repartidor es responsable de la seguridad de los productos\n• Debe manejar productos frágiles con cuidado\n• Debe cumplir con instrucciones especiales\n• Debe reportar daños inmediatamente\n• Debe mantener productos a temperatura adecuada',
            ),
            
            _buildSection(
              '12. Contacto para Repartidores',
              'Para soporte específico de repartidores:\n\n📧 Email: delivery@cubalink23.com\n📞 Teléfono: +1 561 593 6776\n💬 Chat en la aplicación\n📋 Centro de ayuda para repartidores',
            ),
            
            SizedBox(height: 30),
            
            // Footer
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFF1976D2).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.local_shipping,
                    color: Color(0xFF1976D2),
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '¡Únase a nuestro equipo de repartidores!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gane dinero extra con horarios flexibles y tarifas competitivas.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1976D2).withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}




