import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class ArchitectureTest {
  final List<Rule> rules = [];
  Function(String)? errorHandler;

  void setErrorHandler(Function(String) handler) {
    errorHandler = handler;
  }

  void addRule(Rule rule) {
    rules.add(rule);
  }

  void shouldFail(String message) {
    throw Exception(message);
  }

  Future<void> check(String rootDir) async {
    int filesChecked = 0;
    int violationsFound = 0;
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);
    filesChecked = unitsWithPath.length;

    for (final rule in rules) {
      try {
        await rule.check(rootDir);
      } catch (e) {
        violationsFound++;
        if (errorHandler != null) {
          errorHandler!(e.toString());
        } else {
          rethrow;
        }
      }
    }

    print(
        'Resumo: $filesChecked arquivos verificados, $violationsFound violações encontradas');
  }

  ArchitectureTest andAlso() => this;
}
