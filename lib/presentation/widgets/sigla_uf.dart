import 'package:flutter/material.dart';

/// Sigla da unidade da federação em uma caixa de largura fixa, para alinhar
/// os nomes das cidades na lista.
class SiglaUf extends StatelessWidget {
  const SiglaUf(this.uf, {super.key});

  final String uf;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      width: 40,
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: tema.colorScheme.outline),
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.center,
      child: Text(
        uf.isEmpty ? '—' : uf,
        style: tema.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
