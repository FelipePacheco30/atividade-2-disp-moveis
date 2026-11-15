import 'package:flutter_test/flutter_test.dart';
import 'package:previsao_tempo/controllers/controlador_previsao.dart';
import 'package:previsao_tempo/data/cliente_cptec.dart';
import 'package:previsao_tempo/data/falhas.dart';
import 'package:previsao_tempo/data/repositorio_previsao.dart';
import 'package:previsao_tempo/models/cidade.dart';

import '../support/armazenamento_em_memoria.dart';
import '../support/fixtures.dart';

void main() {
  const saoPaulo = Cidade(id: 244, nome: 'São Paulo', uf: 'SP');
  const inexistente = Cidade(id: 999999, nome: 'Inexistente', uf: 'XX');

  late bool online;

  Future<ControladorPrevisao> criarControlador(Cidade cidade) async {
    online = true;
    final repositorio = RepositorioPrevisao(
      cliente: ClienteCptec(cliente: servicoFalso(online: () => online)),
      armazenamento: await armazenamentoEmMemoria(),
    );
    return ControladorPrevisao(repositorio, cidade);
  }

  test('indica carregamento durante a consulta', () async {
    final controlador = await criarControlador(saoPaulo);
    final estados = <bool>[];
    controlador.addListener(() => estados.add(controlador.carregando));

    await controlador.carregar();

    expect(estados, [true, false]);
    expect(controlador.resultado!.previsao.dias, hasLength(4));
  });

  test('expõe a falha quando não há previsão para mostrar', () async {
    final controlador = await criarControlador(saoPaulo);
    online = false;

    await controlador.carregar();

    expect(controlador.resultado, isNull);
    expect(controlador.falha, isA<FalhaConexao>());
  });

  test('mantém a previsão na tela quando a atualização falha', () async {
    final controlador = await criarControlador(inexistente);
    await controlador.carregar();
    online = false;

    await controlador.carregar();

    expect(controlador.resultado!.previsao.vazia, isTrue);
    expect(controlador.falha, isA<FalhaConexao>());
  });

  test('usa a previsão salva quando o serviço fica fora do ar', () async {
    final controlador = await criarControlador(saoPaulo);
    await controlador.carregar();
    online = false;

    await controlador.carregar();

    expect(controlador.falha, isNull);
    expect(controlador.resultado!.doArmazenamento, isTrue);
    expect(controlador.resultado!.previsao.dias, hasLength(4));
  });

  test('não notifica depois de descartado', () async {
    final controlador = await criarControlador(saoPaulo);

    final carregamento = controlador.carregar();
    controlador.dispose();

    await expectLater(carregamento, completes);
  });
}
