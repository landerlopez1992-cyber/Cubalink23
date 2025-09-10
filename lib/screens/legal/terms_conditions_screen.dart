import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Términos y Condiciones',
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
                    'Términos y Condiciones de Uso',
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
            
            // Contenido de términos
            _buildSection(
              '1. Aceptación de los Términos',
              'Al acceder y utilizar la aplicación CubaLink23, usted acepta estar sujeto a estos términos y condiciones de uso. Si no está de acuerdo con alguna parte de estos términos, no debe utilizar nuestra aplicación.',
            ),
            
            _buildSection(
              '2. Descripción del Servicio',
              'CubaLink23 es una plataforma digital que conecta usuarios con vendedores y repartidores para facilitar la compra y entrega de productos en Cuba. Nuestros servicios incluyen:\n\n• Catálogo de productos\n• Sistema de compras\n• Servicio de entrega\n• Reserva de vuelos\n• Servicios de recarga',
            ),
            
            _buildSection(
              '3. Cuenta de Usuario',
              'Para utilizar ciertos servicios, debe crear una cuenta proporcionando información precisa y actualizada. Es responsable de mantener la confidencialidad de su cuenta y contraseña.',
            ),
            
            _buildSection(
              '4. Compras y Pagos',
              'Todas las compras realizadas a través de la aplicación están sujetas a disponibilidad. Los precios pueden cambiar sin previo aviso. Los pagos se procesan de forma segura a través de nuestros socios de pago.',
            ),
            
            _buildSection(
              '5. Política de Devoluciones',
              'Las devoluciones están sujetas a las políticas específicas de cada vendedor. CubaLink23 actúa como intermediario y no se hace responsable de las políticas de devolución de terceros.',
            ),
            
            _buildSection(
              '6. Limitación de Responsabilidad',
              'CubaLink23 no se hace responsable por daños directos, indirectos, incidentales o consecuentes que puedan resultar del uso de nuestra aplicación.',
            ),
            
            _buildSection(
              '7. Modificaciones',
              'Nos reservamos el derecho de modificar estos términos en cualquier momento. Las modificaciones entrarán en vigor inmediatamente después de su publicación en la aplicación.',
            ),
            
            _buildSection(
              '8. Contacto',
              'Para preguntas sobre estos términos y condiciones, puede contactarnos en:\n\n📧 Email: info@cubalink23.com\n📞 Teléfono: +1 561 593 6776',
            ),
            
            SizedBox(height: 30),
            
            // Footer
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Al continuar usando CubaLink23, usted confirma que ha leído, entendido y aceptado estos términos y condiciones.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
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




