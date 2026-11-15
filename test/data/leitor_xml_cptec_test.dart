import 'package:flutter_test/flutter_test.dart';
import 'package:previsao_tempo/data/falhas.dart';
import 'package:previsao_tempo/data/leitor_xml_cptec.dart';

import '../support/fixtures.dart';

void main() {
  group('lerCidades', () {
    test('lê nome, UF e código de cada localidade', () {
      final cidades = lerCidades(fixture('busca_sao_paulo.xml'));

      expect(cidades.map((c) => '${c.nome}/${c.uf}/${c.id}'), [
        'São Paulo/SP/244',
        'São Paulo das Missões/RS/5019',
        'São Paulo de Olivença/AM/5020',
        'São Paulo do Potengi/RN/5021',
      ]);
    });

    test('retorna lista vazia quando nada é encontrado', () {
      expect(lerCidades(fixture('busca_sem_resultados.xml')), isEmpty);
    });

    test('descarta itens sem código ou nome', () {
      const xml =
          '<cidades>'
          '<cidade><nome>Sem código</nome><uf>SP</uf></cidade>'
          '<cidade><uf>SP</uf><id>1</id></cidade>'
          '<cidade><nome>Sem UF</nome><id>2</id></cidade>'
          '</cidades>';

      final cidades = lerCidades(xml);

      expect(cidades.single.nome, 'Sem UF');
      expect(cidades.single.uf, isEmpty);
    });
  });

  group('lerPrevisao', () {
    test('lê a data de atualização e os quatro dias', () {
      final previsao = lerPrevisao(fixture('previsao_sao_paulo.xml'));

      expect(previsao.atualizadaEm, DateTime(2026, 11, 15));
      expect(previsao.dias, hasLength(4));

      final primeiro = previsao.dias.first;
      expect(primeiro.data, DateTime(2026, 11, 15));
      expect(primeiro.condicao.descricao, 'Chuva');
      expect(primeiro.minima, 19);
      expect(primeiro.maxima, 28);
    });

    test('considera IUV 0.0 como não informado', () {
      final previsao = lerPrevisao(fixture('previsao_sao_paulo.xml'));

      expect(previsao.dias.map((d) => d.indiceUv), everyElement(isNull));
    });

    test('lê o IUV quando informado', () {
      const xml =
          '<cidade><previsao><dia>2026-11-15</dia><tempo>ps</tempo>'
          '<maxima>30</maxima><minima>20</minima><iuv>11.0</iuv></previsao></cidade>';

      expect(lerPrevisao(xml).dias.single.indiceUv, 11.0);
    });

    test('retorna previsão vazia para código inexistente', () {
      final previsao = lerPrevisao(fixture('previsao_inexistente.xml'));

      expect(previsao.atualizadaEm, isNull);
      expect(previsao.vazia, isTrue);
    });

    test('mantém o dia quando faltam alguns campos', () {
      const xml =
          '<cidade><atualizacao>2026-11-15</atualizacao>'
          '<previsao><dia>2026-11-16</dia><maxima>abc</maxima></previsao>'
          '</cidade>';

      final dia = lerPrevisao(xml).dias.single;

      expect(dia.data, DateTime(2026, 11, 16));
      expect(dia.maxima, isNull);
      expect(dia.minima, isNull);
      expect(dia.condicao.descricao, 'Não definido');
    });
  });

  group('respostas inválidas', () {
    test('XML malformado', () {
      expect(() => lerPrevisao('<cidade><previsao>'), throwsA(isA<RespostaInvalida>()));
    });

    test('HTML no lugar do XML', () {
      expect(() => lerCidades('<html><body>Erro</body></html>'), throwsA(isA<RespostaInvalida>()));
    });

    test('raiz diferente da esperada', () {
      expect(() => lerPrevisao(fixture('busca_sao_paulo.xml')), throwsA(isA<RespostaInvalida>()));
    });
  });
}
