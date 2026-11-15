import 'package:xml/xml.dart';

import '../models/cidade.dart';
import '../models/condicao_tempo.dart';
import '../models/previsao.dart';
import 'falhas.dart';

/// Converte a resposta de `listaCidades` em cidades. Itens sem código ou
/// nome são descartados, pois não podem ser consultados.
List<Cidade> lerCidades(String xml) {
  final raiz = _abrir(xml, 'cidades');
  return raiz.findElements('cidade').map(_lerCidade).nonNulls.toList();
}

/// Converte a resposta de `cidade/{codigo}/previsao.xml`.
///
/// Para códigos inexistentes o serviço responde com todos os campos iguais a
/// "null"; nesse caso o resultado é uma previsão sem dias.
Previsao lerPrevisao(String xml) {
  final raiz = _abrir(xml, 'cidade');
  final dias = raiz.findElements('previsao').map(_lerDia).where(_temDados).toList();
  return Previsao(atualizadaEm: _data(raiz, 'atualizacao'), dias: dias);
}

Cidade? _lerCidade(XmlElement item) {
  final id = int.tryParse(_texto(item, 'id') ?? '');
  final nome = _texto(item, 'nome');
  if (id == null || nome == null) return null;
  return Cidade(id: id, nome: nome, uf: _texto(item, 'uf') ?? '');
}

PrevisaoDia _lerDia(XmlElement item) {
  final iuv = double.tryParse(_texto(item, 'iuv') ?? '');
  return PrevisaoDia(
    data: _data(item, 'dia'),
    condicao: CondicaoTempo.daSigla(_texto(item, 'tempo')),
    minima: _inteiro(item, 'minima'),
    maxima: _inteiro(item, 'maxima'),
    // O serviço envia 0.0 quando não há índice calculado para o dia.
    indiceUv: iuv != null && iuv > 0 ? iuv : null,
  );
}

bool _temDados(PrevisaoDia dia) =>
    dia.data != null ||
    dia.minima != null ||
    dia.maxima != null ||
    dia.condicao != CondicaoTempo.naoDefinido;

XmlElement _abrir(String xml, String raizEsperada) {
  try {
    final raiz = XmlDocument.parse(xml).rootElement;
    if (raiz.name.local != raizEsperada) throw const RespostaInvalida();
    return raiz;
  } on XmlException {
    throw const RespostaInvalida();
  }
}

String? _texto(XmlElement pai, String nome) {
  final valor = pai.getElement(nome)?.innerText.trim();
  if (valor == null || valor.isEmpty || valor == 'null') return null;
  return valor;
}

int? _inteiro(XmlElement pai, String nome) => num.tryParse(_texto(pai, nome) ?? '')?.round();

DateTime? _data(XmlElement pai, String nome) => DateTime.tryParse(_texto(pai, nome) ?? '');
