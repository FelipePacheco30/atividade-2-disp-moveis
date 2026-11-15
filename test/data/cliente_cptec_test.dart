import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:previsao_tempo/data/cliente_cptec.dart';
import 'package:previsao_tempo/data/falhas.dart';

import '../support/fixtures.dart';

void main() {
  test('busca cidades pelo parâmetro city e decodifica ISO-8859-1', () async {
    late Uri chamada;
    final cliente = ClienteCptec(
      cliente: MockClient((request) async {
        chamada = request.url;
        return respostaCptec('busca_sao_paulo.xml');
      }),
    );

    final cidades = await cliente.buscarCidades('  São Paulo ');

    expect(chamada.toString(), startsWith('https://servicos.cptec.inpe.br/XML/listaCidades?city='));
    expect(chamada.queryParameters['city'], 'São Paulo');
    expect(cidades.first.nome, 'São Paulo');
  });

  test('não consulta o serviço com termo vazio', () async {
    var chamadas = 0;
    final cliente = ClienteCptec(
      cliente: MockClient((_) async {
        chamadas++;
        return respostaCptec('busca_sao_paulo.xml');
      }),
    );

    expect(await cliente.buscarCidades('   '), isEmpty);
    expect(chamadas, 0);
  });

  test('consulta a previsão pelo código retornado na busca', () async {
    late Uri chamada;
    final cliente = ClienteCptec(
      cliente: MockClient((request) async {
        chamada = request.url;
        return respostaCptec('previsao_sao_paulo.xml');
      }),
    );

    final previsao = await cliente.buscarPrevisao(244);

    expect(chamada.toString(), 'https://servicos.cptec.inpe.br/XML/cidade/244/previsao.xml');
    expect(previsao.dias, hasLength(4));
  });

  group('falhas', () {
    Future<void> esperarFalha<T extends FalhaCptec>(MockClientHandler handler) {
      final cliente = ClienteCptec(
        cliente: MockClient(handler),
        tempoLimite: const Duration(milliseconds: 50),
      );
      return expectLater(cliente.buscarPrevisao(244), throwsA(isA<T>()));
    }

    test('sem conexão', () {
      return esperarFalha<FalhaConexao>((_) => throw http.ClientException('Failed host lookup'));
    });

    test('erro de TLS ou socket', () {
      return esperarFalha<FalhaConexao>((_) => throw const SocketException('Network unreachable'));
    });

    test('tempo esgotado', () {
      return esperarFalha<ServicoIndisponivel>((_) => Completer<http.Response>().future);
    });

    test('erro no servidor', () {
      return esperarFalha<ServicoIndisponivel>((_) async => http.Response('', 503));
    });

    test('limite de requisições', () {
      return esperarFalha<ServicoIndisponivel>((_) async => http.Response('', 429));
    });

    test('status inesperado', () {
      return esperarFalha<RespostaInvalida>((_) async => http.Response('', 404));
    });

    test('corpo que não é XML', () {
      return esperarFalha<RespostaInvalida>((_) async => http.Response('Service Unavailable', 200));
    });
  });
}
