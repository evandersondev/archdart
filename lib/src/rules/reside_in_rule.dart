import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class ResideInRule extends Rule {
  final String sourcePackage;
  final String targetPackage;

  ResideInRule(this.sourcePackage, this.targetPackage);

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);

      if (!path.contains(p.join(rootDir, sourcePackage))) continue;

      if (!path.contains(targetPackage)) {
        throw Exception(
          'Classes do pacote "$sourcePackage" devem residir em "$targetPackage"',
        );
      }
    }
  }
}
