import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class NamingRule extends Rule {
  final String package;
  final String suffix;
  final bool isEnum;
  final bool checkContains;

  NamingRule(this.package, this.suffix,
      {this.isEnum = false, this.checkContains = false});

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(p.join(rootDir, package))) continue;

      for (final declaration in unit.declarations) {
        if (isEnum && declaration is! EnumDeclaration) continue;
        if (!isEnum && declaration is! ClassDeclaration) continue;

        final name = declaration is ClassDeclaration
            ? declaration.name.lexeme
            : (declaration as EnumDeclaration).name.lexeme;

        if (checkContains) {
          if (!name.contains(suffix)) {
            throw Exception(
              '${isEnum ? "Enum" : "Classe"} "$name" em "$package" deve conter "$suffix" no nome (Arquivo: $path)',
            );
          }
        } else {
          if (!name.endsWith(suffix)) {
            throw Exception(
              '${isEnum ? "Enum" : "Classe"} "$name" em "$package" deve terminar com "$suffix" (Arquivo: $path)',
            );
          }
        }
      }
    }
  }
}
