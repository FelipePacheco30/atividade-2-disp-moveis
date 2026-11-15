// Gera as capturas de tela usadas no README a partir das telas reais do app,
// com respostas do CPTEC/INPE gravadas em test/fixtures.
//
//   flutter test tool/capturas --update-goldens
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:previsao_tempo/app.dart';
import 'package:previsao_tempo/models/cidade.dart';

import '../../test/support/app_de_teste.dart';
import '../../test/support/fixtures.dart';

const _celular = Size(390, 844);
const _tablet = Size(1280, 800);

const _salvas = [
  (saoPaulo, 'previsao_sao_paulo.xml'),
  (Cidade(id: 241, nome: 'Rio de Janeiro', uf: 'RJ'), 'previsao_rio_de_janeiro.xml'),
  (Cidade(id: 227, nome: 'Curitiba', uf: 'PR'), 'previsao_curitiba.xml'),
  (Cidade(id: 242, nome: 'Salvador', uf: 'BA'), 'previsao_salvador.xml'),
  (Cidade(id: 237, nome: 'Porto Alegre', uf: 'RS'), 'previsao_porto_alegre.xml'),
];

void main() {
  setUpAll(() async {
    await _carregarFontes();
    await initializeDateFormatting('pt_BR');
    EditableText.debugDeterministicCursor = true;
  });

  testWidgets('01 início sem cidades', (tester) async {
    await _abrirApp(tester);
    await _capturar(tester, '01_inicio_vazio');
  });

  testWidgets('02 busca de cidades', (tester) async {
    await _abrirApp(tester, cidadesSalvas: [_salvas.first]);
    await _buscar(tester, 'São Paulo');
    await _capturar(tester, '02_busca');
  });

  testWidgets('03 e 04 previsão', (tester) async {
    await _abrirApp(tester);
    await _buscar(tester, 'São Paulo');
    await tester.tap(find.widgetWithText(ListTile, 'São Paulo'));
    await tester.pumpAndSettle();
    await _capturar(tester, '03_previsao');

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    await _capturar(tester, '04_previsao_dias');
  });

  testWidgets('05 início com cidades salvas', (tester) async {
    await _abrirApp(tester, cidadesSalvas: _salvas);
    await _capturar(tester, '05_inicio_cidades_salvas');
  });

  testWidgets('06 busca sem resultados', (tester) async {
    await _abrirApp(tester, servico: servicoFalso(busca: 'busca_sem_resultados.xml'));
    await _buscar(tester, 'Xyzqq');
    await _capturar(tester, '06_busca_sem_resultados');
  });

  testWidgets('07 carregando', (tester) async {
    final semResposta = Completer<http.Response>();
    await _abrirApp(
      tester,
      cidadesSalvas: [(saoPaulo, null)],
      servico: MockClient((_) => semResposta.future),
    );
    await tester.tap(find.text('São Paulo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await _capturar(tester, '07_carregando');

    semResposta.complete(respostaCptec('previsao_sao_paulo.xml'));
    await tester.pumpAndSettle();
  });

  testWidgets('08 sem conexão com previsão salva', (tester) async {
    await _abrirApp(
      tester,
      cidadesSalvas: _salvas,
      servico: servicoFalso(online: () => false),
    );
    await tester.tap(find.text('São Paulo'));
    await tester.pumpAndSettle();
    await _capturar(tester, '08_offline_previsao_salva');
  });

  testWidgets('09 sem conexão e sem previsão salva', (tester) async {
    await _abrirApp(
      tester,
      cidadesSalvas: [(saoPaulo, null)],
      servico: servicoFalso(online: () => false),
    );
    await tester.tap(find.text('São Paulo'));
    await tester.pumpAndSettle();
    await _capturar(tester, '09_erro_conexao');
  });

  testWidgets('10 previsão indisponível', (tester) async {
    await _abrirApp(tester, servico: servicoFalso(previsoes: const {}));
    await _buscar(tester, 'São Paulo');
    await tester.tap(find.text('São Paulo das Missões'));
    await tester.pumpAndSettle();
    await _capturar(tester, '10_previsao_indisponivel');
  });

  testWidgets('11 tablet', (tester) async {
    await _abrirApp(tester, tamanho: _tablet, cidadesSalvas: _salvas);
    await tester.tap(find.text('São Paulo'));
    await tester.pumpAndSettle();
    await _capturar(tester, '11_tablet');
  });

  testWidgets('12 tema escuro', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await _abrirApp(tester, cidadesSalvas: _salvas);
    await _capturar(tester, '12_escuro_inicio');

    await tester.tap(find.text('São Paulo'));
    await tester.pumpAndSettle();
    await _capturar(tester, '13_escuro_previsao');
  });
}

Future<void> _abrirApp(
  WidgetTester tester, {
  Size tamanho = _celular,
  List<(Cidade, String?)> cidadesSalvas = const [],
  http.Client? servico,
}) {
  tester.view.physicalSize = tamanho * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  return abrirApp(tester, servico: servico, cidadesSalvas: cidadesSalvas);
}

Future<void> _buscar(WidgetTester tester, String termo) async {
  await tester.tap(find.text('Buscar cidade'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), termo);
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

Future<void> _capturar(WidgetTester tester, String nome) {
  return expectLater(find.byType(App), matchesGoldenFile('../../docs/capturas/$nome.png'));
}

Future<void> _carregarFontes() async {
  final flutter =
      Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  final pasta = '$flutter/bin/cache/artifacts/material_fonts';

  ByteData ler(String arquivo) => ByteData.sublistView(File('$pasta/$arquivo').readAsBytesSync());

  final roboto = FontLoader('Roboto');
  for (final peso in ['Light', 'Regular', 'Medium', 'Bold']) {
    roboto.addFont(Future.value(ler('Roboto-$peso.ttf')));
  }
  await roboto.load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(Future.value(ler('MaterialIcons-Regular.otf')))).load();
  await (FontLoader(
    'packages/cupertino_icons/CupertinoIcons',
  )..addFont(rootBundle.load('packages/cupertino_icons/assets/CupertinoIcons.ttf'))).load();
}
