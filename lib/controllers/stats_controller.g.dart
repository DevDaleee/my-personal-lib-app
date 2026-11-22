// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$StatsController on StatsControllerBase, Store {
  Computed<List<DailyStat>>? _$dailyPointsComputed;

  @override
  List<DailyStat> get dailyPoints =>
      (_$dailyPointsComputed ??= Computed<List<DailyStat>>(() => super.dailyPoints, name: 'StatsControllerBase.dailyPoints')).value;
  Computed<List<bool>>? _$lastSevenDaysComputed;

  @override
  List<bool> get lastSevenDays =>
      (_$lastSevenDaysComputed ??= Computed<List<bool>>(() => super.lastSevenDays, name: 'StatsControllerBase.lastSevenDays')).value;
  Computed<DailyStat?>? _$bestDayComputed;

  @override
  DailyStat? get bestDay => (_$bestDayComputed ??= Computed<DailyStat?>(() => super.bestDay, name: 'StatsControllerBase.bestDay')).value;
  Computed<List<MonthlyStat>>? _$monthlyPointsComputed;

  @override
  List<MonthlyStat> get monthlyPoints =>
      (_$monthlyPointsComputed ??= Computed<List<MonthlyStat>>(() => super.monthlyPoints, name: 'StatsControllerBase.monthlyPoints')).value;
  Computed<int?>? _$finishedThisYearComputed;

  @override
  int? get finishedThisYear =>
      (_$finishedThisYearComputed ??= Computed<int?>(() => super.finishedThisYear, name: 'StatsControllerBase.finishedThisYear')).value;

  late final _$isLoadingAtom = Atom(name: 'StatsControllerBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$streakAtom = Atom(name: 'StatsControllerBase.streak', context: context);

  @override
  int? get streak {
    _$streakAtom.reportRead();
    return super.streak;
  }

  @override
  set streak(int? value) {
    _$streakAtom.reportWrite(value, super.streak, () {
      super.streak = value;
    });
  }

  late final _$dailyErrorAtom = Atom(name: 'StatsControllerBase.dailyError', context: context);

  @override
  String? get dailyError {
    _$dailyErrorAtom.reportRead();
    return super.dailyError;
  }

  @override
  set dailyError(String? value) {
    _$dailyErrorAtom.reportWrite(value, super.dailyError, () {
      super.dailyError = value;
    });
  }

  late final _$monthlyErrorAtom = Atom(name: 'StatsControllerBase.monthlyError', context: context);

  @override
  String? get monthlyError {
    _$monthlyErrorAtom.reportRead();
    return super.monthlyError;
  }

  @override
  set monthlyError(String? value) {
    _$monthlyErrorAtom.reportWrite(value, super.monthlyError, () {
      super.monthlyError = value;
    });
  }

  late final _$_dailyAtom = Atom(name: 'StatsControllerBase._daily', context: context);

  @override
  List<DailyStat> get _daily {
    _$_dailyAtom.reportRead();
    return super._daily;
  }

  @override
  set _daily(List<DailyStat> value) {
    _$_dailyAtom.reportWrite(value, super._daily, () {
      super._daily = value;
    });
  }

  late final _$_monthlyAtom = Atom(name: 'StatsControllerBase._monthly', context: context);

  @override
  List<MonthlyStat> get _monthly {
    _$_monthlyAtom.reportRead();
    return super._monthly;
  }

  @override
  set _monthly(List<MonthlyStat> value) {
    _$_monthlyAtom.reportWrite(value, super._monthly, () {
      super._monthly = value;
    });
  }

  late final _$dailyRangeAtom = Atom(name: 'StatsControllerBase.dailyRange', context: context);

  @override
  DailyRange get dailyRange {
    _$dailyRangeAtom.reportRead();
    return super.dailyRange;
  }

  @override
  set dailyRange(DailyRange value) {
    _$dailyRangeAtom.reportWrite(value, super.dailyRange, () {
      super.dailyRange = value;
    });
  }

  late final _$monthlyRangeAtom = Atom(name: 'StatsControllerBase.monthlyRange', context: context);

  @override
  MonthlyRange get monthlyRange {
    _$monthlyRangeAtom.reportRead();
    return super.monthlyRange;
  }

  @override
  set monthlyRange(MonthlyRange value) {
    _$monthlyRangeAtom.reportWrite(value, super.monthlyRange, () {
      super.monthlyRange = value;
    });
  }

  late final _$loadAsyncAction = AsyncAction('StatsControllerBase.load', context: context);

  @override
  Future<void> load() {
    return _$loadAsyncAction.run(() => super.load());
  }

  late final _$StatsControllerBaseActionController = ActionController(name: 'StatsControllerBase', context: context);

  @override
  void selectDailyRange(DailyRange value) {
    final _$actionInfo = _$StatsControllerBaseActionController.startAction(name: 'StatsControllerBase.selectDailyRange');
    try {
      return super.selectDailyRange(value);
    } finally {
      _$StatsControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void selectMonthlyRange(MonthlyRange value) {
    final _$actionInfo = _$StatsControllerBaseActionController.startAction(name: 'StatsControllerBase.selectMonthlyRange');
    try {
      return super.selectMonthlyRange(value);
    } finally {
      _$StatsControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
streak: ${streak},
dailyError: ${dailyError},
monthlyError: ${monthlyError},
dailyRange: ${dailyRange},
monthlyRange: ${monthlyRange},
dailyPoints: ${dailyPoints},
lastSevenDays: ${lastSevenDays},
bestDay: ${bestDay},
monthlyPoints: ${monthlyPoints},
finishedThisYear: ${finishedThisYear}
    ''';
  }
}
