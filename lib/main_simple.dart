import 'package:flutter/material.dart';
import 'package:cubalink23/theme.dart';
import 'package:cubalink23/screens/welcome/welcome_screen.dart';

void main() {
  print('🚀 CUBALINK23 - MODO SIMPLE');
  runApp(CubaLink23SimpleApp());
}

class CubaLink23SimpleApp extends StatelessWidget {
  const CubaLink23SimpleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CubaLink23',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}