#!/usr/bin/env dart

import 'dart:io';

Future<void> main() async {
  print('🔍 Quick Flutter Compilation Check');
  print('==================================\n');
  
  final projectDir = Directory('/hologram/data/project/turecarga');
  if (!projectDir.existsSync()) {
    print('❌ Project directory not found');
    return;
  }
  
  Directory.current = projectDir;
  
  try {
    // Check if pubspec.yaml exists
    final pubspec = File('pubspec.yaml');
    if (!pubspec.existsSync()) {
      print('❌ pubspec.yaml not found');
      return;
    }
    
    print('✅ Project directory exists');
    print('✅ pubspec.yaml found');
    
    // Quick syntax check using dart analyze
    print('\n📊 Running basic syntax analysis...');
    
    final result = await Process.run(
      'dart',
      ['analyze', '--no-fatal-infos', '--no-fatal-warnings'],
      workingDirectory: projectDir.path,
    );
    
    print('Exit code: ${result.exitCode}');
    
    if (result.stdout.toString().isNotEmpty) {
      print('\n📄 Analysis Output:');
      print(result.stdout);
    }
    
    if (result.stderr.toString().isNotEmpty) {
      print('\n⚠️ Analysis Errors:');
      print(result.stderr);
    }
    
    // Summary
    print('\n${'='*40}');
    if (result.exitCode == 0) {
      print('🎉 ANALYSIS PASSED - No critical compilation errors found!');
    } else {
      print('⚠️ ANALYSIS ISSUES FOUND - See output above for details');
    }
    
  } catch (e) {
    print('❌ Error during analysis: $e');
    
    // Fallback: check for common compilation issues manually
    print('\n🔍 Manual check for common issues...');
    await checkCommonIssues();
  }
}

Future<void> checkCommonIssues() async {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('❌ lib directory not found');
    return;
  }
  
  // Check main.dart
  final mainFile = File('lib/main.dart');
  if (mainFile.existsSync()) {
    final content = await mainFile.readAsString();
    if (content.contains('import') && content.contains('main()')) {
      print('✅ lib/main.dart looks good');
    } else {
      print('⚠️ lib/main.dart may have issues');
    }
  }
  
  // Check for syntax issues in key files
  final dartFiles = await libDir
      .list(recursive: true)
      .where((entity) => entity.path.endsWith('.dart'))
      .cast<File>()
      .toList();
  
  print('📁 Found ${dartFiles.length} Dart files');
  
  // Basic syntax check
  int issueCount = 0;
  for (final file in dartFiles.take(10)) { // Check first 10 files
    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        print('⚠️ Empty file: ${file.path}');
        issueCount++;
      } else if (!content.contains(RegExp(r'class|void|import'))) {
        print('⚠️ Suspicious file: ${file.path}');
        issueCount++;
      }
    } catch (e) {
      print('❌ Error reading ${file.path}: $e');
      issueCount++;
    }
  }
  
  if (issueCount == 0) {
    print('✅ Manual check passed - no obvious issues found');
  } else {
    print('⚠️ Manual check found $issueCount potential issues');
  }
}