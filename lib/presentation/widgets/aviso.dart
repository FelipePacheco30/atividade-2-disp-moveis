import 'package:flutter/material.dart';

/// Faixa de aviso discreta, usada quando os dados exibidos podem estar
/// desatualizados.
class Aviso extends StatelessWidget {
  const Aviso(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tema.colorScheme.tertiary.withValues(alpha: 0.08),
        border: Border(left: BorderSide(color: tema.colorScheme.tertiary, width: 3)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cloud_off_outlined, size: 18, color: tema.colorScheme.tertiary),
          const SizedBox(width: 12),
          Expanded(child: Text(texto, style: tema.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
