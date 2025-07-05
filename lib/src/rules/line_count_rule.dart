import 'dart:io';

import 'package:path/path.dart' as p;

import '../utils/rule_base.dart';
import '../utils/rule_messages.dart';

class LineCountRule extends ArchRule {
  final String package;
  final int maxLines;

  LineCountRule(this.package, this.maxLines);

  @override
  Future<void> check() async {
    final violations = <String>[];
    final directory = Directory('.');

    await for (final entity in directory.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final path = p.normalize(entity.path);

        if (!path.contains(package)) continue;

        final lines = await entity.readAsLines();
        final lineCount = lines.length;

        if (lineCount > maxLines) {
          violations
              .add(RuleMessages.lineCountViolation(path, lineCount, maxLines));
        }
      }
    }

    if (violations.isNotEmpty) {
      throw Exception(RuleMessages.violationFound('Line count', violations));
    }
  }
}
