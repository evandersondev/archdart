import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class ExtendRule extends Rule {
  final String package;
  final String parentClass;

  ExtendRule(this.package, this.parentClass);

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(p.join(rootDir, package))) continue;

      for (final declaration in unit.declarations) {
        if (declaration is ClassDeclaration) {
          final extendsClause = declaration.extendsClause;
          if (extendsClause == null ||
              extendsClause.superclass.toString() != parentClass) {
            throw Exception(
              'Classe "${declaration.name}" deve herdar de $parentClass (Arquivo: $path)',
            );
          }
        }
      }
    }
  }
}
