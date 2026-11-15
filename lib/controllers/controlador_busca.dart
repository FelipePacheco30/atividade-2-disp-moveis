import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/falhas.dart';
import '../data/repositorio_previsao.dart';
import '../models/cidade.dart';

/// Estado da busca de cidades. A consulta é feita enquanto o usuário digita,
/// após uma pequena pausa, e respostas de termos antigos são descartadas.
class ControladorBusca extends ChangeNotifier {
  ControladorBusca(this._repositorio, {this.espera = const Duration(milliseconds: 400)});

  static const minimoLetras = 3;

  final RepositorioPrevisao _repositorio;
  final Duration espera;

  Timer? _timer;
  int _consultaAtual = 0;
  bool _descartado = false;

  String _termo = '';
  String _termoBuscado = '';
  bool _carregando = false;
  List<Cidade>? _resultados;
  FalhaCptec? _falha;

  bool get carregando => _carregando;
  bool get termoCurto => _termo.trim().length < minimoLetras;

  /// Termo da última busca concluída, usado nas mensagens de resultado.
  String get termoBuscado => _termoBuscado;

  /// Nulo enquanto nenhuma busca foi concluída para o termo atual.
  List<Cidade>? get resultados => _resultados;
  FalhaCptec? get falha => _falha;

  void alterarTermo(String termo) {
    _termo = termo;
    _timer?.cancel();
    if (termoCurto) {
      _consultaAtual++;
      _carregando = false;
      _resultados = null;
      _falha = null;
      notifyListeners();
      return;
    }
    _timer = Timer(espera, buscar);
  }

  Future<void> buscar() async {
    _timer?.cancel();
    if (termoCurto) return;

    final consulta = ++_consultaAtual;
    final termo = _termo.trim();
    _carregando = true;
    _falha = null;
    notifyListeners();

    List<Cidade>? resultados;
    FalhaCptec? falha;
    try {
      resultados = await _repositorio.buscarCidades(termo);
    } on FalhaCptec catch (erro) {
      falha = erro;
    }
    if (_descartado || consulta != _consultaAtual) return;

    _termoBuscado = termo;
    _resultados = resultados;
    _falha = falha;
    _carregando = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    _timer?.cancel();
    super.dispose();
  }
}
