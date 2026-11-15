import 'package:flutter_test/flutter_test.dart';
import 'package:previsao_tempo/data/armazenamento_local.dart';
import 'package:previsao_tempo/data/leitor_xml_cptec.dart';
import 'package:previsao_tempo/models/cidade.dart';

import '../support/armazenamento_em_memoria.dart';
import '../support/fixtures.dart';

void main() {
  const saoPaulo = Cidade(id: 244, nome: 'São Paulo', uf: 'SP');
  const curitiba = Cidade(id: 227, nome: 'Curitiba', uf: 'PR');

  test('começa sem cidades nem previsões', () async {
    final armazenamento = await armazenamentoEmMemoria();

    expect(armazenamento.lerCidades(), isEmpty);
    expect(armazenamento.lerPrevisao(244), isNull);
  });

  test('salva e lê as cidades na ordem informada', () async {
    final armazenamento = await armazenamentoEmMemoria();

    await armazenamento.salvarCidades([curitiba, saoPaulo]);
    final reaberto = await ArmazenamentoLocal.abrir();

    expect(reaberto.lerCidades().map((c) => c.nome), ['Curitiba', 'São Paulo']);
  });

  test('salva e lê a previsão com o momento em que foi obtida', () async {
    final armazenamento = await armazenamentoEmMemoria();
    final previsao = lerPrevisao(fixture('previsao_sao_paulo.xml'));
    final momento = DateTime(2026, 11, 15, 10, 30);

    await armazenamento.salvarPrevisao(244, previsao, momento);
    final salva = (await ArmazenamentoLocal.abrir()).lerPrevisao(244)!;

    expect(salva.salvaEm, momento);
    expect(salva.previsao.atualizadaEm, previsao.atualizadaEm);
    expect(salva.previsao.dias.map((d) => d.maxima), previsao.dias.map((d) => d.maxima));
  });

  test('mantém apenas as previsões mais recentes', () async {
    final armazenamento = await armazenamentoEmMemoria();
    final previsao = lerPrevisao(fixture('previsao_sao_paulo.xml'));
    final inicio = DateTime(2026, 11, 15);

    for (var codigo = 0; codigo <= ArmazenamentoLocal.limitePrevisoes; codigo++) {
      await armazenamento.salvarPrevisao(codigo, previsao, inicio.add(Duration(minutes: codigo)));
    }

    expect(armazenamento.lerPrevisao(0), isNull);
    expect(armazenamento.lerPrevisao(1), isNotNull);
    expect(armazenamento.lerPrevisao(ArmazenamentoLocal.limitePrevisoes), isNotNull);
  });

  test('ignora dados corrompidos', () async {
    final armazenamento = await armazenamentoEmMemoria({
      'cidades_salvas': '{"não": "é lista"}',
      'previsoes': '{"244": {"salvaEm": 10, "previsao": []}, "227": "x"',
    });

    expect(armazenamento.lerCidades(), isEmpty);
    expect(armazenamento.lerPrevisao(244), isNull);
    expect(armazenamento.lerPrevisao(227), isNull);
  });

  test('ignora previsão salva em formato inválido sem afetar as demais', () async {
    final armazenamento = await armazenamentoEmMemoria({
      'previsoes': '{"244": {"salvaEm": "ontem", "previsao": {"dias": []}}}',
    });
    final previsao = lerPrevisao(fixture('previsao_sao_paulo.xml'));

    await armazenamento.salvarPrevisao(227, previsao, DateTime(2026, 11, 15));

    expect(armazenamento.lerPrevisao(244), isNull);
    expect(armazenamento.lerPrevisao(227), isNotNull);
  });
}
