import 'package:flutter/foundation.dart';

import '../data/falhas.dart';
import '../data/repositorio_previsao.dart';
import '../models/cidade.dart';

/// Estado da previsão de uma cidade.
///
/// Se uma atualização falhar depois de a previsão já estar na tela, ela é
/// mantida e a [falha] fica disponível para ser exibida como aviso.
class ControladorPrevisao extends ChangeNotifier {
  ControladorPrevisao(this._repositorio, this.cidade);

  final RepositorioPrevisao _repositorio;
  final Cidade cidade;

  bool _descartado = false;
  bool _carregando = false;
  ResultadoPrevisao? _resultado;
  FalhaCptec? _falha;

  bool get carregando => _carregando;
  ResultadoPrevisao? get resultado => _resultado;
  FalhaCptec? get falha => _falha;

  Future<void> carregar() async {
    if (_carregando) return;
    _carregando = true;
    _falha = null;
    notifyListeners();

    try {
      _resultado = await _repositorio.buscarPrevisao(cidade);
    } on FalhaCptec catch (erro) {
      _falha = erro;
    } finally {
      _carregando = false;
      if (!_descartado) notifyListeners();
    }
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }
}
