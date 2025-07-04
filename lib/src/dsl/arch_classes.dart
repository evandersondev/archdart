import '../rules/access_rule.dart';
import '../rules/annotation_rule.dart';
import '../rules/combine_rule.dart';
import '../rules/cyclic_dependency_rule.dart';
import '../rules/extend_rule.dart';
import '../rules/field_rule.dart';
import '../rules/implement_rule.dart';
import '../rules/import_rule.dart';
import '../rules/line_count_rule.dart';
import '../rules/method_rule.dart';
import '../rules/method_rule_type.dart';
import '../rules/naming_rule.dart';
import '../rules/no_dependency_rule.dart';
import '../rules/only_dependency_rule.dart';
import '../rules/reside_in_rule.dart';
import '../rules/visibility_rule.dart';
import '../utils/rule_base.dart';

enum VisibilityEnum { public, private }

class ClassSelector {
  final String package;

  ClassSelector(this.package);

  NoDependencyRule shouldNotDependOn(String targetPackage) {
    return NoDependencyRule(package, targetPackage);
  }

  NoDependencyRule shouldNotAccessPackage(String targetPackage) {
    return NoDependencyRule(package, targetPackage);
  }

  AnnotationRule shouldBeAnnotatedWith(String annotation) {
    return AnnotationRule(package, annotation);
  }

  FieldRule shouldHaveFieldsOfType(String type) {
    return FieldRule(package, expectedType: type);
  }

  FieldRule shouldHaveFieldsWithVisibility(Visibility visibility) {
    return FieldRule(package, visibility: visibility);
  }

  FieldRule shouldHaveNonFinalFields() {
    return FieldRule(package, shouldBeFinal: false);
  }

  CyclicDependencyRule shouldHaveNoCyclicDependencies(List<String> packages) {
    return CyclicDependencyRule(packages);
  }

  CombinedRule shouldComplyWith(List<Rule> rules) {
    return CombinedRule(package, rules);
  }

  VisibilityRule shouldBe(Visibility visibility) {
    return VisibilityRule(package, visibility);
  }

  ImplementRule shouldImplement(String interfaceName) {
    return ImplementRule(package, interfaceName);
  }

  MethodRuleBuilder shouldHaveMethodThat() {
    return MethodRuleBuilder(package);
  }

  NamingRule shouldHaveNameEndingWith(String suffix) {
    return NamingRule(package, suffix);
  }

  OnlyDependencyRule shouldOnlyDependOn(List<String> packages) {
    return OnlyDependencyRule(package, packages);
  }

  ImportRule shouldNotHaveImports(List<String> imports) {
    return ImportRule(package, imports);
  }

  FieldRule shouldHaveFinalFields() {
    return FieldRule(package, shouldBeFinal: true);
  }

  NamingRule shouldHaveMethodWithName(String name) {
    return NamingRule(package, name);
  }

  MethodRuleBuilder shouldHaveAllMethods() {
    return MethodRuleBuilder(package, checkAll: true);
  }

  NamingRule withNameEndingWith(String suffix) => NamingRule(package, suffix);
  NamingRule withNameContaining(String substring) =>
      NamingRule(package, substring, checkContains: true);
  AnnotationRule withAnnotation(String annotation) =>
      AnnotationRule(package, annotation);
  LineCountRule withLineCountGreaterThan(int count) =>
      LineCountRule(package, count);

  // Affirmatives
  VisibilityRule shouldBeAbstract() =>
      VisibilityRule(package, Visibility.abstract);
  VisibilityRule shouldBeSealed() => VisibilityRule(package, Visibility.sealed);
  VisibilityRule shouldBeBase() => VisibilityRule(package, Visibility.base);
  VisibilityRule shouldBeMixin() => VisibilityRule(package, Visibility.mixin);
  VisibilityRule shouldBeRecord() => VisibilityRule(package, Visibility.record);
  ExtendRule shouldExtend(String className) => ExtendRule(package, className);
  ExtendRule shouldExtendAnyOf(List<String> classNames) =>
      ExtendRule(package, classNames.first, allowedClasses: classNames);
  ImplementRule shouldImplementOnly(List<String> interfaces) =>
      ImplementRule(package, interfaces.first, allowedInterfaces: interfaces);
  VisibilityRule shouldHaveOnlyPrivateConstructors() =>
      VisibilityRule(package, Visibility.private, isConstructor: true);
  ResideInRule shouldBeInPackage(String packageName) =>
      ResideInRule(package, packageName);
  ResideInRule shouldBeInAnyPackage(List<String> packages) =>
      ResideInRule(package, packages.first, allowedPackages: packages);
  ResideInRule shouldBeInFolder(String folder) =>
      ResideInRule(package, folder, isFolder: true);
  AccessRule shouldOnlyBeAccessedBy(List<String> packages) =>
      AccessRule(package, packages);

  // Negatives
  VisibilityRule shouldNotBe(Visibility visibility) =>
      VisibilityRule(package, visibility, negate: true);
}

ClassSelector classes() => ClassSelectorExtension('').inPackage('');

extension ClassSelectorExtension on Object {
  ClassSelector inPackage(String package) => ClassSelector(package);
}

class MethodRuleBuilder {
  final String package;
  final bool checkAll;

  MethodRuleBuilder(this.package, {this.checkAll = false});

  MethodRule returnType(String type) {
    return MethodRule(
      package,
      MethodRuleType.returnType, // Fixed: Corrected to returnType
      expectedType: type,
      checkAll: checkAll,
    );
  }

  MethodRule shouldBeAsync() {
    return MethodRule(
      package,
      MethodRuleType.async,
      checkAll: checkAll,
    );
  }

  MethodRule shouldBePrivate() {
    return MethodRule(
      package,
      MethodRuleType.visibility,
      isPrivate: true,
      checkAll: checkAll,
    );
  }

  MethodRule shouldBePublic() {
    return MethodRule(
      package,
      MethodRuleType.visibility,
      isPrivate: false,
      checkAll: checkAll,
    );
  }

  MethodRule shouldHaveAnnotation(String annotation) {
    return MethodRule(
      package,
      MethodRuleType.annotation,
      requiredAnnotation: annotation,
      checkAll: checkAll,
    );
  }

  MethodRule hasMethodNamed(String methodName) {
    return MethodRule(
      package,
      MethodRuleType.name,
      expectedMethodName: methodName,
      checkAll: checkAll,
    );
  }

  MethodRule withParameters(List<String> parameters) {
    return MethodRule(
      package,
      MethodRuleType.parameters,
      expectedParameters: parameters,
      checkAll: checkAll,
    );
  }
}
