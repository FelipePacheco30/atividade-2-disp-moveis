/// Agrupa as siglas do CPTEC em poucas categorias visuais (ícone e cor).
enum GrupoTempo {
  sol,
  parcialmenteNublado,
  nublado,
  chuvisco,
  chuva,
  pancadas,
  tempestade,
  nevoeiro,
  geada,
  neve,
  indefinido,
}

/// Condição do tempo identificada pela sigla do CPTEC/INPE.
///
/// As descrições seguem a tabela "Siglas das condições do tempo" da
/// documentação oficial, com as abreviações escritas por extenso.
class CondicaoTempo {
  const CondicaoTempo._(this.sigla, this.descricao, this.grupo);

  factory CondicaoTempo.daSigla(String? sigla) {
    final normalizada = sigla?.trim().toLowerCase() ?? '';
    if (normalizada.isEmpty || normalizada == 'null') return naoDefinido;
    return _porSigla[normalizada] ??
        CondicaoTempo._(normalizada, naoDefinido.descricao, GrupoTempo.indefinido);
  }

  final String sigla;
  final String descricao;
  final GrupoTempo grupo;

  static const naoDefinido = CondicaoTempo._('nd', 'Não definido', GrupoTempo.indefinido);

  static const todas = [
    CondicaoTempo._('ec', 'Encoberto com chuvas isoladas', GrupoTempo.chuva),
    CondicaoTempo._('ci', 'Chuvas isoladas', GrupoTempo.chuva),
    CondicaoTempo._('c', 'Chuva', GrupoTempo.chuva),
    CondicaoTempo._('in', 'Instável', GrupoTempo.tempestade),
    CondicaoTempo._('pp', 'Possibilidade de pancadas de chuva', GrupoTempo.pancadas),
    CondicaoTempo._('cm', 'Chuva pela manhã', GrupoTempo.chuva),
    CondicaoTempo._('cn', 'Chuva à noite', GrupoTempo.chuva),
    CondicaoTempo._('pt', 'Pancadas de chuva à tarde', GrupoTempo.pancadas),
    CondicaoTempo._('pm', 'Pancadas de chuva pela manhã', GrupoTempo.pancadas),
    CondicaoTempo._('np', 'Nublado e pancadas de chuva', GrupoTempo.pancadas),
    CondicaoTempo._('pc', 'Pancadas de chuva', GrupoTempo.pancadas),
    CondicaoTempo._('pn', 'Parcialmente nublado', GrupoTempo.parcialmenteNublado),
    CondicaoTempo._('cv', 'Chuvisco', GrupoTempo.chuvisco),
    CondicaoTempo._('ch', 'Chuvoso', GrupoTempo.chuva),
    CondicaoTempo._('t', 'Tempestade', GrupoTempo.tempestade),
    CondicaoTempo._('ps', 'Predomínio de sol', GrupoTempo.sol),
    CondicaoTempo._('e', 'Encoberto', GrupoTempo.nublado),
    CondicaoTempo._('n', 'Nublado', GrupoTempo.nublado),
    CondicaoTempo._('cl', 'Céu claro', GrupoTempo.sol),
    CondicaoTempo._('nv', 'Nevoeiro', GrupoTempo.nevoeiro),
    CondicaoTempo._('g', 'Geada', GrupoTempo.geada),
    CondicaoTempo._('ne', 'Neve', GrupoTempo.neve),
    naoDefinido,
    CondicaoTempo._('pnt', 'Pancadas de chuva à noite', GrupoTempo.pancadas),
    CondicaoTempo._('psc', 'Possibilidade de chuva', GrupoTempo.chuva),
    CondicaoTempo._('pcm', 'Possibilidade de chuva pela manhã', GrupoTempo.chuva),
    CondicaoTempo._('pct', 'Possibilidade de chuva à tarde', GrupoTempo.chuva),
    CondicaoTempo._('pcn', 'Possibilidade de chuva à noite', GrupoTempo.chuva),
    CondicaoTempo._('npt', 'Nublado com pancadas à tarde', GrupoTempo.pancadas),
    CondicaoTempo._('npn', 'Nublado com pancadas à noite', GrupoTempo.pancadas),
    CondicaoTempo._('ncn', 'Nublado com possibilidade de chuva à noite', GrupoTempo.chuva),
    CondicaoTempo._('nct', 'Nublado com possibilidade de chuva à tarde', GrupoTempo.chuva),
    CondicaoTempo._('ncm', 'Nublado com possibilidade de chuva pela manhã', GrupoTempo.chuva),
    CondicaoTempo._('npm', 'Nublado com pancadas pela manhã', GrupoTempo.pancadas),
    CondicaoTempo._('npp', 'Nublado com possibilidade de chuva', GrupoTempo.chuva),
    CondicaoTempo._('vn', 'Variação de nebulosidade', GrupoTempo.parcialmenteNublado),
    CondicaoTempo._('ct', 'Chuva à tarde', GrupoTempo.chuva),
    CondicaoTempo._('ppn', 'Possibilidade de pancadas de chuva à noite', GrupoTempo.pancadas),
    CondicaoTempo._('ppt', 'Possibilidade de pancadas de chuva à tarde', GrupoTempo.pancadas),
    CondicaoTempo._('ppm', 'Possibilidade de pancadas de chuva pela manhã', GrupoTempo.pancadas),
  ];

  static final Map<String, CondicaoTempo> _porSigla = {
    for (final condicao in todas) condicao.sigla: condicao,
  };

  @override
  bool operator ==(Object other) => other is CondicaoTempo && other.sigla == sigla;

  @override
  int get hashCode => sigla.hashCode;

  @override
  String toString() => '$sigla: $descricao';
}
