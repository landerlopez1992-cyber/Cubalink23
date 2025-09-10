import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class ForceUpdateScreen extends StatefulWidget {
  @override
  _ForceUpdateScreenState createState() => _ForceUpdateScreenState();
}

class _ForceUpdateScreenState extends State<ForceUpdateScreen> {
  Timer? _checkTimer;
  bool _isChecking = false;
  String _iosAppUrl = '';
  String _androidAppUrl = '';
  String _currentVersion = '1.0.0'; // Versión actual de la app

  @override
  void initState() {
    super.initState();
    _startUpdateCheck();
    _getCurrentAppVersion();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  void _getCurrentAppVersion() {
    // Obtener versión actual de la app
    // En un proyecto real, esto vendría del pubspec.yaml o package_info_plus
    setState(() {
      _currentVersion = '1.0.0'; // Versión hardcodeada por ahora
    });
  }

  void _startUpdateCheck() {
    // Verificar cada 10 segundos si el modo actualización forzada sigue activo
    _checkTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      print('🔄 Timer verificando actualizaciones forzadas...');
      _checkForceUpdateStatus();
    });
    
    // Verificar inmediatamente
    _checkForceUpdateStatus();
  }

  Future<void> _checkForceUpdateStatus() async {
    if (_isChecking) return;
    
    setState(() {
      _isChecking = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://cubalink23-backend.onrender.com/admin/api/force-update/status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isForceUpdateMode = data['force_update_mode'] as bool? ?? false;
        final iosUrl = data['ios_app_url'] as String? ?? '';
        final androidUrl = data['android_app_url'] as String? ?? '';
        
        print('🔄 Modo actualización forzada: $isForceUpdateMode');
        print('📱 iOS URL: $iosUrl');
        print('🤖 Android URL: $androidUrl');
        
        setState(() {
          _iosAppUrl = iosUrl;
          _androidAppUrl = androidUrl;
        });
        
        // Si el modo actualización forzada se desactivó, volver a la app
        if (!isForceUpdateMode) {
          print('🔄 Modo actualización forzada DESACTIVADO - volviendo a Welcome');
          _checkTimer?.cancel();
          Navigator.of(context).pushReplacementNamed('/welcome');
        } else {
          print('🔄 Modo actualización forzada ACTIVO - permaneciendo en pantalla');
        }
      }
    } catch (e) {
      print('❌ Error verificando estado actualización forzada: $e');
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  Future<void> _launchStore() async {
    String storeUrl = '';
    
    if (Platform.isIOS && _iosAppUrl.isNotEmpty) {
      storeUrl = _iosAppUrl;
    } else if (Platform.isAndroid && _androidAppUrl.isNotEmpty) {
      storeUrl = _androidAppUrl;
    } else {
      // Fallback a URLs genéricas
      if (Platform.isIOS) {
        storeUrl = 'https://apps.apple.com/';
      } else {
        storeUrl = 'https://play.google.com/store';
      }
    }

    try {
      final Uri url = Uri.parse(storeUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        print('❌ No se pudo abrir la tienda: $storeUrl');
        _showErrorDialog();
      }
    } catch (e) {
      print('❌ Error abriendo tienda: $e');
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('No se pudo abrir la tienda. Por favor, busca "Cubalink23" manualmente en tu tienda de aplicaciones.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevenir que el usuario salga de la pantalla
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.blue.shade50,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade100,
                Colors.blue.shade200,
              ],
            ),
          ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                  // Logo oficial de Cubalink23 (MÁS GRANDE)
                  Container(
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
                            color: Colors.blue.shade600,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.system_update,
                            size: 80,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  
                  SizedBox(height: 15),
                  
                  // Nombre de la app
                  Text(
                    'Cubalink23',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Logo de la plataforma (Android/Apple)
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Platform.isIOS ? Colors.black : Colors.green.shade600,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Platform.isIOS ? Colors.grey.shade400 : Colors.green.shade300,
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Icon(
                      Platform.isIOS ? Icons.apple : Icons.android,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Título
                  Text(
                    'ACTUALIZACIÓN REQUERIDA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 15),
                  
                  // Mensaje principal
                  Text(
                    '¡Nueva versión disponible con mejoras increíbles!',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Mensaje explicativo sobre la actualización
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade200,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '🚀 NUEVOS SERVICIOS Y OFERTAS',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Nuevos servicios de viaje y compras\n• Ofertas exclusivas y descuentos\n• Diseño más moderno y fácil de usar\n• Mejoras en rendimiento y estabilidad',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Mensaje de acción
                  Text(
                    'Para disfrutar de todas estas mejoras, actualiza la aplicación ahora.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Información de versión
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade200,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      'Versión actual: $_currentVersion',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 25),
                  
                  // Botón de actualización mejorado
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _launchStore,
                      icon: Icon(
                        Platform.isIOS ? Icons.apple : Icons.android,
                        size: 20,
                      ),
                      label: Text(
                        'Actualizar Ahora',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Platform.isIOS ? Colors.black : Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 6,
                        shadowColor: Platform.isIOS ? Colors.grey.shade400 : Colors.green.shade300,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 15),
                  
                  // Indicador de verificación
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade200,
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isChecking)
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                            ),
                          )
                        else
                          Icon(
                            Icons.refresh,
                            size: 12,
                            color: Colors.blue.shade600,
                          ),
                        SizedBox(width: 6),
                        Text(
                          _isChecking ? 'Verificando...' : 'Verificando automáticamente',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 10),
                  
                  // Información adicional
                  Text(
                    'La aplicación se reanudará automáticamente cuando se complete la actualización',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade500,
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