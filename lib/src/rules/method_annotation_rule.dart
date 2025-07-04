import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class MethodAnnotationRule extends Rule {
  final String package;
  final String requiredAnnotation;
  final bool checkAll;

  MethodAnnotationRule(this.package, this.requiredAnnotation,
      {this.checkAll = false});

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(p.join(rootDir, package))) continue;

      for (final declaration in unit.declarations) {
        if (declaration is ClassDeclaration) {
          final className = declaration.name.lexeme;
          final methods =
              declaration.members.whereType<MethodDeclaration>().toList();

          if (methods.isEmpty) {
            continue; // Optionally, throw an error if methods are required
          }

          final invalidMethods = <String>[];

          for (final method in methods) {
            final hasAnnotation = method.metadata.any(
              (m) =>
                  m.name.name == requiredAnnotation ||
                  m.name.name == '@$requiredAnnotation',
            );

            if (checkAll && !hasAnnotation) {
              invalidMethods.add(method.name.lexeme);
            } else if (!checkAll && !hasAnnotation) {
              // If not checking all, one valid method is enough
              continue;
            } else if (!checkAll && hasAnnotation) {
              break; // Found a valid method, no need to check further
            }
          }

          if (checkAll && invalidMethods.isNotEmpty) {
            throw Exception(
              'Os seguintes métodos na classe "$className" devem ter a anotação @$requiredAnnotation:\n'
              '${invalidMethods.join(", ")} (Arquivo: $path)',
            );
          } else if (!checkAll && invalidMethods.length == methods.length) {
            throw Exception(
              'A classe "$className" deve ter pelo menos um método com a anotação @$requiredAnnotation (Arquivo: $path)',
            );
          }
        }
      }
    }
  }
}
