import '../utils/rule_base.dart';

class CombinedRule extends Rule {
  final String package;
  final List<Rule> rules;

  CombinedRule(this.package, this.rules);

  @override
  Future<void> check(String rootDir) async {
    for (final rule in rules) {
      await rule.check(rootDir);
    }
  }
}
