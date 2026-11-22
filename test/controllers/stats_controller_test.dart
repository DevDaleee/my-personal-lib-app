import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_personal_lib_app/controllers/stats_controller.dart';
import 'package:my_personal_lib_app/services/api/stats_services.dart';
import 'package:my_personal_lib_app/services/constants.dart';

class MockStatsServices extends Mock implements StatsServices {}

Map<String, dynamic> _ok(Object data) => {"status_code": 200, "data": data, "error": null};
Map<String, dynamic> _fail(int? status, String error) => {"status_code": status, "data": null, "error": error};

/// "Hoje" fixo nos testes: 22/11/2026, às 15h.
DateTime _now() => DateTime(2026, 11, 22, 15);

void main() {
  late MockStatsServices services;
  late StatsController controller;

  setUp(() async {
    await GetIt.instance.reset();
    services = MockStatsServices();
    GetIt.instance.registerSingleton<StatsServices>(services);

    when(() => services.getStreak()).thenAnswer((_) async => _ok({'current_streak': 4}));
    when(() => services.getDaily(days: any(named: 'days'))).thenAnswer(
      (_) async => _ok([
        {'day': '2026-10-30', 'pages_read': 300, 'updates': 2}, // fora dos 15 dias
        {'day': '2026-11-19', 'pages_read': 140, 'updates': 3},
        {'day': '2026-11-21', 'pages_read': 41, 'updates': 1},
        {'day': '2026-11-22', 'pages_read': 20, 'updates': 1},
      ]),
    );
    when(() => services.getMonthly(months: any(named: 'months'))).thenAnswer(
      (_) async => _ok([
        {'month': '2025-12-01', 'finished_count': 5},
        {'month': '2026-06-01', 'finished_count': 2},
        {'month': '2026-11-01', 'finished_count': 1},
      ]),
    );
    controller = StatsController(clock: _now);
  });

  test('busca o maior período de cada gráfico uma vez só', () async {
    await controller.load();

    verify(() => services.getStreak()).called(1);
    verify(() => services.getDaily(days: 30)).called(1);
    verify(() => services.getMonthly(months: 12)).called(1);
  });

  test('isLoading fica verdadeiro durante a busca', () async {
    final future = controller.load();
    expect(controller.isLoading, isTrue);
    await future;
    expect(controller.isLoading, isFalse);
  });

  group('páginas por dia', () {
    test('7 dias: um item por dia até hoje, sem leitura com 0', () async {
      await controller.load();

      final points = controller.dailyPoints;
      expect(points, hasLength(7));
      expect(points.first.day, DateTime(2026, 11, 16));
      expect(points.last.day, DateTime(2026, 11, 22));
      expect(points.map((p) => p.pagesRead), [0, 0, 0, 140, 0, 41, 20]);
    });

    test('trocar o período não faz outra chamada', () async {
      await controller.load();

      controller.selectDailyRange(DailyRange.month);

      expect(controller.dailyPoints, hasLength(30));
      expect(controller.dailyPoints.first.day, DateTime(2026, 10, 24));
      expect(controller.dailyPoints.firstWhere((p) => p.day == DateTime(2026, 10, 30)).pagesRead, 300);
      verify(() => services.getDaily(days: any(named: 'days'))).called(1);
    });

    test('melhor dia: o de mais páginas no período escolhido', () async {
      await controller.load();

      expect(controller.bestDay?.day, DateTime(2026, 11, 19));
      expect(controller.bestDay?.pagesRead, 140);

      controller.selectDailyRange(DailyRange.month);
      expect(controller.bestDay?.day, DateTime(2026, 10, 30));
    });

    test('sem leitura no período: sem melhor dia', () async {
      when(() => services.getDaily(days: any(named: 'days'))).thenAnswer((_) async => _ok([]));
      await controller.load();

      expect(controller.bestDay, isNull);
      expect(controller.dailyPoints.every((p) => p.pagesRead == 0), isTrue);
    });

    test('tracinhos: os últimos 7 dias, do mais antigo para hoje', () async {
      await controller.load();

      expect(controller.lastSevenDays, [false, false, false, true, false, true, true]);
    });
  });

  group('livros por mês', () {
    test('semestral (padrão): seis meses até o atual, vazios com 0', () async {
      await controller.load();

      final points = controller.monthlyPoints;
      expect(points.map((p) => p.month), [for (var m = 6; m <= 11; m++) DateTime(2026, m)]);
      expect(points.map((p) => p.finishedCount), [2, 0, 0, 0, 0, 1]);
    });

    test('anual: passa pelo ano anterior', () async {
      await controller.load();

      controller.selectMonthlyRange(MonthlyRange.annual);

      expect(controller.monthlyPoints.first.month, DateTime(2025, 12));
      expect(controller.monthlyPoints.first.finishedCount, 5);
      expect(controller.monthlyPoints, hasLength(12));
    });

    test('total do ano: só os meses do ano atual', () async {
      await controller.load();

      expect(controller.finishedThisYear, 3);
    });
  });

  group('erros', () {
    test('cada gráfico tem o próprio erro', () async {
      when(() => services.getDaily(days: any(named: 'days'))).thenAnswer((_) async => _fail(null, ApiErrors.connectionError));

      await controller.load();

      expect(controller.dailyError, ApiErrors.connectionError);
      expect(controller.monthlyError, isNull);
      expect(controller.monthlyPoints.last.finishedCount, 1);
      expect(controller.streak, 4);
    });

    test('mensal falha: total do ano nulo', () async {
      when(() => services.getMonthly(months: any(named: 'months'))).thenAnswer((_) async => _fail(500, 'Erro'));

      await controller.load();

      expect(controller.monthlyError, 'Erro');
      expect(controller.finishedThisYear, isNull);
    });

    test('sequência falha: nula', () async {
      when(() => services.getStreak()).thenAnswer((_) async => _fail(500, 'Erro'));

      await controller.load();

      expect(controller.streak, isNull);
    });

    test('JSON fora do contrato: mensagem genérica', () async {
      when(() => services.getDaily(days: any(named: 'days'))).thenAnswer(
        (_) async => _ok([
          {'day': 'ontem'},
        ]),
      );

      await controller.load();

      expect(controller.dailyError, ApiErrors.unexpectedError);
    });

    test('nova busca que dá certo limpa o erro', () async {
      when(() => services.getDaily(days: any(named: 'days'))).thenAnswer((_) async => _fail(500, 'Erro'));
      await controller.load();
      when(() => services.getDaily(days: any(named: 'days'))).thenAnswer((_) async => _ok([]));

      await controller.load();

      expect(controller.dailyError, isNull);
    });
  });
}
