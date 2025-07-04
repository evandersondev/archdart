import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class LineCountRule extends Rule {
  final String package;
  final int minLineCount;

  LineCountRule(this.package, this.minLineCount);

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(p.join(rootDir, package))) continue;

      // Get line information for the compilation unit
      final lineInfo = unit.lineInfo;

      for (final declaration in unit.declarations) {
        if (declaration is ClassDeclaration) {
          final name = declaration.name.lexeme;
          // Calculate number of lines using LineInfo
          final startLine =
              lineInfo.getLocation(declaration.beginToken.offset).lineNumber;
          final endLine =
              lineInfo.getLocation(declaration.endToken.offset).lineNumber;
          final lineCount = endLine - startLine + 1;

          if (lineCount <= minLineCount) {
            throw Exception(
              'Classe "$name" em "$package" deve ter mais de $minLineCount linhas, mas tem $lineCount (Arquivo: $path)',
            );
          }
        }
      }
    }
  }
}
