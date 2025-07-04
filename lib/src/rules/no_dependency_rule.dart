import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class NoDependencyRule extends Rule {
  final String sourcePackage;
  final String targetPackage;

  NoDependencyRule(this.sourcePackage, this.targetPackage);

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      // Verifica apenas arquivos do pacote fonte
      if (!path.contains(p.join(rootDir, sourcePackage))) continue;

      final violations = <String>[];
      final imports = unit.directives.whereType<ImportDirective>();

      for (final import in imports) {
        final importUri = import.uri.stringValue ?? '';

        // Verifica se a importação contém o pacote alvo
        if (importUri.contains(targetPackage)) {
          violations.add(importUri);
        }
      }

      if (violations.isNotEmpty) {
        throw Exception(
          'Violação de dependência encontrada no arquivo: $path\n'
          'O pacote "$sourcePackage" não pode depender de "$targetPackage"\n'
          'Importações proibidas:\n${violations.map((uri) => '  - $uri').join('\n')}',
        );
      }
    }
  }
}
