import 'package:flutter/material.dart';

class WorkSelectionScreen extends StatefulWidget {
  @override
  _WorkSelectionScreenState createState() => _WorkSelectionScreenState();
}

class _WorkSelectionScreenState extends State<WorkSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Trabaja con Nosotros',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Color(0xFF2E7D32),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            children: [
              // Logo de la app
              Container(
                width: 200,
                height: 200,
                margin: EdgeInsets.only(bottom: 20),
                child: Image.asset(
                  'assets/images/assets_task_01k3m7yveaebmtdrdnybpe7ngv_1756247471_img_1.webp',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2E7D32),
                            Color(0xFF4CAF50),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          'CubaLink23',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Título principal
              Text(
                '¡Únete a nuestro equipo!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Elige cómo quieres trabajar con nosotros',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              
              // Opción 1: Vender con nosotros
              _buildWorkOption(
                context: context,
                title: '🛍️ Vender con Nosotros',
                subtitle: 'Vendedor',
                description: 'Vende tus productos a miles de usuarios en nuestra plataforma. Gana dinero desde casa.',
                gradientColors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
                onTap: () {
                  Navigator.pushNamed(context, '/seller_application');
                },
              ),
              
              SizedBox(height: 20),
              
              // Opción 2: Repartidor
              _buildWorkOption(
                context: context,
                title: '🚚 Repartidor con Nosotros',
                subtitle: 'Delivery',
                description: 'Gana dinero repartiendo productos en tu provincia. Horarios flexibles.',
                gradientColors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                onTap: () {
                  Navigator.pushNamed(context, '/delivery_application');
                },
              ),
              
              SizedBox(height: 20),
              
              // Información adicional
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF2E7D32),
                      size: 24,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '¿Necesitas ayuda?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Si tienes alguna pregunta sobre el proceso de aplicación, no dudes en contactarnos.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String description,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título y subtítulo
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 12),
              
              // Descripción
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 16),
              
              // Botón de acción
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Aplicar Ahora',
                      style: TextStyle(
                        color: gradientColors[0],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: gradientColors[0],
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
