import 'package:intl/intl.dart';

import '../models/previsao.dart';

/// Textos formatados em pt-BR exibidos nas telas.
abstract final class Formatos {
  static const indisponivel = '—';

  /// "28°", ou um traço quando o valor não veio do serviço.
  static String temperatura(int? graus) => graus == null ? indisponivel : '$graus°';

  /// "Dom", "Seg"...
  static String diaDaSemanaCurto(DateTime data) =>
      _capitalizar(DateFormat('EEE', 'pt_BR').format(data).replaceAll('.', ''));

  /// "Domingo"
  static String diaDaSemana(DateTime data) =>
      _capitalizar(DateFormat('EEEE', 'pt_BR').format(data));

  /// "15 nov"
  static String diaEMes(DateTime data) =>
      DateFormat('d MMM', 'pt_BR').format(data).replaceAll('.', '');

  /// "Domingo, 15 de novembro"
  static String dataPorExtenso(DateTime data) =>
      _capitalizar(DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(data));

  /// "15/11/2026"
  static String data(DateTime data) => DateFormat('dd/MM/yyyy', 'pt_BR').format(data);

  /// "15/11 às 09:41"
  static String dataEHora(DateTime data) => DateFormat("dd/MM 'às' HH:mm", 'pt_BR').format(data);

  /// "IUV 7 · Alto"
  static String indiceUv(PrevisaoDia dia) {
    final indice = dia.indiceUv;
    if (indice == null) return 'IUV não informado';
    final valor = indice == indice.roundToDouble() ? indice.toStringAsFixed(0) : '$indice';
    return 'IUV $valor · ${dia.nivelUv!.rotulo}';
  }

  static String _capitalizar(String texto) =>
      texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);
}
