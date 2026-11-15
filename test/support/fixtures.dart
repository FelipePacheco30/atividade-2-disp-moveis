import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Respostas reais do CPTEC gravadas em ISO-8859-1, como o serviço envia.
List<int> bytesDaFixture(String nome) => File('test/fixtures/$nome').readAsBytesSync();

String fixture(String nome) => latin1.decode(bytesDaFixture(nome));

http.Response respostaCptec(String nomeFixture, {int status = 200}) {
  return http.Response.bytes(
    bytesDaFixture(nomeFixture),
    status,
    headers: {'content-type': 'text/xml;charset=ISO-8859-1'},
  );
}

/// Simula o serviço: a busca responde com [busca] e a previsão de cada
/// código usa a fixture indicada em [previsoes].
MockClient servicoFalso({
  String busca = 'busca_sao_paulo.xml',
  Map<int, String> previsoes = const {244: 'previsao_sao_paulo.xml'},
}) {
  return MockClient((request) async {
    if (request.url.path.endsWith('listaCidades')) return respostaCptec(busca);
    final codigo = int.parse(request.url.pathSegments[2]);
    return respostaCptec(previsoes[codigo] ?? 'previsao_inexistente.xml');
  });
}
