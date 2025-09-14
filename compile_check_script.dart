import 'dart:io';

void main() async {
  print('Starting Flutter project compilation check...\n');
  
  // Check if flutter is available
  try {
    var result = await Process.run('flutter', ['--version']);
    print('Flutter version check:');
    print(result.stdout);
    if (result.stderr.isNotEmpty) {
      print('Flutter stderr: ${result.stderr}');
    }
  } catch (e) {
    print('Flutter command not found: $e');
    return;
  }

  // Run flutter pub get
  print('\nRunning flutter pub get...');
  try {
    var pubGetResult = await Process.run('flutter', ['pub', 'get'], 
        workingDirectory: '/hologram/data/project/turecarga');
    print('pub get stdout: ${pubGetResult.stdout}');
    if (pubGetResult.stderr.isNotEmpty) {
      print('pub get stderr: ${pubGetResult.stderr}');
    }
    if (pubGetResult.exitCode != 0) {
      print('pub get failed with exit code: ${pubGetResult.exitCode}');
    }
  } catch (e) {
    print('Error running pub get: $e');
  }

  // Run dart analyze
  print('\nRunning dart analyze...');
  try {
    var analyzeResult = await Process.run('dart', ['analyze'], 
        workingDirectory: '/hologram/data/project/turecarga');
    print('analyze stdout: ${analyzeResult.stdout}');
    if (analyzeResult.stderr.isNotEmpty) {
      print('analyze stderr: ${analyzeResult.stderr}');
    }
    print('analyze exit code: ${analyzeResult.exitCode}');
  } catch (e) {
    print('Error running dart analyze: $e');
  }

  // Try to run flutter build
  print('\nTrying flutter build (dry-run)...');
  try {
    var buildResult = await Process.run('flutter', ['build', 'apk', '--dry-run'], 
        workingDirectory: '/hologram/data/project/turecarga');
    print('build stdout: ${buildResult.stdout}');
    if (buildResult.stderr.isNotEmpty) {
      print('build stderr: ${buildResult.stderr}');
    }
    print('build exit code: ${buildResult.exitCode}');
  } catch (e) {
    print('Error running flutter build: $e');
  }
}