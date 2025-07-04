import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class ExtendRule extends Rule {
  final String package;
  final String parentClass;
  final List<String>? allowedClasses;

  ExtendRule(this.package, this.parentClass, {this.allowedClasses});

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
          final superClass = extendsClause?.superclass.toString();
          if (allowedClasses != null) {
            if (superClass == null || !allowedClasses!.contains(superClass)) {
              throw Exception(
                'Classe "${declaration.name}" deve herdar de uma das classes: ${allowedClasses!.join(", ")} (Arquivo: $path)',
              );
            }
          } else if (extendsClause == null || superClass != parentClass) {
            throw Exception(
              'Classe "${declaration.name}" deve herdar de $parentClass (Arquivo: $path)',
            );
          }
        }
      }
    }
  }
}
