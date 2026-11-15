import 'package:flutter/material.dart';

import '../../controllers/cidades_salvas.dart';
import '../../controllers/controlador_busca.dart';
import '../../data/falhas.dart';
import '../../data/repositorio_previsao.dart';
import '../../models/cidade.dart';
import '../widgets/mensagem_estado.dart';
import '../widgets/sigla_uf.dart';
import 'tela_previsao.dart';

class TelaBusca extends StatefulWidget {
  const TelaBusca({super.key, required this.repositorio, required this.cidadesSalvas});

  final RepositorioPrevisao repositorio;
  final CidadesSalvas cidadesSalvas;

  @override
  State<TelaBusca> createState() => _TelaBuscaState();
}

class _TelaBuscaState extends State<TelaBusca> {
  late final _controlador = ControladorBusca(widget.repositorio);
  final _campo = TextEditingController();

  @override
  void dispose() {
    _controlador.dispose();
    _campo.dispose();
    super.dispose();
  }

  void _limpar() {
    _campo.clear();
    _controlador.alterarTermo('');
  }

  void _abrirPrevisao(Cidade cidade) {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TelaPrevisao(
          cidade: cidade,
          repositorio: widget.repositorio,
          cidadesSalvas: widget.cidadesSalvas,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar cidade')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: ListenableBuilder(
              listenable: _campo,
              builder: (context, _) => TextField(
                controller: _campo,
                autofocus: true,
                textInputAction: TextInputAction.search,
                textCapitalization: TextCapitalization.words,
                onChanged: _controlador.alterarTermo,
                onSubmitted: (_) => _controlador.buscar(),
                decoration: InputDecoration(
                  hintText: 'Nome da cidade',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _campo.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: _limpar,
                          tooltip: 'Limpar',
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: Listenable.merge([_controlador, widget.cidadesSalvas]),
              builder: (context, _) => Column(
                children: [
                  SizedBox(
                    height: 2,
                    child: _controlador.carregando
                        ? const LinearProgressIndicator(minHeight: 2)
                        : null,
                  ),
                  Expanded(child: _resultados()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultados() {
    final resultados = _controlador.resultados;
    final falha = _controlador.falha;

    if (falha != null) {
      return MensagemEstado(
        icone: falha is FalhaConexao ? Icons.wifi_off_outlined : Icons.cloud_off_outlined,
        titulo: 'Não foi possível buscar',
        descricao: falha.mensagem,
        acao: _controlador.buscar,
      );
    }
    if (resultados == null) {
      if (_controlador.carregando) return const SizedBox.shrink();
      return const MensagemEstado(
        icone: Icons.travel_explore_outlined,
        titulo: 'Pesquise uma cidade brasileira',
        descricao:
            'Digite ao menos ${ControladorBusca.minimoLetras} letras do nome. '
            'As localidades vêm do CPTEC/INPE.',
      );
    }
    if (resultados.isEmpty) {
      return MensagemEstado(
        icone: Icons.location_off_outlined,
        titulo: 'Nenhuma cidade encontrada',
        descricao:
            'O CPTEC/INPE não tem localidades para “${_controlador.termoBuscado}”. '
            'Confira a grafia ou digite só parte do nome.',
      );
    }

    final tema = Theme.of(context);
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: resultados.length + 1,
      separatorBuilder: (_, indice) =>
          indice == 0 ? const SizedBox.shrink() : const Divider(indent: 20, endIndent: 20),
      itemBuilder: (context, indice) {
        if (indice == 0) {
          final total = resultados.length;
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Text(
              total == 1 ? '1 localidade' : '$total localidades',
              style: tema.textTheme.labelMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant),
            ),
          );
        }
        final cidade = resultados[indice - 1];
        return _ItemCidade(
          cidade: cidade,
          salva: widget.cidadesSalvas.contem(cidade),
          aoTocar: () => _abrirPrevisao(cidade),
        );
      },
    );
  }
}

class _ItemCidade extends StatelessWidget {
  const _ItemCidade({required this.cidade, required this.salva, required this.aoTocar});

  final Cidade cidade;
  final bool salva;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ListTile(
      onTap: aoTocar,
      leading: SiglaUf(cidade.uf),
      title: Text(cidade.nome),
      trailing: salva
          ? Icon(Icons.star, size: 20, color: tema.colorScheme.tertiary, semanticLabel: 'Salva')
          : Icon(Icons.chevron_right, color: tema.colorScheme.onSurfaceVariant),
    );
  }
}
