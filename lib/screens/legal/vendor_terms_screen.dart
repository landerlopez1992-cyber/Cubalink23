import 'package:flutter/material.dart';

class VendorTermsScreen extends StatelessWidget {
  const VendorTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Términos para Vendedores',
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
                      color: Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.store,
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
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Términos y Condiciones para Vendedores',
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
            
            // Contenido de términos para vendedores
            _buildSection(
              '1. Elegibilidad para Vendedores',
              'Para ser vendedor en CubaLink23, debe:\n\n• Tener al menos 18 años de edad\n• Proporcionar información comercial válida\n• Tener productos legales para vender\n• Cumplir con todas las regulaciones locales\n• Mantener un historial comercial limpio',
            ),
            
            _buildSection(
              '2. Proceso de Aplicación',
              'El proceso de aplicación incluye:\n\n• Completar formulario de aplicación\n• Verificación de documentos\n• Revisión de productos\n• Aprobación por parte de CubaLink23\n• Configuración de cuenta de vendedor',
            ),
            
            _buildSection(
              '3. Obligaciones del Vendedor',
              'Como vendedor, usted se compromete a:\n\n• Proporcionar información precisa de productos\n• Mantener precios competitivos\n• Cumplir con tiempos de entrega\n• Proporcionar productos de calidad\n• Mantener comunicación con clientes\n• Respetar políticas de devolución',
            ),
            
            _buildSection(
              '4. Comisiones y Pagos',
              '• CubaLink23 cobra una comisión del 5-10% por transacción\n• Los pagos se procesan semanalmente\n• Se aplican impuestos según la legislación local\n• Las comisiones pueden variar según el tipo de producto',
            ),
            
            _buildSection(
              '5. Gestión de Productos',
              '• Debe mantener inventario actualizado\n• Las descripciones deben ser precisas\n• Las imágenes deben ser de alta calidad\n• Los precios deben incluir todos los costos\n• Debe cumplir con políticas de categorización',
            ),
            
            _buildSection(
              '6. Atención al Cliente',
              '• Debe responder consultas en 24 horas\n• Debe manejar quejas de manera profesional\n• Debe mantener comunicación clara\n• Debe resolver disputas de manera justa',
            ),
            
            _buildSection(
              '7. Políticas de Entrega',
              '• Debe cumplir con tiempos de entrega prometidos\n• Debe coordinar con repartidores\n• Debe proporcionar seguimiento de pedidos\n• Debe manejar entregas fallidas apropiadamente',
            ),
            
            _buildSection(
              '8. Prohibiciones',
              'Está prohibido:\n\n• Vender productos ilegales o falsificados\n• Engañar a los clientes\n• Manipular reseñas o calificaciones\n• Violar derechos de propiedad intelectual\n• Usar información de clientes inapropiadamente',
            ),
            
            _buildSection(
              '9. Suspensión y Terminación',
              'CubaLink23 se reserva el derecho de suspender o terminar cuentas de vendedores que:\n\n• Violen estos términos\n• Reciban múltiples quejas\n• No cumplan con estándares de calidad\n• Participen en actividades fraudulentas',
            ),
            
            _buildSection(
              '10. Responsabilidad',
              '• El vendedor es responsable de la calidad de sus productos\n• Debe cumplir con garantías ofrecidas\n• Debe manejar devoluciones según políticas\n• Debe mantener seguros apropiados',
            ),
            
            _buildSection(
              '11. Contacto para Vendedores',
              'Para soporte específico de vendedores:\n\n📧 Email: vendors@cubalink23.com\n📞 Teléfono: +1 561 593 6776\n💬 Chat en la aplicación\n📋 Centro de ayuda para vendedores',
            ),
            
            SizedBox(height: 30),
            
            // Footer
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFF2E7D32).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.handshake,
                    color: Color(0xFF2E7D32),
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '¡Únase a nuestra red de vendedores!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Crezca su negocio con CubaLink23 y llegue a más clientes en toda Cuba.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2E7D32).withOpacity(0.8),
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
              color: Color(0xFF2E7D32),
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




