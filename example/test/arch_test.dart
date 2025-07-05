import 'package:archdart/archdart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Regras de Nome e Visibilidade', () {
    test('Repositories devem terminar com Repository', () async {
      ArchRule rule = classes()
          .inFolder('infra/repositories')
          .shouldHaveNameEndingWith('Repository');

      await rule.check();
    });

    test('Services devem terminar com Service e ser públicos', () async {
      await classes()
          .inFolder('infra/services')
          .shouldBe(Visibility.public)
          .andAlso()
          .shouldHaveNameEndingWith('Service')
          .check();
    });

    // test('Classes muito grandes devem ser evitadas', () async {
    //   await classes()
    //       .withLineCountGreaterThan(500)
    //       .shouldFail('Classes com mais de 500 linhas precisam ser divididas')
    //       .check();
    // });
  });

  group('Camadas e Dependências', () {
    test('Presentation não deve acessar Infra', () async {
      await classes()
          .inPackage('presentation')
          .shouldNotDependOn('infra')
          .check();
    });

    test('Domain não deve depender de Presentation ou Infra', () async {
      await classes()
          .inPackage('domain')
          .shouldNotDependOnAny(['presentation', 'infra']).check();
    });

    test('Infra só pode acessar Domain e Core', () async {
      await classes()
          .inPackage('infra')
          .shouldOnlyDependOn(['domain', 'core']).check();
    });

    test('Presentation só pode acessar Domain e Core', () async {
      await classes()
          .inPackage('presentation')
          .shouldOnlyDependOn(['domain', 'core']).check();
    });

    test('Repositories no domínio devem ser abstratos', () async {
      await classes()
          .inFolder('domain/repositories')
          .shouldBeAbstract()
          .andAlso()
          .shouldHaveNameEndingWith('Repository')
          .check();
    });
  });

  group('Pureza do domínio', () {
    test('Domain não deve importar pacotes Flutter ou IO', () async {
      await classes().inPackage('domain').shouldNotHaveImports([
        'package:flutter',
        'package:flutter/material.dart',
        'dart:io',
      ]).check();
    });

    test('Entities devem ser final', () async {
      await classes().inFolder('domain/entities').shouldBeFinal().check();
    });

    test(
        'Classes que terminam com Controller. devem estar nas pastas corretas.',
        () async {
      await classes()
          .withNameEndingWith('Controller')
          .shouldBeInFolder('presentation/controllers')
          .check();
    });

    test('Entities devem ter todos parâmetros obrigatórios nomeados', () async {
      await classes()
          .inFolder('domain/entities')
          .shouldHaveOnlyNamedRequiredParams()
          .check();
    });
  });

  group('Regras de Clean Architecture', () {
    test('UseCases devem ter método execute', () async {
      await classes()
          .inFolder('domain/usecases')
          .shouldHaveMethodThat()
          .hasMethodNamed('execute')
          .check();
    });

    test('Entities não devem ter dependências externas', () async {
      await classes().inFolder('domain/entities').shouldNotHaveImports([
        'package:http',
        'package:dio',
        'package:flutter',
      ]).check();
    });
  });

  group('Isolamento de Features', () {
    test('Features não devem se referenciar entre si', () async {
      await features().shouldBeIndependent().check();
    });
  });

  group('Regras de Estado na Presentation', () {
    test('Controllers devem ser anotados com @immutable', () async {
      await classes()
          .inFolder('presentation/controllers')
          .shouldBeAnnotatedWith('immutable')
          .check();
    });

    test('States devem terminar com State e usar Freezed', () async {
      await classes()
          .inFolder('presentation/states')
          .shouldHaveNameEndingWith('State')
          .check();

      await classes()
          .inFolder('presentation/states')
          .shouldBeAnnotatedWith('freezed')
          .check();
    });
  });

  group('Organização de Camadas', () {
    // test('Camadas principais devem existir', () async {
    //   await layers(['presentation', 'domain', 'infra', 'core'])
    //       .onlyStructure()
    //       .requireAllLayers()
    //       .check();
    // });

    test('Camadas devem respeitar estrutura esperada', () async {
      await layers(['presentation', 'domain', 'infra', 'core'])
          .onlyStructure()
          .allowMissingLayers()
          .check();
    });
  });

  group('Interfaces', () {
    test('Repositories devem implementar suas interfaces', () async {
      await classes()
          .inFolder('infra/repositories')
          .shouldImplement('IUserRepository')
          .check();
    });

    // test('Services devem implementar suas interfaces', () async {
    //   await classes()
    //       .inFolder('infra/services')
    //       .shouldImplementInterfaceThatEndsWith('Service')
    //       .check();
    // });
  });
}
