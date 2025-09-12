import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cubalink23/screens/auth/login_screen.dart';
import 'package:cubalink23/screens/welcome/welcome_screen.dart';
import 'package:cubalink23/services/auth_service_bypass.dart';
// MIGRATED TO SUPABASE: Firebase services removed

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isSuspended = false;
  final String _suspensionMessage = '';

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      print('🔍 ===== VERIFICACIÓN RÁPIDA DE AUTENTICACIÓN =====');
      
      // Simplified auth check without blocking operations
      setState(() {
        _isLoggedIn = false; // Default to not logged in for now
        _isSuspended = false;
        _isLoading = false;
      });
      
      print('✅ AuthWrapper inicializado sin bloqueos');
      
    } catch (e) {
      print('❌ Error en auth check: $e');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isSuspended = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
              SizedBox(height: 16),
              Text(
                'Iniciando TuRecarga...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isSuspended) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Cuenta Suspendida'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning,
                  size: 64,
                  color: Colors.red,
                ),
                SizedBox(height: 16),
                Text(
                  'Cuenta Suspendida',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  _suspensionMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // Log out the suspended user
                    AuthServiceBypass.instance.signOut();
                    setState(() {
                      _isLoggedIn = false;
                      _isSuspended = false;
                    });
                  },
                  icon: Icon(Icons.logout),
                  label: Text('Cerrar Sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If user is logged in, go to WelcomeScreen
    if (_isLoggedIn) {
      return WelcomeScreen();
    } else {
      // If user is not logged in, show LoginScreen
      return LoginScreen();
    }
  }
}