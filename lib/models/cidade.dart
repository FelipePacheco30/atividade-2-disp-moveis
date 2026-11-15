/// Localidade retornada pela busca do CPTEC. O [id] é o código usado na
/// consulta de previsão.
class Cidade {
  const Cidade({required this.id, required this.nome, required this.uf});

  factory Cidade.deJson(Map<String, Object?> json) {
    return Cidade(id: json['id'] as int, nome: json['nome'] as String, uf: json['uf'] as String);
  }

  final int id;
  final String nome;
  final String uf;

  Map<String, Object?> paraJson() => {'id': id, 'nome': nome, 'uf': uf};

  @override
  bool operator ==(Object other) => other is Cidade && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$nome/$uf ($id)';
}
