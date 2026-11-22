import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:my_personal_lib_app/models/daily_stat.dart';
import 'package:my_personal_lib_app/models/monthly_stat.dart';
import 'package:my_personal_lib_app/services/api/stats_services.dart';
import 'package:my_personal_lib_app/services/constants.dart';

part 'stats_controller.g.dart';

/// Períodos do gráfico de páginas por dia.
enum DailyRange {
  week(7, '7 dias'),
  fortnight(15, '15 dias'),
  month(30, '30 dias');

  const DailyRange(this.days, this.label);

  final int days;
  final String label;
}

/// Períodos do gráfico de livros concluídos por mês.
enum MonthlyRange {
  bimonthly(2, 'Bimestral'),
  quarterly(3, 'Trimestral'),
  semiannual(6, 'Semestral'),
  annual(12, 'Anual');

  const MonthlyRange(this.months, this.label);

  final int months;
  final String label;
}

class StatsController = StatsControllerBase with _$StatsController;

/// Estatísticas de leitura. Busca o maior período de cada gráfico uma vez só
/// (`days=30`, `months=12`) e monta os períodos menores aqui, então trocar o
/// período não faz outra chamada. A API omite dias e meses vazios: o app
/// preenche com zero.
abstract class StatsControllerBase with Store {
  StatsControllerBase({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final StatsServices services = GetIt.I.get<StatsServices>();

  /// "Hoje" (trocável nos testes).
  final DateTime Function() _clock;

  static final int _maxDays = DailyRange.values.last.days;
  static final int _maxMonths = MonthlyRange.values.last.months;

  @observable
  bool isLoading = false;

  /// A primeira busca já terminou (com ou sem erro). Antes disso, a tela mostra o carregando.
  @observable
  bool hasLoaded = false;

  /// Dias seguidos com leitura. Nulo se a chamada falhar (a tela mostra "–").
  @observable
  int? streak;

  /// Cada gráfico tem o próprio erro: se um falhar, o outro continua aparecendo.
  @observable
  String? dailyError;

  @observable
  String? monthlyError;

  @observable
  List<DailyStat> _daily = const [];

  @observable
  List<MonthlyStat> _monthly = const [];

  @observable
  DailyRange dailyRange = DailyRange.week;

  @observable
  MonthlyRange monthlyRange = MonthlyRange.semiannual;

  DateTime get _today {
    final now = _clock();
    return DateTime(now.year, now.month, now.day);
  }

  /// Um item por dia do período, do mais antigo para hoje (dias sem leitura com 0).
  @computed
  List<DailyStat> get dailyPoints => _lastDays(dailyRange.days);

  /// Os 7 tracinhos da sequência: `true` nos dias com leitura (do mais antigo para hoje).
  @computed
  List<bool> get lastSevenDays => _lastDays(7).map((day) => day.pagesRead > 0).toList();

  /// Dia com mais páginas no período escolhido; nulo se não leu nada.
  @computed
  DailyStat? get bestDay {
    DailyStat? best;
    for (final day in dailyPoints) {
      if (day.pagesRead > 0 && (best == null || day.pagesRead > best.pagesRead)) best = day;
    }
    return best;
  }

  /// Um item por mês do período, do mais antigo até o mês atual (meses vazios com 0).
  @computed
  List<MonthlyStat> get monthlyPoints {
    final today = _today;
    final counts = {for (final stat in _monthly) _monthKey(stat.month): stat.finishedCount};
    return [
      for (var i = monthlyRange.months - 1; i >= 0; i--)
        // DateTime ajusta mês negativo para o ano anterior.
        () {
          final month = DateTime(today.year, today.month - i);
          return MonthlyStat(month: month, finishedCount: counts[_monthKey(month)] ?? 0);
        }(),
    ];
  }

  /// Livros concluídos no ano atual; nulo se a chamada falhou.
  @computed
  int? get finishedThisYear {
    if (monthlyError != null) return null;
    final year = _today.year;
    return _monthly.where((stat) => stat.month.year == year).fold<int>(0, (sum, stat) => sum + stat.finishedCount);
  }

  @action
  void selectDailyRange(DailyRange value) => dailyRange = value;

  @action
  void selectMonthlyRange(MonthlyRange value) => monthlyRange = value;

  @action
  Future<void> load() async {
    if (isLoading) return;
    isLoading = true;
    try {
      final results = await Future.wait([services.getStreak(), services.getDaily(days: _maxDays), services.getMonthly(months: _maxMonths)]);
      streak = _parseStreak(results[0]);
      _applyDaily(results[1]);
      _applyMonthly(results[2]);
    } finally {
      isLoading = false;
      hasLoaded = true;
    }
  }

  List<DailyStat> _lastDays(int count) {
    final today = _today;
    final pages = {for (final stat in _daily) _dayKey(stat.day): stat.pagesRead};
    return [
      for (var i = count - 1; i >= 0; i--)
        () {
          final day = DateTime(today.year, today.month, today.day - i);
          return DailyStat(day: day, pagesRead: pages[_dayKey(day)] ?? 0);
        }(),
    ];
  }

  void _applyDaily(Map<String, dynamic> response) {
    final (items, error) = _parseList(response, DailyStat.fromJson, 'daily');
    dailyError = error;
    if (items != null) _daily = items;
  }

  void _applyMonthly(Map<String, dynamic> response) {
    final (items, error) = _parseList(response, MonthlyStat.fromJson, 'monthly');
    monthlyError = error;
    if (items != null) _monthly = items;
  }

  /// Lista da API ou a mensagem de erro (a da API, ou a genérica se o JSON vier fora do contrato).
  (List<T>?, String?) _parseList<T>(Map<String, dynamic> response, T Function(Map<String, dynamic>) fromJson, String label) {
    if (response["status_code"] != 200) return (null, response["error"] as String? ?? ApiErrors.unexpectedError);
    try {
      return ((response["data"] as List<dynamic>).map((json) => fromJson(json as Map<String, dynamic>)).toList(), null);
    } catch (e) {
      debugPrint('StatsController.$label: $e');
      return (null, ApiErrors.unexpectedError);
    }
  }

  int? _parseStreak(Map<String, dynamic> response) {
    if (response["status_code"] != 200) return null;
    final data = response["data"];
    return data is Map && data["current_streak"] is int ? data["current_streak"] as int : null;
  }

  static String _dayKey(DateTime day) => '${day.year}-${day.month}-${day.day}';

  static String _monthKey(DateTime month) => '${month.year}-${month.month}';
}
