import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class CyclicDependencyRule extends Rule {
  final List<String> packages;

  CyclicDependencyRule(this.packages);

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);
    final dependencies = <String, Set<String>>{};

    // Build dependency graph
    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      final sourcePackage = _getPackageFromPath(path, rootDir);
      if (sourcePackage == null || !packages.contains(sourcePackage)) continue;

      final imports = unit.directives.whereType<ImportDirective>();
      final targetPackages = <String>{};

      for (final import in imports) {
        final importUri = import.uri.stringValue ?? '';
        if (!importUri.startsWith('package:')) continue;

        final targetPackage = _getPackageFromImport(importUri, rootDir);
        if (targetPackage != null && packages.contains(targetPackage)) {
          targetPackages.add(targetPackage);
        }
      }

      dependencies[sourcePackage] = targetPackages;
    }

    // Detect cycles using DFS
    final visited = <String>{};
    final stack = <String>{};
    final cycles = <List<String>>[];

    for (final package in packages) {
      if (!visited.contains(package)) {
        _detectCycles(package, dependencies, visited, stack, [], cycles);
      }
    }

    if (cycles.isNotEmpty) {
      final buffer = StringBuffer();
      buffer.writeln('Ciclos de dependência detectados:');
      for (final cycle in cycles) {
        buffer.writeln('  - ${cycle.join(" -> ")}');
      }
      throw Exception(buffer.toString());
    }
  }

  String? _getPackageFromPath(String path, String rootDir) {
    final relativePath = p.relative(path, from: rootDir);
    final parts = p.split(relativePath);
    if (parts.isEmpty) return null;
    return parts.first;
  }

  String? _getPackageFromImport(String importUri, String rootDir) {
    final match = RegExp(r'package:([^/]+)/').firstMatch(importUri);
    return match?.group(1);
  }

  void _detectCycles(
    String current,
    Map<String, Set<String>> dependencies,
    Set<String> visited,
    Set<String> stack,
    List<String> currentPath,
    List<List<String>> cycles,
  ) {
    visited.add(current);
    stack.add(current);
    currentPath.add(current);

    final neighbors = dependencies[current] ?? {};
    for (final neighbor in neighbors) {
      if (!visited.contains(neighbor)) {
        _detectCycles(
            neighbor, dependencies, visited, stack, currentPath, cycles);
      } else if (stack.contains(neighbor)) {
        final cycleStart = currentPath.indexOf(neighbor);
        final cycle = currentPath.sublist(cycleStart)..add(neighbor);
        cycles.add(cycle);
      }
    }

    stack.remove(current);
    currentPath.removeLast();
  }
}
