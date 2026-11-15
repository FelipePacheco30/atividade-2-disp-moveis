import '../models/cidade.dart';
import '../models/previsao.dart';
import 'armazenamento_local.dart';
import 'cliente_cptec.dart';
import 'falhas.dart';

class ResultadoPrevisao {
  const ResultadoPrevisao(this.previsao, {this.salvaEm, this.falha});

  final Previsao previsao;

  /// Preenchidos quando o serviço falhou e a previsão veio do aparelho.
  final DateTime? salvaEm;
  final FalhaCptec? falha;

  bool get doArmazenamento => falha != null;
}

/// Ponto único de acesso às previsões: consulta o CPTEC, guarda a resposta e
/// recorre à cópia local quando o serviço não pode ser alcançado.
class RepositorioPrevisao {
  RepositorioPrevisao({
    required this._cliente,
    required this._armazenamento,
    this._agora = DateTime.now,
  });

  final ClienteCptec _cliente;
  final ArmazenamentoLocal _armazenamento;
  final DateTime Function() _agora;

  Future<List<Cidade>> buscarCidades(String nome) => _cliente.buscarCidades(nome);

  Future<ResultadoPrevisao> buscarPrevisao(Cidade cidade) async {
    try {
      final previsao = await _cliente.buscarPrevisao(cidade.id);
      if (!previsao.vazia) {
        await _armazenamento.salvarPrevisao(cidade.id, previsao, _agora());
      }
      return ResultadoPrevisao(previsao);
    } on FalhaCptec catch (falha) {
      final salva = _armazenamento.lerPrevisao(cidade.id);
      if (salva == null) rethrow;
      return ResultadoPrevisao(salva.previsao, salvaEm: salva.salvaEm, falha: falha);
    }
  }

  PrevisaoSalva? previsaoSalva(Cidade cidade) => _armazenamento.lerPrevisao(cidade.id);
}
