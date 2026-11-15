import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cidade.dart';
import '../models/previsao.dart';

class PrevisaoSalva {
  const PrevisaoSalva({required this.previsao, required this.salvaEm});

  final Previsao previsao;
  final DateTime salvaEm;
}

/// Persiste as cidades salvas pelo usuário e a última previsão obtida de
/// cada cidade consultada, em JSON no `SharedPreferences`.
///
/// Dados corrompidos ou de formato antigo são ignorados em vez de derrubar o app.
class ArmazenamentoLocal {
  ArmazenamentoLocal(this._prefs);

  static const _chaveCidades = 'cidades_salvas';
  static const _chavePrevisoes = 'previsoes';
  static const chaves = {_chaveCidades, _chavePrevisoes};

  /// Quantidade máxima de previsões guardadas; as mais antigas saem primeiro.
  static const limitePrevisoes = 20;

  final SharedPreferencesWithCache _prefs;

  static Future<ArmazenamentoLocal> abrir() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(allowList: chaves),
    );
    return ArmazenamentoLocal(prefs);
  }

  List<Cidade> lerCidades() {
    final lista = _lerJson(_chaveCidades);
    if (lista is! List<Object?>) return [];
    try {
      return [for (final item in lista) Cidade.deJson(item as Map<String, Object?>)];
    } on TypeError {
      return [];
    }
  }

  Future<void> salvarCidades(List<Cidade> cidades) {
    return _prefs.setString(_chaveCidades, jsonEncode([for (final c in cidades) c.paraJson()]));
  }

  PrevisaoSalva? lerPrevisao(int codigoCidade) {
    final item = _lerPrevisoes()['$codigoCidade'];
    if (item == null) return null;
    try {
      return PrevisaoSalva(
        previsao: Previsao.deJson(item['previsao'] as Map<String, Object?>),
        salvaEm: DateTime.parse(item['salvaEm'] as String),
      );
    } on TypeError {
      return null;
    } on FormatException {
      return null;
    }
  }

  Future<void> salvarPrevisao(int codigoCidade, Previsao previsao, DateTime salvaEm) {
    final previsoes = _lerPrevisoes();
    previsoes['$codigoCidade'] = {
      'salvaEm': salvaEm.toIso8601String(),
      'previsao': previsao.paraJson(),
    };

    final maisRecentes = previsoes.entries.toList()
      ..sort((a, b) => '${b.value['salvaEm']}'.compareTo('${a.value['salvaEm']}'));
    return _prefs.setString(
      _chavePrevisoes,
      jsonEncode(Map.fromEntries(maisRecentes.take(limitePrevisoes))),
    );
  }

  Map<String, Map<String, Object?>> _lerPrevisoes() {
    final mapa = _lerJson(_chavePrevisoes);
    if (mapa is! Map<String, Object?>) return {};
    return {
      for (final MapEntry(:key, :value) in mapa.entries)
        if (value is Map<String, Object?>) key: value,
    };
  }

  Object? _lerJson(String chave) {
    final texto = _prefs.getString(chave);
    if (texto == null) return null;
    try {
      return jsonDecode(texto);
    } on FormatException {
      return null;
    }
  }
}
