import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

import 'visibility_rule.dart';

class FieldRule extends Rule {
  final String package;
  final bool shouldBeFinal;
  final String? expectedType;
  final Visibility? visibility;

  FieldRule(this.package,
      {this.shouldBeFinal = true, this.expectedType, this.visibility});

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
          final fields =
              declaration.members.whereType<FieldDeclaration>().toList();

          if (fields.isEmpty) {
            continue; // Optionally, throw an error if fields are required
          }

          for (final field in fields) {
            final fieldNames =
                field.fields.variables.map((v) => v.name.lexeme).join(', ');
            final isFinal =
                field.fields.isFinal; // Corrected: Use field.fields.isFinal
            final fieldType = field.fields.type?.toSource();
            final isPrivate = field.fields.variables
                .any((v) => v.name.lexeme.startsWith('_'));

            // Check final constraint
            if (shouldBeFinal && !isFinal) {
              throw Exception(
                'Campo(s) "$fieldNames" na classe "$className" deve(m) ser final (Arquivo: $path)',
              );
            } else if (!shouldBeFinal && isFinal) {
              throw Exception(
                'Campo(s) "$fieldNames" na classe "$className" não deve(m) ser final (Arquivo: $path)',
              );
            }

            // Check type constraint
            if (expectedType != null && fieldType != expectedType) {
              throw Exception(
                'Campo(s) "$fieldNames" na classe "$className" deve(m) ser do tipo "$expectedType", mas é(são) "$fieldType" (Arquivo: $path)',
              );
            }

            // Check visibility constraint
            if (visibility != null) {
              final isFieldPrivate = isPrivate;
              if (visibility == Visibility.public && isFieldPrivate) {
                throw Exception(
                  'Campo(s) "$fieldNames" na classe "$className" deve(m) ser público(s) (Arquivo: $path)',
                );
              } else if (visibility == Visibility.private && !isFieldPrivate) {
                throw Exception(
                  'Campo(s) "$fieldNames" na classe "$className" deve(m) ser privado(s) (Arquivo: $path)',
                );
              }
            }
          }
        }
      }
    }
  }
}
