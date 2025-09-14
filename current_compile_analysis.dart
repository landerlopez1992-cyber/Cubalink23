// Current Compilation Analysis for CubaLink23
// This file analyzes the current Flutter project for compilation issues

import 'dart:io';

void main() async {
  print('🔍 ANÁLISIS DE COMPILACIÓN - CUBALINK23');
  print('═' * 50);
  print('Fecha: ${DateTime.now()}');
  print('Directorio: ${Directory.current.path}');
  print('');

  // Check project structure
  await checkProjectStructure();
  
  // Check for missing implementations
  await checkMissingImplementations();
  
  // Check for Flutter API compatibility
  await checkFlutterCompatibility();
  
  // Run compilation test
  await runCompilationTest();
}

Future<void> checkProjectStructure() async {
  print('📁 Verificando estructura del proyecto...');
  
  final requiredFiles = [
    'pubspec.yaml',
    'lib/main.dart',
    'android/app/build.gradle',
    'ios/Runner/Info.plist',
  ];
  
  for (final file in requiredFiles) {
    final exists = await File(file).exists();
    print('${exists ? "✅" : "❌"} $file');
  }
  print('');
}

Future<void> checkMissingImplementations() async {
  print('🔍 Verificando implementaciones faltantes...');
  
  // Check for getSampleHistory method
  final rechargeHistoryFile = File('lib/models/recharge_history.dart');
  if (await rechargeHistoryFile.exists()) {
    final content = await rechargeHistoryFile.readAsString();
    final hasSampleHistory = content.contains('getSampleHistory');
    print('${hasSampleHistory ? "✅" : "❌"} RechargeHistory.getSampleHistory()');
    
    if (!hasSampleHistory) {
      print('   ⚠️  Método getSampleHistory() faltante en RechargeHistory');
    }
  }
  
  // Check for withValues API usage
  print('🔍 Verificando uso de APIs modernas...');
  final homeScreen = File('lib/screens/home/home_screen.dart');
  if (await homeScreen.exists()) {
    final content = await homeScreen.readAsString();
    final usesWithValues = content.contains('withValues');
    print('${usesWithValues ? "⚠️" : "✅"} Uso de withValues() API${usesWithValues ? " (requiere Flutter 3.22+)" : ""}');
  }
  
  print('');
}

Future<void> checkFlutterCompatibility() async {
  print('🚀 Verificando compatibilidad Flutter...');
  
  try {
    // Check Flutter version
    final result = await Process.run('flutter', ['--version']);
    if (result.exitCode == 0) {
      print('✅ Flutter instalado');
      final version = result.stdout.toString();
      if (version.contains('Flutter')) {
        final lines = version.split('\n');
        for (final line in lines) {
          if (line.trim().startsWith('Flutter')) {
            print('   📱 $line');
            break;
          }
        }
      }
    } else {
      print('❌ Flutter no encontrado o error');
    }
  } catch (e) {
    print('❌ Error verificando Flutter: $e');
  }
  
  print('');
}

Future<void> runCompilationTest() async {
  print('⚡ Ejecutando pruebas de compilación...');
  
  try {
    // Run flutter doctor
    print('🔧 Ejecutando flutter doctor...');
    final doctorResult = await Process.run('flutter', ['doctor']);
    print('   Estado: ${doctorResult.exitCode == 0 ? "✅" : "⚠️"}');
    
    // Run pub get
    print('📦 Ejecutando flutter pub get...');
    final pubResult = await Process.run('flutter', ['pub', 'get']);
    print('   Estado: ${pubResult.exitCode == 0 ? "✅" : "❌"}');
    if (pubResult.exitCode != 0) {
      print('   Error: ${pubResult.stderr}');
    }
    
    // Run analyze
    print('🔍 Ejecutando dart analyze...');
    final analyzeResult = await Process.run('dart', ['analyze', '--fatal-infos']);
    print('   Estado: ${analyzeResult.exitCode == 0 ? "✅" : "⚠️"}');
    
    if (analyzeResult.exitCode != 0) {
      print('   ⚠️  Problemas encontrados:');
      final output = analyzeResult.stdout.toString();
      if (output.isNotEmpty) {
        final lines = output.split('\n').take(10);
        for (final line in lines) {
          if (line.trim().isNotEmpty) {
            print('      $line');
          }
        }
      }
    }
    
  } catch (e) {
    print('❌ Error durante pruebas: $e');
  }
  
  print('');
  print('🏁 ANÁLISIS COMPLETADO');
  print('═' * 50);
}