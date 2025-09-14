import 'package:flutter/material.dart';
import 'package:cubalink23/services/auth_service_bypass.dart';
import 'package:cubalink23/services/credentials_storage_service.dart';
import 'package:cubalink23/screens/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isEmailLogin = true; // true para email, false para teléfono
  bool _saveCredentials = false; // Nueva variable para la casilla

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  // Cargar credenciales guardadas al inicializar
  Future<void> _loadSavedCredentials() async {
    try {
      final savedCredentials = await CredentialsStorageService.getSavedCredentials();
      if (savedCredentials != null) {
        setState(() {
          _identifierController.text = savedCredentials['identifier'] ?? '';
          _passwordController.text = savedCredentials['password'] ?? '';
          _isEmailLogin = savedCredentials['isEmailLogin'] ?? true;
          _saveCredentials = true;
        });
        print('✅ Credenciales cargadas automáticamente');
      }
    } catch (e) {
      print('❌ Error cargando credenciales: $e');
    }
  }

  Future<void> _login() async {
    print('🔐 === INICIANDO PROCESO LOGIN ===');
    setState(() => _isLoading = true);

    try {
      if (_isEmailLogin) {
        print('🔐 Login con email seleccionado');
        // Validar campos para login con email
        if (_identifierController.text.isEmpty || _passwordController.text.isEmpty) {
          print('❌ Campos vacíos detectados');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Por favor completa todos los campos'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
        
        String email = _identifierController.text.trim();
        String password = _passwordController.text;
        
        print('🔐 Intentando login con:');
        print('   - Email: $email');
        print('   - Password length: ${password.length}');
        
        // Login con email y contraseña
        final user = await AuthServiceBypass.instance.loginUser(
          email: email,
          password: password,
        );
        
        print('🔐 Resultado del login: ${user != null ? 'EXITOSO' : 'FALLIDO'}');
        
        if (user != null) {
          print('✅ Usuario logueado exitosamente: ${user.name}');
          
          // Guardar credenciales si la casilla está marcada
          if (_saveCredentials) {
            await CredentialsStorageService.saveCredentials(
              identifier: email,
              password: password,
              isEmailLogin: true,
            );
            print('✅ Credenciales guardadas para futuros logins');
          } else {
            // Si no está marcada, eliminar credenciales guardadas
            await CredentialsStorageService.clearSavedCredentials();
            print('✅ Credenciales no guardadas');
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Bienvenido, ${user.name}!'),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.pushReplacementNamed(context, '/welcome');
        } else {
          print('❌ Login retornó null');
          throw Exception('Error inesperado durante el login');
        }
        
      } else {
        print('🔐 Login con teléfono seleccionado');
        // Validar teléfono y contraseña
        if (_identifierController.text.isEmpty || _passwordController.text.isEmpty) {
          print('❌ Campos vacíos detectados');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Por favor completa todos los campos'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
        
        String phone = _identifierController.text.trim();
        String password = _passwordController.text;
        
        print('🔐 Intentando login con:');
        print('   - Teléfono: $phone');
        print('   - Password length: ${password.length}');
        
        // Login con teléfono y contraseña
        final user = await AuthServiceBypass.instance.loginUser(
          phone: phone,
          password: password,
        );
        
        print('🔐 Resultado del login: ${user != null ? 'EXITOSO' : 'FALLIDO'}');
        
        if (user != null) {
          print('✅ Usuario logueado exitosamente: ${user.name}');
          
          // Guardar credenciales si la casilla está marcada
          if (_saveCredentials) {
            await CredentialsStorageService.saveCredentials(
              identifier: phone,
              password: password,
              isEmailLogin: false,
            );
            print('✅ Credenciales guardadas para futuros logins');
          } else {
            // Si no está marcada, eliminar credenciales guardadas
            await CredentialsStorageService.clearSavedCredentials();
            print('✅ Credenciales no guardadas');
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Bienvenido, ${user.name}!'),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.pushReplacementNamed(context, '/welcome');
        } else {
          print('❌ Login retornó null');
          throw Exception('Error inesperado durante el login');
        }
      }
      
      setState(() => _isLoading = false);
      
    } catch (e) {
      print('❌ === ERROR EN LOGIN SCREEN ===');
      print('❌ Error capturado: $e');
      print('❌ Tipo de error: ${e.runtimeType}');
      
      setState(() => _isLoading = false);
      
      // Extraer el mensaje del error
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      
      print('❌ Mostrando error al usuario: $errorMessage');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $errorMessage'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 6),
          action: SnackBarAction(
            label: 'CERRAR',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              // Logo de la app
              SizedBox(
                width: 140,
                height: 140,
                child: Image.asset(
                  'assets/images/assets_task_01k3m7yveaebmtdrdnybpe7ngv_1756247471_img_1.webp',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.phone_android,
                        size: 60,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              // Nombre de la app
              Text(
                'Cubalink23',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Disfruta, Conecta con el Mundo',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48),
              // Selector de tipo de login
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isEmailLogin = true),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isEmailLogin ? Theme.of(context).primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.email,
                                color: _isEmailLogin ? Colors.white : Colors.grey,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Email',
                                style: TextStyle(
                                  color: _isEmailLogin ? Colors.white : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isEmailLogin = false),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isEmailLogin ? Theme.of(context).primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.phone,
                                color: !_isEmailLogin ? Colors.white : Colors.grey,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Teléfono',
                                style: TextStyle(
                                  color: !_isEmailLogin ? Colors.white : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _identifierController,
                keyboardType: _isEmailLogin ? TextInputType.emailAddress : TextInputType.phone,
                decoration: InputDecoration(
                  labelText: _isEmailLogin ? 'Correo electrónico' : 'Número de teléfono',
                  hintText: _isEmailLogin ? 'ejemplo@correo.com' : '53123456789',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(_isEmailLogin ? Icons.email : Icons.phone),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 16),
              // Casilla para guardar credenciales
              Row(
                children: [
                  Checkbox(
                    value: _saveCredentials,
                    onChanged: (bool? value) {
                      setState(() {
                        _saveCredentials = value ?? false;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _saveCredentials = !_saveCredentials;
                        });
                      },
                      child: Text(
                        'Guardar usuario para futuros logins',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      ),
                      child: Text('INICIAR SESIÓN'),
                    ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text(
                  'CREAR CUENTA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Botón para limpiar credenciales guardadas
              FutureBuilder<bool>(
                future: CredentialsStorageService.hasSavedCredentials(),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return TextButton(
                      onPressed: () async {
                        await CredentialsStorageService.clearSavedCredentials();
                        setState(() {
                          _identifierController.clear();
                          _passwordController.clear();
                          _saveCredentials = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ Credenciales guardadas eliminadas'),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text(
                        'Limpiar credenciales guardadas',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[700],
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}