import '../rules/annotation_rule.dart';
import '../rules/enum_value_rule.dart';
import '../rules/naming_rule.dart';

class EnumSelector {
  final String package;

  EnumSelector(this.package);

  // Filters
  NamingRule withNameEndingWith(String suffix) =>
      NamingRule(package, suffix, isEnum: true);
  NamingRule withNameContaining(String substring) =>
      NamingRule(package, substring, isEnum: true, checkContains: true);
  AnnotationRule withAnnotation(String annotation) =>
      AnnotationRule(package, annotation, isEnum: true);
  EnumValueRule withValueCountGreaterThan(int count) =>
      EnumValueRule(package, count);

  // Affirmatives
  AnnotationRule shouldBeAnnotatedWith(String annotation) =>
      AnnotationRule(package, annotation, isEnum: true);
  NamingRule shouldHaveNameEndingWith(String suffix) =>
      NamingRule(package, suffix, isEnum: true);
}
