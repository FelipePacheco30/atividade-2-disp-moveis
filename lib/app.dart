import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/cidades_salvas.dart';
import 'core/tema.dart';
import 'data/repositorio_previsao.dart';
import 'presentation/screens/tela_inicial.dart';

class App extends StatelessWidget {
  const App({super.key, required this.repositorio, required this.cidadesSalvas});

  final RepositorioPrevisao repositorio;
  final CidadesSalvas cidadesSalvas;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Previsão do tempo',
      debugShowCheckedModeBanner: false,
      theme: criarTema(Brightness.light),
      darkTheme: criarTema(Brightness.dark),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: TelaInicial(repositorio: repositorio, cidadesSalvas: cidadesSalvas),
    );
  }
}
