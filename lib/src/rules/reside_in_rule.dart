import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class ResideInRule extends Rule {
  final String sourcePackage;
  final String targetPackage;
  final bool isFolder;
  final List<String>? allowedPackages;

  ResideInRule(this.sourcePackage, this.targetPackage,
      {this.isFolder = false, this.allowedPackages});

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);

      if (!path.contains(p.join(rootDir, sourcePackage))) continue;

      if (allowedPackages != null) {
        final isInAllowedPackage =
            allowedPackages!.any((pkg) => path.contains(p.join(rootDir, pkg)));
        if (!isInAllowedPackage) {
          throw Exception(
            'Classes do pacote "$sourcePackage" devem residir em um dos pacotes: ${allowedPackages!.join(", ")} (Arquivo: $path)',
          );
        }
      } else {
        if (!path.contains(
            isFolder ? targetPackage : p.join(rootDir, targetPackage))) {
          throw Exception(
            'Classes do pacote "$sourcePackage" devem residir em "${isFolder ? targetPackage : p.join(rootDir, targetPackage)}" (Arquivo: $path)',
          );
        }
      }
    }
  }
}
