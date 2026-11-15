import 'package:flutter_test/flutter_test.dart';
import 'package:previsao_tempo/data/cliente_cptec.dart';
import 'package:previsao_tempo/data/falhas.dart';
import 'package:previsao_tempo/data/repositorio_previsao.dart';
import 'package:previsao_tempo/models/cidade.dart';

import '../support/armazenamento_em_memoria.dart';
import '../support/fixtures.dart';

void main() {
  const saoPaulo = Cidade(id: 244, nome: 'São Paulo', uf: 'SP');
  final momento = DateTime(2026, 11, 15, 9, 41);

  late bool online;

  Future<RepositorioPrevisao> criarRepositorio() async {
    online = true;
    return RepositorioPrevisao(
      cliente: ClienteCptec(cliente: servicoFalso(online: () => online)),
      armazenamento: await armazenamentoEmMemoria(),
      agora: () => momento,
    );
  }

  test('consulta o serviço e guarda a previsão no aparelho', () async {
    final repositorio = await criarRepositorio();

    final resultado = await repositorio.buscarPrevisao(saoPaulo);

    expect(resultado.doArmazenamento, isFalse);
    expect(resultado.previsao.dias, hasLength(4));
    expect(repositorio.previsaoSalva(saoPaulo)?.salvaEm, momento);
  });

  test('usa a previsão guardada quando o serviço falha', () async {
    final repositorio = await criarRepositorio();
    await repositorio.buscarPrevisao(saoPaulo);
    online = false;

    final resultado = await repositorio.buscarPrevisao(saoPaulo);

    expect(resultado.doArmazenamento, isTrue);
    expect(resultado.falha, isA<FalhaConexao>());
    expect(resultado.salvaEm, momento);
    expect(resultado.previsao.dias, hasLength(4));
  });

  test('repassa a falha quando não há previsão guardada', () async {
    final repositorio = await criarRepositorio();
    online = false;

    await expectLater(repositorio.buscarPrevisao(saoPaulo), throwsA(isA<FalhaConexao>()));
  });

  test('não guarda previsão vazia', () async {
    final repositorio = await criarRepositorio();
    const inexistente = Cidade(id: 999999, nome: 'Inexistente', uf: 'XX');

    final resultado = await repositorio.buscarPrevisao(inexistente);

    expect(resultado.previsao.vazia, isTrue);
    expect(repositorio.previsaoSalva(inexistente), isNull);
  });
}
