import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class ConstructorParameterRule extends Rule {
  final String package;
  final bool allRequired;
  final bool onlyNamedRequired;

  ConstructorParameterRule(this.package,
      {this.allRequired = false, this.onlyNamedRequired = false});

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
          final constructors =
              declaration.members.whereType<ConstructorDeclaration>().toList();

          if (constructors.isEmpty) {
            throw Exception(
                'Classe "$className" não possui construtores (Arquivo: $path)');
          }

          for (final constructor in constructors) {
            final parameters = constructor.parameters.parameters ?? [];

            if (allRequired) {
              final hasOptional = parameters.any((p) =>
                  p.isOptional || p.isOptionalNamed || p.isOptionalPositional);
              if (hasOptional) {
                throw Exception(
                  'Construtor em "$className" deve ter todos os parâmetros obrigatórios (Arquivo: $path)',
                );
              }
            }

            if (onlyNamedRequired) {
              final hasNonNamedRequired = parameters
                  .any((p) => !p.isNamed || (p.isNamed && p.isOptional));
              if (hasNonNamedRequired) {
                throw Exception(
                  'Construtor em "$className" deve ter apenas parâmetros nomeados obrigatórios (Arquivo: $path)',
                );
              }
            }
          }
        }
      }
    }
  }
}
