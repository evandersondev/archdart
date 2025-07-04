import '../rules/annotation_rule.dart';
import '../rules/field_rule.dart';
import '../rules/implement_rule.dart';
import '../rules/import_rule.dart';
import '../rules/method_rule.dart';
import '../rules/method_rule_type.dart';
import '../rules/naming_rule.dart';
import '../rules/no_dependency_rule.dart';
import '../rules/only_dependency_rule.dart';
import '../rules/visibility_rule.dart';

enum VisibilityEnum { public, private }

class ClassSelector {
  final String package;

  ClassSelector(this.package);

  NoDependencyRule shouldNotDependOn(String targetPackage) {
    return NoDependencyRule(package, targetPackage);
  }

  AnnotationRule shouldBeAnnotatedWith(String annotation) {
    return AnnotationRule(package, annotation);
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
      MethodRuleType.visibility,
      isPrivate: true,
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
