import 'package:flutter_test/flutter_test.dart';
import 'package:previsao_tempo/models/condicao_tempo.dart';

void main() {
  group('CondicaoTempo', () {
    test('cobre todas as siglas da documentação do CPTEC', () {
      const siglasDocumentadas = [
        'ec', 'ci', 'c', 'in', 'pp', 'cm', 'cn', 'pt', 'pm', 'np', //
        'pc', 'pn', 'cv', 'ch', 't', 'ps', 'e', 'n', 'cl', 'nv', //
        'g', 'ne', 'nd', 'pnt', 'psc', 'pcm', 'pct', 'pcn', 'npt', 'npn', //
        'ncn', 'nct', 'ncm', 'npm', 'npp', 'vn', 'ct', 'ppn', 'ppt', 'ppm',
      ];

      expect(CondicaoTempo.todas.map((c) => c.sigla), unorderedEquals(siglasDocumentadas));
    });

    test('converte a sigla em descrição legível', () {
      expect(CondicaoTempo.daSigla('pn').descricao, 'Parcialmente nublado');
      expect(
        CondicaoTempo.daSigla('ppm').descricao,
        'Possibilidade de pancadas de chuva pela manhã',
      );
      expect(CondicaoTempo.daSigla('t').grupo, GrupoTempo.tempestade);
    });

    test('ignora espaços e maiúsculas', () {
      expect(CondicaoTempo.daSigla(' CL ').descricao, 'Céu claro');
    });

    test('trata sigla ausente ou "null" como não definida', () {
      expect(CondicaoTempo.daSigla(null), CondicaoTempo.naoDefinido);
      expect(CondicaoTempo.daSigla(''), CondicaoTempo.naoDefinido);
      expect(CondicaoTempo.daSigla('null'), CondicaoTempo.naoDefinido);
    });

    test('mantém a sigla desconhecida com descrição genérica', () {
      final condicao = CondicaoTempo.daSigla('xyz');

      expect(condicao.sigla, 'xyz');
      expect(condicao.descricao, 'Não definido');
      expect(condicao.grupo, GrupoTempo.indefinido);
    });
  });
}
