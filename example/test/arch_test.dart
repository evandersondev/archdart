import 'package:archdart/archdart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Classes em repository devem terminar com Repository', () async {
    await classes()
        .inPackage('repositories')
        .shouldHaveNameEndingWith('Repository')
        .check('lib');
  });

  test('Classes em service devem ter anotação @immutable', () async {
    await classes()
        .inPackage('services')
        .shouldBeAnnotatedWith('immutable')
        .check('lib');
  });

  test('Classes em service devem ser públicas', () async {
    await classes()
        .that()
        .inPackage('services')
        .shouldBe(Visibility.public)
        .check('lib');
  });

  test('Regras de camadas', () async {
    final layerRule = LayerRule([
      'presentation',
      'domain',
      'data',
      'core',
      'utils',
    ]);

    await layerRule.check('lib');
  });

  test('Regras de métodos', () async {
    await classes()
        .inPackage('repositories')
        .that()
        .haveField('client')
        .check('lib');
  });

  test('Métodos dos serviços devem retornar Future', () async {
    await classes()
        .that()
        .inPackage('services')
        .shouldHaveMethodThat()
        .returnType('Future<void>')
        .check('lib');
  });

  test('Métodos privados em utils', () async {
    await classes()
        .that()
        .inPackage('utils')
        .shouldHaveAllMethods()
        .shouldBePrivate()
        .check('lib');
  });

  group('Regras de Dependência', () {
    test('Domain não deve depender de Data', () async {
      await classes()
          .inPackage('domain')
          .shouldNotDependOn('data')
          .check('lib');
    });

    // Todo: Continar daqui!
    test('Presentation só pode depender de Domain', () async {
      await classes()
          .inPackage('presentation')
          .shouldOnlyDependOn(['domain', 'core'])
          .check('lib');
    });

    test('Domain não deve importar pacotes externos HTTP', () async {
      await classes()
          .inPackage('domain')
          .shouldNotHaveImports([
            'package:http',
            'package:dio',
            'package:retrofit',
          ])
          .check('lib');
    });

    test('Presentation só pode depender de Domain e Core', () async {
      await classes()
          .inPackage('presentation')
          .shouldOnlyDependOn(['domain', 'core'])
          .check('lib');
    });
  });

  group('Regras de Interface', () {
    test('Repositories devem implementar interface', () async {
      await classes()
          .inPackage('repositories')
          .that()
          .implement('IRepository')
          .check('lib');
    });

    test('Services devem implementar interface', () async {
      await classes()
          .inPackage('services')
          .that()
          .implement('IService')
          .check('lib');
    });
  });

  group('Regras de Clean Architecture', () {
    test('UseCases devem ter método execute', () async {
      await classes()
          .inPackage('domain/usecases') // Corrigido o pacote
          .shouldHaveMethodThat() // Adicionado método correto
          .hasMethodNamed('execute') // Método para verificar nome
          .check('lib');
    });

    test('Entities não devem ter dependências externas', () async {
      await classes()
          .inPackage('domain/entities')
          .shouldNotDependOn('package:http') // Usando método existente
          .check('lib');
    });
  });

  group('Regras de Estado', () {
    test('Controllers devem ser imutáveis', () async {
      await classes()
          .inPackage('presentation/controllers') // Corrigido o pacote
          .shouldBeAnnotatedWith('immutable') // Usando método existente
          .check('lib');
    });

    test('States devem implementar Freezed', () async {
      await classes()
          .inPackage('presentation/states') // Corrigido o pacote
          .shouldHaveNameEndingWith('State') // Primeiro verifica o nome
          .check('lib');

      // Teste separado para verificar a anotação
      await classes()
          .inPackage('presentation/states')
          .shouldBeAnnotatedWith('freezed') // Usando método existente
          .check('lib');
    });
  });
}
