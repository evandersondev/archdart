# ArchDart - Guia de Referência de Métodos

Este documento lista todos os métodos disponíveis e os **padrões de nomenclatura** do `archdart`, um pacote para validação de regras arquiteturais em projetos Dart e Flutter, inspirado no ArchUnit do Java.

A sintaxe é expressiva, fluida e adequada ao ecossistema Dart.

---

## 📁 Entradas iniciais (tipos de elementos)

Estes métodos definem o tipo de elementos a serem validados:

| Método           | O que seleciona            |
| ---------------- | -------------------------- |
| `classes()`      | Todas as classes           |
| `enums()`        | Todos os enums             |
| `methods()`      | Todos os métodos           |
| `constructors()` | Todos os construtores      |
| `files()`        | Todos os arquivos Dart     |
| `functions()`    | Todas as funções top-level |

---

## 📋 Escopo (onde buscar)

| Método                | Uso                                     |
| --------------------- | --------------------------------------- |
| `inPackage('x')`      | Pacote lógico (ex: controller, service) |
| `inFolder('path')`    | Caminho real no projeto                 |
| `inDirectory('path')` | Idêntico a `inFolder`                   |
| `inFile('x.dart')`    | Aponta para um arquivo específico       |

---

## 🔄 Filtros (selecionar subconjuntos)

| Método                         | Uso                            |
| ------------------------------ | ------------------------------ |
| `withNameEndingWith('X')`      | Nomes que terminam com "X"     |
| `withNameContaining('X')`      | Nomes que contêm "X"           |
| `withAnnotation('X')`          | Elementos com anotacão `@X`    |
| `withLineCountGreaterThan(n)`  | Classes com mais de `n` linhas |
| `withValueCountGreaterThan(n)` | Enums com mais de `n` valores  |

---

## ✅ Afirmativas (`should...`)

### Modificadores / Tipos

| Método                       | Uso                      |
| ---------------------------- | ------------------------ |
| `shouldBePublic()`           | Deve ser pública         |
| `shouldBePrivate()`          | Deve ser privada         |
| `shouldBeFinal()`            | Deve ser `final`         |
| `shouldBeAbstract()`         | Deve ser `abstract`      |
| `shouldBeSealed()`           | Deve ser `sealed`        |
| `shouldBeBase()`             | Deve ser `base`          |
| `shouldBeMixin()`            | Deve ser `mixin`         |
| `shouldBeEnum()`             | Deve ser um `enum`       |
| `shouldBeRecord()`           | Deve ser um `record`     |
| `shouldBeAnnotatedWith('X')` | Deve ter a anotação `@X` |

### Herança e Implementação

| Método                         | Uso                              |
| ------------------------------ | -------------------------------- |
| `shouldExtend('SuperClass')`   | Deve extender determinada classe |
| `shouldExtendAnyOf([...])`     | Deve extender uma das fornecidas |
| `shouldImplement('Interface')` | Deve implementar interface       |
| `shouldImplementOnly([...])`   | Deve implementar apenas essas    |

### Estrutura / Nome / Construtores

| Método                                | Uso                                        |
| ------------------------------------- | ------------------------------------------ |
| `shouldHaveNameEndingWith('X')`       | Nome deve terminar com `X`                 |
| `shouldHaveOnlyPrivateConstructors()` | Todos os construtores devem ser privados   |
| `shouldRequireAllParams()`            | Construtores com todos params obrigatórios |
| `shouldHaveOnlyNamedRequiredParams()` | Parâmetros nomeados obrigatórios           |

### Dependências / Camadas

| Método                          | Uso                                     |
| ------------------------------- | --------------------------------------- |
| `shouldOnlyDependOn([...])`     | Só pode depender dos pacotes fornecidos |
| `shouldOnlyBeAccessedBy([...])` | Só pode ser acessado pelos pacotes      |
| `shouldBeInPackage('X')`        | Deve estar no pacote `X`                |
| `shouldBeInAnyPackage([...])`   | Deve estar em um dos pacotes fornecidos |
| `shouldBeInFolder('path')`      | Deve estar dentro da pasta `path`       |
| `shouldOnlyContainRecords()`    | Arquivo deve conter apenas records      |

### Conteúdo de arquivos

| Método                          | Uso                                           |
| ------------------------------- | --------------------------------------------- |
| `shouldContain('texto')`        | Deve conter texto                             |
| `shouldNotBeExportedIn('file')` | Não deve ser exportado em determinado arquivo |

---

## ❌ Negativas (`shouldNot...`)

| Método                                | Uso                                     |
| ------------------------------------- | --------------------------------------- |
| `shouldNotBe(...)`                    | Não deve ter certo tipo/modificador     |
| `shouldNotHave(...)`                  | Não deve conter algo específico         |
| `shouldNotDependOn('package/folder')` | Não deve importar ou depender de pacote |
| `shouldNotAccessPackage('X')`         | Não deve acessar determinado pacote     |
| `shouldNotContain('texto')`           | Arquivo não pode conter string literal  |
| `shouldNotBeExportedIn('file')`       | Não pode ser exportado no arquivo X     |

---

## 📑 Utilitários

| Método                   | Uso                                           |
| ------------------------ | --------------------------------------------- |
| `check('path')`          | Executa as validações no diretório fornecido  |
| `andAlso()`              | Encadeia mais de uma validação na mesma regra |
| `shouldFail('mensagem')` | Marca a regra como falha com uma mensagem     |

---

Esta tabela serve como uma referência rápida para a criação de testes arquiteturais em projetos Dart e Flutter utilizando o `archdart`. Ela orienta desde a seleção dos elementos até as afirmações e negações para garantir a conformidade com as diretrizes de arquitetura definidas.
