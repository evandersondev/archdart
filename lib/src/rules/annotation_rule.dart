import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class AnnotationRule extends Rule {
  final String package;
  final String requiredAnnotation;

  AnnotationRule(this.package, this.requiredAnnotation);

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(p.join(rootDir, package))) continue;

      for (final declaration in unit.declarations) {
        if (declaration is ClassDeclaration) {
          final annotations = declaration.metadata;
          final hasAnnotation = annotations.any(
            (m) =>
                m.name.name == requiredAnnotation ||
                m.name.name == '@$requiredAnnotation',
          );

          if (!hasAnnotation) {
            throw Exception(
              'Classe "${declaration.name}" deveria ter a anotação @$requiredAnnotation (Arquivo: $path)',
            );
          }
        }
      }
    }
  }
}
