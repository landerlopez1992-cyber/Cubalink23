#!/usr/bin/env dart

import 'dart:io';

Future<void> main() async {
  print('🔄 Running Flutter compilation check...\n');
  
  // Change to the project directory
  Directory.current = '/hologram/data/project/turecarga';
  
  try {
    // Run flutter analyze
    print('📊 Running flutter analyze...');
    final analyzeResult = await Process.run('flutter', ['analyze']);
    print('Exit code: ${analyzeResult.exitCode}');
    print('Stdout: ${analyzeResult.stdout}');
    if (analyzeResult.stderr.isNotEmpty) {
      print('Stderr: ${analyzeResult.stderr}');
    }
    
    print('\n${'='*50}\n');
    
    // Run flutter build (dry run)
    print('🏗️  Running flutter build check...');
    final buildResult = await Process.run('flutter', ['build', 'apk', '--debug', '--verbose']);
    print('Exit code: ${buildResult.exitCode}');
    print('Stdout: ${buildResult.stdout}');
    if (buildResult.stderr.isNotEmpty) {
      print('Stderr: ${buildResult.stderr}');
    }
    
    // Summary
    print('\n${'='*50}');
    print('📋 COMPILATION SUMMARY');
    print('='*50);
    print('Analyze result: ${analyzeResult.exitCode == 0 ? "✅ PASS" : "❌ FAIL"}');
    print('Build result: ${buildResult.exitCode == 0 ? "✅ PASS" : "❌ FAIL"}');
    
    if (analyzeResult.exitCode == 0 && buildResult.exitCode == 0) {
      print('\n🎉 ALL CHECKS PASSED! The project compiles successfully.');
    } else {
      print('\n⚠️  Some issues remain. Check the output above for details.');
    }
    
  } catch (e) {
    print('❌ Error running compilation check: $e');
  }
}