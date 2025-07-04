import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

enum Visibility { public, private }

class VisibilityRule extends Rule {
  final String package;
  final Visibility visibility;

  VisibilityRule(this.package, this.visibility);

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(p.join(rootDir, package))) continue;

      for (final declaration in unit.declarations) {
        if (declaration is ClassDeclaration) {
          final name = declaration.name.lexeme;
          final isPrivate = name.startsWith('_');

          if (visibility == Visibility.public && isPrivate) {
            throw Exception('Classe "$name" deve ser pública');
          } else if (visibility == Visibility.private && !isPrivate) {
            throw Exception('Classe "$name" deve ser privada');
          }
        }
      }
    }
  }
}
