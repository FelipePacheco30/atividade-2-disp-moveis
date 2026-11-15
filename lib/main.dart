import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'controllers/cidades_salvas.dart';
import 'data/armazenamento_local.dart';
import 'data/cliente_cptec.dart';
import 'data/repositorio_previsao.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  final armazenamento = await ArmazenamentoLocal.abrir();

  runApp(
    App(
      repositorio: RepositorioPrevisao(cliente: ClienteCptec(), armazenamento: armazenamento),
      cidadesSalvas: CidadesSalvas(armazenamento),
    ),
  );
}
