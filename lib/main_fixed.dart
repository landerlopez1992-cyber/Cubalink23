import 'package:flutter/material.dart';
import 'package:cubalink23/theme.dart';
import 'package:cubalink23/supabase/supabase_config_fixed.dart';
import 'package:cubalink23/screens/welcome/welcome_screen_fixed.dart';

/// VERSIÓN CORREGIDA QUE SOLUCIONA EL PROBLEMA DE "PREVIEW STARTING"
/// Esta versión inicializa Supabase de forma NO BLOQUEANTE
void main() async {
  print('🚀 CUBALINK23 - VERSIÓN CORREGIDA INICIANDO');
  
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase en background SIN BLOQUEAR la UI
  // Esta llamada NO espera a que se complete la conexión
  SupabaseConfigFixed.initializeAsync().catchError((e) {
    print('🔶 Supabase inicialización en background falló, continuando: $e');
  });
  
  print('✅ App iniciando - Supabase inicializándose en background');
  runApp(CubaLink23AppFixed());
}

class CubaLink23AppFixed extends StatelessWidget {
  const CubaLink23AppFixed({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CubaLink23',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: AppInitializer(),
    );
  }
}

/// Widget que maneja la inicialización progresiva de la app
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _appReady = false;
  String _initStatus = 'Iniciando aplicación...';

  @override
  void initState() {
    super.initState();
    _initializeAppProgressively();
  }

  /// Inicialización progresiva que NO bloquea la UI
  Future<void> _initializeAppProgressively() async {
    try {
      // Paso 1: Mostrar que la app está iniciando
      setState(() {
        _initStatus = 'Iniciando servicios...';
      });
      
      // Pequeña pausa para permitir que la UI se renderice
      await Future.delayed(Duration(milliseconds: 100));
      
      // Paso 2: Esperar un poco por Supabase (pero no más de 2 segundos)
      setState(() {
        _initStatus = 'Conectando servicios...';
      });
      
      // Esperar máximo 2 segundos por Supabase
      int attempts = 0;
      while (attempts < 20 && !SupabaseConfigFixed.isInitialized) {
        await Future.delayed(Duration(milliseconds: 100));
        attempts++;
      }
      
      // Paso 3: App lista para usar
      setState(() {
        _initStatus = 'Preparando interfaz...';
      });
      
      await Future.delayed(Duration(milliseconds: 200));
      
      // Paso 4: Navegar a la pantalla principal
      setState(() {
        _appReady = true;
      });
      
      print('✅ App completamente inicializada. Estado Supabase: ${SupabaseConfigFixed.status.name}');
      
    } catch (e) {
      print('🔶 Error en inicialización progresiva, continuando: $e');
      // Incluso si hay error, permitir que la app funcione
      setState(() {
        _appReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_appReady) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo o icono de la app
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity( 0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.phone_android,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Tu Recarga',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              // Indicador de progreso
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white.withOpacity( 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(height: 20),
              Text(
                _initStatus,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity( 0.9),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Supabase: ${SupabaseConfigFixed.status.name}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity( 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // App lista - navegar a la pantalla principal
    return WelcomeScreenFixed();
  }
}

/// Widget de fallback si hay problemas con WelcomeScreen
class SafeHomeScreen extends StatelessWidget {
  const SafeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tu Recarga'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              '¡APP FUNCIONANDO!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Problema de "preview starting" solucionado',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Estado Supabase: ${SupabaseConfigFixed.status.name}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade600,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreenFixed()),
                );
              },
              child: Text('Ir a App Principal'),
            ),
          ],
        ),
      ),
    );
  }
}