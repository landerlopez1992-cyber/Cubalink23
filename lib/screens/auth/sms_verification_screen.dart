import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:cubalink23/services/auth_service.dart';

class SmsVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final bool isRegistration;
  final Map<String, String>? registrationData;
  final bool isPhoneLogin;

  const SmsVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    this.isRegistration = false,
    this.registrationData,
    this.isPhoneLogin = false,
  });

  @override
  State<SmsVerificationScreen> createState() => _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends State<SmsVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String _errorMessage = '';
  int _countdown = 60;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _canResend = false;
    _countdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onCodeChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    if (_code.length == 6) {
      _verifyCode();
    }
    
    setState(() {
      _errorMessage = '';
    });
  }

  void _verifyCode() async {
    if (_code.length != 6) {
      setState(() {
        _errorMessage = 'Por favor ingresa el código completo de 6 dígitos';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (widget.isRegistration && widget.registrationData != null) {
        // Simulando verificación mientras se implementan los métodos
        // final success = await _authService.verifyPhoneAndCreateAccount(
        //   widget.verificationId,
        //   _code,
        //   widget.registrationData!,
        // );
        
        final success = true; // Simulado
        
        if (success && mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/welcome',
            (route) => false,
          );
          _showSuccessMessage('¡Cuenta creada exitosamente!');
        }
      } else {
        // Simulando verificación de login
        bool success = true; // Simulado
        // if (widget.isPhoneLogin) {
        //   success = await _authService.verifyPhoneAndLogin(
        //     widget.verificationId,
        //     _code,
        //     widget.phoneNumber,
        //   );
        // } else {
        //   success = await _authService.verifyPhoneForLogin(
        //     widget.verificationId,
        //     _code,
        //   );
        // }
        
        if (success && mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/welcome',
            (route) => false,
          );
          _showSuccessMessage('¡Ingreso exitoso!');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('invalid-verification-code') 
            ? 'Código incorrecto, intenta de nuevo'
            : 'Error al verificar código: ${e.toString()}';
      });
      _clearCode();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resendCode() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Simulando reenvío de código mientras se implementa el método
      // await _authService.resendVerificationCode(widget.phoneNumber);
      _startCountdown();
      _showSuccessMessage('Código reenviado exitosamente');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al reenviar código: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearCode() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar Teléfono'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(
              Icons.sms,
              size: 80,
              color: Colors.blue[600],
            ),
            const SizedBox(height: 30),
            const Text(
              'Verificación SMS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Hemos enviado un código de verificación al número:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              widget.phoneNumber,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => 
                SizedBox(
                  width: 45,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                      ),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) => _onCodeChanged(index, value),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red[600], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading || _code.length != 6 ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Verificar Código',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿No recibiste el código? ',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (_canResend)
                  GestureDetector(
                    onTap: _resendCode,
                    child: Text(
                      'Reenviar',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Text(
                    'Reenviar en ${_countdown}s',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}