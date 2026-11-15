import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../support/app_de_teste.dart';
import '../support/fixtures.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  testWidgets('pesquisa, consulta a previsão e salva a cidade na tela inicial', (tester) async {
    await abrirApp(tester);
    expect(find.text('Nenhuma cidade salva'), findsOneWidget);
    expect(find.textContaining('CPTEC/INPE', findRichText: true), findsWidgets);

    await tester.tap(find.text('Buscar cidade'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'São Paulo');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('4 localidades'), findsOneWidget);
    expect(find.text('São Paulo das Missões'), findsOneWidget);
    expect(find.text('RS'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'São Paulo'));
    await tester.pumpAndSettle();

    expect(find.text('Domingo, 15 de novembro'), findsOneWidget);
    expect(find.text('Atualizada pelo CPTEC/INPE em 15/11/2026'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Qua'), 300);
    expect(find.text('PREVISÃO PARA 4 DIAS'), findsOneWidget);
    for (final dia in ['Dom', 'Seg', 'Ter', 'Qua']) {
      expect(find.text(dia), findsWidgets);
    }
    expect(find.text('Parcialmente nublado'), findsOneWidget);
    expect(find.text('IUV não informado'), findsWidgets);

    await tester.tap(find.byTooltip('Salvar cidade'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remover das cidades salvas'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.star), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('CIDADES SALVAS'), findsOneWidget);
    expect(find.text('Dom, 15 nov · Chuva'), findsOneWidget);
    expect(find.text('28° / 19°'), findsOneWidget);
  });

  testWidgets('remove a cidade salva deslizando e permite desfazer', (tester) async {
    await abrirApp(tester, cidadesSalvas: [(saoPaulo, 'previsao_sao_paulo.xml')]);

    await tester.drag(find.text('São Paulo'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma cidade salva'), findsOneWidget);

    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();
    expect(find.text('São Paulo'), findsOneWidget);
  });

  testWidgets('a busca exige ao menos três letras', (tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('Buscar cidade'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Sã');
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Pesquise uma cidade brasileira'), findsOneWidget);
  });

  testWidgets('informa quando nenhuma cidade é encontrada', (tester) async {
    await abrirApp(tester, servico: servicoFalso(busca: 'busca_sem_resultados.xml'));
    await tester.tap(find.text('Buscar cidade'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Xyzqq');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma cidade encontrada'), findsOneWidget);
    expect(find.textContaining('“Xyzqq”'), findsOneWidget);
  });
}
