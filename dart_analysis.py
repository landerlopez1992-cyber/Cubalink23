#!/usr/bin/env python3

import os
import re
import sys
from pathlib import Path

class DartAnalyzer:
    def __init__(self, project_root):
        self.project_root = Path(project_root)
        self.lib_dir = self.project_root / 'lib'
        self.errors = []
        self.warnings = []
        
    def analyze(self):
        print("🔧 DART PROJECT STATIC ANALYSIS")
        print("=" * 50)
        
        # Check project structure
        self.check_project_structure()
        
        # Analyze Dart files
        dart_files = list(self.lib_dir.glob('**/*.dart'))
        print(f"📁 Found {len(dart_files)} Dart files to analyze")
        
        for dart_file in dart_files:
            self.analyze_dart_file(dart_file)
        
        # Generate report
        self.generate_report()
        
    def check_project_structure(self):
        print("📋 Checking project structure...")
        
        required_files = ['pubspec.yaml', 'lib/main.dart']
        for file_path in required_files:
            full_path = self.project_root / file_path
            if not full_path.exists():
                self.errors.append(f"Missing required file: {file_path}")
            else:
                print(f"  ✅ Found {file_path}")
        
        print()
        
    def analyze_dart_file(self, file_path):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
            relative_path = file_path.relative_to(self.project_root)
            
            # Check for basic syntax issues
            self.check_imports(content, relative_path)
            self.check_class_structure(content, relative_path)
            self.check_method_structure(content, relative_path)
            self.check_common_errors(content, relative_path)
            
        except Exception as e:
            self.errors.append(f"Error reading {file_path}: {str(e)}")
    
    def check_imports(self, content, file_path):
        lines = content.split('\n')
        for line_num, line in enumerate(lines, 1):
            line = line.strip()
            
            # Check for malformed import statements
            if line.startswith('import '):
                if not line.endswith(';'):
                    self.errors.append(f"{file_path}:{line_num} - Missing semicolon in import statement")
                
                # Check for non-existent local imports
                if 'package:turecarga/' in line:
                    import_path = re.search(r"'package:turecarga/(.+?)'", line)
                    if import_path:
                        imported_file = self.lib_dir / import_path.group(1)
                        if not imported_file.exists():
                            self.errors.append(f"{file_path}:{line_num} - Import file not found: {imported_file}")
    
    def check_class_structure(self, content, file_path):
        lines = content.split('\n')
        brace_balance = 0
        in_class = False
        
        for line_num, line in enumerate(lines, 1):
            line = line.strip()
            
            # Check for class declarations
            if re.match(r'class\s+\w+', line):
                in_class = True
                if '{' not in line:
                    # Check if opening brace is on next line
                    next_line_num = line_num
                    found_brace = False
                    while next_line_num < len(lines):
                        next_line = lines[next_line_num].strip()
                        if '{' in next_line:
                            found_brace = True
                            break
                        if next_line and not next_line.startswith('//'):
                            break
                        next_line_num += 1
                    
                    if not found_brace:
                        self.errors.append(f"{file_path}:{line_num} - Class missing opening brace")
            
            # Count braces for balance check
            brace_balance += line.count('{') - line.count('}')
        
        if brace_balance != 0:
            self.errors.append(f"{file_path} - Unbalanced braces: {brace_balance}")
    
    def check_method_structure(self, content, file_path):
        lines = content.split('\n')
        
        for line_num, line in enumerate(lines, 1):
            line = line.strip()
            
            # Check for method without body
            if re.match(r'^\s*\w+.*\(.*\)\s*;?\s*$', line) and 'abstract' not in line and 'external' not in line:
                if not line.endswith(';') and not line.endswith('{') and '=>' not in line:
                    # Check if next line has opening brace
                    if line_num < len(lines):
                        next_line = lines[line_num].strip()
                        if not next_line.startswith('{'):
                            self.warnings.append(f"{file_path}:{line_num} - Possible incomplete method definition")
    
    def check_common_errors(self, content, file_path):
        lines = content.split('\n')
        
        for line_num, line in enumerate(lines, 1):
            # Check for common typos and issues
            if 'setState(() =>' in line and not line.strip().endswith(');'):
                self.warnings.append(f"{file_path}:{line_num} - Possible incomplete setState call")
            
            # Check for missing const keywords
            if re.search(r'Widget\s+\w+.*return\s+[A-Z]\w+\(', line):
                if 'const' not in line:
                    self.warnings.append(f"{file_path}:{line_num} - Consider adding const to widget constructor")
            
            # Check for unused imports (basic check)
            if line.strip().startswith('import ') and 'dart:' not in line:
                import_match = re.search(r"import\s+'[^']+/(\w+)\.dart'", line)
                if import_match:
                    import_name = import_match.group(1)
                    # Convert snake_case to PascalCase for class names
                    class_name = ''.join(word.capitalize() for word in import_name.split('_'))
                    if class_name not in content and import_name not in content:
                        self.warnings.append(f"{file_path}:{line_num} - Possibly unused import: {import_name}")
    
    def generate_report(self):
        print("\n" + "=" * 50)
        print("📊 ANALYSIS RESULTS")
        print("=" * 50)
        
        if not self.errors and not self.warnings:
            print("✅ NO ISSUES FOUND - Project should compile successfully!")
            return True
        
        if self.errors:
            print(f"❌ ERRORS ({len(self.errors)}):")
            for error in self.errors:
                print(f"  • {error}")
            print()
        
        if self.warnings:
            print(f"⚠️  WARNINGS ({len(self.warnings)}):")
            for warning in self.warnings:
                print(f"  • {warning}")
            print()
        
        # Summary
        total_issues = len(self.errors) + len(self.warnings)
        print(f"📈 SUMMARY: {len(self.errors)} errors, {len(self.warnings)} warnings")
        
        if len(self.errors) == 0:
            print("✅ No critical errors found - Project should compile!")
            return True
        else:
            print("❌ Critical errors found - Fix before compiling!")
            return False

if __name__ == "__main__":
    project_root = "/hologram/data/project/turecarga"
    analyzer = DartAnalyzer(project_root)
    success = analyzer.analyze()
    sys.exit(0 if success else 1)