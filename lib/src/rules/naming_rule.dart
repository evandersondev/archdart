import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class NamingRule extends Rule {
  final String package;
  final String suffix;

  NamingRule(this.package, this.suffix);

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);

    for (final entry in unitsWithPath.entries) {
      final path = entry.key;
      final unit = entry.value;

      if (!p.split(path).contains(package)) continue;

      for (final declaration in unit.declarations) {
        if (declaration is ClassDeclaration) {
          final name = declaration.name.lexeme;
          if (!name.endsWith(suffix)) {
            throw Exception(
              'Classe "$name" em "$package" deve terminar com "$suffix" (Arquivo: $path)',
            );
          }
        }
      }
    }
  }
}
