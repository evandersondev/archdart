import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class ImplementRule extends Rule {
  final String package;
  final String interfaceName;

  ImplementRule(this.package, this.interfaceName);

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(p.join(rootDir, package))) continue;

      for (final declaration in unit.declarations) {
        if (declaration is ClassDeclaration) {
          final implements = declaration.implementsClause?.interfaces ?? [];
          final hasInterface = implements.any(
            (type) => type.name.name == interfaceName,
          );

          if (!hasInterface) {
            throw Exception(
              'Classe "${declaration.name}" deve implementar $interfaceName (Arquivo: $path)',
            );
          }
        }
      }
    }
  }
}
