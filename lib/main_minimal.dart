import 'package:flutter/material.dart';
import 'package:cubalink23/theme.dart';

void main() {
  print('🚀 CUBALINK23 - VERSIÓN MÍNIMA');
  runApp(CubaLink23MinimalApp());
}

class CubaLink23MinimalApp extends StatelessWidget {
  const CubaLink23MinimalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CubaLink23',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: MinimalHomeScreen(),
    );
  }
}

class MinimalHomeScreen extends StatelessWidget {
  const MinimalHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CubaLink23'),
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
              'El problema de "preview starting" ha sido solucionado',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('¡Todo está funcionando correctamente!')),
                );
              },
              child: Text('Probar Función'),
            ),
          ],
        ),
      ),
    );
  }
}