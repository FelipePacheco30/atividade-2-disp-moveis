import 'package:flutter/material.dart';

/// Mensagem centralizada para estados sem conteúdo: vazio, erro ou instrução.
class MensagemEstado extends StatelessWidget {
  const MensagemEstado({
    super.key,
    required this.icone,
    required this.titulo,
    this.descricao,
    this.acao,
    this.rotuloAcao,
  });

  final IconData icone;
  final String titulo;
  final String? descricao;
  final VoidCallback? acao;
  final String? rotuloAcao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 40, color: tema.colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (descricao != null) ...[
                const SizedBox(height: 8),
                Text(
                  descricao!,
                  textAlign: TextAlign.center,
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (acao != null) ...[
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: acao,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(rotuloAcao ?? 'Tentar novamente'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
