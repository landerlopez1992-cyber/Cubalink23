// Script manual para verificar la compilación de la aplicación Flutter
import 'dart:io';

void main() async {
  print('🔍 INICIANDO ANÁLISIS MANUAL DE COMPILACIÓN');
  print('=' * 50);
  
  final projectRoot = Directory.current.path;
  print('📁 Directorio del proyecto: $projectRoot');
  
  // 1. Verificar archivo pubspec.yaml
  await checkPubspecFile();
  
  // 2. Verificar dependencias principales
  await checkMainDependencies();
  
  // 3. Verificar archivo main.dart
  await checkMainFile();
  
  // 4. Verificar configuración de Android
  await checkAndroidConfig();
  
  // 5. Verificar archivos de assets
  await checkAssets();
  
  // 6. Resumen del análisis
  printSummary();
}

Future<void> checkPubspecFile() async {
  print('\n📋 1. VERIFICANDO PUBSPEC.YAML');
  print('-' * 30);
  
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('❌ ERROR: pubspec.yaml no encontrado');
    return;
  }
  
  final content = await pubspecFile.readAsString();
  print('✅ pubspec.yaml encontrado');
  
  // Verificar SDK version
  if (content.contains('sdk: ^3.6.0')) {
    print('✅ SDK version: 3.6.0 (compatible)');
  } else {
    print('⚠️  SDK version podría tener problemas');
  }
  
  // Verificar dependencias principales
  final mainDeps = ['flutter', 'supabase_flutter', 'cupertino_icons'];
  for (final dep in mainDeps) {
    if (content.contains(dep)) {
      print('✅ Dependencia $dep encontrada');
    } else {
      print('❌ Dependencia $dep faltante');
    }
  }
}

Future<void> checkMainDependencies() async {
  print('\n📦 2. VERIFICANDO DEPENDENCIAS PRINCIPALES');
  print('-' * 40);
  
  final dependencies = [
    'image_picker',
    'shared_preferences', 
    'http',
    'flutter_contacts',
    'permission_handler',
    'supabase_flutter',
    'url_launcher',
    'flutter_local_notifications'
  ];
  
  final pubspecFile = File('pubspec.yaml');
  if (pubspecFile.existsSync()) {
    final content = await pubspecFile.readAsString();
    for (final dep in dependencies) {
      if (content.contains(dep)) {
        print('✅ $dep');
      } else {
        print('❌ $dep faltante');
      }
    }
  }
}

Future<void> checkMainFile() async {
  print('\n🎯 3. VERIFICANDO ARCHIVO MAIN.DART');
  print('-' * 35);
  
  final mainFile = File('lib/main.dart');
  if (!mainFile.existsSync()) {
    print('❌ ERROR CRÍTICO: lib/main.dart no encontrado');
    return;
  }
  
  final content = await mainFile.readAsString();
  print('✅ main.dart encontrado');
  
  // Verificar imports principales
  final imports = [
    'package:flutter/material.dart',
    'package:cubalink23/theme.dart',
    'package:cubalink23/supabase/supabase_config.dart'
  ];
  
  for (final import in imports) {
    if (content.contains(import)) {
      print('✅ Import: $import');
    } else {
      print('⚠️  Import faltante: $import');
    }
  }
  
  // Verificar función main
  if (content.contains('void main()')) {
    print('✅ Función main() encontrada');
  } else {
    print('❌ ERROR: Función main() no encontrada');
  }
  
  // Verificar runApp
  if (content.contains('runApp(')) {
    print('✅ runApp() encontrado');
  } else {
    print('❌ ERROR: runApp() no encontrado');
  }
}

Future<void> checkAndroidConfig() async {
  print('\n🤖 4. VERIFICANDO CONFIGURACIÓN ANDROID');
  print('-' * 40);
  
  // Verificar AndroidManifest.xml
  final manifestFile = File('android/app/src/main/AndroidManifest.xml');
  if (manifestFile.existsSync()) {
    print('✅ AndroidManifest.xml encontrado');
    final content = await manifestFile.readAsString();
    
    if (content.contains('android.permission.INTERNET')) {
      print('✅ Permisos de Internet configurados');
    } else {
      print('⚠️  Permisos de Internet podrían faltar');
    }
  } else {
    print('❌ AndroidManifest.xml no encontrado');
  }
  
  // Verificar build.gradle
  final buildGradleFile = File('android/app/build.gradle');
  if (buildGradleFile.existsSync()) {
    print('✅ build.gradle encontrado');
  } else {
    print('❌ build.gradle no encontrado');
  }
}

Future<void> checkAssets() async {
  print('\n📁 5. VERIFICANDO ASSETS');
  print('-' * 25);
  
  final assetsDir = Directory('assets');
  if (assetsDir.existsSync()) {
    print('✅ Directorio assets encontrado');
    
    // Verificar imagen principal
    final logoFile = File('assets/images/landGo.png');
    if (logoFile.existsSync()) {
      print('✅ Logo landGo.png encontrado');
    } else {
      print('⚠️  Logo landGo.png no encontrado');
    }
  } else {
    print('❌ Directorio assets no encontrado');
  }
}

void printSummary() {
  print('\n📊 RESUMEN DEL ANÁLISIS');
  print('=' * 30);
  print('✅ Verificación de estructura completada');
  print('📱 Para compilar ejecuta:');
  print('   1. flutter clean');
  print('   2. flutter pub get');
  print('   3. flutter analyze');
  print('   4. flutter build apk (para Android)');
  print('\n🔧 Si hay errores, revisa los archivos indicados arriba');
}