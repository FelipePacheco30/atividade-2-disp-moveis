import 'package:flutter/material.dart';

import '../../core/formatos.dart';
import '../../core/tema.dart';
import '../../models/previsao.dart';
import 'icone_condicao.dart';

/// Um dia da previsão: data, condição, índice UV e temperaturas.
class LinhaDia extends StatelessWidget {
  const LinhaDia(this.dia, {super.key});

  final PrevisaoDia dia;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = CoresTemperatura.de(context);
    final secundario = tema.colorScheme.onSurfaceVariant;
    final numeros = tema.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final data = dia.data;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data == null ? 'Sem data' : Formatos.diaDaSemanaCurto(data),
                  style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (data != null)
                  Text(
                    Formatos.diaEMes(data),
                    style: tema.textTheme.bodySmall?.copyWith(color: secundario),
                  ),
              ],
            ),
          ),
          IconeCondicao(dia.condicao, tamanho: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dia.condicao.descricao, style: tema.textTheme.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  Formatos.indiceUv(dia),
                  style: tema.textTheme.bodySmall?.copyWith(color: secundario),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            label:
                'Máxima ${Formatos.temperatura(dia.maxima)}, mínima ${Formatos.temperatura(dia.minima)}',
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatos.temperatura(dia.maxima),
                  style: numeros?.copyWith(color: cores.maxima),
                ),
                Text(
                  Formatos.temperatura(dia.minima),
                  style: numeros?.copyWith(color: cores.minima),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
