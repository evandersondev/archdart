import '../utils/rule_base.dart';

class FieldRule extends Rule {
  final String package;
  final bool shouldBeFinal;

  FieldRule(this.package, {this.shouldBeFinal = true});

  @override
  Future<void> check(String rootDir) async {
    // Implementação...
  }
}
