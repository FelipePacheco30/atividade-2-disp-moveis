import 'package:flutter_test/flutter_test.dart';
import 'package:previsao_tempo/models/cidade.dart';
import 'package:previsao_tempo/models/condicao_tempo.dart';
import 'package:previsao_tempo/models/previsao.dart';

void main() {
  test('Cidade sobrevive à conversão para JSON e é identificada pelo código', () {
    const cidade = Cidade(id: 244, nome: 'São Paulo', uf: 'SP');

    expect(Cidade.deJson(cidade.paraJson()), cidade);
    expect(Cidade.deJson(cidade.paraJson()).nome, 'São Paulo');
    expect(const Cidade(id: 244, nome: 'Outro nome', uf: 'SP'), cidade);
  });

  test('Previsao sobrevive à conversão para JSON, inclusive campos ausentes', () {
    final previsao = Previsao(
      atualizadaEm: DateTime(2026, 11, 15),
      dias: [
        PrevisaoDia(
          data: DateTime(2026, 11, 15),
          condicao: CondicaoTempo.daSigla('pn'),
          minima: 19,
          maxima: 28,
          indiceUv: 9.5,
        ),
        PrevisaoDia(
          data: null,
          condicao: CondicaoTempo.naoDefinido,
          minima: null,
          maxima: null,
          indiceUv: null,
        ),
      ],
    );

    final copia = Previsao.deJson(previsao.paraJson());

    expect(copia.atualizadaEm, DateTime(2026, 11, 15));
    expect(copia.dias, hasLength(2));
    expect(copia.dias.first.condicao.descricao, 'Parcialmente nublado');
    expect(copia.dias.first.maxima, 28);
    expect(copia.dias.first.indiceUv, 9.5);
    expect(copia.dias.last.data, isNull);
    expect(copia.dias.last.minima, isNull);
  });

  test('NivelUv segue as faixas de exposição', () {
    expect(NivelUv.doIndice(0.5), NivelUv.baixo);
    expect(NivelUv.doIndice(3), NivelUv.moderado);
    expect(NivelUv.doIndice(6.5), NivelUv.alto);
    expect(NivelUv.doIndice(10.9), NivelUv.muitoAlto);
    expect(NivelUv.doIndice(13), NivelUv.extremo);
  });
}
