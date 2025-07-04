abstract class Rule {
  List<String> excludedFiles = [];
  List<String> excludedClasses = [];

  Future<void> check(String rootDir);

  void excludeFiles(List<String> files) {
    excludedFiles.addAll(files);
  }

  void excludeClasses(List<String> classes) {
    excludedClasses.addAll(classes);
  }

  bool isExcluded(String path, String? className) {
    if (excludedFiles.any((f) => path.contains(f))) return true;
    if (className != null && excludedClasses.contains(className)) return true;
    return false;
  }
}
