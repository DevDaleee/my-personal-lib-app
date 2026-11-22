import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:my_personal_lib_app/controllers/stats_controller.dart';
import 'package:my_personal_lib_app/models/daily_stat.dart';
import 'package:my_personal_lib_app/models/monthly_stat.dart';
import 'package:my_personal_lib_app/pages/components/app_navigation_bar.dart';
import 'package:my_personal_lib_app/pages/components/profile_button.dart';
import 'package:my_personal_lib_app/pages/helpers/dates.dart';
import 'package:my_personal_lib_app/pages/styles/app_theme.dart';

/// Estatísticas: sequência, páginas por dia e livros concluídos por mês.
/// Do Figma, ficam de fora o recorde de dias, as páginas do ano e a citação
/// (a API não tem).
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final StatsController controller = GetIt.I.get<StatsController>();

  // Medidas do Figma (px).
  static const double _maxWidth = 600;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(16, 8, 16, 32);
  static const double _sectionGap = 24;

  @override
  void initState() {
    super.initState();
    // Busca sempre ao abrir: as estatísticas mudam de forma assíncrona (NATS).
    controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estatísticas'), actions: const [ProfileButton(), SizedBox(width: 16)]),
      bottomNavigationBar: const AppNavigationBar(current: AppTab.stats),
      body: Observer(
        builder: (context) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              // "Puxar para atualizar".
              child: RefreshIndicator(
                onRefresh: controller.load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: _padding,
                  children: [
                    const _Heading(),
                    const SizedBox(height: 16),
                    if (!controller.hasLoaded)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      _StreakCard(streak: controller.streak, lastSevenDays: controller.lastSevenDays),
                      const SizedBox(height: _sectionGap),
                      _DailyCard(controller: controller),
                      const SizedBox(height: _sectionGap),
                      _MonthlyCard(controller: controller),
                      if (controller.finishedThisYear != null) ...[const SizedBox(height: _sectionGap), _YearSummary(finished: controller.finishedThisYear!)],
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// "Registro de Hábito … ANO 2026".
class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text('Registro de Hábito', style: textTheme.titleLarge?.copyWith(color: colors.primary)),
        ),
        Text('ANO ${DateTime.now().year}', style: textTheme.labelSmall?.copyWith(color: colors.secondary)),
      ],
    );
  }
}

/// Sequência de dias e os 7 tracinhos (dias com e sem leitura).
class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak, required this.lastSevenDays});

  static const double _iconSize = 32;
  static const double _dashHeight = 6;

  final int? streak;
  final List<bool> lastSevenDays;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colors.surfaceContainer, borderRadius: BorderRadius.circular(mediumRadius)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(streak?.toString() ?? '–', style: textTheme.displaySmall?.copyWith(color: colors.primary)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        streak == 1 ? 'dia seguido lendo' : 'dias seguidos lendo',
                        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500, color: colors.secondary),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: _iconSize,
                height: _iconSize,
                decoration: BoxDecoration(color: colors.secondaryContainer, shape: BoxShape.circle),
                child: Icon(Icons.local_fire_department, size: 16, color: colors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Semantics(
            label: 'Leitura nos últimos 7 dias: ${lastSevenDays.where((read) => read).length} de 7',
            child: Row(
              children: [
                for (final (index, read) in lastSevenDays.indexed) ...[
                  if (index > 0) const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: _dashHeight,
                      decoration: BoxDecoration(
                        color: read ? colors.primaryContainer : colors.secondaryContainer,
                        borderRadius: BorderRadius.circular(_dashHeight / 2),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de seção (`surfaceContainerLow`, cantos 8) com título, seletor e conteúdo.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.selector, required this.child});

  final String title;
  final Widget selector;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: textTheme.titleLarge?.copyWith(color: colors.primary)),
            const SizedBox(height: 12),
            selector,
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

/// Seletor de período em "trilho": `7 dias | 15 dias | 30 dias`.
/// `strong` = selecionado em `primary` (mensal); senão, em `surface` (diário).
class _RangeSelector<T> extends StatelessWidget {
  const _RangeSelector({required this.values, required this.selected, required this.labelOf, required this.onSelected, this.strong = false});

  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: colors.secondaryContainer, borderRadius: BorderRadius.circular(smallRadius)),
      child: Row(
        children: [
          for (final value in values)
            Expanded(
              child: Semantics(
                selected: value == selected,
                button: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(smallRadius),
                  onTap: () => onSelected(value),
                  child: Container(
                    height: 28,
                    alignment: Alignment.center,
                    decoration: value == selected
                        ? BoxDecoration(color: strong ? colors.primary : colors.surface, borderRadius: BorderRadius.circular(smallRadius))
                        : null,
                    child: Text(
                      labelOf(value),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelMedium?.copyWith(
                        color: value == selected ? (strong ? colors.onPrimary : colors.primary) : colors.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Páginas por dia: seletor, gráfico de barras e a "Sessão mais produtiva".
class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.controller});

  final StatsController controller;

  @override
  Widget build(BuildContext context) {
    // Observer próprio: o card lê o controller no seu build, fora do Observer da tela.
    return Observer(
      builder: (context) {
        return _SectionCard(
          title: 'Páginas por dia',
          selector: _RangeSelector<DailyRange>(
            values: DailyRange.values,
            selected: controller.dailyRange,
            labelOf: (range) => range.label,
            onSelected: controller.selectDailyRange,
          ),
          child: controller.dailyError != null
              ? _InlineError(message: controller.dailyError!, onRetry: controller.load)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DailyChart(points: controller.dailyPoints),
                    const SizedBox(height: 16),
                    _BestDay(day: controller.bestDay),
                  ],
                ),
        );
      },
    );
  }
}

/// Gráfico de barras (fl_chart), plano e de uma cor só (ver `design.md`).
class _DailyChart extends StatelessWidget {
  const _DailyChart({required this.points});

  static const double _height = 148;
  static const double _maxBarWidth = 14;
  static const double _valueSpace = 16;

  final List<DailyStat> points;

  /// Com muitos dias não cabem todas as datas: mostra uma a cada N (e sempre hoje).
  int get _labelEvery => switch (points.length) {
    <= 7 => 1,
    <= 15 => 3,
    _ => 5,
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final axisStyle = textTheme.bodySmall?.copyWith(fontSize: 10, color: colors.secondary.withValues(alpha: 0.6));
    final maxPages = points.fold<int>(0, (max, day) => math.max(max, day.pagesRead));
    // Sem leitura, um teto qualquer para o gráfico não ficar sem escala.
    final maxY = maxPages == 0 ? 10.0 : maxPages.toDouble();
    // Os valores em cima das barras só cabem nos 7 dias.
    final showValues = points.length <= 7;

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = math.min(_maxBarWidth, constraints.maxWidth / points.length * 0.5);

        return Container(
          height: _height + _valueSpace,
          // Espaço para o valor em cima da barra mais alta não encostar no seletor.
          padding: const EdgeInsets.only(top: _valueSpace),
          child: Semantics(
            label: 'Páginas por dia: ${points.map((day) => '${dayMonth(day.day)}: ${day.pagesRead}').join(', ')}',
            child: ExcludeSemantics(
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  minY: 0,
                  alignment: BarChartAlignment.spaceAround,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 2,
                    getDrawingHorizontalLine: (_) => FlLine(color: colors.secondaryContainer, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: maxY,
                        getTitlesWidget: (value, meta) => SideTitleWidget(
                          meta: meta,
                          child: Text(value.round().toString(), style: axisStyle),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          final isToday = index == points.length - 1;
                          // De trás para a frente, para hoje sempre aparecer.
                          if (!isToday && (points.length - 1 - index) % _labelEvery != 0) return const SizedBox.shrink();
                          return SideTitleWidget(
                            meta: meta,
                            // Não deixa a primeira e a última data passarem da borda.
                            fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                            child: Text(
                              dayMonth(points[index].day),
                              style: textTheme.bodySmall?.copyWith(
                                color: isToday ? colors.primary : colors.secondary,
                                fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Sem toque: os valores aparecem fixos em cima das barras.
                  barTouchData: BarTouchData(
                    enabled: false,
                    handleBuiltInTouches: false,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.transparent,
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 2,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                        rod.toY.round().toString(),
                        textTheme.bodySmall!.copyWith(fontSize: 10, color: colors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  barGroups: [
                    for (final (index, day) in points.indexed)
                      BarChartGroupData(
                        x: index,
                        showingTooltipIndicators: showValues && day.pagesRead > 0 ? const [0] : const [],
                        barRods: [
                          BarChartRodData(
                            toY: day.pagesRead.toDouble(),
                            width: barWidth,
                            color: colors.primaryContainer,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// "Sessão mais produtiva … 19 de novembro (140 págs)".
class _BestDay extends StatelessWidget {
  const _BestDay({required this.day});

  final DailyStat? day;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final best = day;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(smallRadius)),
      child: best == null
          ? Text('Nenhuma leitura registrada no período.', style: textTheme.bodyMedium?.copyWith(color: colors.secondary))
          : Row(
              children: [
                Expanded(
                  child: Text('Sessão mais produtiva', style: textTheme.bodyMedium?.copyWith(color: colors.secondary)),
                ),
                Text(
                  '${dayMonthLong(best.day)} (${best.pagesRead} ${best.pagesRead == 1 ? 'pág' : 'págs'})',
                  style: textTheme.titleSmall?.copyWith(color: colors.primary),
                ),
              ],
            ),
    );
  }
}

/// Livros concluídos por mês: seletor e uma barra horizontal por mês.
class _MonthlyCard extends StatelessWidget {
  const _MonthlyCard({required this.controller});

  final StatsController controller;

  @override
  Widget build(BuildContext context) {
    // Observer próprio: o card lê o controller no seu build, fora do Observer da tela.
    return Observer(
      builder: (context) {
        final points = controller.monthlyPoints;
        final max = points.fold<int>(0, (max, month) => math.max(max, month.finishedCount));

        return _SectionCard(
          title: 'Livros concluídos por mês',
          selector: _RangeSelector<MonthlyRange>(
            values: MonthlyRange.values,
            selected: controller.monthlyRange,
            labelOf: (range) => range.label,
            onSelected: controller.selectMonthlyRange,
            strong: true,
          ),
          child: controller.monthlyError != null
              ? _InlineError(message: controller.monthlyError!, onRetry: controller.load)
              : Column(
                  children: [
                    for (final (index, month) in points.indexed) ...[if (index > 0) const SizedBox(height: 10), _MonthRow(month: month, max: max)],
                  ],
                ),
        );
      },
    );
  }
}

class _MonthRow extends StatelessWidget {
  const _MonthRow({required this.month, required this.max});

  static const double _labelWidth = 48;
  static const double _countWidth = 56;
  static const double _barHeight = 16;

  final MonthlyStat month;

  /// Maior quantidade do período (a barra mais cheia).
  final int max;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final count = month.finishedCount;
    final fraction = max == 0 ? 0.0 : count / max;

    // Meses sem livro ficam apagados (60%).
    return Opacity(
      opacity: count == 0 ? 0.6 : 1,
      child: Row(
        children: [
          SizedBox(
            width: _labelWidth,
            child: Text(monthShortYear(month.month), style: textTheme.labelMedium?.copyWith(color: colors.secondary)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(smallRadius),
              child: Container(
                height: _barHeight,
                color: colors.surface,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: fraction,
                  heightFactor: 1,
                  child: ColoredBox(color: colors.primaryContainer),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: _countWidth,
            child: Text(
              switch (count) {
                0 => '0',
                1 => '1 livro',
                _ => '$count livros',
              },
              textAlign: TextAlign.right,
              style: textTheme.labelSmall?.copyWith(letterSpacing: 0.44, color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Total de 4 livros lidos em 2026".
class _YearSummary extends StatelessWidget {
  const _YearSummary({required this.finished});

  final int finished;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final year = DateTime.now().year;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: colors.secondaryContainer.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(smallRadius)),
      child: Text(
        finished == 1 ? 'Total de 1 livro lido em $year' : 'Total de $finished livros lidos em $year',
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium?.copyWith(color: colors.onSecondaryContainer),
      ),
    );
  }
}

/// Erro de um gráfico, dentro do próprio card.
class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            message,
            style: textTheme.bodyMedium?.copyWith(color: colors.secondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onRetry, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }
}
