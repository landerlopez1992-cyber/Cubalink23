import 'package:flutter/material.dart';

void main() {
  print('🚀 CUBALINK23 - TEST MÍNIMO');
  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CubaLink23 Test',
      home: TestScreen(),
    );
  }
}

class TestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test')),
      body: Center(
        child: Text('¡FUNCIONANDO!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}