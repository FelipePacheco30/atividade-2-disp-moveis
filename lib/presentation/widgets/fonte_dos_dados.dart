import 'package:flutter/material.dart';

/// Identificação do CPTEC/INPE como fonte das informações exibidas.
class FonteDosDados extends StatelessWidget {
  const FonteDosDados({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Text.rich(
        const TextSpan(
          children: [
            TextSpan(text: 'Dados: '),
            TextSpan(
              text: 'CPTEC/INPE',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: ' · Centro de Previsão de Tempo e Estudos Climáticos'),
          ],
        ),
        style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant),
        textAlign: TextAlign.center,
      ),
    );
  }
}
