/// Falhas previstas ao consultar o CPTEC. A [mensagem] já é adequada para
/// ser exibida ao usuário.
sealed class FalhaCptec implements Exception {
  const FalhaCptec(this.mensagem);

  final String mensagem;

  @override
  String toString() => '$runtimeType: $mensagem';
}

class FalhaConexao extends FalhaCptec {
  const FalhaConexao() : super('Sem conexão com a internet. Verifique sua rede e tente novamente.');
}

class ServicoIndisponivel extends FalhaCptec {
  const ServicoIndisponivel([
    super.mensagem =
        'O serviço do CPTEC/INPE está indisponível no momento. Tente novamente em instantes.',
  ]);
}

class RespostaInvalida extends FalhaCptec {
  const RespostaInvalida()
    : super('O CPTEC/INPE enviou uma resposta que não pôde ser lida. Tente novamente mais tarde.');
}
