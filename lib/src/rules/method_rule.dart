import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';
import 'method_rule_type.dart';

class MethodRule extends ArchRule {
  final String package;
  final MethodRuleType ruleType;
  final String? expectedType;
  final String? expectedMethodName;
  final List<String>? expectedParameters;
  final String? requiredAnnotation;
  final bool? isPrivate;
  final bool checkAll;
  final bool isFunction;
  final bool negate;

  MethodRule(
    this.package,
    this.ruleType, {
    this.expectedType,
    this.expectedMethodName,
    this.expectedParameters,
    this.requiredAnnotation,
    this.isPrivate,
    this.checkAll = false,
    this.isFunction = false,
    this.negate = false,
  });

  @override
  Future<void> check() async {
    final unitsWithPath = await parseDirectoryWithPaths('.');
    final violations = <String>[];

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(package)) continue;

      for (final declaration in unit.declarations) {
        if (isFunction && declaration is FunctionDeclaration) {
          _checkFunction(declaration, path, violations);
        } else if (declaration is ClassDeclaration) {
          _checkClassMethods(declaration, path, violations);
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(RuleMessages.violationFound('Method', violations));
    }
  }

  void _checkFunction(
      FunctionDeclaration function, String path, List<String> violations) {
    final functionName = function.name.lexeme;
    final hasExpectedBehavior = _checkFunctionRule(function);

    if (negate) {
      if (hasExpectedBehavior) {
        violations.add(
            'Function "$functionName" should NOT ${_getRuleDescription()} (file: $path)');
      }
    } else {
      if (!hasExpectedBehavior) {
        violations.add(
            'Function "$functionName" should ${_getRuleDescription()} (file: $path)');
      }
    }
  }

  void _checkClassMethods(
      ClassDeclaration classDeclaration, String path, List<String> violations) {
    final className = classDeclaration.name.lexeme;
    final methods = classDeclaration.members.whereType<MethodDeclaration>();

    for (final method in methods) {
      final methodName = method.name.lexeme;
      final hasExpectedBehavior = _checkMethodRule(method);

      if (negate) {
        if (hasExpectedBehavior) {
          violations.add(
              'Method "$methodName" in class "$className" should NOT ${_getRuleDescription()} (file: $path)');
        }
      } else {
        if (!hasExpectedBehavior) {
          violations.add(
              'Method "$methodName" in class "$className" should ${_getRuleDescription()} (file: $path)');
        }
      }
    }
  }

  bool _checkFunctionRule(FunctionDeclaration function) {
    switch (ruleType) {
      case MethodRuleType.async:
        return function.functionExpression.body is BlockFunctionBody &&
            (function.functionExpression.body as BlockFunctionBody)
                    .keyword
                    ?.lexeme ==
                'async';
      case MethodRuleType.sync:
        return function.functionExpression.body is BlockFunctionBody &&
            (function.functionExpression.body as BlockFunctionBody)
                    .keyword
                    ?.lexeme !=
                'async';
      case MethodRuleType.returnType:
        return function.returnType?.toString() == expectedType;
      case MethodRuleType.parameters:
        final params = function.functionExpression.parameters?.parameters;
        return _checkFunctionParameters(params);
      case MethodRuleType.name:
        return function.name.lexeme == expectedMethodName;
      case MethodRuleType.annotation:
        return _hasAnnotation(function.metadata);
      case MethodRuleType.visibility:
        final isPrivateFunction = function.name.lexeme.startsWith('_');
        return isPrivate == true ? isPrivateFunction : !isPrivateFunction;
    }
  }

  bool _checkMethodRule(MethodDeclaration method) {
    switch (ruleType) {
      case MethodRuleType.async:
        return method.body is BlockFunctionBody &&
            (method.body as BlockFunctionBody).keyword?.lexeme == 'async';
      case MethodRuleType.sync:
        return method.body is BlockFunctionBody &&
            (method.body as BlockFunctionBody).keyword?.lexeme != 'async';
      case MethodRuleType.returnType:
        return method.returnType?.toString() == expectedType;
      case MethodRuleType.parameters:
        final params = method.parameters?.parameters;
        return _checkMethodParameters(params);
      case MethodRuleType.name:
        return method.name.lexeme == expectedMethodName;
      case MethodRuleType.annotation:
        return _hasAnnotation(method.metadata);
      case MethodRuleType.visibility:
        final isPrivateMethod = method.name.lexeme.startsWith('_');
        return isPrivate == true ? isPrivateMethod : !isPrivateMethod;
    }
  }

  bool _checkFunctionParameters(List<FormalParameter>? params) {
    if (expectedParameters == null) return true;

    final paramList = params ?? [];

    if (paramList.length != expectedParameters!.length) return false;

    for (int i = 0; i < paramList.length; i++) {
      final param = paramList[i];
      final expectedParam = expectedParameters![i];

      // Verificar tipo do parâmetro
      if (param is SimpleFormalParameter) {
        if (param.type?.toString() != expectedParam) return false;
      } else if (param is DefaultFormalParameter) {
        final innerParam = param.parameter;
        if (innerParam is SimpleFormalParameter) {
          if (innerParam.type?.toString() != expectedParam) return false;
        }
      }
    }

    return true;
  }

  bool _checkMethodParameters(List<FormalParameter>? params) {
    if (expectedParameters == null) return true;

    final paramList = params ?? [];

    if (paramList.length != expectedParameters!.length) return false;

    for (int i = 0; i < paramList.length; i++) {
      final param = paramList[i];
      final expectedParam = expectedParameters![i];

      // Verificar tipo do parâmetro
      if (param is SimpleFormalParameter) {
        if (param.type?.toString() != expectedParam) return false;
      } else if (param is DefaultFormalParameter) {
        final innerParam = param.parameter;
        if (innerParam is SimpleFormalParameter) {
          if (innerParam.type?.toString() != expectedParam) return false;
        }
      }
    }

    return true;
  }

  bool _hasAnnotation(List<Annotation> annotations) {
    if (requiredAnnotation == null) return true;

    return annotations
        .any((annotation) => annotation.name.toString() == requiredAnnotation);
  }

  String _getRuleDescription() {
    switch (ruleType) {
      case MethodRuleType.async:
        return 'be async';
      case MethodRuleType.sync:
        return 'be sync';
      case MethodRuleType.returnType:
        return 'return type $expectedType';
      case MethodRuleType.parameters:
        return 'have parameters: ${expectedParameters?.join(', ') ?? 'none'}';
      case MethodRuleType.name:
        return 'be named $expectedMethodName';
      case MethodRuleType.annotation:
        return 'have annotation @$requiredAnnotation';
      case MethodRuleType.visibility:
        return isPrivate == true ? 'be private' : 'be public';
    }
  }
}
