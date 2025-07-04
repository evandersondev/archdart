import '../utils/rule_base.dart';

class ArchitectureTest {
  final List<Rule> rules = [];

  void check(String rootDir) async {
    for (final rule in rules) {
      await rule.check(rootDir);
    }
  }

  void addRule(Rule rule) {
    rules.add(rule);
  }
}
