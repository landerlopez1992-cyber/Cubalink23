import 'package:flutter/material.dart';
import 'package:cubalink23/services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Fondo general oficial Cubalink23
      appBar: AppBar(
        backgroundColor: Color(0xFF37474F), // Header oficial Cubalink23
        title: Text(
          'Cambiar Contraseña',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con gradiente
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF37474F), // Header oficial Cubalink23
                    Color(0xFF4CAF50), // Verde secciones oficial
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity( 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Actualiza tu Contraseña',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Por tu seguridad, ingresa tu contraseña actual y la nueva contraseña',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Formulario
            Padding(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Contraseña actual
                    _buildPasswordField(
                      controller: _currentPasswordController,
                      label: 'Contraseña Actual',
                      isVisible: _isCurrentPasswordVisible,
                      onVisibilityToggle: () {
                        setState(() {
                          _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu contraseña actual';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Nueva contraseña
                    _buildPasswordField(
                      controller: _newPasswordController,
                      label: 'Nueva Contraseña',
                      isVisible: _isNewPasswordVisible,
                      onVisibilityToggle: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa una nueva contraseña';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        if (value == _currentPasswordController.text) {
                          return 'La nueva contraseña debe ser diferente a la actual';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Confirmar nueva contraseña
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirmar Nueva Contraseña',
                      isVisible: _isConfirmPasswordVisible,
                      onVisibilityToggle: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirma tu nueva contraseña';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // Indicadores de seguridad
                    _buildPasswordStrengthIndicator(),
                    SizedBox(height: 32),

                    // Botón cambiar contraseña
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF9800), // Naranja oficial Cubalink23
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading 
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Actualizando...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Cambiar Contraseña',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Botón cancelar
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[400]!),
                          foregroundColor: Colors.grey[700],
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Theme.of(context).colorScheme.primary,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[600],
          ),
          onPressed: onVisibilityToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _newPasswordController.text;
    final strength = _calculatePasswordStrength(password);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seguridad de la contraseña',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength.level / 4,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(strength.color),
                minHeight: 4,
              ),
            ),
            SizedBox(width: 12),
            Text(
              strength.text,
              style: TextStyle(
                color: strength.color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        if (password.isNotEmpty) ...[
          ...strength.requirements.map((req) => Padding(
            padding: EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(
                  req.isMet ? Icons.check_circle : Icons.cancel,
                  color: req.isMet ? Colors.green : Colors.red,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  req.text,
                  style: TextStyle(
                    color: req.isMet ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  PasswordStrength _calculatePasswordStrength(String password) {
    int score = 0;
    
    final requirements = [
      PasswordRequirement(
        text: 'Al menos 6 caracteres',
        isMet: password.length >= 6,
      ),
      PasswordRequirement(
        text: 'Contiene mayúsculas',
        isMet: password.contains(RegExp(r'[A-Z]')),
      ),
      PasswordRequirement(
        text: 'Contiene números',
        isMet: password.contains(RegExp(r'[0-9]')),
      ),
      PasswordRequirement(
        text: 'Contiene caracteres especiales',
        isMet: password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
      ),
    ];
    
    score = requirements.where((req) => req.isMet).length;
    
    if (score == 0) {
      return PasswordStrength(
        level: 0,
        text: 'Muy débil',
        color: Colors.red,
        requirements: requirements,
      );
    } else if (score == 1) {
      return PasswordStrength(
        level: 1,
        text: 'Débil',
        color: Colors.orange,
        requirements: requirements,
      );
    } else if (score == 2) {
      return PasswordStrength(
        level: 2,
        text: 'Regular',
        color: Colors.yellow[700]!,
        requirements: requirements,
      );
    } else if (score == 3) {
      return PasswordStrength(
        level: 3,
        text: 'Fuerte',
        color: Colors.lightGreen,
        requirements: requirements,
      );
    } else {
      return PasswordStrength(
        level: 4,
        text: 'Muy fuerte',
        color: Colors.green,
        requirements: requirements,
      );
    }
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isLoading = true);
        
        // Cambiar contraseña usando AuthService
        await AuthService.instance.changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '✅ Contraseña actualizada exitosamente',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFF4CAF50), // Verde éxito oficial
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        
        // Esperar un momento y regresar
        await Future.delayed(Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context);
        }
        
      } catch (e) {
        String errorMessage = 'Error al cambiar contraseña';
        
        if (e.toString().contains('wrong-password')) {
          errorMessage = 'La contraseña actual es incorrecta';
        } else if (e.toString().contains('weak-password')) {
          errorMessage = 'La nueva contraseña es muy débil';
        } else if (e.toString().contains('requires-recent-login')) {
          errorMessage = 'Por seguridad, necesitas iniciar sesión de nuevo';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '❌ $errorMessage',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFFDC2626), // Rojo error oficial
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

class PasswordStrength {
  final int level;
  final String text;
  final Color color;
  final List<PasswordRequirement> requirements;

  PasswordStrength({
    required this.level,
    required this.text,
    required this.color,
    required this.requirements,
  });
}

class PasswordRequirement {
  final String text;
  final bool isMet;

  PasswordRequirement({
    required this.text,
    required this.isMet,
  });
}