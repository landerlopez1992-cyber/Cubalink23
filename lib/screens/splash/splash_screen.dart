import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cubalink23/screens/welcome/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _logoAnimation;
  late Animation<double> _progressAnimation;
  
  double _progress = 0.0;
  Timer? _progressTimer;
  Timer? _navigationTimer;
  bool _isPaused = false;
  bool _navigationStarted = false;

  @override
  void initState() {
    super.initState();
    print('🎬 SplashScreen initState() llamado');
    
    try {
      // Configurar animaciones
      _logoAnimationController = AnimationController(
        duration: Duration(milliseconds: 1500),
        vsync: this,
      );
      
      _progressAnimationController = AnimationController(
        duration: Duration(seconds: 1), // Reducido a 1 segundo para debug
        vsync: this,
      );
      
      _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoAnimationController, curve: Curves.easeInOut),
      );
      
      _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _progressAnimationController, curve: Curves.linear),
      );
      
      print('✅ Animaciones configuradas correctamente');
      
      // Iniciar animaciones
      _startSplashSequence();
    } catch (e, stackTrace) {
      print('❌ Error en initState de SplashScreen: $e');
      print('❌ Stack trace: $stackTrace');
      // Navegar inmediatamente si hay error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToWelcome();
      });
    }
  }

  void _startSplashSequence() {
    print('🎬 Iniciando secuencia de splash screen...');
    
    // Animar logo primero
    _logoAnimationController.forward();
    print('▶️ Animación de logo iniciada');
    
    // Después de 500ms, iniciar la barra de progreso realista
    Timer(Duration(milliseconds: 500), () {
      if (mounted) {
        print('📊 Iniciando progreso realista...');
        _startRealisticProgress();
      }
    });
  }

  void _startRealisticProgress() {
    // Progreso realista con pausas - Lógica completamente nueva
    _progressTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_isPaused) {
        return; // No hacer nada si está pausado
      }

      setState(() {
        if (_progress < 0.30) {
          // 0% a 30% - Progreso normal
          _progress += 0.02;
          if (_progress >= 0.30) {
            _progress = 0.30; // Asegurar que llegue exactamente a 30%
            _isPaused = true;
            print('⏸️ Pausa en 30% iniciada');
            Timer(Duration(milliseconds: 500), () {
              if (mounted) {
                _isPaused = false;
                print('⏸️ Pausa en 30% completada');
              }
            });
          }
        } else if (_progress >= 0.30 && _progress < 0.60) {
          // 30% a 60% - Progreso normal
          _progress += 0.015;
          if (_progress >= 0.60) {
            _progress = 0.60; // Asegurar que llegue exactamente a 60%
            _isPaused = true;
            print('⏸️ Pausa en 60% iniciada');
            Timer(Duration(milliseconds: 1000), () {
              if (mounted) {
                _isPaused = false;
                print('⏸️ Pausa en 60% completada');
              }
            });
          }
        } else if (_progress >= 0.60 && _progress < 0.80) {
          // 60% a 80% - Progreso normal
          _progress += 0.012;
          if (_progress >= 0.80) {
            _progress = 0.80; // Asegurar que llegue exactamente a 80%
            _isPaused = true;
            print('⏸️ Pausa en 80% iniciada');
            Timer(Duration(milliseconds: 1000), () {
              if (mounted) {
                _isPaused = false;
                print('⏸️ Pausa en 80% completada');
              }
            });
          }
        } else if (_progress >= 0.80 && _progress < 1.0) {
          // 80% a 100% - Progreso normal
          _progress += 0.01;
          if (_progress >= 1.0) {
            _progress = 1.0; // Asegurar que llegue exactamente a 100%
            timer.cancel();
            if (!_navigationStarted) {
              _navigationStarted = true;
              print('✅ Progreso completado al 100%');
              Timer(Duration(milliseconds: 1000), () {
                if (mounted) {
                  _navigateToWelcome();
                }
              });
            }
          }
        }
      });
    });
  }
  
  void _navigateToWelcome() {
    if (!mounted) {
      print('❌ Widget no está montado, navegación cancelada');
      return;
    }
    
    print('🚀 ===== NAVEGANDO A WELCOME =====');
    
    try {
      // Navegar directamente usando MaterialPageRoute para evitar problemas de contexto
      print('🔧 Navegando directamente a WelcomeScreen...');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => WelcomeScreen(),
          settings: RouteSettings(name: '/welcome'),
        ),
      );
      print('✅ Navegación exitosa a WelcomeScreen');
    } catch (e) {
      print('❌ Error navegando a WelcomeScreen: $e');
      
      // Fallback: Intentar con ruta nombrada
      try {
        print('🔧 Intentando fallback con ruta nombrada...');
        Navigator.of(context).pushReplacementNamed('/welcome');
        print('✅ Navegación exitosa con ruta nombrada');
      } catch (e2) {
        print('❌ Error total en navegación: $e2');
        print('⚠️ NAVEGACIÓN COMPLETAMENTE FALLIDA');
      }
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _progressAnimationController.dispose();
    _progressTimer?.cancel();
    _navigationTimer?.cancel();
    _isPaused = false;
    _navigationStarted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ SplashScreen build() llamado');
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.cyan.shade50,
              Colors.teal.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex: 2),
              
              // Logo con animación - Más grande y sin fondo oscuro
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoAnimation.value,
                    child: Opacity(
                      opacity: _logoAnimation.value,
                      child: SizedBox(
                        width: 280, // Más grande para mejor visibilidad
                        height: 280, // Más grande para mejor visibilidad
                        child: Image.asset(
                          'assets/images/assets_task_01k3m7yveaebmtdrdnybpe7ngv_1756247471_img_1.webp',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            print('⚠️ Error cargando imagen del logo: $error');
                            // Fallback si no se encuentra la imagen
                            return Container(
                              width: 280,
                              height: 280,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.1),
                                    blurRadius: 25,
                                    offset: Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.flight_takeoff,
                                size: 100, // Icono más grande también
                                color: Colors.blue.shade600,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              SizedBox(height: 20),
              
              // Título de la app - Pegado al logo
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoAnimation.value,
                    child: Text(
                      'CubaLink23',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  );
                },
              ),
              
              SizedBox(height: 12),
              
              // Subtítulo - Tema de viajes
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoAnimation.value * 0.8,
                    child: Text(
                      'Disfruta, Conecta con el Mundo',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue.shade600,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
              
              SizedBox(height: 8),
              
              // Subtítulo adicional
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoAnimation.value * 0.7,
                    child: Text(
                      'Tu puerta de entrada a nuevas aventuras',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                },
              ),
              
              Spacer(),
              
              // Barra de progreso moderna
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60),
                child: Column(
                  children: [
                    // Texto "Cargando..." con emoji de avión
                    Text(
                      'Preparando tu viaje${_getLoadingDots()}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Barra de progreso moderna
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue.shade600,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 12),
                    
                    // Porcentaje con estilo moderno
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        '${(_progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  String _getLoadingDots() {
    int dotCount = ((_progress * 12) % 4).toInt();
    return '.' * (dotCount + 1);
  }
}