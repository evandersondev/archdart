import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import '../utils/analyzer_utils.dart';
import '../utils/rule_base.dart';

class LayerRule extends Rule {
  final List<String> layerOrder;

  LayerRule(this.layerOrder);

  @override
  Future<void> check(String rootDir) async {
    final unitsWithPath = await parseDirectoryWithPaths(rootDir);
    bool foundAnyLayer = false;

    for (final entry in unitsWithPath.entries) {
      final path = p.normalize(entry.key);
      final unit = entry.value;

      final currentLayerIndex = _findLayerIndex(path);

      // Verifica se encontrou alguma camada durante a análise
      if (currentLayerIndex != -1) {
        foundAnyLayer = true;
      }

      // Pula arquivos que não estão em nenhuma camada
      if (currentLayerIndex == -1) continue;

      final imports = unit.directives.whereType<ImportDirective>();

      for (final import in imports) {
        final importPath = import.uri.stringValue ?? '';
        if (!importPath.startsWith('package:')) continue;

        final importLayerIndex = _findLayerIndex(importPath);
        if (importLayerIndex == -1) continue;

        if (importLayerIndex < currentLayerIndex) {
          throw Exception(
            'Violação de camada: "${p.basename(path)}" (camada: ${layerOrder[currentLayerIndex]}) '
            'não pode depender de "${p.basename(importPath)}" (camada: ${layerOrder[importLayerIndex]})',
          );
        }
      }
    }

    // Lança exceção se nenhuma das camadas definidas foi encontrada
    if (!foundAnyLayer) {
      throw Exception(
        'Nenhuma das camadas definidas (${layerOrder.join(", ")}) '
        'foi encontrada no diretório $rootDir. '
        'Verifique se a estrutura de pastas está correta.',
      );
    }
  }

  int _findLayerIndex(String path) {
    for (var i = 0; i < layerOrder.length; i++) {
      if (path.contains(layerOrder[i])) return i;
    }
    return -1;
  }
}
