import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_personal_lib_app/controllers/stats_controller.dart';
import 'package:my_personal_lib_app/pages/stats/stats_page.dart';
import 'package:my_personal_lib_app/pages/styles/light_theme.dart';
import 'package:my_personal_lib_app/services/api/stats_services.dart';
import 'package:my_personal_lib_app/services/constants.dart';

class MockStatsServices extends Mock implements StatsServices {}

Map<String, dynamic> _ok(Object data) => {"status_code": 200, "data": data, "error": null};
Map<String, dynamic> _fail(int? status, String error) => {"status_code": status, "data": null, "error": error};

/// "Hoje" fixo: 22/11 do ano atual (o "ANO" e o resumo usam o ano real).
final _year = DateTime.now().year;
DateTime _now() => DateTime(_year, 11, 22, 15);

Widget _app() {
  final router = GoRouter(
    initialLocation: '/stats',
    routes: [
      GoRoute(path: '/stats', builder: (_, _) => const StatsPage()),
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('BIBLIOTECA')),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, _) => const Scaffold(body: Text('PERFIL')),
      ),
    ],
  );
  return MaterialApp.router(theme: lightTheme, routerConfig: router);
}

void main() {
  late MockStatsServices services;

  Future<void> openStats(WidgetTester tester) async {
    await tester.pumpWidget(_app());
    await tester.pump();
  }

  setUp(() async {
    await GetIt.instance.reset();
    services = MockStatsServices();
    GetIt.instance.registerSingleton<StatsServices>(services);
    GetIt.instance.registerSingleton<StatsController>(StatsController(clock: _now));

    when(() => services.getStreak()).thenAnswer((_) async => _ok({'current_streak': 4}));
    when(() => services.getDaily(days: any(named: 'days'))).thenAnswer(
      (_) async => _ok([
        {'day': '$_year-11-19', 'pages_read': 140, 'updates': 3},
        {'day': '$_year-11-22', 'pages_read': 20, 'updates': 1},
      ]),
    );
    when(() => services.getMonthly(months: any(named: 'months'))).thenAnswer(
      (_) async => _ok([
        {'month': '$_year-06-01', 'finished_count': 2},
        {'month': '$_year-11-01', 'finished_count': 1},
      ]),
    );
  });

  testWidgets('mostra sequência, gráfico diário, meses e o resumo do ano', (tester) async {
    await openStats(tester);

    expect(find.text('Estatísticas'), findsWidgets); // AppBar e barra inferior
    expect(find.text('Registro de Hábito'), findsOneWidget);
    expect(find.text('ANO $_year'), findsOneWidget);

    expect(find.text('4'), findsOneWidget);
    expect(find.text('dias seguidos lendo'), findsOneWidget);

    expect(find.text('Páginas por dia'), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);
    expect(find.text('Sessão mais produtiva'), findsOneWidget);
    expect(find.text('19 de novembro (140 págs)'), findsOneWidget);

    await tester.scrollUntilVisible(find.textContaining('Total de'), 200);
    expect(find.text('Livros concluídos por mês'), findsOneWidget);
    expect(find.text('jun/${_year % 100}'), findsOneWidget);
    expect(find.text('2 livros'), findsOneWidget);
    expect(find.text('1 livro'), findsOneWidget);
    expect(find.text('Total de 3 livros lidos em $_year'), findsOneWidget);
  });

  testWidgets('enquanto a primeira busca não termina: carregando', (tester) async {
    final streak = Completer<Map<String, dynamic>>();
    when(() => services.getStreak()).thenAnswer((_) => streak.future);
    await tester.pumpWidget(_app());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Páginas por dia'), findsNothing);

    streak.complete(_ok({'current_streak': 4}));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Páginas por dia'), findsOneWidget);
  });

  testWidgets('trocar o período muda o melhor dia sem nova chamada', (tester) async {
    when(() => services.getDaily(days: any(named: 'days'))).thenAnswer(
      (_) async => _ok([
        {'day': '$_year-11-01', 'pages_read': 300, 'updates': 1}, // fora dos 7 dias
        {'day': '$_year-11-19', 'pages_read': 140, 'updates': 3},
      ]),
    );
    await openStats(tester);
    expect(find.text('19 de novembro (140 págs)'), findsOneWidget);

    await tester.tap(find.text('30 dias'));
    await tester.pump();

    expect(find.text('1 de novembro (300 págs)'), findsOneWidget);
    verify(() => services.getDaily(days: 30)).called(1);
  });

  testWidgets('sem leitura no período: mensagem no lugar do melhor dia', (tester) async {
    when(() => services.getDaily(days: any(named: 'days'))).thenAnswer((_) async => _ok([]));
    await openStats(tester);

    expect(find.text('Nenhuma leitura registrada no período.'), findsOneWidget);
  });

  testWidgets('trocar o período mensal muda a quantidade de meses', (tester) async {
    await openStats(tester);
    await tester.scrollUntilVisible(find.text('Bimestral'), 200);

    await tester.tap(find.text('Bimestral'));
    await tester.pump();

    expect(find.text('out/${_year % 100}'), findsOneWidget);
    expect(find.text('nov/${_year % 100}'), findsOneWidget);
    expect(find.text('jun/${_year % 100}'), findsNothing);
  });

  testWidgets('um gráfico com erro não esconde o outro', (tester) async {
    when(() => services.getDaily(days: any(named: 'days'))).thenAnswer((_) async => _fail(null, ApiErrors.connectionError));
    await openStats(tester);

    expect(find.text(ApiErrors.connectionError), findsOneWidget);
    expect(find.byType(BarChart), findsNothing);
    await tester.scrollUntilVisible(find.text('2 livros'), 200);
    expect(find.text('2 livros'), findsOneWidget);
  });

  testWidgets('sequência falha: mostra "–"', (tester) async {
    when(() => services.getStreak()).thenAnswer((_) async => _fail(500, 'Erro'));
    await openStats(tester);

    expect(find.text('–'), findsOneWidget);
  });

  testWidgets('a barra inferior volta para a Biblioteca', (tester) async {
    await openStats(tester);

    await tester.tap(find.text('Biblioteca'));
    await tester.pumpAndSettle();

    expect(find.text('BIBLIOTECA'), findsOneWidget);
  });

  testWidgets('o botão Perfil abre o perfil', (tester) async {
    await openStats(tester);

    await tester.tap(find.byTooltip('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('PERFIL'), findsOneWidget);
  });
}
