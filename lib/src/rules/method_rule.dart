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
  final String? requiredAnnotation;
  final bool isFunction;

  MethodRule(
    this.package,
    this.ruleType, {
    this.checkAll = false,
    this.expectedType,
    this.expectedParameters,
    this.isPrivate,
    this.expectedMethodName,
    this.requiredAnnotation,
    this.isFunction = false,
  });

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(p.join(rootDir, package))) continue;

      if (isFunction) {
        final functions =
            unit.declarations.whereType<FunctionDeclaration>().toList();
        if (functions.isEmpty) {
          throw Exception('Nenhuma função top-level encontrada em "$path"');
        }

        if (checkAll) {
          _validateAllFunctions(functions, path);
        } else {
          _validateAtLeastOneFunction(functions, path);
        }
      } else {
        for (final declaration in unit.declarations) {
          if (declaration is ClassDeclaration) {
            final className = declaration.name.lexeme;
            final methods =
                declaration.members.whereType<MethodDeclaration>().toList();

            if (methods.isEmpty) {
              throw Exception(
                  'A classe "$className" não possui métodos (Arquivo: $path)');
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
  }

  void _validateAllFunctions(List<FunctionDeclaration> functions, String path) {
    final invalidFunctions = <String>[];

    for (final function in functions) {
      if (!_isFunctionValid(function, functions)) {
        invalidFunctions.add(_getErrorMessageForFunction(function));
      }
    }

    if (invalidFunctions.isNotEmpty) {
      throw Exception(
        'As seguintes funções têm problemas:\n${invalidFunctions.join("\n")}\n(Arquivo: $path)',
      );
    }
  }

  void _validateAtLeastOneFunction(
      List<FunctionDeclaration> functions, String path) {
    for (final function in functions) {
      if (_isFunctionValid(function, functions)) {
        return; // Found at least one valid function
      }
    }

    throw Exception(
      'Deve haver pelo menos uma função que atenda aos critérios:\n${_getCriteriaDescription()}\n(Arquivo: $path)',
    );
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
        'A classe "$className" tem os seguintes problemas:\n${invalidMethods.join("\n")}\n(Arquivo: $path)',
      );
    }
  }

  void _validateAtLeastOneMethod(
      String className, List<MethodDeclaration> methods, String path) {
    for (final method in methods) {
      if (_isMethodValid(method, methods)) {
        return; // Found at least one valid method
      }
    }

    throw Exception(
      'A classe "$className" deve ter pelo menos um método que atenda aos critérios:\n${_getCriteriaDescription()}\n(Arquivo: $path)',
    );
  }

  bool _isFunctionValid(
      FunctionDeclaration function, List<FunctionDeclaration> allFunctions) {
    switch (ruleType) {
      case MethodRuleType.async:
        return function.functionExpression.body.isAsynchronous;
      case MethodRuleType.sync:
        return !function.functionExpression.body.isAsynchronous;
      case MethodRuleType.name:
        return expectedMethodName != null &&
            function.name.lexeme == expectedMethodName;
      case MethodRuleType.annotation:
        return requiredAnnotation != null &&
            function.metadata.any(
              (m) =>
                  m.name.name == requiredAnnotation ||
                  m.name.name == '@$requiredAnnotation',
            );
      case MethodRuleType.returnType:
        return expectedType != null &&
            (function.returnType?.toString() ?? '') == expectedType;
      case MethodRuleType.visibility:
        final isFunctionPrivate = function.name.lexeme.startsWith('_');
        return isPrivate != null && isFunctionPrivate == isPrivate;
      case MethodRuleType.parameters:
        final parameters = function.functionExpression.parameters?.parameters
            .map((p) => p.toString())
            .toList();
        return expectedParameters != null &&
            listEquals(parameters, expectedParameters);
    }
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
      case MethodRuleType.annotation:
        return requiredAnnotation != null &&
            method.metadata.any(
              (m) =>
                  m.name.name == requiredAnnotation ||
                  m.name.name == '@$requiredAnnotation',
            );
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

  String _getErrorMessageForFunction(FunctionDeclaration function) {
    switch (ruleType) {
      case MethodRuleType.async:
        return 'Função "${function.name}" deve ser assíncrona';
      case MethodRuleType.sync:
        return 'Função "${function.name}" deve ser síncrona';
      case MethodRuleType.name:
        return 'Deve haver uma função chamada "$expectedMethodName"';
      case MethodRuleType.annotation:
        return 'Função "${function.name}" deve ter a anotação @$requiredAnnotation';
      case MethodRuleType.returnType:
        return 'Função "${function.name}" deve retornar $expectedType';
      case MethodRuleType.visibility:
        return 'Função "${function.name}" deve ser ${isPrivate! ? "privada" : "pública"}';
      case MethodRuleType.parameters:
        return 'Função "${function.name}" deve ter os parâmetros: ${expectedParameters?.join(", ")}';
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
      case MethodRuleType.annotation:
        return 'Método "${method.name}" deve ter a anotação @$requiredAnnotation';
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
      case MethodRuleType.annotation:
        return 'tenha a anotação @$requiredAnnotation';
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
