import 'condicao_tempo.dart';

/// Previsão de uma localidade como informada pelo CPTEC.
class Previsao {
  const Previsao({required this.atualizadaEm, required this.dias});

  factory Previsao.deJson(Map<String, Object?> json) {
    final dias = json['dias'] as List<Object?>;
    return Previsao(
      atualizadaEm: _lerData(json['atualizadaEm']),
      dias: [for (final dia in dias) PrevisaoDia.deJson(dia as Map<String, Object?>)],
    );
  }

  /// Data de atualização informada pelo serviço (campo `atualizacao`).
  final DateTime? atualizadaEm;
  final List<PrevisaoDia> dias;

  bool get vazia => dias.isEmpty;

  Map<String, Object?> paraJson() => {
    'atualizadaEm': atualizadaEm?.toIso8601String(),
    'dias': [for (final dia in dias) dia.paraJson()],
  };
}

class PrevisaoDia {
  const PrevisaoDia({
    required this.data,
    required this.condicao,
    required this.minima,
    required this.maxima,
    required this.indiceUv,
  });

  factory PrevisaoDia.deJson(Map<String, Object?> json) {
    return PrevisaoDia(
      data: _lerData(json['data']),
      condicao: CondicaoTempo.daSigla(json['condicao'] as String?),
      minima: json['minima'] as int?,
      maxima: json['maxima'] as int?,
      indiceUv: (json['indiceUv'] as num?)?.toDouble(),
    );
  }

  final DateTime? data;
  final CondicaoTempo condicao;

  /// Temperaturas em graus Celsius.
  final int? minima;
  final int? maxima;

  /// Índice ultravioleta máximo do dia; nulo quando o serviço não informa.
  final double? indiceUv;

  NivelUv? get nivelUv => indiceUv == null ? null : NivelUv.doIndice(indiceUv!);

  Map<String, Object?> paraJson() => {
    'data': data?.toIso8601String(),
    'condicao': condicao.sigla,
    'minima': minima,
    'maxima': maxima,
    'indiceUv': indiceUv,
  };
}

/// Faixas de exposição ao índice ultravioleta usadas pelo CPTEC (padrão OMS).
enum NivelUv {
  baixo('Baixo'),
  moderado('Moderado'),
  alto('Alto'),
  muitoAlto('Muito alto'),
  extremo('Extremo');

  const NivelUv(this.rotulo);

  final String rotulo;

  static NivelUv doIndice(double indice) {
    if (indice < 3) return baixo;
    if (indice < 6) return moderado;
    if (indice < 8) return alto;
    if (indice < 11) return muitoAlto;
    return extremo;
  }
}

DateTime? _lerData(Object? valor) => valor is String ? DateTime.tryParse(valor) : null;
