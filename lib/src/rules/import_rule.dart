import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class ImportRule extends Rule {
  final String package;
  final List<String> forbiddenImports;

  ImportRule(this.package, this.forbiddenImports);

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(p.join(rootDir, package))) continue;

      final imports = unit.directives.whereType<ImportDirective>();

      for (final import in imports) {
        final importUri = import.uri.stringValue ?? '';

        for (final forbiddenImport in forbiddenImports) {
          if (importUri.contains(forbiddenImport)) {
            throw Exception(
              'O arquivo em "$path" não pode importar "$forbiddenImport"\n'
              'Importação encontrada: $importUri',
            );
          }
        }
      }
    }
  }
}
