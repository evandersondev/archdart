import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class AccessRule extends Rule {
  final String package;
  final List<String> allowedPackages;

  AccessRule(this.package, this.allowedPackages);

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);
    final projectName = await _getProjectName(rootDir);

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      // Check all files to see if they import the target package
      final imports = unit.directives.whereType<ImportDirective>();
      for (final import in imports) {
        final importUri = import.uri.stringValue ?? '';
        if (importUri.contains(package) &&
            importUri.startsWith('package:$projectName/')) {
          final importingPackage = _getPackageFromPath(path, rootDir);
          if (importingPackage != null &&
              !allowedPackages.contains(importingPackage)) {
            throw Exception(
              'Pacote "$package" só pode ser acessado por ${allowedPackages.join(", ")}, mas foi acessado por "$importingPackage" (Arquivo: $path)',
            );
          }
        }
      }
    }
  }

  String? _getPackageFromPath(String path, String rootDir) {
    final relativePath = p.relative(path, from: rootDir);
    final parts = p.split(relativePath);
    if (parts.isEmpty) return null;
    return parts.first;
  }

  Future<String> _getProjectName(String rootDir) async {
    try {
      final pubspecFile = File(p.join(rootDir, '../pubspec.yaml'));
      if (!pubspecFile.existsSync()) return '';
      final content = await pubspecFile.readAsString();
      final yaml = loadYaml(content) as Map;
      return yaml['name'] as String? ?? '';
    } catch (e) {
      print('Erro ao ler pubspec.yaml: $e');
      return '';
    }
  }
}
