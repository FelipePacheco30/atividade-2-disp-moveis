import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../support/app_de_teste.dart';
import '../support/fixtures.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  Future<void> abrirPrevisao(WidgetTester tester) async {
    await tester.tap(find.text('São Paulo'));
    await tester.pumpAndSettle();
  }

  testWidgets('mostra indicador de carregamento durante a consulta', (tester) async {
    final resposta = Completer<http.Response>();
    await abrirApp(
      tester,
      cidadesSalvas: [(saoPaulo, null)],
      servico: MockClient((_) => resposta.future),
    );

    await tester.tap(find.text('São Paulo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Consultando o CPTEC/INPE…'), findsOneWidget);

    resposta.complete(respostaCptec('previsao_sao_paulo.xml'));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Domingo, 15 de novembro'), findsOneWidget);
  });

  testWidgets('mostra a falha de conexão e tenta de novo', (tester) async {
    var online = false;
    await abrirApp(
      tester,
      cidadesSalvas: [(saoPaulo, null)],
      servico: servicoFalso(online: () => online),
    );
    await abrirPrevisao(tester);

    expect(find.text('Não foi possível carregar a previsão'), findsOneWidget);
    expect(find.textContaining('Sem conexão com a internet'), findsOneWidget);

    online = true;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(find.text('Domingo, 15 de novembro'), findsOneWidget);
  });

  testWidgets('mostra a indisponibilidade do serviço', (tester) async {
    await abrirApp(
      tester,
      cidadesSalvas: [(saoPaulo, null)],
      servico: MockClient((_) async => http.Response('', 503)),
    );
    await abrirPrevisao(tester);

    expect(find.textContaining('indisponível no momento'), findsOneWidget);
  });

  testWidgets('mostra a previsão salva quando está sem conexão', (tester) async {
    await abrirApp(
      tester,
      cidadesSalvas: [(saoPaulo, 'previsao_sao_paulo.xml')],
      servico: servicoFalso(online: () => false),
    );
    await abrirPrevisao(tester);

    expect(find.textContaining('Exibindo a previsão salva em 15/11 às 09:41'), findsOneWidget);
    expect(find.text('Domingo, 15 de novembro'), findsOneWidget);
  });

  testWidgets('avisa quando não há previsão para a localidade', (tester) async {
    await abrirApp(
      tester,
      cidadesSalvas: [(saoPaulo, null)],
      servico: servicoFalso(previsoes: const {}),
    );
    await abrirPrevisao(tester);

    expect(find.text('Previsão indisponível'), findsOneWidget);
  });

  testWidgets('exibe traços no lugar de campos ausentes', (tester) async {
    const incompleta =
        '<cidade><previsao><dia>2026-11-15</dia><tempo>xyz</tempo>'
        '<maxima>null</maxima><minima>18</minima></previsao></cidade>';
    await abrirApp(
      tester,
      cidadesSalvas: [(saoPaulo, null)],
      servico: MockClient((_) async => http.Response(incompleta, 200)),
    );
    await abrirPrevisao(tester);

    expect(find.text('—'), findsWidgets);
    expect(find.text('18°'), findsWidgets);
    expect(find.text('Não definido'), findsWidgets);
    expect(find.text('Data de atualização não informada pelo CPTEC/INPE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('atualiza a previsão pela ação da barra superior', (tester) async {
    var consultas = 0;
    await abrirApp(
      tester,
      cidadesSalvas: [(saoPaulo, null)],
      servico: MockClient((_) async {
        consultas++;
        return respostaCptec('previsao_sao_paulo.xml');
      }),
    );
    await abrirPrevisao(tester);

    await tester.tap(find.byTooltip('Atualizar previsão'));
    await tester.pumpAndSettle();

    expect(consultas, 2);
  });

  testWidgets('mantém a previsão e avisa quando a atualização falha', (tester) async {
    var online = true;
    await abrirApp(
      tester,
      cidadesSalvas: [(saoPaulo, null)],
      servico: servicoFalso(previsoes: const {}, online: () => online),
    );
    await abrirPrevisao(tester);
    online = false;

    await tester.tap(find.byTooltip('Atualizar previsão'));
    await tester.pumpAndSettle();

    expect(find.text('Previsão indisponível'), findsOneWidget);
    expect(find.textContaining('Não foi possível atualizar'), findsOneWidget);
  });
}
