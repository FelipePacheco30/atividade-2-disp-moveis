import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:previsao_tempo/controllers/controlador_busca.dart';
import 'package:previsao_tempo/data/cliente_cptec.dart';
import 'package:previsao_tempo/data/falhas.dart';
import 'package:previsao_tempo/data/repositorio_previsao.dart';

import '../support/armazenamento_em_memoria.dart';
import '../support/fixtures.dart';

void main() {
  late List<String> termosConsultados;

  Future<ControladorBusca> criarControlador(MockClientHandler servico) async {
    termosConsultados = [];
    final repositorio = RepositorioPrevisao(
      cliente: ClienteCptec(
        cliente: MockClient((request) {
          termosConsultados.add(request.url.queryParameters['city']!);
          return servico(request);
        }),
      ),
      armazenamento: await armazenamentoEmMemoria(),
    );
    return ControladorBusca(repositorio, espera: const Duration(milliseconds: 10));
  }

  Future<http.Response> responderSaoPaulo(http.Request _) async =>
      respostaCptec('busca_sao_paulo.xml');

  test('busca depois de uma pausa na digitação, uma única vez', () async {
    final controlador = await criarControlador(responderSaoPaulo);

    controlador.alterarTermo('São');
    controlador.alterarTermo('São P');
    controlador.alterarTermo('São Paulo');
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(termosConsultados, ['São Paulo']);
    expect(controlador.resultados, hasLength(4));
    expect(controlador.termoBuscado, 'São Paulo');
    expect(controlador.carregando, isFalse);
  });

  test('não busca com menos de três letras e limpa os resultados', () async {
    final controlador = await criarControlador(responderSaoPaulo);
    controlador.alterarTermo('São');
    await controlador.buscar();

    controlador.alterarTermo('Sã');
    await controlador.buscar();

    expect(termosConsultados, ['São']);
    expect(controlador.termoCurto, isTrue);
    expect(controlador.resultados, isNull);
  });

  test('informa lista vazia quando nenhuma cidade é encontrada', () async {
    final controlador = await criarControlador(
      (_) async => respostaCptec('busca_sem_resultados.xml'),
    );

    controlador.alterarTermo('xyzqq');
    await controlador.buscar();

    expect(controlador.resultados, isEmpty);
    expect(controlador.falha, isNull);
  });

  test('expõe a falha do serviço', () async {
    final controlador = await criarControlador((_) async => http.Response('', 503));

    controlador.alterarTermo('Curitiba');
    await controlador.buscar();

    expect(controlador.falha, isA<ServicoIndisponivel>());
    expect(controlador.resultados, isNull);
    expect(controlador.carregando, isFalse);
  });

  test('descarta a resposta de um termo antigo que chega por último', () async {
    final respostaLenta = Completer<http.Response>();
    final controlador = await criarControlador((request) {
      if (request.url.queryParameters['city'] == 'Rio') return respostaLenta.future;
      return Future.value(respostaCptec('busca_sao_paulo.xml'));
    });

    controlador.alterarTermo('Rio');
    final buscaAntiga = controlador.buscar();
    controlador.alterarTermo('São Paulo');
    await controlador.buscar();
    respostaLenta.complete(respostaCptec('busca_sem_resultados.xml'));
    await buscaAntiga;

    expect(controlador.termoBuscado, 'São Paulo');
    expect(controlador.resultados, hasLength(4));
  });
}
