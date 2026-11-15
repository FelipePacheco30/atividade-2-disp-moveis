import 'package:flutter/material.dart';

import '../../controllers/cidades_salvas.dart';
import '../../controllers/controlador_previsao.dart';
import '../../core/formatos.dart';
import '../../data/falhas.dart';
import '../../data/repositorio_previsao.dart';
import '../../models/cidade.dart';
import '../../models/previsao.dart';
import '../widgets/aviso.dart';
import '../widgets/fonte_dos_dados.dart';
import '../widgets/grafico_temperatura.dart';
import '../widgets/icone_condicao.dart';
import '../widgets/linha_dia.dart';
import '../widgets/mensagem_estado.dart';

class TelaPrevisao extends StatefulWidget {
  const TelaPrevisao({
    super.key,
    required this.cidade,
    required this.repositorio,
    required this.cidadesSalvas,
  });

  final Cidade cidade;
  final RepositorioPrevisao repositorio;
  final CidadesSalvas cidadesSalvas;

  @override
  State<TelaPrevisao> createState() => _TelaPrevisaoState();
}

class _TelaPrevisaoState extends State<TelaPrevisao> {
  late final _controlador = ControladorPrevisao(widget.repositorio, widget.cidade);

  @override
  void initState() {
    super.initState();
    _controlador.carregar();
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _alternarCidadeSalva() {
    final cidade = widget.cidade;
    final salva = !widget.cidadesSalvas.contem(cidade);
    widget.cidadesSalvas.alternar(cidade);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            salva
                ? '${cidade.nome} aparece agora na tela inicial.'
                : '${cidade.nome} foi removida das cidades salvas.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([_controlador, widget.cidadesSalvas]),
      builder: (context, _) {
        final salva = widget.cidadesSalvas.contem(widget.cidade);
        final carregando = _controlador.carregando;
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.cidade.nome, overflow: TextOverflow.ellipsis),
                Text(
                  widget.cidade.uf,
                  style: tema.textTheme.labelMedium?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: _alternarCidadeSalva,
                tooltip: salva ? 'Remover das cidades salvas' : 'Salvar cidade',
                isSelected: salva,
                icon: const Icon(Icons.star_outline),
                selectedIcon: Icon(Icons.star, color: tema.colorScheme.tertiary),
              ),
              IconButton(
                onPressed: carregando ? null : _controlador.carregar,
                tooltip: 'Atualizar previsão',
                icon: const Icon(Icons.refresh),
              ),
              const SizedBox(width: 4),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2),
              child: carregando && _controlador.resultado != null
                  ? const LinearProgressIndicator(minHeight: 2)
                  : const SizedBox(height: 2),
            ),
          ),
          body: _corpo(),
        );
      },
    );
  }

  Widget _corpo() {
    final resultado = _controlador.resultado;
    final falha = _controlador.falha;

    if (resultado == null) {
      if (falha != null) {
        return MensagemEstado(
          icone: falha is FalhaConexao ? Icons.wifi_off_outlined : Icons.cloud_off_outlined,
          titulo: 'Não foi possível carregar a previsão',
          descricao: falha.mensagem,
          acao: _controlador.carregar,
        );
      }
      return const _Carregando();
    }

    final previsao = resultado.previsao;
    final aviso = switch ((falha, resultado.salvaEm)) {
      (final falha?, _) => 'Não foi possível atualizar. ${falha.mensagem}',
      (null, final salvaEm?) =>
        '${resultado.falha!.mensagem} Exibindo a previsão salva em ${Formatos.dataEHora(salvaEm)}.',
      _ => null,
    };

    if (previsao.vazia) {
      return Column(
        children: [
          if (aviso != null) Aviso(aviso),
          Expanded(
            child: MensagemEstado(
              icone: Icons.event_busy_outlined,
              titulo: 'Previsão indisponível',
              descricao:
                  'O CPTEC/INPE não retornou previsão para ${widget.cidade.nome} no momento.',
              acao: _controlador.carregar,
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _controlador.carregar,
      child: _ConteudoPrevisao(previsao: previsao, aviso: aviso),
    );
  }
}

class _Carregando extends StatelessWidget {
  const _Carregando();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Consultando o CPTEC/INPE…',
            style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ConteudoPrevisao extends StatelessWidget {
  const _ConteudoPrevisao({required this.previsao, required this.aviso});

  static const larguraDuasColunas = 840.0;

  final Previsao previsao;
  final String? aviso;

  @override
  Widget build(BuildContext context) {
    final destaque = _Destaque(dia: previsao.dias.first, atualizadaEm: previsao.atualizadaEm);
    final dias = _Secao(
      titulo: 'Previsão para ${previsao.dias.length} dias',
      espacamento: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (indice, dia) in previsao.dias.indexed) ...[
            if (indice > 0) const Divider(indent: 20, endIndent: 20),
            LinhaDia(dia),
          ],
        ],
      ),
    );
    final grafico = _Secao(
      titulo: 'Temperatura',
      child: GraficoTemperatura(dias: previsao.dias),
    );

    return LayoutBuilder(
      builder: (context, restricoes) {
        final largo = restricoes.maxWidth >= larguraDuasColunas;
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (aviso != null) Aviso(aviso!),
            if (largo)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Column(children: [destaque, const Divider(), dias])),
                      const SizedBox(width: 24),
                      Expanded(child: grafico),
                    ],
                  ),
                ),
              )
            else ...[
              destaque,
              const Divider(),
              grafico,
              const Divider(),
              dias,
            ],
            const FonteDosDados(),
          ],
        );
      },
    );
  }
}

class _Destaque extends StatelessWidget {
  const _Destaque({required this.dia, required this.atualizadaEm});

  final PrevisaoDia dia;
  final DateTime? atualizadaEm;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final secundario = tema.colorScheme.onSurfaceVariant;
    const numeros = [FontFeature.tabularFigures()];
    final data = dia.data;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data == null ? 'Data não informada' : Formatos.dataPorExtenso(data),
            style: tema.textTheme.labelLarge?.copyWith(color: secundario),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconeCondicao(dia.condicao, tamanho: 56),
              const SizedBox(width: 20),
              _Temperatura(
                valor: dia.maxima,
                rotulo: 'Máxima',
                estilo: tema.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontFeatures: numeros,
                ),
              ),
              const SizedBox(width: 20),
              _Temperatura(
                valor: dia.minima,
                rotulo: 'Mínima',
                estilo: tema.textTheme.displaySmall?.copyWith(
                  color: secundario,
                  fontFeatures: numeros,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(dia.condicao.descricao, style: tema.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            Formatos.indiceUv(dia),
            style: tema.textTheme.bodySmall?.copyWith(color: secundario),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: secundario),
              const SizedBox(width: 6),
              Text(
                atualizadaEm == null
                    ? 'Data de atualização não informada pelo CPTEC/INPE'
                    : 'Atualizada pelo CPTEC/INPE em ${Formatos.data(atualizadaEm!)}',
                style: tema.textTheme.bodySmall?.copyWith(color: secundario),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Temperatura extends StatelessWidget {
  const _Temperatura({required this.valor, required this.rotulo, required this.estilo});

  final int? valor;
  final String rotulo;
  final TextStyle? estilo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Formatos.temperatura(valor), style: estilo),
        Text(
          rotulo,
          style: tema.textTheme.labelSmall?.copyWith(color: tema.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao({
    required this.titulo,
    required this.child,
    this.espacamento = const EdgeInsets.symmetric(horizontal: 20),
  });

  final String titulo;
  final Widget child;
  final EdgeInsets espacamento;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              titulo.toUpperCase(),
              style: tema.textTheme.labelMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Padding(padding: espacamento, child: child),
        ],
      ),
    );
  }
}
