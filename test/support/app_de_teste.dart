import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:previsao_tempo/app.dart';
import 'package:previsao_tempo/controllers/cidades_salvas.dart';
import 'package:previsao_tempo/data/cliente_cptec.dart';
import 'package:previsao_tempo/data/leitor_xml_cptec.dart';
import 'package:previsao_tempo/data/repositorio_previsao.dart';
import 'package:previsao_tempo/models/cidade.dart';

import 'armazenamento_em_memoria.dart';
import 'fixtures.dart';

const saoPaulo = Cidade(id: 244, nome: 'São Paulo', uf: 'SP');

/// Momento usado como data das previsões já salvas no aparelho.
final momentoSalvo = DateTime(2026, 11, 15, 9, 41);

/// Abre o app completo sobre o [servico] informado (o CPTEC simulado por
/// padrão). Cada item de [cidadesSalvas] pode trazer a fixture da previsão
/// que já estaria guardada no aparelho.
Future<void> abrirApp(
  WidgetTester tester, {
  http.Client? servico,
  List<(Cidade, String?)> cidadesSalvas = const [],
}) async {
  final armazenamento = await armazenamentoEmMemoria();
  await armazenamento.salvarCidades([for (final (cidade, _) in cidadesSalvas) cidade]);
  for (final (cidade, xml) in cidadesSalvas) {
    if (xml != null) {
      await armazenamento.salvarPrevisao(cidade.id, lerPrevisao(fixture(xml)), momentoSalvo);
    }
  }

  await tester.pumpWidget(
    App(
      repositorio: RepositorioPrevisao(
        cliente: ClienteCptec(cliente: servico ?? servicoFalso()),
        armazenamento: armazenamento,
      ),
      cidadesSalvas: CidadesSalvas(armazenamento),
    ),
  );
  await tester.pumpAndSettle();
}
