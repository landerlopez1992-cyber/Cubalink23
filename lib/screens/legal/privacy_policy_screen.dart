import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Política de Privacidad',
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
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.privacy_tip,
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
                      color: Colors.blue[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Política de Privacidad',
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
            
            // Contenido de política de privacidad
            _buildSection(
              '1. Información que Recopilamos',
              'Recopilamos información que usted nos proporciona directamente, como:\n\n• Información de registro (nombre, email, teléfono)\n• Información de perfil\n• Historial de compras\n• Comunicaciones con nosotros\n• Información de ubicación (para servicios de entrega)',
            ),
            
            _buildSection(
              '2. Cómo Utilizamos su Información',
              'Utilizamos su información para:\n\n• Proporcionar y mejorar nuestros servicios\n• Procesar transacciones\n• Comunicarnos con usted\n• Personalizar su experiencia\n• Cumplir con obligaciones legales\n• Prevenir fraudes y mejorar la seguridad',
            ),
            
            _buildSection(
              '3. Compartir Información',
              'No vendemos, alquilamos ni compartimos su información personal con terceros, excepto:\n\n• Con su consentimiento explícito\n• Para cumplir con la ley\n• Con proveedores de servicios que nos ayudan a operar\n• En caso de fusión o adquisición',
            ),
            
            _buildSection(
              '4. Seguridad de Datos',
              'Implementamos medidas de seguridad técnicas y organizativas para proteger su información personal contra acceso no autorizado, alteración, divulgación o destrucción.',
            ),
            
            _buildSection(
              '5. Cookies y Tecnologías Similares',
              'Utilizamos cookies y tecnologías similares para mejorar su experiencia, recordar sus preferencias y analizar el uso de nuestra aplicación.',
            ),
            
            _buildSection(
              '6. Sus Derechos',
              'Usted tiene derecho a:\n\n• Acceder a su información personal\n• Corregir información inexacta\n• Eliminar su información\n• Restringir el procesamiento\n• Portabilidad de datos\n• Oponerse al procesamiento',
            ),
            
            _buildSection(
              '7. Retención de Datos',
              'Conservamos su información personal solo durante el tiempo necesario para cumplir con los propósitos descritos en esta política o según lo requiera la ley.',
            ),
            
            _buildSection(
              '8. Menores de Edad',
              'Nuestros servicios no están dirigidos a menores de 18 años. No recopilamos conscientemente información personal de menores de edad.',
            ),
            
            _buildSection(
              '9. Cambios en esta Política',
              'Podemos actualizar esta política de privacidad ocasionalmente. Le notificaremos sobre cambios significativos a través de la aplicación o por email.',
            ),
            
            _buildSection(
              '10. Contacto',
              'Para preguntas sobre esta política de privacidad, puede contactarnos en:\n\n📧 Email: privacy@cubalink23.com\n📞 Teléfono: +1 561 593 6776\n🏢 Dirección: CubaLink23 Privacy Team',
            ),
            
            SizedBox(height: 30),
            
            // Footer
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.security,
                    color: Colors.blue[700],
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Su privacidad es importante para nosotros',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Nos comprometemos a proteger su información personal y utilizarla de manera responsable.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
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
              color: Colors.blue[700],
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




