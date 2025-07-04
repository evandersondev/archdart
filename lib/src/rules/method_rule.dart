import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import 'method_rule_type.dart';

class MethodRule extends Rule {
  final String package;
  final MethodRuleType ruleType;
  final String? expectedType;
  final List<String>? expectedParameters;
  final bool? isPrivate;
  final String? expectedMethodName;
  final bool checkAll;

  MethodRule(
    this.package,
    this.ruleType, {
    this.checkAll = false,
    this.expectedType,
    this.expectedParameters,
    this.isPrivate,
    this.expectedMethodName,
  });

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
            throw Exception(
              'A classe "$className" não possui métodos '
              '(Arquivo: $path)',
            );
          }

          if (checkAll) {
            _validateAllMethods(className, methods, path);
          } else {
            _validateAtLeastOneMethod(className, methods, path);
          }
        }
      }
    }
  }

  void _validateAllMethods(
      String className, List<MethodDeclaration> methods, String path) {
    final invalidMethods = <String>[];

    for (final method in methods) {
      if (!_isMethodValid(method, methods)) {
        invalidMethods.add(_getErrorMessage(method));
      }
    }

    if (invalidMethods.isNotEmpty) {
      throw Exception(
        'A classe "$className" tem os seguintes problemas:\n'
        '${invalidMethods.join("\n")}\n'
        '(Arquivo: $path)',
      );
    }
  }

  void _validateAtLeastOneMethod(
      String className, List<MethodDeclaration> methods, String path) {
    for (final method in methods) {
      if (_isMethodValid(method, methods)) {
        return; // Encontrou pelo menos um método válido
      }
    }

    throw Exception(
      'A classe "$className" deve ter pelo menos um método que atenda aos critérios:\n'
      '${_getCriteriaDescription()}\n'
      '(Arquivo: $path)',
    );
  }

  bool _isMethodValid(
      MethodDeclaration method, List<MethodDeclaration> allMethods) {
    switch (ruleType) {
      case MethodRuleType.async:
        return method.body.isAsynchronous;

      case MethodRuleType.sync:
        return !method.body.isAsynchronous;

      case MethodRuleType.name:
        return expectedMethodName != null &&
            allMethods.any((m) => m.name.lexeme == expectedMethodName);

      case MethodRuleType.returnType:
        return expectedType != null &&
            (method.returnType?.toString() ?? '') == expectedType;

      case MethodRuleType.visibility:
        final isMethodPrivate = method.name.lexeme.startsWith('_');
        return isPrivate != null && isMethodPrivate == isPrivate;

      case MethodRuleType.parameters:
        final parameters =
            method.parameters?.parameters.map((p) => p.toString()).toList();
        return expectedParameters != null &&
            listEquals(parameters, expectedParameters);
    }
  }

  String _getErrorMessage(MethodDeclaration method) {
    switch (ruleType) {
      case MethodRuleType.async:
        return 'Método "${method.name}" deve ser assíncrono';
      case MethodRuleType.sync:
        return 'Método "${method.name}" deve ser síncrono';
      case MethodRuleType.name:
        return 'Classe deve ter um método chamado "$expectedMethodName"';
      case MethodRuleType.returnType:
        return 'Método "${method.name}" deve retornar $expectedType';
      case MethodRuleType.visibility:
        return 'Método "${method.name}" deve ser ${isPrivate! ? "privado" : "público"}';
      case MethodRuleType.parameters:
        return 'Método "${method.name}" deve ter os parâmetros: ${expectedParameters?.join(", ")}';
    }
  }

  String _getCriteriaDescription() {
    switch (ruleType) {
      case MethodRuleType.async:
        return 'seja assíncrono';
      case MethodRuleType.sync:
        return 'seja síncrono';
      case MethodRuleType.name:
        return 'tenha o nome "$expectedMethodName"';
      case MethodRuleType.returnType:
        return 'retorne $expectedType';
      case MethodRuleType.visibility:
        return 'seja ${isPrivate! ? "privado" : "público"}';
      case MethodRuleType.parameters:
        return 'tenha os parâmetros: ${expectedParameters?.join(", ")}';
    }
  }

  bool listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
