import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

enum Visibility { public, private, abstract, sealed, base, mixin, record }

class VisibilityRule extends Rule {
  final String package;
  final Visibility visibility;
  final bool isConstructor;
  final bool isFunction;
  final bool negate;

  VisibilityRule(this.package, this.visibility,
      {this.isConstructor = false,
      this.isFunction = false,
      this.negate = false});

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(p.join(rootDir, package))) continue;

      for (final declaration in unit.declarations) {
        if (isConstructor && declaration is ClassDeclaration) {
          final className = declaration.name.lexeme;
          final constructors =
              declaration.members.whereType<ConstructorDeclaration>().toList();
          for (final constructor in constructors) {
            final isPrivate = constructor.name?.lexeme.startsWith('_') ?? false;
            if (visibility == Visibility.private && negate
                ? isPrivate
                : !isPrivate) {
              throw Exception(
                'Construtor em "$className" deve ${negate ? "não " : ""}ser privado (Arquivo: $path)',
              );
            }
          }
        } else if (isFunction && declaration is FunctionDeclaration) {
          final name = declaration.name.lexeme;
          final isPrivate = name.startsWith('_');
          if (visibility == Visibility.public && negate
              ? isPrivate
              : !isPrivate) {
            throw Exception(
              'Função "$name" deve ${negate ? "não " : ""}ser pública (Arquivo: $path)',
            );
          } else if (visibility == Visibility.private && negate
              ? !isPrivate
              : isPrivate) {
            throw Exception(
              'Função "$name" deve ${negate ? "não " : ""}ser privada (Arquivo: $path)',
            );
          }
        } else if (declaration is ClassDeclaration) {
          final name = declaration.name.lexeme;
          final isPrivate = name.startsWith('_');
          final isAbstract = declaration.abstractKeyword != null;
          final isSealed =
              declaration.metadata.any((m) => m.name.name == 'sealed');
          final isBase = declaration.metadata.any((m) => m.name.name == 'base');
          final isMixin =
              declaration.metadata.any((m) => m.name.name == 'mixin');
          final isRecord =
              declaration.metadata.any((m) => m.name.name == 'record');

          switch (visibility) {
            case Visibility.public:
              if (negate ? isPrivate : !isPrivate) break;
              throw Exception(
                  'Classe "$name" deve ${negate ? "não " : ""}ser pública (Arquivo: $path)');
            case Visibility.private:
              if (negate ? !isPrivate : isPrivate) break;
              throw Exception(
                  'Classe "$name" deve ${negate ? "não " : ""}ser privada (Arquivo: $path)');
            case Visibility.abstract:
              if (negate ? !isAbstract : isAbstract) break;
              throw Exception(
                  'Classe "$name" deve ${negate ? "não " : ""}ser abstrata (Arquivo: $path)');
            case Visibility.sealed:
              if (negate ? !isSealed : isSealed) break;
              throw Exception(
                  'Classe "$name" deve ${negate ? "não " : ""}ser selada (Arquivo: $path)');
            case Visibility.base:
              if (negate ? !isBase : isBase) break;
              throw Exception(
                  'Classe "$name" deve ${negate ? "não " : ""}ser base (Arquivo: $path)');
            case Visibility.mixin:
              if (negate ? !isMixin : isMixin) break;
              throw Exception(
                  'Classe "$name" deve ${negate ? "não " : ""}ser mixin (Arquivo: $path)');
            case Visibility.record:
              if (negate ? !isRecord : isRecord) break;
              throw Exception(
                  'Classe "$name" deve ${negate ? "não " : ""}ser record (Arquivo: $path)');
          }
        }
      }
    }
  }
}
