import 'package:flutter/foundation.dart';

import '../data/armazenamento_local.dart';
import '../models/cidade.dart';

/// Cidades que o usuário acompanha na tela inicial. Compartilhado entre as
/// telas para que a estrela da previsão e a lista fiquem sincronizadas.
class CidadesSalvas extends ChangeNotifier {
  CidadesSalvas(this._armazenamento) : _cidades = _armazenamento.lerCidades();

  final ArmazenamentoLocal _armazenamento;
  final List<Cidade> _cidades;

  List<Cidade> get cidades => List.unmodifiable(_cidades);

  bool contem(Cidade cidade) => _cidades.contains(cidade);

  Future<void> alternar(Cidade cidade) => contem(cidade) ? remover(cidade) : adicionar(cidade);

  /// Novas cidades entram no topo; [posicao] permite desfazer uma remoção.
  Future<void> adicionar(Cidade cidade, {int posicao = 0}) {
    if (contem(cidade)) return Future.value();
    _cidades.insert(posicao.clamp(0, _cidades.length), cidade);
    return _salvar();
  }

  Future<void> remover(Cidade cidade) {
    _cidades.remove(cidade);
    return _salvar();
  }

  Future<void> _salvar() {
    notifyListeners();
    return _armazenamento.salvarCidades(_cidades);
  }
}
