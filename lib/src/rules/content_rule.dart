import 'dart:io';

import 'package:analyzer/dart/element/type.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class ContentRule extends Rule {
  final String package;
  final String text;
  final bool shouldContain;
  final bool onlyRecords;

  ContentRule(this.package, this.text,
      {this.shouldContain = true, this.onlyRecords = false});

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      if (!path.contains(p.join(rootDir, package))) continue;

      if (onlyRecords) {
        // Check if the file contains only record type aliases
        final hasNonRecord = unit.declarations.any((d) {
          if (d is RecordType) {
            return false; // Record type alias is allowed
          }
          return true; // Any other declaration is considered non-record
        });
        if (hasNonRecord) {
          throw Exception(
              'Arquivo "$path" deve conter apenas type aliases de records');
        }
      } else {
        final content = await File(path).readAsString();
        final containsText = content.contains(text);

        if (shouldContain && !containsText) {
          throw Exception('Arquivo "$path" deve conter o texto "$text"');
        } else if (!shouldContain && containsText) {
          throw Exception('Arquivo "$path" não deve conter o texto "$text"');
        }
      }
    }
  }
}
