import 'package:flutter/material.dart';

import '../../controllers/cidades_salvas.dart';
import '../../core/formatos.dart';
import '../../data/armazenamento_local.dart';
import '../../data/repositorio_previsao.dart';
import '../../models/cidade.dart';
import '../../models/previsao.dart';
import '../widgets/fonte_dos_dados.dart';
import '../widgets/icone_condicao.dart';
import '../widgets/mensagem_estado.dart';
import '../widgets/sigla_uf.dart';
import 'tela_busca.dart';
import 'tela_previsao.dart';

/// Ponto de partida: acesso à busca e lista das cidades salvas com o resumo
/// da última previsão guardada no aparelho.
class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key, required this.repositorio, required this.cidadesSalvas});

  final RepositorioPrevisao repositorio;
  final CidadesSalvas cidadesSalvas;

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  static const larguraMaxima = 720.0;

  Future<void> _abrir(Widget tela) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => tela));
    // Volta com previsões possivelmente atualizadas no armazenamento.
    if (mounted) setState(() {});
  }

  void _abrirBusca() =>
      _abrir(TelaBusca(repositorio: widget.repositorio, cidadesSalvas: widget.cidadesSalvas));

  void _abrirPrevisao(Cidade cidade) => _abrir(
    TelaPrevisao(
      cidade: cidade,
      repositorio: widget.repositorio,
      cidadesSalvas: widget.cidadesSalvas,
    ),
  );

  void _remover(Cidade cidade) {
    final posicao = widget.cidadesSalvas.cidades.indexOf(cidade);
    widget.cidadesSalvas.remover(cidade);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${cidade.nome} foi removida.'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => widget.cidadesSalvas.adicionar(cidade, posicao: posicao),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previsão do tempo'),
        actions: [
          IconButton(
            onPressed: _abrirBusca,
            tooltip: 'Buscar cidade',
            icon: const Icon(Icons.search),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: larguraMaxima),
          child: ListenableBuilder(
            listenable: widget.cidadesSalvas,
            builder: (context, _) {
              final cidades = widget.cidadesSalvas.cidades;
              return Column(
                children: [
                  _CampoBusca(aoTocar: _abrirBusca),
                  Expanded(
                    child: cidades.isEmpty
                        ? const MensagemEstado(
                            icone: Icons.star_outline,
                            titulo: 'Nenhuma cidade salva',
                            descricao:
                                'Busque uma cidade e toque na estrela para acompanhar a '
                                'previsão dela por aqui.',
                          )
                        : _ListaCidades(
                            cidades: cidades,
                            previsaoSalva: widget.repositorio.previsaoSalva,
                            aoTocar: _abrirPrevisao,
                            aoRemover: _remover,
                          ),
                  ),
                  if (cidades.isEmpty) const FonteDosDados(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CampoBusca extends StatelessWidget {
  const _CampoBusca({required this.aoTocar});

  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Semantics(
        button: true,
        label: 'Buscar cidade',
        excludeSemantics: true,
        child: Material(
          color: tema.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: tema.colorScheme.outline),
            borderRadius: BorderRadius.circular(4),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: aoTocar,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.search, color: tema.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Text(
                    'Buscar cidade',
                    style: tema.textTheme.bodyLarge?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ListaCidades extends StatelessWidget {
  const _ListaCidades({
    required this.cidades,
    required this.previsaoSalva,
    required this.aoTocar,
    required this.aoRemover,
  });

  final List<Cidade> cidades;
  final PrevisaoSalva? Function(Cidade) previsaoSalva;
  final ValueChanged<Cidade> aoTocar;
  final ValueChanged<Cidade> aoRemover;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            'CIDADES SALVAS',
            style: tema.textTheme.labelMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        for (final (indice, cidade) in cidades.indexed) ...[
          if (indice > 0) const Divider(indent: 20, endIndent: 20),
          Dismissible(
            key: ValueKey(cidade.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => aoRemover(cidade),
            background: Container(
              color: tema.colorScheme.error,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Icon(Icons.delete_outline, color: tema.colorScheme.onError),
            ),
            child: _ItemCidadeSalva(
              cidade: cidade,
              salva: previsaoSalva(cidade),
              aoTocar: () => aoTocar(cidade),
            ),
          ),
        ],
        const Divider(indent: 20, endIndent: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Text(
            'Deslize uma cidade para a esquerda para removê-la.',
            style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant),
          ),
        ),
        const FonteDosDados(),
      ],
    );
  }
}

class _ItemCidadeSalva extends StatelessWidget {
  const _ItemCidadeSalva({required this.cidade, required this.salva, required this.aoTocar});

  final Cidade cidade;
  final PrevisaoSalva? salva;
  final VoidCallback aoTocar;

  /// "Dom, 15 nov · Chuva", referente ao primeiro dia da previsão salva.
  static String _resumo(PrevisaoDia dia) {
    final data = dia.data;
    final quando = data == null
        ? null
        : '${Formatos.diaDaSemanaCurto(data)}, ${Formatos.diaEMes(data)}';
    return [?quando, dia.condicao.descricao].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final secundario = tema.colorScheme.onSurfaceVariant;
    final dia = salva?.previsao.dias.firstOrNull;

    return ListTile(
      onTap: aoTocar,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: SiglaUf(cidade.uf),
      title: Text(cidade.nome, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        dia == null ? 'Toque para consultar a previsão' : _resumo(dia),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: secundario),
      ),
      trailing: dia == null
          ? Icon(Icons.chevron_right, color: secundario)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconeCondicao(dia.condicao),
                const SizedBox(width: 12),
                Text(
                  '${Formatos.temperatura(dia.maxima)} / ${Formatos.temperatura(dia.minima)}',
                  style: tema.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
    );
  }
}
