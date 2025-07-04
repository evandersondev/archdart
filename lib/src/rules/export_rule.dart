import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class ExportRule extends Rule {
  final String package;
  final String forbiddenFile;

  ExportRule(this.package, this.forbiddenFile);

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);
    final forbiddenPath = p.join(rootDir, forbiddenFile);

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(p.join(rootDir, package))) continue;

      final exports = unit.directives.whereType<ExportDirective>();
      for (final export in exports) {
        final exportUri = export.uri.stringValue ?? '';
        if (p.normalize(p.join(rootDir, exportUri)) == forbiddenPath) {
          throw Exception(
              'Arquivo "$path" não pode ser exportado em "$forbiddenFile"');
        }
      }
    }
  }
}
