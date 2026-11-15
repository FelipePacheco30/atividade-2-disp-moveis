import 'package:flutter_test/flutter_test.dart';
import 'package:previsao_tempo/controllers/cidades_salvas.dart';
import 'package:previsao_tempo/data/armazenamento_local.dart';
import 'package:previsao_tempo/models/cidade.dart';

import '../support/armazenamento_em_memoria.dart';

void main() {
  const saoPaulo = Cidade(id: 244, nome: 'São Paulo', uf: 'SP');
  const curitiba = Cidade(id: 227, nome: 'Curitiba', uf: 'PR');
  const recife = Cidade(id: 239, nome: 'Recife', uf: 'PE');

  test('adiciona no topo, sem repetir, e persiste', () async {
    final cidades = CidadesSalvas(await armazenamentoEmMemoria());

    await cidades.adicionar(saoPaulo);
    await cidades.adicionar(curitiba);
    await cidades.adicionar(saoPaulo);

    expect(cidades.cidades, [curitiba, saoPaulo]);
    expect((await ArmazenamentoLocal.abrir()).lerCidades(), [curitiba, saoPaulo]);
  });

  test('alterna entre salvar e remover', () async {
    final cidades = CidadesSalvas(await armazenamentoEmMemoria());

    await cidades.alternar(recife);
    expect(cidades.contem(recife), isTrue);

    await cidades.alternar(recife);
    expect(cidades.contem(recife), isFalse);
  });

  test('desfaz a remoção na posição original', () async {
    final cidades = CidadesSalvas(await armazenamentoEmMemoria());
    for (final cidade in [recife, curitiba, saoPaulo]) {
      await cidades.adicionar(cidade);
    }

    await cidades.remover(curitiba);
    await cidades.adicionar(curitiba, posicao: 1);

    expect(cidades.cidades, [saoPaulo, curitiba, recife]);
  });

  test('notifica as telas a cada mudança', () async {
    final cidades = CidadesSalvas(await armazenamentoEmMemoria());
    var notificacoes = 0;
    cidades.addListener(() => notificacoes++);

    await cidades.adicionar(saoPaulo);
    await cidades.remover(saoPaulo);

    expect(notificacoes, 2);
  });
}
