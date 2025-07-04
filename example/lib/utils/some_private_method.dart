class MyUtil {
  // Este método fará o teste falhar porque é público
  void _publicMethod() {
    _privateMethod();
    // implementação
  }

  // Este método está correto pois é privado
  void _privateMethod() {
    // implementação
  }
}
