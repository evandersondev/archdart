import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class EnumValueRule extends Rule {
  final String package;
  final int minValueCount;

  EnumValueRule(this.package, this.minValueCount);

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(p.join(rootDir, package))) continue;

      for (final declaration in unit.declarations) {
        if (declaration is EnumDeclaration) {
          final name = declaration.name.lexeme;
          final values = declaration.constants.length;

          if (values <= minValueCount) {
            throw Exception(
              'Enum "$name" em "$package" deve ter mais de $minValueCount valores, mas tem $values (Arquivo: $path)',
            );
          }
        }
      }
    }
  }
}
