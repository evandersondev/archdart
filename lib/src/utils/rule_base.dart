import '../rules/annotation_rule.dart';
import '../rules/extend_rule.dart';
import '../rules/field_rule.dart';
import '../rules/implement_interface_ending_rule.dart';
import '../rules/implement_rule.dart';
import '../rules/import_rule.dart';
import '../rules/naming_rule.dart';
import '../rules/no_dependency_any_rule.dart';
import '../rules/no_dependency_rule.dart';
import '../rules/only_dependency_rule.dart';
import '../rules/visibility_rule.dart';

// Atualizar o enum Visibility para evitar palavras reservadas
enum Visibility {
  public,
  private,
  abstract,
  finalClass, // Mudança: final -> finalClass
  sealed,
  base,
  mixin,
  enumClass, // Mudança: enum -> enumClass
  record,
  interface,
  abstractInterface, // Para abstract interface
}

abstract class ArchRule {
  List<String> excludedFiles = [];
  List<String> excludedClasses = [];

  Future<void> check();

  void excludeFiles(List<String> files) {
    excludedFiles.addAll(files);
  }

  void excludeClasses(List<String> classes) {
    excludedClasses.addAll(classes);
  }

  bool isExcluded(String path, String? className) {
    if (excludedFiles.any((f) => path.contains(f))) return true;
    if (className != null && excludedClasses.contains(className)) return true;
    return false;
  }

  // Método para encadear regras
  ChainedRule andAlso() {
    return ChainedRule([this]);
  }

  // Método para criar regras combinadas com OR
  ChainedRule orElse() {
    return ChainedRule([this], useOr: true);
  }
}

class ChainedRule extends ArchRule {
  final List<ArchRule> rules;
  final bool useOr;

  ChainedRule(this.rules, {this.useOr = false});

  // Adiciona uma nova regra à cadeia
  ChainedRule _addRule(ArchRule rule) {
    return ChainedRule([...rules, rule], useOr: useOr);
  }

  // Métodos de encadeamento - retornam RuleBuilder para continuar a cadeia
  RuleBuilder shouldBe(Visibility visibility) {
    return RuleBuilder(this, 'shouldBe', [visibility]);
  }

  RuleBuilder shouldHaveNameEndingWith(String suffix) {
    return RuleBuilder(this, 'shouldHaveNameEndingWith', [suffix]);
  }

  RuleBuilder shouldBeAnnotatedWith(String annotation) {
    return RuleBuilder(this, 'shouldBeAnnotatedWith', [annotation]);
  }

  RuleBuilder shouldImplement(String interfaceName) {
    return RuleBuilder(this, 'shouldImplement', [interfaceName]);
  }

  RuleBuilder shouldImplementInterfaceThatEndsWith(String suffix) {
    return RuleBuilder(this, 'shouldImplementInterfaceThatEndsWith', [suffix]);
  }

  RuleBuilder shouldNotDependOnAny(List<String> packages) {
    return RuleBuilder(this, 'shouldNotDependOnAny', [packages]);
  }

  RuleBuilder shouldExtend(String className) {
    return RuleBuilder(this, 'shouldExtend', [className]);
  }

  RuleBuilder shouldNotDependOn(String targetPackage) {
    return RuleBuilder(this, 'shouldNotDependOn', [targetPackage]);
  }

  RuleBuilder shouldOnlyDependOn(List<String> packages) {
    return RuleBuilder(this, 'shouldOnlyDependOn', [packages]);
  }

  RuleBuilder shouldHaveFinalFields() {
    return RuleBuilder(this, 'shouldHaveFinalFields', []);
  }

  RuleBuilder shouldHaveNonFinalFields() {
    return RuleBuilder(this, 'shouldHaveNonFinalFields', []);
  }

  RuleBuilder shouldNotHaveImports(List<String> imports) {
    return RuleBuilder(this, 'shouldNotHaveImports', [imports]);
  }

  @override
  Future<void> check() async {
    if (useOr) {
      // Lógica OR: pelo menos uma regra deve passar
      final errors = <String>[];
      for (final rule in rules) {
        try {
          await rule.check();
          return; // Se uma regra passou, não precisa verificar as outras
        } catch (e) {
          errors.add(e.toString());
        }
      }
      // Se chegou aqui, todas as regras falharam
      throw Exception(
          'Nenhuma das regras alternativas foi atendida:\n${errors.join('\n---\n')}');
    } else {
      // Lógica AND: todas as regras devem passar
      for (final rule in rules) {
        await rule.check();
      }
    }
  }
}

class RuleBuilder {
  final ChainedRule _chainedRule;
  final String _methodName;
  final List<dynamic> _parameters;
  final String? _package;

  RuleBuilder(this._chainedRule, this._methodName, this._parameters,
      [this._package]);

  // Constrói a regra atual e adiciona à cadeia
  ChainedRule _buildCurrentRule() {
    final package = _package ?? _extractPackageFromChain();
    final rule = _createRuleFromMethod(package, _methodName, _parameters);
    return _chainedRule._addRule(rule);
  }

  String _extractPackageFromChain() {
    // Extrai o pacote da primeira regra da cadeia
    for (final rule in _chainedRule.rules) {
      if (rule is NamingRule) return rule.package;
      if (rule is VisibilityRule) return rule.package;
      if (rule is AnnotationRule) return rule.package;
      if (rule is ImplementRule) return rule.package;
      if (rule is ImplementInterfaceEndingRule) return rule.package;
      if (rule is ExtendRule) return rule.package;
      if (rule is NoDependencyRule) return rule.sourcePackage;
      if (rule is NoDependencyAnyRule) return rule.sourcePackage;
      if (rule is OnlyDependencyRule) return rule.sourcePackage;
      if (rule is FieldRule) return rule.package;
      if (rule is ImportRule) return rule.package;
    }
    throw Exception('Não foi possível extrair o pacote da cadeia de regras');
  }

  ArchRule _createRuleFromMethod(
      String package, String methodName, List<dynamic> parameters) {
    switch (methodName) {
      case 'shouldBe':
        return VisibilityRule(package, parameters[0] as Visibility);
      case 'shouldHaveNameEndingWith':
        return NamingRule(package, parameters[0] as String);
      case 'shouldBeAnnotatedWith':
        return AnnotationRule(package, parameters[0] as String);
      case 'shouldImplement':
        return ImplementRule(package, parameters[0] as String);
      case 'shouldImplementInterfaceThatEndsWith':
        return ImplementInterfaceEndingRule(package, parameters[0] as String);
      case 'shouldNotDependOnAny':
        return NoDependencyAnyRule(package, parameters[0] as List<String>);
      case 'shouldImplementOnly':
        return ImplementRule(
          package,
          (parameters[0] as List<String>).first,
          allowedInterfaces: parameters[0] as List<String>,
        );
      case 'shouldExtend':
        return ExtendRule(package, parameters[0] as String);
      case 'shouldNotDependOn':
        return NoDependencyRule(package, parameters[0] as String);
      case 'shouldOnlyDependOn':
        return OnlyDependencyRule(package, parameters[0] as List<String>);
      case 'shouldHaveFinalFields':
        return FieldRule(package, shouldBeFinal: true);
      case 'shouldHaveNonFinalFields':
        return FieldRule(package, shouldBeFinal: false);
      case 'shouldNotHaveImports':
        return ImportRule(package, parameters[0] as List<String>);
      default:
        throw Exception('Método não suportado: $methodName');
    }
  }

  // Métodos de encadeamento AND
  ChainedRule andAlso() {
    return _buildCurrentRule();
  }

  // Métodos de encadeamento OR
  ChainedRule orElse() {
    final currentChain = _buildCurrentRule();
    return ChainedRule(currentChain.rules, useOr: true);
  }

  // Métodos para continuar o encadeamento
  RuleBuilder shouldBe(Visibility visibility) {
    final currentChain = _buildCurrentRule();
    return RuleBuilder(currentChain, 'shouldBe', [visibility]);
  }

  RuleBuilder shouldHaveNameEndingWith(String suffix) {
    final currentChain = _buildCurrentRule();
    return RuleBuilder(currentChain, 'shouldHaveNameEndingWith', [suffix]);
  }

  RuleBuilder shouldBeAnnotatedWith(String annotation) {
    final currentChain = _buildCurrentRule();
    return RuleBuilder(currentChain, 'shouldBeAnnotatedWith', [annotation]);
  }

  RuleBuilder shouldImplement(String interfaceName) {
    final currentChain = _buildCurrentRule();
    return RuleBuilder(currentChain, 'shouldImplement', [interfaceName]);
  }

  RuleBuilder shouldExtend(String className) {
    final currentChain = _buildCurrentRule();
    return RuleBuilder(currentChain, 'shouldExtend', [className]);
  }

  RuleBuilder shouldNotDependOn(String targetPackage) {
    final currentChain = _buildCurrentRule();
    return RuleBuilder(currentChain, 'shouldNotDependOn', [targetPackage]);
  }

  RuleBuilder shouldOnlyDependOn(List<String> packages) {
    final currentChain = _buildCurrentRule();
    return RuleBuilder(currentChain, 'shouldOnlyDependOn', [packages]);
  }

  RuleBuilder shouldHaveFinalFields() {
    final currentChain = _buildCurrentRule();
    return RuleBuilder(currentChain, 'shouldHaveFinalFields', []);
  }

  RuleBuilder shouldHaveNonFinalFields() {
    final currentChain = _buildCurrentRule();
    return RuleBuilder(currentChain, 'shouldHaveNonFinalFields', []);
  }

  RuleBuilder shouldNotHaveImports(List<String> imports) {
    final currentChain = _buildCurrentRule();
    return RuleBuilder(currentChain, 'shouldNotHaveImports', [imports]);
  }

  Future<void> check() async {
    final finalChain = _buildCurrentRule();
    await finalChain.check();
  }
}
