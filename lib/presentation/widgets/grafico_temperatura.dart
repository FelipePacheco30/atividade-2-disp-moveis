import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/formatos.dart';
import '../../core/tema.dart';
import '../../models/previsao.dart';

/// Linhas de temperatura máxima e mínima ao longo dos dias da previsão.
/// Dias sem temperatura interrompem a linha em vez de inventar um valor.
class GraficoTemperatura extends StatelessWidget {
  const GraficoTemperatura({super.key, required this.dias});

  final List<PrevisaoDia> dias;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = CoresTemperatura.de(context);
    final temperaturas = [
      for (final dia in dias) ...[?dia.minima, ?dia.maxima],
    ];

    if (temperaturas.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'O CPTEC/INPE não informou temperaturas para estes dias.',
            style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    final menor = temperaturas.reduce(math.min);
    final maior = temperaturas.reduce(math.max);
    final intervalo = maior - menor <= 8 ? 2.0 : 5.0;
    // Uma linha de grade de folga além dos extremos, sem sobrar faixa vazia.
    final minY = (menor / intervalo).ceil() * intervalo - intervalo;
    final maxY = (maior / intervalo).floor() * intervalo + intervalo;
    final estiloEixo = tema.textTheme.labelSmall?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Legenda(cor: cores.maxima, rotulo: 'Máxima'),
            const SizedBox(width: 20),
            _Legenda(cor: cores.minima, rotulo: 'Mínima'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minX: -0.25,
              maxX: dias.length - 0.75,
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                _linha([for (final dia in dias) dia.maxima], cores.maxima, tema),
                _linha([for (final dia in dias) dia.minima], cores.minima, tema),
              ],
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: intervalo,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: tema.colorScheme.outlineVariant,
                  strokeWidth: 1,
                  dashArray: const [3, 4],
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: intervalo,
                    getTitlesWidget: (valor, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text('${valor.round()}°', style: estiloEixo),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    interval: 1,
                    getTitlesWidget: (valor, meta) {
                      final indice = valor.round();
                      if (valor != indice || indice < 0 || indice >= dias.length) {
                        return const SizedBox.shrink();
                      }
                      final data = dias[indice].data;
                      return SideTitleWidget(
                        meta: meta,
                        space: 10,
                        child: Text(
                          data == null
                              ? Formatos.indisponivel
                              : '${Formatos.diaDaSemanaCurto(data)}\n${Formatos.diaEMes(data)}',
                          style: estiloEixo,
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => tema.colorScheme.inverseSurface,
                  tooltipBorderRadius: BorderRadius.circular(4),
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (pontos) => [
                    for (final ponto in pontos)
                      LineTooltipItem(
                        '${ponto.barIndex == 0 ? 'Máx.' : 'Mín.'} ${ponto.y.round()}°',
                        TextStyle(
                          color: tema.colorScheme.onInverseSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  LineChartBarData _linha(List<int?> valores, Color cor, ThemeData tema) {
    return LineChartBarData(
      spots: [
        for (final (indice, valor) in valores.indexed)
          valor == null ? FlSpot.nullSpot : FlSpot(indice.toDouble(), valor.toDouble()),
      ],
      color: cor,
      barWidth: 2.5,
      isCurved: true,
      preventCurveOverShooting: true,
      dotData: FlDotData(
        getDotPainter: (_, _, _, _) => FlDotCirclePainter(
          radius: 4,
          color: cor,
          strokeWidth: 2,
          strokeColor: tema.colorScheme.surfaceContainerLow,
        ),
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda({required this.cor, required this.rotulo});

  final Color cor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 3, color: cor),
        const SizedBox(width: 8),
        Text(rotulo, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
