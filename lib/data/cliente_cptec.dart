import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/cidade.dart';
import '../models/previsao.dart';
import 'falhas.dart';
import 'leitor_xml_cptec.dart';

/// Acesso ao serviço XML do CPTEC/INPE.
///
/// Documentação: https://servicos.cptec.inpe.br/XML/
class ClienteCptec {
  ClienteCptec({http.Client? cliente, this.tempoLimite = const Duration(seconds: 15)})
    : _http = cliente ?? http.Client();

  static const _host = 'servicos.cptec.inpe.br';

  final http.Client _http;
  final Duration tempoLimite;

  Future<List<Cidade>> buscarCidades(String nome) async {
    final termo = nome.trim();
    if (termo.isEmpty) return const [];
    final xml = await _get(Uri.https(_host, '/XML/listaCidades', {'city': termo}));
    return lerCidades(xml);
  }

  /// Previsão de quatro dias para o [codigo] retornado por [buscarCidades].
  Future<Previsao> buscarPrevisao(int codigo) async {
    final xml = await _get(Uri.https(_host, '/XML/cidade/$codigo/previsao.xml'));
    return lerPrevisao(xml);
  }

  void fechar() => _http.close();

  Future<String> _get(Uri uri) async {
    final http.Response resposta;
    try {
      resposta = await _http.get(uri).timeout(tempoLimite);
    } on TimeoutException {
      throw const ServicoIndisponivel(
        'O CPTEC/INPE demorou demais para responder. Tente novamente.',
      );
    } on http.ClientException {
      throw const FalhaConexao();
    } on IOException {
      throw const FalhaConexao();
    }

    if (resposta.statusCode == 429 || resposta.statusCode >= 500) {
      throw const ServicoIndisponivel();
    }
    if (resposta.statusCode != 200) throw const RespostaInvalida();

    // O serviço declara ISO-8859-1 no Content-Type, e `body` decodifica
    // com esse charset (latin1 também é o padrão quando ele não vem).
    return resposta.body;
  }
}
