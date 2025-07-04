import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class OnlyDependencyRule extends Rule {
  final String sourcePackage;
  final List<String> allowedPackages;

  OnlyDependencyRule(this.sourcePackage, this.allowedPackages);

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);
    final projectName = await _getProjectName(rootDir);
    final violations = <String, List<String>>{};

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      // Verifica apenas arquivos do pacote fonte
      if (!path.contains(p.join(rootDir, sourcePackage))) continue;

      final fileViolations = <String>[];
      final imports = unit.directives.whereType<ImportDirective>();

      for (final import in imports) {
        final importUri = import.uri.stringValue ?? '';

        // Ignora importações internas do Dart e do próprio projeto
        if (_isInternalImport(importUri, projectName)) continue;

        // Verifica se a importação é de um pacote não permitido
        if (_isProjectImport(importUri, projectName) &&
            !_isAllowedImport(importUri)) {
          fileViolations.add(importUri);
        }
      }

      if (fileViolations.isNotEmpty) {
        violations[path] = fileViolations;
      }
    }

    if (violations.isNotEmpty) {
      _throwViolationError(violations);
    }
  }

  bool _isInternalImport(String importUri, String projectName) {
    return importUri.startsWith('dart:');
  }

  bool _isProjectImport(String importUri, String projectName) {
    return importUri.startsWith('package:$projectName/');
  }

  bool _isAllowedImport(String importUri) {
    return allowedPackages.any((package) => importUri.contains(package));
  }

  void _throwViolationError(Map<String, List<String>> violations) {
    final buffer = StringBuffer();
    buffer.writeln('Violações de dependência encontradas:');
    buffer.writeln(
      'O pacote "$sourcePackage" só pode depender de: ${allowedPackages.join(", ")}',
    );
    buffer.writeln();

    violations.forEach((file, imports) {
      buffer.writeln('Arquivo: $file');
      buffer.writeln('Importações não permitidas:');
      for (final import in imports) {
        buffer.writeln('  - $import');
      }
      buffer.writeln();
    });

    throw Exception(buffer.toString());
  }

  Future<String> _getProjectName(String rootDir) async {
    try {
      final pubspecFile = File(p.join(rootDir, '../pubspec.yaml'));
      if (!pubspecFile.existsSync()) {
        return '';
      }

      final content = await pubspecFile.readAsString();
      final yaml = loadYaml(content) as Map;

      return yaml['name'] as String? ?? '';
    } catch (e) {
      print('Erro ao ler pubspec.yaml: $e');
      return '';
    }
  }
}
