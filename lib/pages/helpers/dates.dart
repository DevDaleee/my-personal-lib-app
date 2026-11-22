/// Meses abreviados em pt-BR, sem ponto ("mar", não "mar.").
const _months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];

/// "mar/2024": mês abreviado e ano, no fuso do aparelho.
String monthYear(DateTime date) {
  final local = date.toLocal();
  return '${_months[local.month - 1]}/${local.year}';
}
