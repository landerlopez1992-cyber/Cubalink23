import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  _MaintenanceScreenState createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> with TickerProviderStateMixin {
  Timer? _checkTimer;
  bool _isChecking = false;
  late AnimationController _shovelController;
  late AnimationController _sandController;
  late Animation<double> _shovelAnimation;
  late Animation<double> _sandAnimation;

  @override
  void initState() {
    super.initState();
    _startMaintenanceCheck();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Animación de la pala
    _shovelController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _shovelAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shovelController,
      curve: Curves.easeInOut,
    ));

    // Animación de la arena
    _sandController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _sandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sandController,
      curve: Curves.easeInOut,
    ));

    // Iniciar animaciones
    _shovelController.repeat();
    _sandController.repeat();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _shovelController.dispose();
    _sandController.dispose();
    super.dispose();
  }

  void _startMaintenanceCheck() {
    // Verificar cada 3 segundos si el modo mantenimiento sigue activo
    _checkTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      print('🔧 Timer ejecutándose - verificando mantenimiento...');
      _checkMaintenanceStatus();
    });
    
    // Verificar inmediatamente
    print('🔧 Verificación inicial de mantenimiento...');
    _checkMaintenanceStatus();
  }

  Future<void> _checkMaintenanceStatus() async {
    if (_isChecking) return;
    
    setState(() {
      _isChecking = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://cubalink23-backend.onrender.com/admin/api/maintenance/status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isMaintenanceMode = data['maintenance_mode'] as bool? ?? false;
        
        print('🔧 Estado mantenimiento: $isMaintenanceMode');
        
        // Si el modo mantenimiento se desactivó, volver a la app
        if (!isMaintenanceMode) {
          print('🔧 Modo mantenimiento DESACTIVADO - volviendo a Welcome');
          _checkTimer?.cancel();
          Navigator.of(context).pushReplacementNamed('/welcome');
        } else {
          print('🔧 Modo mantenimiento ACTIVO - permaneciendo en pantalla');
        }
      }
    } catch (e) {
      print('❌ Error verificando estado mantenimiento: $e');
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevenir que el usuario salga de la pantalla
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.orange.shade50,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.orange.shade100,
                Colors.orange.shade200,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo de la app
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback si no se encuentra el logo
                        return Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade600,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.construction,
                            size: 80,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Nombre de la app
                  Text(
                    'Cubalink23',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Animación del obrero trabajando
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: AnimatedBuilder(
                      animation: _shovelAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: WorkerPainter(_shovelAnimation.value, _sandAnimation.value),
                          size: Size(200, 200),
                        );
                      },
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Mensaje principal
                  Text(
                    'La aplicación está temporalmente en mantenimiento',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Mensaje secundario
                  Text(
                    'Estamos trabajando para mejorar tu experiencia. Por favor, intenta de nuevo en unos minutos.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.orange.shade600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Indicador de verificación
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.shade200,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isChecking)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
                            ),
                          )
                        else
                          Icon(
                            Icons.refresh,
                            size: 16,
                            color: Colors.orange.shade600,
                          ),
                        SizedBox(width: 8),
                        Text(
                          _isChecking ? 'Verificando...' : 'Verificando automáticamente',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Información adicional
                  Text(
                    'La aplicación se reanudará automáticamente cuando el mantenimiento termine',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WorkerPainter extends CustomPainter {
  final double shovelProgress;
  final double sandProgress;

  WorkerPainter(this.shovelProgress, this.sandProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 3.0;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Dibujar montículo de arena más realista
    paint.color = Colors.amber.shade400;
    final sandPath = Path();
    sandPath.moveTo(centerX - 90, centerY + 50);
    sandPath.quadraticBezierTo(centerX - 20, centerY + 30, centerX + 20, centerY + 35);
    sandPath.quadraticBezierTo(centerX + 60, centerY + 40, centerX + 90, centerY + 50);
    sandPath.lineTo(centerX + 90, centerY + 70);
    sandPath.lineTo(centerX - 90, centerY + 70);
    sandPath.close();
    canvas.drawPath(sandPath, paint);

    // Sombra del montículo
    paint.color = Colors.amber.shade600;
    final shadowPath = Path();
    shadowPath.moveTo(centerX - 90, centerY + 50);
    shadowPath.quadraticBezierTo(centerX - 20, centerY + 30, centerX + 20, centerY + 35);
    shadowPath.quadraticBezierTo(centerX + 60, centerY + 40, centerX + 90, centerY + 50);
    shadowPath.lineTo(centerX + 90, centerY + 70);
    shadowPath.lineTo(centerX - 90, centerY + 70);
    shadowPath.close();
    canvas.drawPath(shadowPath, paint);

    // Dibujar partículas de arena cayendo más realistas
    paint.color = Colors.amber.shade700;
    for (int i = 0; i < 12; i++) {
      final x = centerX - 70 + (i * 12) + (math.sin(sandProgress * math.pi * 2 + i) * 5);
      final y = centerY + 10 + (sandProgress * 40) + (i * 2);
      final size = 1.5 + (math.sin(sandProgress * math.pi * 2 + i) * 0.5);
      canvas.drawCircle(Offset(x, y), size, paint);
    }

    // Dibujar obrero más realista
    final armAngle = math.sin(shovelProgress * math.pi * 2) * 0.4;
    
    // Cuerpo del obrero (overall azul)
    paint.color = Colors.blue.shade800;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX, centerY - 15), width: 35, height: 50),
      Radius.circular(8),
    );
    canvas.drawRRect(bodyRect, paint);

    // Cinturón
    paint.color = Colors.brown.shade800;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(centerX, centerY - 5), width: 35, height: 8),
      paint,
    );

    // Cabeza más realista
    paint.color = Colors.orange.shade200;
    canvas.drawCircle(Offset(centerX, centerY - 55), 18, paint);

    // Casco de seguridad más realista
    paint.color = Colors.yellow.shade600;
    final helmetPath = Path();
    helmetPath.addOval(Rect.fromCenter(center: Offset(centerX, centerY - 55), width: 30, height: 25));
    canvas.drawPath(helmetPath, paint);

    // Visera del casco
    paint.color = Colors.yellow.shade700;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(centerX, centerY - 50), width: 30, height: 3),
      paint,
    );

    // Brazos más realistas
    paint.color = Colors.blue.shade800;
    paint.strokeWidth = 8;
    paint.strokeCap = StrokeCap.round;
    
    // Brazo izquierdo (con pala) - más dinámico
    final leftArmX = centerX - 20 + math.cos(armAngle) * 35;
    final leftArmY = centerY - 25 + math.sin(armAngle) * 35;
    canvas.drawLine(
      Offset(centerX - 15, centerY - 25),
      Offset(leftArmX, leftArmY),
      paint,
    );

    // Pala más realista
    paint.color = Colors.grey.shade700;
    final shovelX = leftArmX + math.cos(armAngle) * 25;
    final shovelY = leftArmY + math.sin(armAngle) * 25;
    
    // Mango de la pala
    paint.color = Colors.brown.shade600;
    paint.strokeWidth = 4;
    canvas.drawLine(
      Offset(leftArmX, leftArmY),
      Offset(shovelX, shovelY),
      paint,
    );
    
    // Cabeza de la pala
    paint.color = Colors.grey.shade600;
    paint.style = PaintingStyle.fill;
    final shovelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(shovelX, shovelY), width: 12, height: 16),
      Radius.circular(2),
    );
    canvas.drawRRect(shovelRect, paint);

    // Brazo derecho
    paint.color = Colors.blue.shade800;
    paint.strokeWidth = 8;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(centerX + 15, centerY - 25),
      Offset(centerX + 30, centerY - 15),
      paint,
    );

    // Piernas más realistas
    paint.strokeWidth = 10;
    paint.strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX - 8, centerY + 10),
      Offset(centerX - 12, centerY + 40),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + 8, centerY + 10),
      Offset(centerX + 12, centerY + 40),
      paint,
    );

    // Botas de trabajo más realistas
    paint.color = Colors.brown.shade800;
    paint.style = PaintingStyle.fill;
    final leftBoot = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX - 12, centerY + 45), width: 16, height: 12),
      Radius.circular(3),
    );
    canvas.drawRRect(leftBoot, paint);
    
    final rightBoot = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX + 12, centerY + 45), width: 16, height: 12),
      Radius.circular(3),
    );
    canvas.drawRRect(rightBoot, paint);

    // Detalles adicionales
    // Reflejo en el casco
    paint.color = Colors.white.withOpacity(0.3);
    canvas.drawCircle(Offset(centerX - 5, centerY - 60), 3, paint);
    
    // Sombras
    paint.color = Colors.black.withOpacity(0.2);
    canvas.drawCircle(Offset(centerX + 2, centerY + 2), 18, paint);
  }

  @override
  bool shouldRepaint(WorkerPainter oldDelegate) {
    return oldDelegate.shovelProgress != shovelProgress || 
           oldDelegate.sandProgress != sandProgress;
  }
}