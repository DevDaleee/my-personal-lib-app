/// Meses abreviados em pt-BR, sem ponto ("mar", não "mar.").
const _shortMonths = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];

const _longMonths = ['janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho', 'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'];

String _twoDigits(int value) => value.toString().padLeft(2, '0');

/// "mar/2024": mês abreviado e ano, no fuso do aparelho.
String monthYear(DateTime date) {
  final local = date.toLocal();
  return '${_shortMonths[local.month - 1]}/${local.year}';
}

/// "jun/26": mês abreviado e ano com dois dígitos (eixo do gráfico mensal).
String monthShortYear(DateTime date) => '${_shortMonths[date.month - 1]}/${_twoDigits(date.year % 100)}';

/// "13/11": dia e mês (eixo do gráfico diário).
String dayMonth(DateTime date) => '${_twoDigits(date.day)}/${_twoDigits(date.month)}';

/// "19 de novembro".
String dayMonthLong(DateTime date) => '${date.day} de ${_longMonths[date.month - 1]}';

/// "03/11/2026": data completa, no fuso do aparelho.
String fullDate(DateTime date) {
  final local = date.toLocal();
  return '${_twoDigits(local.day)}/${_twoDigits(local.month)}/${local.year}';
}
